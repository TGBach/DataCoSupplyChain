Use Dataco;
Go
---B1: KIEM TRA CAU TRUC DATASET
--- Tong so dong
Select COUNT(*) as total_rows
FROM DBO.DataCoSupplyChainDataset;

--- CAU TRUC BANG
SELECT
	COLUMN_NAME,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DATACOSUPPLYCHAINDATASET'
ORDER BY ORDINAL_POSITION;

--- PREVIEW DU LIEU
SELECT TOP 10*
FROM DataCoSupplyChainDataset;

--- XAC DINH GRAIN DATASET
SELECT
	COUNT(*) AS Total_Rows,
	COUNT(DISTINCT Order_Id) AS Unique_Order,
	COUNT(DISTINCT Order_Item_Id) AS Unique_Order_Items,
	COUNT(DISTINCT Customer_Id) AS Unique_CusTomers,
	COUNT(DISTINCT Product_card_Id) AS Unique_Products
FROM dbo.DataCoSupplyChainDataset;

SELECT 
	ORDER_ID,
	COUNT (*) AS ITEM_COUNT
FROM DataCoSupplyChainDataset
GROUP BY Order_Id
HAVING COUNT(*) > 1 
ORDER BY ITEM_COUNT DESC

SELECT
	Order_Item_Id,
	COUNT(*) AS Row_Count
FROM dbo.DataCoSupplyChainDataset
GROUP BY Order_Item_Id
HAVING COUNT(*) > 1;

--- DATA QUALITY CHECK
SELECT
COUNT(*) AS Total_Rows,
 
SUM(CASE WHEN Order_Id IS NULL THEN 1 ELSE 0 END) AS Null_Order_ID,
SUM(CASE WHEN Customer_Id IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
SUM(CASE WHEN Product_Card_Id IS NULL THEN 1 ELSE 0 END) AS Null_Product_ID,
 
SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Null_Sales,
SUM(CASE WHEN Benefit_per_order IS NULL THEN 1 ELSE 0 END) AS Null_Profit,
SUM(CASE WHEN Order_Item_Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
 
SUM(CASE WHEN order_date_DateOrders IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date,
SUM(CASE WHEN shipping_date_DateOrders IS NULL THEN 1 ELSE 0 END) AS Null_Shipping_Date,
 
SUM(CASE WHEN Customer_Zipcode IS NULL THEN 1 ELSE 0 END) AS Null_Zipcode
FROM dbo.DataCoSupplyChainDataset;


--- DATA RANGE
SELECT
	MIN(order_date_DateOrders) AS First_Order_Date,
	MAX(order_date_DateOrders) AS Last_Order_Date,
COUNT(DISTINCT CAST(order_date_DateOrders AS DATE)) AS Number_of_Days
FROM dbo.DataCoSupplyChainDataset;

--- B2 Data Analysis
--- KIEM TRA QUAN HE GIUA CAC COT TAI CHINH
SELECT TOP 20
	Order_Id,
	Order_Item_Id,
	Sales,
	Sales_per_customer,
	Benefit_per_order,
	Order_Profit_Per_Order,
	Order_Item_Total,
	Order_Item_Quantity,
	Order_Item_Discount	
	Order_Item_Discount_Rate,
	Product_Price
FROM dbo.DataCoSupplyChainDataset
ORDER BY Order_Id, Order_Item_Id;

--- TAO KPI
SELECT
	COUNT(DISTINCT Order_Id) AS Total_Orders,
	COUNT(DISTINCT Customer_Id) AS Total_Customers,
	COUNT(DISTINCT Product_Card_Id) AS Total_Products,
	SUM(Sales) AS Total_Sales,
	SUM(Benefit_per_order) AS Total_Profit,
	AVG(Benefit_per_order) AS Avg_Profit_Per_Item,
	COUNT(DISTINCT CASE
WHEN Late_delivery_risk = 1
THEN Order_Id
END) * 100.0
/ COUNT(DISTINCT Order_Id) AS Late_Delivery_Rate
 
FROM dbo.DataCoSupplyChainDataset;

--- SALES THEO THOI GIAN
SELECT
	YEAR(order_date_DateOrders) AS Order_Year,
	MONTH(order_date_DateOrders) AS Order_Month,
	COUNT(DISTINCT Order_Id) AS Total_Orders,
	SUM(Sales) AS Total_Sales,
	SUM(Benefit_per_order) AS Total_Profit
 
FROM dbo.DataCoSupplyChainDataset
 
GROUP BY
YEAR(order_date_DateOrders),
MONTH(order_date_DateOrders)
 
ORDER BY
Order_Year,
Order_Month;

--- MARKET PERFORMANCE
SELECT
Market,
 
COUNT(DISTINCT Order_Id) AS Total_Orders,
 
SUM(Sales) AS Total_Sales,
 
SUM(Benefit_per_order) AS Total_Profit,
 
SUM(Benefit_per_order) * 100.0
/ NULLIF(SUM(Sales), 0) AS Profit_Margin
 
FROM dbo.DataCoSupplyChainDataset
 
GROUP BY Market
 
ORDER BY Total_Sales DESC;

--- PRODUCT/CATEGORY PERFORMANCE
SELECT
Category_Name,
 
COUNT(DISTINCT Order_Id) AS Total_Orders,
 
SUM(Order_Item_Quantity) AS Units_Sold,
 
SUM(Sales) AS Total_Sales,
 
SUM(Benefit_per_order) AS Total_Profit,
 
SUM(Benefit_per_order) * 100.0
/ NULLIF(SUM(Sales), 0) AS Profit_Margin
 
FROM dbo.DataCoSupplyChainDataset
 
GROUP BY Category_Name
 
ORDER BY Total_Sales DESC;

--- CATEGORY MAKE LOSS
SELECT
Category_Name,
SUM(Sales) AS Total_Sales,
SUM(Benefit_per_order) AS Total_Profit,
SUM(Benefit_per_order) * 100.0
/ NULLIF(SUM(Sales), 0) AS Profit_Margin,
SUM(CASE
WHEN Benefit_per_order < 0 THEN 1
ELSE 0
END) AS Loss_Count
FROM dbo.DataCoSupplyChainDataset
GROUP BY Category_Name
HAVING SUM(CASE
WHEN Benefit_per_order < 0 THEN 1
ELSE 0
END) > 0
ORDER BY Total_Profit ASC;

--- DELIVERY ANALYSIS
SELECT
	Shipping_Mode,
	COUNT(DISTINCT Order_Id) AS Total_Orders,
	COUNT(DISTINCT CASE
WHEN Late_delivery_risk = 1
THEN Order_Id
END) AS Late_Orders,
	COUNT(DISTINCT CASE
WHEN Late_delivery_risk = 1
THEN Order_Id
END) * 100.0
/ COUNT(DISTINCT Order_Id) AS Late_Rate
 
FROM dbo.DataCoSupplyChainDataset
GROUP BY Shipping_Mode 
ORDER BY Late_Rate DESC;

--- PLANNED DAYS VS ACTUAL DAYS
SELECT
	Shipping_Mode,
 	COUNT(DISTINCT Order_Id) AS Total_Orders,
 	AVG(CAST(Days_for_shipping_real AS FLOAT)) AS Avg_Actual_Days,
	AVG(CAST(Days_for_shipment_scheduled AS FLOAT)) AS Avg_Scheduled_Days,
	AVG(
	CAST(Days_for_shipping_real AS FLOAT)
	- Days_for_shipment_scheduled
	) AS Avg_Delay_Days, 
	COUNT(DISTINCT CASE
	WHEN Late_delivery_risk = 1
	THEN Order_Id
	END) * 100.0
	/ NULLIF(COUNT(DISTINCT Order_Id),0) AS Late_Rate
 
FROM dbo.DataCoSupplyChainDataset 
GROUP BY Shipping_Mode
ORDER BY Late_Rate DESC;

--- CUSTOMER ANALYSIS
SELECT TOP 10
	Customer_Id,
	Customer_Fname,
	Customer_Lname,
	COUNT(DISTINCT Order_Id) AS Total_Orders,
	SUM(Sales) AS Total_Sales,
	SUM(Benefit_per_order) AS Total_Profit
FROM dbo.DataCoSupplyChainDataset
GROUP BY
Customer_Id,
Customer_Fname,
Customer_Lname
ORDER BY Total_Sales DESC;

--- CUSTOMER SEGMENT
SELECT
	Customer_Segment,
	COUNT(DISTINCT Customer_Id) AS Total_Customers,
	COUNT(DISTINCT Order_Id) AS Total_Orders,
	SUM(Sales) AS Total_Sales,
	SUM(Benefit_per_order) AS Total_Profit,
	SUM(Benefit_per_order) * 100.0
	/ NULLIF(SUM(Sales),0) AS Profit_Margin
FROM dbo.DataCoSupplyChainDataset
GROUP BY Customer_Segment
ORDER BY Total_Sales DESC;

--- GEOGRAPHIC ANALYSIS
SELECT TOP 10
Order_Country,
COUNT(DISTINCT Order_Id) AS Total_Orders,
SUM(Sales) AS Total_Sales,
SUM(Benefit_per_order) AS Total_Profit,
SUM(Benefit_per_order) * 100.0
/ NULLIF(SUM(Sales),0) AS Profit_Margin
FROM dbo.DataCoSupplyChainDataset
GROUP BY Order_Country
ORDER BY Total_Sales DESC;

--- DISCOUNT VS PROFIT
SELECT
	CASE
	WHEN Order_Item_Discount_Rate = 0 THEN 'No Discount'
	WHEN Order_Item_Discount_Rate <= 0.10 THEN '0-10%'
	WHEN Order_Item_Discount_Rate <= 0.20 THEN '10-20%'
	WHEN Order_Item_Discount_Rate <= 0.30 THEN '20-30%'
ELSE '>30%'
END AS Discount_Group,
 
COUNT(*) AS Total_Items,
SUM(Sales) AS Total_Sales,
SUM(Benefit_per_Order) AS Total_Profit,
 
SUM(Benefit_per_order) * 100.0
/ NULLIF(SUM(Sales),0) AS Profit_Margin
 
FROM dbo.DataCoSupplyChainDataset
 
GROUP BY
CASE
WHEN order_Item_Discount_Rate = 0 THEN 'No Discount'
WHEN Order_Item_Discount_Rate <= 0.10 THEN '0-10%'
WHEN Order_Item_Discount_Rate <= 0.20 THEN '10-20%'
WHEN Order_Item_Discount_Rate <= 0.0 THEN '20-30%'
ELSE '>30%'
END;