
SElECT * FROM 
(

--estimated or forecasted values
SELECT DISTINCT
	   [utcTimestamp]
      ,[region]
      ,[Load]
	  , 'Forecast' Quality
FROM [forecastdb].[dbo].[DemandForecast]
where region ='61263654'  and 0 = DATEPART(Minute, utcTimeStamp)


UNION ALL


--actual values
SELECT TOP 26
	   [utcTimestamp]
      ,[region]
      ,[Load]
	  , 'Actual' Quality
FROM [forecastdb].[dbo].[DemandReal]
where region ='61263654'
ORDER BY 1 DESC


) tbl
order by utctimestamp desc