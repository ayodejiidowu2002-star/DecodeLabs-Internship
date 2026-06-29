--=====================================================================================================
--Name: Idowu Ayodeji Amos
--Role: Data Analyst Intern
-- Course: Data Analytics
-- Date: June 2026
--=====================================================================================================

--=====================================================================================================
-- DATA CLEANING AND EXPLORATORY DATA ANALYSIS
--=====================================================================================================

-- VERIFY TOTAL ROWS
SELECT COUNT (*) AS TOTALROW
 FROM SalesData;

 -- VERIFY COLUMN WITH NULL OR BLANKS
 SELECT
    SUM(CASE WHEN OrderID         IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
    SUM(CASE WHEN Date            IS NULL THEN 1 ELSE 0 END) AS Null_Date,
    SUM(CASE WHEN CustomerID      IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
    SUM(CASE WHEN Product         IS NULL THEN 1 ELSE 0 END) AS Null_Product,
    SUM(CASE WHEN Quantity        IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN UnitPrice       IS NULL THEN 1 ELSE 0 END) AS Null_UnitPrice,
    SUM(CASE WHEN PaymentMethod   IS NULL THEN 1 ELSE 0 END) AS Null_PaymentMethod,
    SUM(CASE WHEN OrderStatus     IS NULL THEN 1 ELSE 0 END) AS Null_OrderStatus,
    SUM(CASE WHEN CouponCode      IS NULL THEN 1 ELSE 0 END) AS Null_CouponCode,
    SUM(CASE WHEN ReferralSource  IS NULL THEN 1 ELSE 0 END) AS Null_ReferralSource,
    SUM(CASE WHEN TotalPrice      IS NULL THEN 1 ELSE 0 END) AS Null_TotalPrice
FROM SalesData;

-- REPLACING NULL VALUE WITH 'NO COUPON'
UPDATE SalesData
SET CouponCode = 'NO COUPON'
WHERE CouponCode IS NULL;

-- CONFIRM THE CHANGES ARE DONE
SELECT * FROM SalesData

-- Verify the count of each couponcode
SELECT CouponCode, COUNT(*) AS Count
FROM SalesData
GROUP BY CouponCode
ORDER BY Count DESC;

-- DISTINCT VALUES OF EACH CATEGORICAL COLUMN
SELECT DISTINCT Product        FROM SalesData;
SELECT DISTINCT PaymentMethod  FROM SalesData;
SELECT DISTINCT OrderStatus    FROM SalesData;
SELECT DISTINCT CouponCode     FROM SalesData;
SELECT DISTINCT ReferralSource FROM SalesData;

-- RANGE CHECK ON NUMERIC COLUMN
SELECT
    MIN(Quantity)   AS Min_Qty,   MAX(Quantity)   AS Max_Qty,
    MIN(UnitPrice)  AS Min_Price, MAX(UnitPrice)  AS Max_Price,
    MIN(TotalPrice) AS Min_Total, MAX(TotalPrice) AS Max_Total
FROM SalesData;

-- DATE CONVERT FROM TEXT TO PROPER DATE TYPE
UPDATE SalesData
SET Date = CONVERT(DATE, Date, 103);

--
SELECT TOP 5 [Date]
FROM SalesData;

--

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesData';
--
SELECT * FROM SalesData

--
UPDATE SalesData
SET
OrderYear = YEAR(Date),
OrderMonth = MONTH(Date),
OrderQuarter = DATEPART(QUARTER,Date);
--
SELECT * FROM SalesData

--===========================================================================================================
--EXPLORATORY DATA ANALYSIS - AGGREGATE (SUM, AVERAGE, COUNT, MIN AND MAX)
--===========================================================================================================

--EDA ANALYSIS - OVERALL SUMMARY METRICS
SELECT
    COUNT(*)                        AS Total_Orders,
    COUNT(DISTINCT CustomerID)      AS Unique_Customers,
    COUNT(DISTINCT Product)         AS Product_Types,
    ROUND(SUM(TotalPrice), 2)       AS Total_Revenue,
    ROUND(AVG(TotalPrice), 2)       AS Avg_Order_Value,
    ROUND(MIN(TotalPrice), 2)       AS Min_Order_Value,
    ROUND(MAX(TotalPrice), 2)       AS Max_Order_Value
FROM SalesData;

-- TOTAL REVENUE BY PRODUCT

SELECT
    Product,
    COUNT(*)                        AS Orders,
    SUM(Quantity)                   AS Units_Sold,
    ROUND(SUM(TotalPrice), 2)       AS Total_Revenue,
    ROUND(AVG(TotalPrice), 2)       AS Avg_Order_Value,
    ROUND(AVG(UnitPrice), 2)        AS Avg_Unit_Price
FROM SalesData
GROUP BY Product
ORDER BY Total_Revenue DESC;

-- TOTAL REVENUE BY YEAR AND MONTH
SELECT
   OrderYear,
   OrderMonth,
   COUNT(*)						AS Orders,
   ROUND(SUM(TotalPrice), 2)	AS Monthly_Revenue
   FROM SalesData
   GROUP BY OrderYear, OrderMonth
   ORDER BY OrderYear, OrderMonth;

   -- QUARTERLY REVENUE
   SELECT
    OrderYear,
    OrderQuarter,
    COUNT(*)                    AS Orders,
    ROUND(SUM(TotalPrice), 2)   AS Quarterly_Revenue
FROM SalesData
GROUP BY OrderYear, OrderQuarter
ORDER BY OrderYear, OrderQuarter;

-- ORDER STATUS BREAKDOWN
SELECT
    OrderStatus,
    COUNT(*)                                AS Orders,
    ROUND(COUNT(*) * 100.0 / 1200, 2)      AS Pct_of_Total,
    ROUND(SUM(TotalPrice), 2)               AS Revenue
FROM SalesData
GROUP BY OrderStatus
ORDER BY Orders DESC;

-- REVENUE AT RISK (CANCELLATION+RETURNED)
SELECT
    ROUND(SUM(TotalPrice), 2)       AS Revenue_At_Risk,
    COUNT(*)                        AS Affected_Orders
FROM SalesData 
WHERE OrderStatus IN ('Cancelled', 'Returned');

--PAYMENT METHOD ANALYSIS
SELECT
    PaymentMethod,
    COUNT(*)                    AS Orders,
    ROUND(SUM(TotalPrice), 2)   AS Total_Revenue,
    ROUND(AVG(TotalPrice), 2)   AS Avg_Order_Value
FROM SalesData
GROUP BY PaymentMethod
ORDER BY Total_Revenue DESC;

--COUPON USAGE AND ITS IMPACT ON REVENUE
SELECT
    CouponCode,
    COUNT(*)                    AS Orders,
    ROUND(AVG(TotalPrice), 2)   AS Avg_Order_Value,
    ROUND(SUM(TotalPrice), 2)   AS Total_Revenue
FROM SalesData
GROUP BY CouponCode
ORDER BY Orders DESC;

--TOP 10 CUSTOMER BY REVENUE
SELECT TOP 10
    CustomerID,
    COUNT(*)                    AS Orders,
    ROUND(SUM(TotalPrice), 2)   AS Revenue,
    ROUND(AVG(TotalPrice), 2)   AS Avg_Order_Value
FROM SalesData
GROUP BY CustomerID
ORDER BY Revenue DESC;

-- QUANTITY DISTRIBUTION
SELECT
    Quantity,
    COUNT(*)                            AS Orders,
    ROUND(COUNT(*) * 100.0 / 1200, 2)  AS Pct_of_Total,
    ROUND(SUM(TotalPrice), 2)           AS Total_Revenue
FROM SalesData
GROUP BY Quantity
ORDER BY Quantity;

-- PRODUCT PERFORMANCE BY ORDER STATUS
SELECT
    Product,
    OrderStatus,
    COUNT(*)                    AS Orders,
    ROUND(SUM(TotalPrice), 2)   AS Revenue
FROM SalesData
GROUP BY Product, OrderStatus
ORDER BY Product, Orders DESC;

--=======================================================================================================
-- ADVANCE QUERY
--=======================================================================================================
-- YEAR-ON-YEAR COMPARISON
WITH YearlyRevenue AS (
    SELECT
        OrderYear,
        ROUND(SUM(TotalPrice), 2) AS Total_Revenue
    FROM SalesData
    GROUP BY OrderYear
)
SELECT
    curr.OrderYear,
    curr.Total_Revenue,
    prev.Total_Revenue                                              AS Prev_Year_Revenue,
    ROUND(curr.Total_Revenue - prev.Total_Revenue, 2)              AS YoY_Change,
    ROUND(
        (curr.Total_Revenue - prev.Total_Revenue) * 100.0
        / NULLIF(prev.Total_Revenue, 0), 2
    )                                                               AS YoY_Pct_Change
FROM YearlyRevenue curr
LEFT JOIN YearlyRevenue prev ON curr.OrderYear = prev.OrderYear + 1
ORDER BY curr.OrderYear;

--


