/*

Project 2 - Advanced SQL
Dor Ben Harosh
318534963

*/


-- Question 1:

--WITH YearlySales AS (
--    SELECT 
--        YEAR(o.OrderDate) AS Year,
--        SUM(ol.PickedQuantity * ol.UnitPrice) AS IncomePerYear,
--        round((SUM(ol.PickedQuantity * ol.UnitPrice) / COUNT(DISTINCT month(o.OrderDate))) * 12,1)  AS LinearAnnualIncome
--		,COUNT(DISTINCT month(o.OrderDate)) AS NumberOfDistinctMonth
--    FROM Sales.OrderLines ol
--    JOIN Sales.Orders o ON ol.OrderID = o.OrderID
--    JOIN Sales.Invoices i ON o.OrderID = i.OrderID
--    GROUP BY YEAR(o.OrderDate)
--),
--GrowthCalc AS (
--    SELECT 
--        Year,
--        IncomePerYear,
--        LinearAnnualIncome,
--        LAG(LinearAnnualIncome) OVER(ORDER BY Year) AS PreviousYearIncome,
--        CASE 
--            WHEN LAG(LinearAnnualIncome) OVER(ORDER BY Year) IS NOT NULL 
--				 THEN (LinearAnnualIncome - LAG(LinearAnnualIncome) OVER(ORDER BY Year)) / LAG(LinearAnnualIncome) OVER(ORDER BY Year) * 100
--            ELSE NULL
--        END AS GrowthRate
--		,NumberOfDistinctMonth
--    FROM YearlySales
--)
--SELECT 
--    Year,
--    IncomePerYear,
--	NumberOfDistinctMonth,
--    CAST(LinearAnnualIncome as decimal(18,2)) as YearlyLinearIncome ,
--    CAST(GrowthRate as decimal(18,2)) as GrowthRate
--FROM GrowthCalc
--ORDER BY Year




-- Question 2:

--WITH QuarterlyIncome AS (
--    SELECT 
--        YEAR(o.OrderDate) AS TheYear,
--        DATEPART(QUARTER, o.OrderDate) AS TheQuarter, 
--        c.CustomerName,
--        CAST(SUM(ol.PickedQuantity * ol.UnitPrice) AS DECIMAL(18,2)) AS IncomePerYear,
--        RANK() OVER (PARTITION BY YEAR(o.OrderDate), DATEPART(QUARTER, o.OrderDate) 
--                     ORDER BY SUM(ol.PickedQuantity * ol.UnitPrice) DESC) AS DNR
--    FROM Sales.Orders o
--    JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
--    JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
--    GROUP BY 
--        YEAR(o.OrderDate), 
--        DATEPART(QUARTER, o.OrderDate), 
--        c.CustomerName
--)
--SELECT 
--    TheYear,
--    TheQuarter,
--    CustomerName,
--    IncomePerYear,
--    DNR
--FROM QuarterlyIncome
--WHERE DNR <= 5 
--ORDER BY TheYear, TheQuarter, DNR



-- Question 3:

--WITH StockSalesData AS (
--    SELECT 
--		S.StockItemID AS StockItemID,
--        S.StockItemName AS StockItemName,
--        SUM(SIL.ExtendedPrice - SIL.TaxAmount) AS TotalProfit
--    FROM Sales.Invoices SI
--    INNER JOIN Sales.InvoiceLines SIL ON SIL.InvoiceID = SI.InvoiceID
--    INNER JOIN Sales.Customers SC ON SC.CustomerID = SI.CustomerID
--	  INNER JOIN Warehouse.StockItems S ON S.StockItemID = SIL.StockItemID
--    GROUP BY S.StockItemID, S.StockItemName
--)
--SELECT StockItemID, StockItemName, TotalProfit
--FROM (
--    SELECT *,
--           DENSE_RANK() OVER (ORDER BY TotalProfit DESC) AS DNR
--    FROM StockSalesData
--) AS RankedData
--WHERE DNR <= 10




-- Question 4:

--WITH A AS (
--    SELECT
--		S.StockItemID AS StockItemID,
--        S.StockItemName AS StockItemName,
--		S.UnitPrice,
--		S.RecommendedRetailPrice,
--        S.RecommendedRetailPrice - S.UnitPrice AS NominalProductProfit
--    FROM Warehouse.StockItems S 
--	WHERE S.ValidTo >= GETDATE()
--    GROUP BY S.StockItemID ,S.StockItemName , S.UnitPrice,S.RecommendedRetailPrice
--)
--SELECT *
--FROM (
--    SELECT 
--	      ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Rn,
--	      *,
--          DENSE_RANK() OVER(ORDER BY NominalProductProfit DESC) AS DNR
--    FROM A
--) AS RankedData




-- Question 5:

--with temp as (
--SELECT 
--    CONCAT(S.SupplierID, ' - ', S.SupplierName) AS SupplierDetails,
--    STRING_AGG(concat(SI.StockItemID, ' ',  SI.StockItemName), ' /, ') AS ProductDetails
--FROM 
--    Purchasing.Suppliers S
--JOIN 
--    Warehouse.StockItems SI ON S.SupplierID = SI.SupplierID
--GROUP BY 
--    S.SupplierID, S.SupplierName
--)
--select *
--from temp




-- Question 6:

--SELECT TOP 5
--    C.CustomerID AS CustomerID,
--    CT.CityName AS CityName,
--    CO.CountryName AS CountryName,
--    'Americas' AS Region,
--    FORMAT(SUM(IL.ExtendedPrice), 'N2') AS TotalExtendedPrice
--FROM Sales.Customers C
--JOIN Sales.Invoices I ON C.CustomerID = I.CustomerID
--JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
--JOIN Application.Cities CT ON C.DeliveryCityID = CT.CityID
--JOIN Application.StateProvinces SP ON CT.StateProvinceID = SP.StateProvinceID
--JOIN Application.Countries CO ON SP.CountryID = CO.CountryID
--GROUP BY C.CustomerID, CT.CityName, CO.CountryName, SP.SalesTerritory
--ORDER BY SUM(IL.ExtendedPrice) DESC




-- Question 7:

--WITH TEMP1 AS
--(
--    SELECT  
--        YEAR(o.OrderDate) AS OrderYear,
--        ISNULL(MONTH(o.OrderDate), 13) AS OrderMonth, 
--        SUM(ol.PickedQuantity * ol.UnitPrice) AS MonthlyTotal 
--    FROM Sales.OrderLines ol 
--    JOIN Sales.Orders o ON ol.OrderID = o.OrderID
--    GROUP BY CUBE(YEAR(o.OrderDate), MONTH(o.OrderDate))
--)
--SELECT 
--    TEMP1.OrderYear, 
--    CASE 
--        WHEN TEMP1.OrderMonth = 13 THEN 'Grand Total' 
--        ELSE CAST(TEMP1.OrderMonth AS NVARCHAR) 
--    END AS OrderMonth,
--    FORMAT(TEMP1.MonthlyTotal, 'N2') AS MonthlyTotal,
--    FORMAT(
--        SUM(CASE WHEN TEMP1.OrderMonth != 13 THEN TEMP1.MonthlyTotal ELSE 0 END) 
--        OVER(PARTITION BY TEMP1.OrderYear ORDER BY TEMP1.OrderYear, TEMP1.OrderMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 
--        'N2'
--    ) AS CumulativeTotal 
--FROM TEMP1
--WHERE TEMP1.OrderYear IS NOT NULL
--ORDER BY TEMP1.OrderYear, TEMP1.OrderMonth




-- Question 8:

--SELECT OrderMonth,[2013], [2014], [2015], [2016]
--FROM (
--    SELECT 
--		 MONTH(O.OrderDate) as OrderMonth,
--		 YEAR(O.OrderDate) as OrderYear,
--		 O.OrderID 
--    FROM Sales.Orders O 
--) AS SourceTable
--PIVOT (
--    count(OrderID) 
--    FOR OrderYear IN ([2013], [2014], [2015], [2016])
--) AS PivotTable
--ORDER BY OrderMonth ASC




-- Question 9:

--WITH OrderData AS (
--    SELECT
--        o.CustomerID,
--        c.CustomerName,
--        o.OrderDate,
--        LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate) AS PreviousOrderDate,
--        MAX(o.OrderDate) OVER (PARTITION BY o.CustomerID) AS LastOrderDate,
--        MAX(o.OrderDate) OVER () AS GlobalLastOrderDate
--    FROM Sales.Orders o
--    JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
--),
--CustomerStats AS (
--    SELECT
--        CustomerID,
--        CustomerName,
--        OrderDate,
--        PreviousOrderDate,
--        AVG(DATEDIFF(DAY, PreviousOrderDate, OrderDate)) OVER (PARTITION BY CustomerID) AS AvgDaysBetweenOrders,
--        MAX(LastOrderDate) OVER (PARTITION BY CustomerID) AS LastOrderDate,
--        MAX(GlobalLastOrderDate) OVER () AS GlobalLastOrderDate
--    FROM OrderData
--)
--SELECT
--    CustomerID,
--    CustomerName,
--    OrderDate,
--    PreviousOrderDate,
--    DATEDIFF(DAY, LastOrderDate, GlobalLastOrderDate) AS DaysSinceLastOrder,
--    AvgDaysBetweenOrders,
--    CASE
--        WHEN DATEDIFF(DAY, LastOrderDate, GlobalLastOrderDate) > 2 
--						* AvgDaysBetweenOrders THEN 'Potential Churn'
--        ELSE 'Active'
--    END AS CustomerStatus
--FROM CustomerStats
--ORDER BY CustomerID, OrderDate




-- Question 10: 

--WITH table1 AS 
--(
--    SELECT cc.CustomerCategoryName AS CustomerCategoryName,
--           CASE 
--               WHEN c.CustomerName LIKE 'Wingtip%' THEN 'Wingtip' 
--               WHEN c.CustomerName LIKE 'Tailspin%' THEN 'Tailspin'
--               ELSE c.CustomerName
--           END AS CustomerName
--    FROM Sales.Customers c JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
--),
--table2 AS (
--    SELECT CustomerCategoryName,
--           SUM(COUNT(distinct table1.CustomerName)) OVER() AS TotalCustCount
--    FROM table1
--    GROUP BY CustomerCategoryName
--),
--TotalResulte as (
--SELECT table1.CustomerCategoryName,
--       COUNT(distinct table1.CustomerName) AS CustomerCOUNT,
--       table2.TotalCustCount
--FROM table1 JOIN table2 ON table1.CustomerCategoryName = table2.CustomerCategoryName
--GROUP BY table1.CustomerCategoryName, table2.TotalCustCount
--)
--select *,
--	   CONCAT(ROUND((CAST(TotalResulte.CustomerCOUNT AS FLOAT) 
--				/ CAST(TotalResulte.TotalCustCount AS FLOAT)) * 100, 2), '%') AS DistributionFactor
--from TotalResulte