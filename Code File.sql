-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

/* Step 1: Data Exploration and Understanding */
-- Exploring the first few rows of the dataset
SELECT * FROM wholesale_customers LIMIT 5;

/*Step 2: Customer Segmentation
Let's segment customers based on their spending behavior using clustering techniques.*/
-- Use K-means clustering to segment customers based on spending behavior
-- Segmenting customers into 4 clusters based on spending on 'Fresh', 'Milk', 'Grocery', 'Frozen', 'Detergents_Paper', and 'Delicassen'

-- Creating a temporary table to store normalized spending data
WITH normalized_spending AS (
    SELECT
        (Fresh - MIN(Fresh) OVER ()) / (MAX(Fresh) OVER () - MIN(Fresh) OVER ()) AS Norm_Fresh,
        (Milk - MIN(Milk) OVER ()) / (MAX(Milk) OVER () - MIN(Milk) OVER ()) AS Norm_Milk,
        (Grocery - MIN(Grocery) OVER ()) / (MAX(Grocery) OVER () - MIN(Grocery) OVER ()) AS Norm_Grocery,
        (Frozen - MIN(Frozen) OVER ()) / (MAX(Frozen) OVER () - MIN(Frozen) OVER ()) AS Norm_Frozen,
        (Detergents_Paper - MIN(Detergents_Paper) OVER ()) / (MAX(Detergents_Paper) OVER () - MIN(Detergents_Paper) OVER ()) AS Norm_Detergents_Paper,
        (Delicassen - MIN(Delicassen) OVER ()) / (MAX(Delicassen) OVER () - MIN(Delicassen) OVER ()) AS Norm_Delicassen
    FROM wholesale_customers
)

-- Perform K-means clustering
, kmeans_clusters AS (SELECT
        KMeans(Norm_Fresh, Norm_Milk, Norm_Grocery, Norm_Frozen, Norm_Detergents_Paper, Norm_Delicassen, 4) OVER () AS Cluster
    FROM normalized_spending
)

-- View clustered customers
SELECT * FROM kmeans_clusters;

/* Step 3: Analyzing Customer Segments
Let's analyze spending patterns and characteristics of each customer segment.*/
-- Calculating average spending for each product category within each cluster
SELECT
    Cluster,
    AVG(Fresh) AS Avg_Fresh,
    AVG(Milk) AS Avg_Milk,
    AVG(Grocery) AS Avg_Grocery,
    AVG(Frozen) AS Avg_Frozen,
    AVG(Detergents_Paper) AS Avg_Detergents_Paper,
    AVG(Delicassen) AS Avg_Delicassen
FROM
    (SELECT
        Fresh,
        Milk,
        Grocery,
        Frozen,
        Detergents_Paper,
        Delicassen,
        KMeans(Norm_Fresh, Norm_Milk, Norm_Grocery, Norm_Frozen, Norm_Detergents_Paper, Norm_Delicassen, 4) OVER () AS Cluster
    FROM normalized_spending) AS clustered_spending
GROUP BY Cluster;

/*Step 4: Customer Lifetime Value (CLV) Analysis
Let's now calculate the Customer Lifetime Value (CLV) for each customer.*/

-- Calculating CLV using window functions
SELECT
    SUM(TotalSpending) OVER () AS TotalSpending,
    AVG(TotalSpending) OVER () AS AvgSpendingPerOrder,
    COUNT(*) OVER () AS TotalOrders,
    SUM(TotalSpending) OVER () / COUNT(*) OVER () AS AvgOrderValue,
    (SUM(TotalSpending) OVER () / COUNT(*) OVER ()) / (AVG(SUM(TotalSpending) OVER () / COUNT(*) OVER ())) AS CLV
FROM wholesale_customers;

/*Step 5: Analyzing Customer Churn
Identifing customers who haven't made purchases recently, potentially indicating churn.*/

-- Calculating the recency of last purchase for each customer
WITH customer_recency AS (
    SELECT
        MAX(InvoiceDate) AS LastPurchaseDate,
        DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) AS RecencyDays
    FROM sales_data
)

-- Identifing potentially churned customers (no purchases in the last 90 days)
SELECT
    LastPurchaseDate,
    RecencyDays,
    CASE
        WHEN RecencyDays >= 90 THEN 'Churned'
        ELSE 'Active'
    END AS CustomerStatus
FROM customer_recency;
