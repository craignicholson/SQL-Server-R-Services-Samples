USE [forecastdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_energyDemandForecastMain]    Script Date: 10/1/2018 1:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_energyDemandForecastMain]
	@region nvarchar(64),
	@server varchar(255),
	@database varchar(255),
	@user varchar(255),
	@pwd varchar(255),
	@WindowsORSQLAuthenticationFlag varchar(5),
	@interval_length_minutes int
AS
BEGIN
	--declare parameters
	DECLARE @curTime datetime;	
	DECLARE @startTime varchar(50);
	DECLARE @endTime varchar(50);
	DECLARE @scoreStartTime varchar(50);
	DECLARE @scoreEndTime varchar(50);
	DECLARE @sqlConnString varchar(255);

	--set values, @curTime is set to the value we need to start forecasting from
	SET @curTime = dateadd(minute, datediff(minute,0,GETUTCDATE()) / 15 * 15, 0)	

	-- TODO
	-- set values
	-- for us @curTime needs to be timestamp of the last interval (actual/real) collected
	-- for this meter - account entity uom relationship
	SET @curTime = (SELECT MAX(utcTimestamp) FROM DemandReal WHERE region = @region)

	SET @startTime=CONVERT(varchar(50),DATEADD(year,-1,@curTime),20);
	SET @endTime=CONVERT(varchar(50),@curTime,20);

	-- TODO: REVIEW
	-- does this need to be rolled forward 15 minutes????????????
	-- do this for 15 or 60 based on parameter @interval_lenght_min
	SET @scoreStartTime = CONVERT(varchar(50),DATEADD(minute,@interval_length_minutes,@curTime),20);

	-- set the forecast for 24 hours
	-- End time is how far we want to forecast the data into the future
	-- THis is ok to be hard coded right now... anything longer than 24 hours is ok
	-- Note how would this be coded for Register Reads which are daily forecasts
	-- Or if we always have intervals hourly or smaller we can calculate the daily 
	-- register read from the intervals and yesterday's register read value.
	SET @scoreEndTime=CONVERT(varchar(50),DATEADD(hour,24,@curTime),20);

	-- TODO: REVIEW
	-- feature engineering
	-- for reference features are the variables which are used to forecast the load value
	-- Day of week, time of day, temperature, weekend, weekday, etc..
	EXEC usp_featureEngineering @region, @startTime, @endTime, @scoreStartTime,@scoreEndTime,@interval_length_minutes;
	
	IF @WindowsORSQLAuthenticationFlag = 'YES'
	BEGIN
		SET @sqlConnString =CONCAT('Driver=SQL Server;Server=',@server,';Database=',@database,';trusted_connection=true')
	END
	ELSE
		SET @sqlConnString =CONCAT('Driver=SQL Server;Server=',@server,';Database=',@database,';Uid=',@user,';Pwd=',@pwd)
	
	-- train is called from inside of usp_persistModel
	-- train creates the model and persits writes the model to the database
	-- Note, we don't have to train and persist the model on each new single interval 
	-- if we need to make predictions.  We can just update the model for each meter over a
	-- frame to help with performance, if this is the main time sink (which I believe it will be)
	-- we can also skip this step and move directly to usp_predictDemand
	EXEC usp_persistModel @region, @scoreStartTime, @sqlConnString; 

	Declare @tmpTable TABLE 
	(
		load float,
		utcTimestamp varchar(50)
	)

	DECLARE @predictQuery NVARCHAR(MAX) = concat('select * from inputAllfeatures where region=''',  @region, ''' and utcTimestamp >= ''',  @scoreStartTime , '''')

	--forecast the data...
	INSERT INTO @tmpTable EXEC usp_predictDemand @querystr = @predictQuery, @region=@region, @startTime=@scoreStartTime;
					
	-- TODO: REVIEW					
	-- write the results of the forecast to the table 
	-- additionally we can just pump the data back to MDM.dbo.MeterReadIntervalHeader and MeterReadIntervalDetail
	-- as well tagging the UOM we have with -fcast for forecast.		
	MERGE DemandForecast as target 
		USING @tmpTable as source
		on (target.utcTimestamp=source.utcTimestamp and target.region=@region)
		WHEN MATCHED THEN
			UPDATE SET Load = source.Load
		WHEN NOT MATCHED THEN
			INSERT (utcTimestamp, region, load)
			VALUES (source.utcTimestamp, @region, source.load);
END;
