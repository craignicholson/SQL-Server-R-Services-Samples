USE [forecastdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_featureEngineering]    Script Date: 10/1/2018 1:33:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_featureEngineering] (
	@region NVARCHAR(64),
	@startTime VARCHAR(50), 
	@endTime VARCHAR(50),
	@scoreStartTime VARCHAR(50),
	@scoreEndTime VARCHAR(50),
	@interval_length_minutes INT)
AS
BEGIN
	-- TODO -----------------------------
	-- We need to pass in the interval length in minutes
	-- so we can calculate the correct number of intervals
	-- such as 96, 24, etc.. (15min to hourly)
	-- Valid Values {60, 15}
	-- using @interval_lenght_minutes

	DECLARE @InputAllFeaturesTable NVARCHAR(50);
	DECLARE @numTS bigint;
	SET @numTS= cast(datediff(minute,@startTime,@scoreEndTime) as bigint);

	-- table var to hold our data for features for this specific region
	DECLARE @InputData TABLE (
		utcTimestamp 	DATETIME,
		Load 			float,
		temperature 	float
	);

	DECLARE @InputDataNAfilled TABLE (
		utcTimestamp 	DATETIME,
		Load 			float,
		temperature 	float
	);

	-- remove current features for this region
	delete InputAllFeatures where region=@region;

	BEGIN TRY
		with TimeSequence as
		(
			Select cast(@scoreStartTime as datetime) as utcTimestamp
				union all
			Select dateadd(minute, @interval_length_minutes, utcTimestamp)
				from TimeSequence
				where utcTimestamp < cast(@scoreEndTime as datetime)
		),
		e1(n) AS
		(
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
			SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
		), 
		e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b), 
		e3(n) AS (SELECT 1 FROM e2 CROSS JOIN e2 AS b), 
		e4(n) AS (SELECT 1 FROM e3 CROSS JOIN (SELECT TOP 5 n FROM e1) AS b)
		insert into @InputData 
		select e.utcTimestamp as utcTimestamp, Load, temperature 
		from 
		(
			SELECT CONVERT(varchar(50),DATEADD(minute, n, CONVERT(datetime,@startTime,120)),120) utcTimestamp
				FROM
				(
				  SELECT ((ROW_NUMBER() OVER (ORDER BY n))-1)*@interval_length_minutes n FROM e4
				 ) as d
			   where n<=@numTS
		) as e
		left join
		(
			select a.utcTimestamp as utcTimestamp, b.region, a.Load, b.temperature from (
				select utcTimestamp,Load from dbo.DemandReal where region=@region and utcTimestamp>=@startTime and utcTimestamp<=@endTime
					union all 
					select convert(NVARCHAR(50),utcTimestamp,120) as utcTimestamp, NULL as Load from TimeSequence
					) as a
			right join 
				(select utcTimestamp, region, temperature from dbo.TemperatureReal where region=@region and utcTimestamp>=@startTime and utcTimestamp<=@scoreEndTime
					) as b 
			on dateadd(hour, datediff(hour, 0, CAST(a.utcTimestamp as datetime)), 0)
				= dateadd(hour, datediff(hour, 0, CAST(b.utcTimestamp as datetime)), 0) 
		) as c
		on e.utcTimestamp=c.utcTimestamp 
		order by e.utcTimestamp;

		-- get the averages for the load and temperature
		DECLARE @avgLoad float;
		DECLARE @avgTemp float;
		SELECT @avgLoad=avg(Load), @avgTemp = avg(temperature) from @InputData;

		-- TODO
		-- https://docs.microsoft.com/en-us/sql/t-sql/functions/lag-transact-sql?view=sql-server-2017
		-- LAG function review
		-- LAG (scalar_expression [,offset] [,default]) 
		-- offeset should be the expected intervals in the timeframe
		-- For us this should be 96 for 15min intervals, 24 for hourly intervals
		DECLARE @interval_offset INT = 24;
		INSERT INTO @InputDataNAfilled
		SELECT utcTimestamp,
			(CASE WHEN Load is NULL and loadLag96 is NULL THEN @avgLoad
				  WHEN Load is NULL and loadLag96 is not NULL THEN loadLag96
				  ELSE Load END) as Load,
			(CASE WHEN temperature is NULL and tempLag96 is NULL THEN @avgTemp
				  WHEN temperature is NULL and tempLag96 is not NULL THEN tempLag96
				  ELSE temperature END) as temperature
		from 
		(SELECT utcTimestamp,Load,temperature,
			LAG(Load,@interval_offset,NULL) OVER (ORDER BY utcTimestamp) as loadLag96,
			LAG(temperature,@interval_offset,NULL) OVER (ORDER BY utcTimestamp) as tempLag96 
		from @InputData) as a
		order by utcTimestamp

		-- TODO: NOT SURE IF THE LAG for each value is needed.  We can remove and re-test the accuracy of the forecast
		INSERT INTO InputAllFeatures
		SELECT 
			utcTimestamp,@region, Load,temperature,
			LAG(Load,24,NULL) OVER (ORDER BY utcTimestamp) as lag24,
			LAG(Load,25,NULL) OVER (ORDER BY utcTimestamp) as lag25,
			LAG(Load,26,NULL) OVER (ORDER BY utcTimestamp) as lag26,
			LAG(Load,27,NULL) OVER (ORDER BY utcTimestamp) as lag27,
			LAG(Load,28,NULL) OVER (ORDER BY utcTimestamp) as lag28,
			LAG(Load,31,NULL) OVER (ORDER BY utcTimestamp) as lag31,
			LAG(Load,36,NULL) OVER (ORDER BY utcTimestamp) as lag36,
			LAG(Load,40,NULL) OVER (ORDER BY utcTimestamp) as lag40,
			LAG(Load,48,NULL) OVER (ORDER BY utcTimestamp) as lag48,
			LAG(Load,72,NULL) OVER (ORDER BY utcTimestamp) as lag72,
			LAG(Load,96,NULL) OVER (ORDER BY utcTimestamp) as lag96,
			hourofday, dayinweek, monofyear, weekend,
			(case when hourofday<=18 and hourofday>=8 then 1 else 0 end) as businesstime,
			(case when hourofday>=5 and hourofday<=8 then 1 else 0 end) as ismorning,
			t/365.25 as LinearTrend,
			cos(t*2*pi()/365.25)*weekend as WKFreqCos1,
			sin(t*2*pi()/365.25)*weekend as WKFreqSin1,
			cos(t*2*pi()/365.25)*(1-weekend) as WDFreqCos1,
			sin(t*2*pi()/365.25)*(1-weekend) as WDFreqSin1,
			cos(t*2*pi()*2/365.25)*weekend as WKFreqCos2,
			sin(t*2*pi()*2/365.25)*weekend as WKFreqSin2,
			cos(t*2*pi()*2/365.25)*(1-weekend) as WDFreqCos2,
			sin(t*2*pi()*2/365.25)*(1-weekend) as WDFreqSin2
		 from (
			select 	utcTimestamp,Load,temperature,
					datepart(hour, utcTimestamp) as hourofday, 
					datepart(weekday, utcTimestamp) as dayinweek, 
					datepart(month, utcTimestamp) as monofyear,
					(case when datepart(weekday, utcTimestamp) in (1,7) then 1 else 0 end) as weekend,
					floor((convert(float, ROW_NUMBER() OVER (ORDER BY utcTimestamp))-1)/24/4) as t			
			from (
				select convert(datetime,utcTimestamp,120) as utcTimestamp,Load,temperature 
				from @InputDataNAfilled
				) as a
		) as b;
		
		-- Write out data to see what we have, or just go check the table for the data...

		merge runlogs a 
		using (select 1 as step, @scoreStartTime as utcTimeStamp, @region as region, getutcdate() as runtimestamp, 0 as success_flag, '' as errMsg) b
		on a.step = b.step and a.utcTimeStamp = b.utcTimeStamp and a.region=b.region and a.runTimestamp = b.runTimestamp
		when matched then
			update set ErrorMessage = b.errMsg, success_flag = b.success_flag
		WHEN NOT MATCHED THEN	
			insert (step,utcTimeStamp,region, runTimestamp,success_flag,errorMessage)
			values (b.step,b.utcTimeStamp,b.region, b.runTimestamp,b.success_flag,b.errMsg);	
	END TRY
	BEGIN CATCH
		merge runlogs a 
		using (select 1 as step, @scoreStartTime as utcTimeStamp, @region as region, getutcdate() as runtimestamp, -1 as success_flag, ERROR_MESSAGE() as errMsg) b
		on a.step = b.step and a.utcTimeStamp = b.utcTimeStamp and a.region=b.region and a.runTimestamp = b.runTimestamp
		when matched then
			update set ErrorMessage = b.errMsg, success_flag = b.success_flag
		WHEN NOT MATCHED THEN	
			insert (step,utcTimeStamp,region, runTimestamp,success_flag,errorMessage)
			values (b.step,b.utcTimeStamp,b.region, b.runTimestamp,b.success_flag,b.errMsg);
	END CATCH;	
END;
