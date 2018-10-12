use mdm

-- Collect some data to insert into DemandReal Table
SELECT 
'INSERT INTO DemandReal (utcTimestamp, region, Load) VALUES 
(''' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), d.ReadDate)) + ''', ' 
+ '''' + h.MeterIdentifier+ '-ACCOUNT-ENTITY-' + h.UOM + ''', ' 
+ convert(varchar, d.ReadValue) + ')'
FROM mdm.dbo.MeterReadIntervalHeader h
inner join mdm.dbo.MeterReadIntervalDetail d 
on h.MeterReadIntervalHeaderId = d.MeterReadIntervalHeaderId
--TODO, just make this one year data range from CurrentDay - 366
WHERE h.UOM = 'kWh' and h.ReadLogDate > GETDATE()-366
AND h.MeterIdentifier IN
('57741868'
,'56689480'
,'56679397'
,'61263517'
,'58512668'
,'61263654',
'SystemLoad_Electric_VMD-ACCOUNT-ENTITY-kWh')

SELECT 
'INSERT INTO DemandReal (utcTimestamp, region, Load) VALUES 
(''' + CONVERT(varchar, DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), d.ReadDate)) + ''', ' 
+ '''' + h.MeterIdentifier+ '-ACCOUNT-ENTITY-' + h.UOM + ''', ' 
+ convert(varchar, d.ReadValue) + ')'
FROM mdm.dbo.MeterReadIntervalHeader h
inner join mdm.dbo.MeterReadIntervalDetail d 
on h.MeterReadIntervalHeaderId = d.MeterReadIntervalHeaderId
--TODO, just make this one year data range from CurrentDay - 366
WHERE h.UOM = 'kWh' and h.ReadLogDate > GETDATE()-366
AND h.MeterIdentifier IN
('SystemLoad_Electric_VMD')


