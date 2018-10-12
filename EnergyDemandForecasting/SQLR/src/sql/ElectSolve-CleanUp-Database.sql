  -- reset 
  truncate table runlogs
  truncate table model
  truncate table InputAllFeatures
  truncate table DemandForecast
  truncate table DemandReal
  TRUNCATE table TemperatureReal


SELECT DISTINCT region 
FROM [dbo].[TemperatureReal]

SELECT DISTINCT region 
FROM [dbo].DemandReal

-- Fake the temperature for the other meters

--UPDATE TemperatureReal
--SET region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, '56679397-ACCOUNT-ENTITY-kWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, '61263654-ACCOUNT-ENTITY-kWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, '61263517-ACCOUNT-ENTITY-kWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, '58512668-ACCOUNT-ENTITY-KWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'

INSERT INTO TemperatureReal
SELECT utcTimestamp, '57741868-ACCOUNT-ENTITY-kWh', Temperature, Flag FROM TemperatureReal
WHERE region = '56689480-ACCOUNT-ENTITY-KWh'


SELECT DISTINCT region 
FROM [dbo].[TemperatureReal]

SELECT DISTINCT region 
FROM [dbo].DemandReal

INSERT INTO RegionLookup SELECT '56679397-ACCOUNT-ENTITY-kWh', '56679397-ACCOUNT-ENTITY-kWh', null, null
INSERT INTO RegionLookup SELECT '61263654-ACCOUNT-ENTITY-kWh', '61263654-ACCOUNT-ENTITY-kWh', null, null
INSERT INTO RegionLookup SELECT '61263517-ACCOUNT-ENTITY-kWh', '61263517-ACCOUNT-ENTITY-kWh', null, null
INSERT INTO RegionLookup SELECT 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh', 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh', null, null
INSERT INTO RegionLookup SELECT '58512668-ACCOUNT-ENTITY-KWh', '58512668-ACCOUNT-ENTITY-KWh', null, null
INSERT INTO RegionLookup SELECT '56689480-ACCOUNT-ENTITY-KWh', '56689480-ACCOUNT-ENTITY-KWh', null, null
INSERT INTO RegionLookup SELECT '57741868-ACCOUNT-ENTITY-kWh', '57741868-ACCOUNT-ENTITY-kWh', null, null


--Take the last 24 or 96 records for a meter in this dataset and flip the values to region -Actual
--So we can compare the results.
56689480-ACCOUNT-ENTITY-KWh 
56679397-ACCOUNT-ENTITY-kWh 
61263654-ACCOUNT-ENTITY-kWh
61263517-ACCOUNT-ENTITY-kWh
SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh
58512668-ACCOUNT-ENTITY-KWh
57741868-ACCOUNT-ENTITY-kWh

--56689480-ACCOUNT-ENTITY-KWh (15 minute data)
SELECT TOP (1000) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '56689480-ACCOUNT-ENTITY-KWh' AND utcTimestamp >= '2018-10-10 05:15:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '56689480-ACCOUNT-ENTITY-KWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '56689480-ACCOUNT-ENTITY-KWh' AND utcTimestamp >= '2018-10-10 05:15:00.000'

--56679397-ACCOUNT-ENTITY-kWh (60 minute data)
SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '56679397-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '56679397-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '56679397-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'

  --61263654-ACCOUNT-ENTITY-kWh (60 minute data)
SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '61263654-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '61263654-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '61263654-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'

  --61263517-ACCOUNT-ENTITY-kWh (60 min)
SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '61263517-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '61263517-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '61263517-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'

--SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh
SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-09-16 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-09-16 05:00:00.000'


  ---58512668 15min 
  SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '58512668-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '58512668-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '58512668-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'


--57741868 60 minute
  SELECT TOP (100) [utcTimestamp]
      ,[region]
      ,[Load]
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '57741868-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
  ORDER BY utcTimestamp desc


  UPDATE [forecastdb].[dbo].[DemandReal]
  SET region = '57741868-ACCOUNT-ENTITY-kWh-ACTUAL'
  FROM [forecastdb].[dbo].[DemandReal]
  WHERE region = '57741868-ACCOUNT-ENTITY-kWh' AND utcTimestamp > '2018-10-10 05:00:00.000'
