select top 10 * from [Ajio Fasion Clothing Men];

------- Checking how many rows are inserted
SELECT COUNT(*) AS Total_Sales FROM [Ajio Fasion Clothing Men];

------- Total Brands
SELECT COUNT(DISTINCT(Brand)) AS Total_Brands FROM [Ajio Fasion Clothing Men];

------ Null Value Checks
SELECT 
     SUM(CASE WHEN Brand IS NULL THEN 1 ELSE 0 END) AS Brand_nulls,
     SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS Description_nulls,
     SUM(CASE WHEN Id_Product IS NULL THEN 1 ELSE 0 END) AS IdProduct_nulls,
     SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
     SUM(CASE WHEN Discount_Price IS NULL THEN 1 ELSE 0 END) AS DiscountPrice_nulls,
     SUM(CASE WHEN Original_Price IS NULL THEN 1 ELSE 0 END) AS OriginalPrice_nulls,
     SUM(CASE WHEN Color IS NULL THEN 1 ELSE 0 END) AS Color_nulls
FROM [Ajio Fasion Clothing Men];

------- Highest Average Discounts By Brands
SELECT Brand,
       COUNT(*) AS Total_Products,
       ROUND(AVG(Original_Price), 2) AS Avg_Original_Price,
       ROUND(AVG(Discount_Price), 2) AS Avg_Discount_Price,
       ROUND(AVG(Original_Price - Discount_Price), 2) AS Avg_Discount,
       ROUND(AVG(Original_Price - Discount_Price) * 100.0 / AVG(Original_Price), 2) AS Avg_Discount_PCT
FROM [Ajio Fasion Clothing Men]
WHERE gender = 'Men'
GROUP BY Brand
ORDER BY Avg_Discount_PCT DESC;

------- Original Price Tiers
SELECT 
    Brand,
    Description,
    Original_Price,
    CASE 
        WHEN Original_Price < 1000 THEN '1. Budget (< 1k)'
        WHEN Original_Price BETWEEN 1000 AND 4999 THEN '2. Mid-Range (1k - 5k)'
        WHEN Original_Price BETWEEN 5000 AND 19999 THEN '3. Premium (5k - 20k)'
        WHEN Original_Price BETWEEN 20000 AND 49999 THEN '4. Luxury (20k - 50k)'
        ELSE '5. Super Luxury (50k+)'
    END AS Detailed_Price_Tier
FROM [Ajio Fasion Clothing Men]
ORDER BY Original_Price DESC;

------- Price Tier
WITH Price_Tier AS(
SELECT
     *,
     CASE 
        WHEN Original_Price < 1000 THEN '1. Budget (< 1k)'
        WHEN Original_Price BETWEEN 1000 AND 4999 THEN '2. Mid-Range (1k - 5k)'
        WHEN Original_Price BETWEEN 5000 AND 19999 THEN '3. Premium (5k - 20k)'
        WHEN Original_Price BETWEEN 20000 AND 49999 THEN '4. Luxury (20k - 50k)'
        ELSE '5. Super Luxury (50k+)'
    END AS Detailed_Price_Tier
FROM [Ajio Fasion Clothing Men]
WHERE gender = 'Men'
)
SELECT 
     Detailed_Price_Tier,
     COUNT(Detailed_Price_Tier) As Total,
     CAST(COUNT(Detailed_Price_Tier) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5, 2)) AS PCT
FROM Price_Tier
GROUP BY Detailed_Price_Tier;

--------- Catelog distribution By Price
SELECT 
    CASE 
        WHEN Description LIKE '%T-shirt%' THEN 'T-Shirt'
        WHEN Description LIKE '%Shirt%' THEN 'Shirt'
        WHEN Description LIKE '%Trousers%' OR Description LIKE '%Jeans%' OR Description LIKE '%Pants%' THEN 'Bottomwear'
        WHEN Description LIKE '%Shorts%' THEN 'Shorts'
        ELSE 'Other'
    END AS Category,
    ROUND(AVG(Discount_Price), 2) AS Avg_Price
FROM [Ajio Fasion Clothing Men]
WHERE gender = 'Men'
GROUP BY 
    CASE 
        WHEN Description LIKE '%T-shirt%' THEN 'T-Shirt'
        WHEN Description LIKE '%Shirt%' THEN 'Shirt'
        WHEN Description LIKE '%Trousers%' OR Description LIKE '%Jeans%' OR Description LIKE '%Pants%' THEN 'Bottomwear'
        WHEN Description LIKE '%Shorts%' THEN 'Shorts'
        ELSE 'Other'
    END
ORDER BY Avg_Price DESC;

--------- Top Dicounted Products Within Each Brand
WITH DiscountedProducts AS(
SELECT
     Brand,
     Description,
     Discount_Price,
     Original_price,
     ROUND((Original_Price - Discount_Price) * 100.0 / Original_Price, 2) AS Discount_PCT
FROM [Ajio Fasion Clothing Men]
WHERE Discount_Price != Original_Price
AND gender = 'Men'
),
RankedProducts AS (
SELECT
     *,
     DENSE_RANK() OVER (ORDER BY Discount_PCT DESC) AS Dense_PCT
FROM DiscountedProducts
)
SELECT
      *
FROM RankedProducts
WHERE Dense_PCT <= 10
ORDER BY Dense_PCT ASC;

--------- Color Assortment Analysis
SELECT 
     Color,
     COUNT(*) AS Total_Items,
     ROUND(AVG(Discount_Price), 2) As Avg_Selling_Price
FROM [Ajio Fasion Clothing Men]
WHERE gender = 'Men'
GROUP BY Color
ORDER BY Total_Items DESC;