
-- TODO
-- Pull data from MDM and insert int DemandRead
-- Pulling and then inserting into a physical table is slow
INSERT INTO DemandReal (utcTimestamp, region, Load) 
SELECT 
CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), d.ReadDate)) ,
'''' + h.MeterIdentifier+ '-ACCOUNT-ENTITY-' + h.UOM + '''',  
d.ReadValue 
FROM mdm.dbo.MeterReadIntervalHeader h
inner join mdm.dbo.MeterReadIntervalDetail d 
on h.MeterReadIntervalHeaderId = d.MeterReadIntervalHeaderId
--TODO, just make this one year data range from CurrentDay - 366
WHERE h.UOM = 'kWh' and h.ReadLogDate > GETDATE()-366
AND h.MeterIdentifier IN
('SystemLoad_Electric_VMD')

DECLARE 	
    @region nvarchar(64) = 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh',
	@server varchar(255) = 'etss-dbdev16\ucentra',
	@database varchar(255) = 'forecastdb',
	@user varchar(255) = 'electsolve',
	@pwd varchar(255) = 'electsolve',
	@WindowsORSQLAuthenticationFlag varchar(5) = 'NO',
	@interval_lenght_min int = 60

DELETE FROM DemandForecast WHERE region = @region

exec [dbo].[usp_energyDemandForecastMain] 
	@region, @server, @database, @user, @pwd, @WindowsORSQLAuthenticationFlag, @interval_lenght_min


/*************************************************************************/


  truncate table runlogs
  truncate table model
  truncate table InputAllFeatures
  truncate table DemandForecast

  --SELECT DISTINCT region from TemperatureReal 

  --UPDATE TemperatureReal
  --SET --utcTimestamp = dateadd(hour, datediff(hour, 0, utcTimestamp), 0)
  --region = '56689480-ACCOUNT-ENTITY-KWh'

  DECLARE 	
    @region nvarchar(64) = '57741868-ACCOUNT-ENTITY-kWh',
	@server varchar(255) = 'etss-dbdev16\ucentra',
	@database varchar(255) = 'forecastdb',
	@user varchar(255) = 'electsolve',
	@pwd varchar(255) = 'electsolve',
	@WindowsORSQLAuthenticationFlag varchar(5) = 'NO',
	@interval_lenght_min int = 60

  DELETE FROM DemandForecast WHERE region = @region

exec [dbo].[usp_energyDemandForecastMain] 
	@region, @server, @database, @user, @pwd, @WindowsORSQLAuthenticationFlag, @interval_lenght_min





/****** Script for SelectTopNRows command from SSMS  ******/
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





DECLARE 	
    @region nvarchar(64) = 'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh'

DECLARE 	
    @region nvarchar(64) = '56689480-ACCOUNT-ENTITY-KWh'

SElECT * FROM 
(
--estimated or forecasted values
SELECT DISTINCT
	   [utcTimestamp]
      ,[region]
	  ,[load] Forecast
      ,NULL Actual
FROM [forecastdb].[dbo].[DemandForecast]
where region =@region  

UNION ALL

--actual values
SELECT TOP 96
	   [utcTimestamp]
      ,[region]
	  ,NULL Forecast
      ,[Load] Actual
FROM [forecastdb].[dbo].[DemandReal]
where region = @region
ORDER BY 1 DESC

) tbl
order by utctimestamp 


SELECT DISTINCT
	   [utcTimestamp]
      ,[region]
	  ,[load] Actual
FROM [forecastdb].[dbo].[DemandReal]
where region =@region+'-ACTUAL'
ORDER BY utcTimestamp







DECLARE @region nvarchar(64) = '61263517-ACCOUNT-ENTITY-KWh'
SET @region = '57741868-ACCOUNT-ENTITY-kWh'

SElECT * FROM 
(
--estimated or forecasted values
SELECT DISTINCT
	   [utcTimestamp]
      ,[region]
	  ,[load] Forecast
      ,NULL Actual
FROM [forecastdb].[dbo].[DemandForecast]
where region =@region  

UNION ALL

--actual values
SELECT TOP 24
	   [utcTimestamp]
      ,[region]
	  ,NULL Forecast
      ,[Load] Actual
FROM [forecastdb].[dbo].[DemandReal]
where region = @region
ORDER BY 1 DESC

) tbl
order by utctimestamp 


SELECT DISTINCT
	   [utcTimestamp]
      ,[region]
	  ,[load] Actual
FROM [forecastdb].[dbo].[DemandReal]
where region =@region+'-ACTUAL'
ORDER BY utcTimestamp