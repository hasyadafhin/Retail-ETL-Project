select * from dim_date;

select * from dim_feature;

select * from dim_store;

select * 
from fact_sales;


SELECT
    fs.*,
    ds.type,
    ds.size,
    df.temperature,
    df.fuel_price,
    df.cpi,
    df.unemployment,
    dd.year,
    dd.month,
    dd.week
FROM fact_sales AS fs
INNER JOIN dim_store AS ds
    ON fs.store = ds.store
INNER JOIN dim_feature AS df
    ON fs.store = df.store
    AND fs.date = df.date
INNER JOIN dim_date AS dd
    ON fs.date = dd.date;

# Pembuatan Tabel baru
CREATE TABLE retail_eda AS
SELECT
    -- Data penjualan
    fs.store,
    fs.dept,
    fs.date::date AS date,
    fs.weekly_sales,
    fs.isholiday,

    -- Informasi toko
    ds.type AS store_type,
    ds.size AS store_size,

    -- Faktor ekonomi
    df.temperature,
    df.fuel_price,
    df.cpi,
    df.unemployment,

    -- Informasi waktu
    dd.year,
    dd.month,
    dd.week

FROM fact_sales AS fs

LEFT JOIN dim_store AS ds
    ON fs.store = ds.store

LEFT JOIN dim_feature AS df
    ON fs.store = df.store
    AND fs.date::date = df.date::date

LEFT JOIN dim_date AS dd
    ON fs.date::date = dd.date::date;

# pengecekan
select * from retail_eda


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE store IS NULL) AS null_store,
    COUNT(*) FILTER (WHERE dept IS NULL) AS null_dept,
    COUNT(*) FILTER (WHERE date IS NULL) AS null_date,
    COUNT(*) FILTER (WHERE weekly_sales IS NULL) AS null_sales,
    COUNT(*) FILTER (WHERE store_type IS NULL) AS null_store_type,
    COUNT(*) FILTER (WHERE temperature IS NULL) AS null_temperature,
    COUNT(*) FILTER (WHERE fuel_price IS NULL) AS null_fuel_price,
    COUNT(*) FILTER (WHERE cpi IS NULL) AS null_cpi,
    COUNT(*) FILTER (WHERE unemployment IS NULL) AS null_unemployment
FROM retail_eda;


SELECT
    store,
    dept,
    date,
    COUNT(*) AS duplicate_count
FROM retail_eda
GROUP BY store, dept, date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


SELECT
    COUNT(*) FILTER (WHERE weekly_sales < 0)
        AS negative_sales,
    COUNT(*) FILTER (WHERE weekly_sales = 0)
        AS zero_sales,
    COUNT(*) FILTER (WHERE weekly_sales > 0)
        AS positive_sales
FROM retail_eda;


# Eksplorasi
## Tren perjualan Bulanan
SELECT
    year,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales,
    ROUND(AVG(weekly_sales)::numeric, 2)
        AS average_sales
FROM retail_eda
GROUP BY year
ORDER BY year;

# Top 10 highest sales by store

SELECT
    store,
    store_type,
    store_size,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales
FROM retail_eda
GROUP BY store, store_type, store_size
ORDER BY total_sales DESC
LIMIT 10;

# Top 10 by sales
SELECT
    dept,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales,
    ROUND(AVG(weekly_sales)::numeric, 2)
        AS average_sales
FROM retail_eda
GROUP BY dept
ORDER BY total_sales DESC
LIMIT 10;

# sales by type of store

SELECT
    store_type,
    COUNT(DISTINCT store) AS total_stores,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales,
    ROUND(AVG(weekly_sales)::numeric, 2)
        AS average_sales
FROM retail_eda
GROUP BY store_type
ORDER BY total_sales DESC;

## Holiday Season
# Perbandingan holiday dan non-holiday

SELECT
    CASE
        WHEN isholiday = TRUE THEN 'Holiday'
        WHEN isholiday = FALSE THEN 'Non-Holiday'
        ELSE 'Unknown'
    END AS holiday_status,
    COUNT(*) AS total_records,
    ROUND(AVG(weekly_sales)::numeric, 2)
        AS average_sales,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales
FROM retail_eda
GROUP BY isholiday
ORDER BY isholiday DESC NULLS LAST;

# Holidays by year
SELECT
    year,
    isholiday,
    ROUND(AVG(weekly_sales)::numeric, 2)
        AS average_sales,
    ROUND(SUM(weekly_sales)::numeric, 2)
        AS total_sales
FROM retail_eda
GROUP BY year, isholiday
ORDER BY year, isholiday DESC;

# Economic Conditions and Sales by Year
WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM date)::integer AS year,
        SUM(weekly_sales) AS total_sales
    FROM retail_eda
    GROUP BY 1
),
yearly_economy AS (
    SELECT
        EXTRACT(YEAR FROM date)::integer AS year,
        AVG(temperature) AS avg_temperature,
        AVG(fuel_price) AS avg_fuel_price,
        AVG(cpi) AS avg_cpi,
        AVG(unemployment) AS avg_unemployment
    FROM (
        SELECT DISTINCT
            store,
            date,
            temperature,
            fuel_price,
            cpi,
            unemployment
        FROM retail_eda
    ) AS unique_features
    GROUP BY 1
)
SELECT
    s.year,
    ROUND(e.avg_temperature::numeric, 2)
        AS avg_temperature,
    ROUND(e.avg_fuel_price::numeric, 2)
        AS avg_fuel_price,
    ROUND(e.avg_cpi::numeric, 2)
        AS avg_cpi,
    ROUND(e.avg_unemployment::numeric, 2)
        AS avg_unemployment,
    ROUND(s.total_sales::numeric, 2)
        AS total_sales
FROM yearly_sales s
LEFT JOIN yearly_economy e
    ON s.year = e.year
ORDER BY s.year;

