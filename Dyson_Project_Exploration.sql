--Dyson Data exploration

Select * from [Instrument Data]
-- The table above has identified data I would like to exclude from my analysis as the reliability of the data is in question
-- Only Normal data will need to be included

Select * from Measurement_item_info
-- will need to be joined onto the data table Measurement_info

Select * from Measurement_station_info$
-- Will need to be joined onto the measurement Info table

Select top 100 * from Measurement_info
-- The main data table that will provide me with analysis

-- First I want to work out the overall average of PM2.5 and No2 with the pre covid data
Select b.[Item name],
AVG(a.[Average value]) 
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Where [Instrument status] = '0'
and a.[Item code] in ('3','8','9')
Group by b.[Item name]
order by 1
--We can see that the Precovid data between 2017 and 2019 averages to 24.08

Select b.[Item name],
YEAR(a.[Measurement date]) [Year],
AVG(a.[Average value]) as Average
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Where [Instrument status] = '0'
and a.[Item code] in ('3','8','9')
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by YEAR(a.[Measurement date]), b.[Item name]
order by 1
-- We can see the Average PM2.5, NO2 and PM10 each year between 2017 and 2019

Select DATEPART(hour,a.[Measurement date]) [Hour],
AVG(a.[Average value]) as [PM2.5]
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Left Join Measurement_station_info$ c on c.[Station code] = a.[Station code]
Where [Instrument status] = '0'
and a.[Item code] = '9'
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by DATEPART(hour,a.[Measurement date])
order by 2 desc
-- We can see the Average PM2.5 each hour of the day I want to find the highest PM2.5 hours of the day 
-- I feel the best way to show this data will be in a linegraph format

Select a.[Station code],
c.[Station name(district)],
c.Address,
DATEPART(hour,a.[Measurement date]) [Hour],
AVG(a.[Average value]) as [PM2.5]
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Left Join Measurement_station_info$ c on c.[Station code] = a.[Station code]
Where [Instrument status] = '0'
and a.[Item code] = '9'
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by DATEPART(hour,a.[Measurement date]),a.[Station code],c.[Station name(district)],c.Address
order by 2 desc
-- We can see the Average PM2.5 each hour of the day for each station. 

Select b.[Item name],(AVG(a.[Average value])*1000) as NO2_ppb from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Where [Instrument status] = '0'
and a.[Item code] = '3'
Group by b.[Item name]
order by 1
-- I times by 1000 to convert ppm to ppb. We can see the Average NO2 ppb over 2017 and 2019 is 28.64

Select YEAR(a.[Measurement date]),
(AVG(a.[Average value])*1000) as NO2_ppb
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Where [Instrument status] = '0'
and a.[Item code] = '3'
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by YEAR(a.[Measurement date])
order by 1
-- I times by 1000 to convert ppm to ppb. We can see the Average NO2 ppb each year between 2017 and 2019

Select a.[Station code],
c.[Station name(district)],
c.Address,b.[Item name],
AVG(a.[Average value]) [Average value PM2.5],
c.Latitude,
c.Longitude
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Left Join Measurement_station_info$ c on c.[Station code] = a.[Station code]
Where [Instrument status] = '0'
and a.[Item code] = '9'
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by b.[Item name], a.[Station code] ,c.[Station name(district)], c.Latitude , c.Longitude, c.Address
order by 4 asc
--We can see that which stations had the highest concentration of PM2.5

Select a.[Station code],
c.[Station name(district)],
c.Address,b.[Item name],
(AVG(a.[Average value])*1000) [Average value NO2],
c.Latitude,
c.Longitude
from Measurement_info a
Left Join Measurement_item_info b on b.[Item code] = a.[Item code]
Left Join Measurement_station_info$ c on c.[Station code] = a.[Station code]
Where [Instrument status] = '0'
and a.[Item code] = '3'
and a.[Measurement date] Between '01 Jan 2017' and '31 Dec 2019'
Group by b.[Item name], a.[Station code] ,c.[Station name(district)], c.Latitude , c.Longitude, c.Address
order by 4 asc
--We can see that which stations had the highest concentration of NO2
