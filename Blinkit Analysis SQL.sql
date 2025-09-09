SELECT * FROM blinkit_data

SELECT COUNT(*) FROM blinkit_data

/* Data Cleaning
UPDATE blinkit_data
SET Item_Fat_Content = 
CASE 
WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
WHEN Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END

SELECT DISTINCT (Item_Fat_Content) FROM blinkit_data */

--KPI 1.Total Sales
SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)) AS Total_Sales_Millions
FROM blinkit_data
WHERE Item_Fat_Content = 'Low Fat'  --total sales only for low fat

--KPI 2. Average Sales
SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales FROM blinkit_data
WHERE Outlet_Establishment_Year = 2022  

--KPI 3. Number of Items
SELECT COUNT(*) AS No_Of_Items FROM blinkit_data

--KPI 4. Average Rating
SELECT CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating FROM blinkit_data

--GRANULAR REQUIREMENTS
--1. Total Sales by Fat Content
SELECT Item_Fat_Content, 
        CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) AS Total_Sales_Thousands,
        CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
        COUNT(*) AS No_Of_Items,
        CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data  
GROUP BY Item_Fat_Content -- Whenever u r using any deminsional field with aggregrate Function i.e sum, u have to group it by whatever deminsional field u have brought.
ORDER BY Total_Sales_Thousands DESC

--2. Total Sales by Item Types
SELECT Item_Type, 
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
        CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
        COUNT(*) AS No_Of_Items,
        CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data  
GROUP BY Item_Type 
ORDER BY Total_Sales DESC

--3. Fat Content by Outlet for total sales
SELECT Outlet_Location_Type, Item_Fat_Content, 
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data  
GROUP BY Outlet_Location_Type, Item_Fat_Content  
ORDER BY Total_Sales ASC

SELECT Outlet_Location_Type, 
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM blinkit_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT                               --to transform rows in columns
(
    SUM(Total_Sales) 
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;



--4. Total Sales by Outlet Establishment
    SELECT Outlet_Establishment_Year,
            CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
            CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
            COUNT(*) AS No_Of_Items,
            CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
    FROM blinkit_data  
    GROUP BY Outlet_Establishment_Year
    ORDER BY Total_Sales DESC

--5. Percentage of Sales by Outlet Size
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

--6. Sales by Outlet Location
SELECT Outlet_Location_Type,
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
        CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
        CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
        COUNT(*) AS No_Of_Items,
        CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

--6. All Metrics by Outlet Type
SELECT Outlet_Type,
        CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
        CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
        CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
        COUNT(*) AS No_Of_Items,
        CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;
