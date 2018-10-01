USE [forecastdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_energyDemandForecastMain]    Script Date: 10/1/2018 1:33:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_energyDemandForecastMain]
	@region nvarchar(10),
	@server varchar(255),
	@database varchar(255),
	@user varchar(255),
	@pwd varchar(255),
	@WindowsORSQLAuthenticationFlag varchar(5)
AS
BEGIN
	--declare parameters
	DECLARE @curTime datetime;	
	DECLARE @startTime varchar(50);
	DECLARE @endTime varchar(50);
	DECLARE @scoreStartTime varchar(50);
	DECLARE @scoreEndTime varchar(50);
	DECLARE @sqlConnString varchar(255);

	--set values
	SET @curTime = dateadd(minute, datediff(minute,0,GETUTCDATE()) / 15 * 15, 0)	

	--set values
	-- for us @curTime needs to be timestamp of the last interval collected
	SET @curTime = (SELECT MAX(utcTimestamp) FROM DemandReal WHERE region = @region)
	SET @curTime = '2018-09-12 05:00:00.000'

	SET @startTime=CONVERT(varchar(50),DATEADD(year,-1,@curTime),20);
	SET @endTime=CONVERT(varchar(50),@curTime,20);
	SET @scoreStartTime = CONVERT(varchar(50),DATEADD(minute,15,@curTime),20);
	-- set the forecast for 24 hours
	SET @scoreEndTime=CONVERT(varchar(50),DATEADD(hour,24,@curTime),20);

	--feaure engineering
	EXEC usp_featureEngineering @region, @startTime, @endTime, @scoreStartTime,@scoreEndTime;
	
	IF @WindowsORSQLAuthenticationFlag = 'YES'
	BEGIN
		SET @sqlConnString =CONCAT('Driver=SQL Server;Server=',@server,';Database=',@database,';trusted_connection=true')
	END
	ELSE
		SET @sqlConnString =CONCAT('Driver=SQL Server;Server=',@server,';Database=',@database,';Uid=',@user,';Pwd=',@pwd)
	
	--train model and persist
	EXEC usp_persistModel @region, @scoreStartTime, @sqlConnString; 

	--forecast
	Declare @tmpTable TABLE (
	load float,
	utcTimestamp varchar(50))

	DECLARE @predictQuery NVARCHAR(MAX) = concat('select * from inputAllfeatures where region=''',  @region, ''' and utcTimestamp >= ''',  @scoreStartTime , '''')

	INSERT INTO @tmpTable EXEC usp_predictDemand @querystr = @predictQuery, @region=@region, @startTime=@scoreStartTime;
					
	MERGE DemandForecast as target 
		USING @tmpTable as source
		on (target.utcTimestamp=source.utcTimestamp and target.region=@region)
		WHEN MATCHED THEN
			UPDATE SET Load = source.Load
		WHEN NOT MATCHED THEN
			INSERT (utcTimestamp, region, load)
			VALUES (source.utcTimestamp, @region, source.load);
END;
