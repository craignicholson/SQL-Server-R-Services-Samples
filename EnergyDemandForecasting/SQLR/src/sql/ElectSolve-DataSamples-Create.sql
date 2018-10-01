use mdm

SELECT 
'INSERT INTO DemandReal (utcTimestamp, region, Load) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), d.ReadDate)) + '", ' +h.MeterIdentifier + ', ' + convert(varchar, d.ReadValue) + ')'
FROM mdm.dbo.MeterReadIntervalHeader h
inner join mdm.dbo.MeterReadIntervalDetail d 
on h.MeterReadIntervalHeaderId = d.MeterReadIntervalHeaderId
WHERE h.UOM = 'kWh' and h.ReadLogDate > '2018-06-01' 
AND h.MeterIdentifier IN
('57741868'
,'56689480'
,'56679397'
,'61263517'
,'58512668'
,'61263654')


-- temperature data
SELECT 
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDate)) + '", ' 
+ '57741868' + ', ' + convert(varchar, t.TemperatureF) + ')'
FROM mdm.dbo.Temperature t
union
SELECT 
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDate)) + '", ' 
+ '56689480' + ', ' + convert(varchar, t.TemperatureF) + ')'
FROM mdm.dbo.Temperature t
union
SELECT 
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDate)) + '", ' 
+ '56679397' + ', ' + convert(varchar, t.TemperatureF) + ')'
FROM mdm.dbo.Temperature t
union
SELECT 
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDate)) + '", ' 
+ '61263517' + ', ' + convert(varchar, t.TemperatureF) + ')'
FROM mdm.dbo.Temperature t
union  
SELECT 
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature) VALUES ("' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDate)) + '", ' 
+ '58512668' + ', ' + convert(varchar, t.TemperatureF) + ')'
FROM mdm.dbo.Temperature t
union

SELECT DISTINCT
'INSERT INTO TemperatureReal (utcTimestamp, region, Temperature, Flag) VALUES (''' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDateTime)) + ''', ' 
+ '61263654' + ', ' + convert(varchar, t.TemperatureF) + ', 1)'
FROM mdm.dbo.Temperature t
WHERE t.TempDate > '2017-06-01'

SELECT 
CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), t.TempDateTime)) 
--, t.TempDateTime
,'61263654'
,t.TemperatureF
,1
FROM mdm.dbo.Temperature t
WHERE t.TempDate > '2017-06-01'