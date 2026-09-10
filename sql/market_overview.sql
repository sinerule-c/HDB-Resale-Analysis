-- 1. Overall market summary
SELECT
	COUNT(*) AS total_transactions,
    COUNT(DISTINCT town) AS number_of_towns,
    COUNT(DISTINCT flat_type) AS number_of_flat_types,
    MIN(sale_month) AS first_month,
    MAX(sale_month) AS latest_month,
    ROUND(AVG(resale_price), 2) AS average_resale_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm,
    MIN(resale_price) AS lowest_resale_price,
    MAX(resale_price) AS highest_resale_price
FROM hdb_resale;

-- 2. Transactions by flat type
SELECT
	flat_type,
    COUNT(*) AS total_transactions,
    ROUND(
		COUNT(*)/ SUM(COUNT(*)) OVER() * 100,
        2
	) AS percentage_of_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY flat_type
ORDER BY total_transactions DESC;

-- 3. Transactions by town
SELECT
	town,
    COUNT(*) AS total_transactions,
    ROUND(
		COUNT(*)/ SUM(COUNT(*)) OVER() * 100,
        2
	) AS percentage_of_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY town
ORDER BY total_transactions DESC;

-- 4. Monthly market trend (Exclude September 2026 because it is an incomplete month.
SELECT
	sale_month,
    COUNT(*) AS total_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
WHERE sale_month < '2026-09-01'
GROUP BY sale_month
ORDER BY sale_month;

-- 5. Full-year comparison (Because 2026 is incomplete, compare only 2017-2025)
SELECT
	YEAR(sale_month) AS sale_year,
    COUNT(*) AS total_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
WHERE sale_month < '2026-01-01'
GROUP BY sale_year
ORDER BY sale_year;

-- 6. Year-over-year growth
WITH yearly_market AS (
	SELECT
		YEAR(sale_month) AS sale_year,
        COUNT(*) AS total_transactions,
        AVG(price_per_sqm) AS average_price_per_sqm
	FROM hdb_resale
    WHERE sale_month < '2026-01-01'
    GROUP BY sale_year
),
yearly_comparison AS (
	SELECT
		*,
        LAG(average_price_per_sqm) OVER (
			ORDER BY sale_year
		) AS previous_year_price
	FROM yearly_market
)
SELECT
	sale_year,
    total_transactions,
    ROUND(average_price_per_sqm, 2) AS average_price_per_sqm,
    ROUND(
		(average_price_per_sqm - previous_year_price)
        / previous_year_price * 100,
        2
	) AS yoy_price_growth_pct
FROM yearly_comparison
ORDER BY sale_year;

-- 7. Most and least expensive towns
SELECT
	town,
    COUNT(*) AS total_transactions,
    ROUND(AVG(resale_price), 2) AS average_resale_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY town
ORDER BY average_price_per_sqm DESC;

-- 8. Town rankings within each flat type
WITH town_flat_summary AS (
	SELECT
		town,
        flat_type,
        COUNT(*) AS total_transactions,
        AVG(price_per_sqm) AS average_price_per_sqm
	FROM hdb_resale
    GROUP BY town, flat_type
)
SELECT
	town,
    flat_type,
    total_transactions,
    ROUND(average_price_per_sqm, 2) AS average_price_sqm,
    DENSE_RANK() OVER (
		PARTITION BY flat_type
        ORDER BY average_price_per_sqm DESC
	) AS town_rank
FROM town_flat_summary
ORDER BY flat_type, town_rank;

-- 9. Affordable but active towns
WITH town_market AS (
	SELECT
		town,
        COUNT(*) AS total_transactions,
        AVG(price_per_sqm) AS average_price_per_sqm
	FROM hdb_resale
    GROUP BY town
)
SELECT
	town,
    total_transactions,
    ROUND(average_price_per_sqm, 2) AS average_price_per_sqm
FROM town_market
WHERE average_price_per_sqm <
	(SELECT AVG(price_per_sqm) FROM hdb_resale)
ORDER BY total_transactions DESC;

-- 10. Flat-type comparison
SELECT
	flat_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(floor_area_sqm), 2) AS average_floor_area,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY flat_type
ORDER BY average_price;

-- 11. Storey premium
SELECT
	storey_range,
    COUNT(*) AS total_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY storey_range
ORDER BY
	CAST(SUBSTRING_INDEX(storey_range, ' TO ', 1) AS UNSIGNED);

-- 12. Flat-model comparison
SELECT
	flat_model,
    COUNT(*) AS total_transactions,
    ROUND(AVG(floor_area_sqm), 2) AS average_floor_area,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY flat_model
ORDER BY average_price_per_sqm DESC;

-- 13. Property age
SELECT
	CASE
		WHEN YEAR(sale_month) - lease_commence_year < 10
			THEN 'Under 10 years'
		WHEN YEAR(sale_month) - lease_commence_year < 20
			THEN '10-19 years'
		WHEN YEAR(sale_month) - lease_commence_year < 30
			THEN '20-29 years'
		WHEN YEAR(sale_month) - lease_commence_year < 40
			THEN '30-39 years'
		ELSE '40 years and above'
	END AS property_age_group,
    COUNT(*) AS total_transactions,
    ROUND(AVG(resale_price), 2) AS average_price,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale
GROUP BY property_age_group
ORDER BY MIN(YEAR(sale_month) - lease_commence_year);

-- 14. Million-dollar transactions by year
SELECT
	YEAR(sale_month) AS sale_year,
    COUNT(*) AS million_dollar_transactions
FROM hdb_resale
WHERE resale_price >= 1000000
GROUP BY YEAR(sale_month)
ORDER BY sale_year;

-- 15. Where million-dollar transactions occur
SELECT
	town,
    flat_type,
    COUNT(*) AS million_dollar_transactions,
    ROUND(AVG(resale_price), 2) AS average_price
FROM hdb_resale
WHERE resale_price >= 1000000
GROUP BY town, flat_type
ORDER BY million_dollar_transactions DESC;
