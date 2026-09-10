-- Preview the first 10 transactions
SELECT *
FROM hdb_resale_raw
LIMIT 10;

-- Check the date range
SELECT
	MIN(month) AS first_month,
    MAX(month) AS latest_month
FROM hdb_resale_raw;

-- Check missing values
SELECT
    SUM(month IS NULL OR TRIM(month) = '') AS missing_month,
    SUM(town IS NULL OR TRIM(town) = '') AS missing_town,
    SUM(flat_type IS NULL OR TRIM(flat_type) = '') AS missing_flat_type,
    SUM(block IS NULL OR TRIM(block) = '') AS missing_block,
    SUM(street_name IS NULL OR TRIM(street_name) = '') AS missing_street_name,
    SUM(storey_range IS NULL OR TRIM(storey_range) = '') AS missing_storey_range,
    SUM(floor_area_sqm IS NULL OR TRIM(floor_area_sqm) = '') AS missing_floor_area,
    SUM(flat_model IS NULL OR TRIM(flat_model) = '') AS missing_flat_model,
    SUM(lease_commence_date IS NULL OR TRIM(lease_commence_date) = '') AS missing_lease_commence_date,
    SUM(remaining_lease IS NULL OR TRIM(remaining_lease) = '') AS missing_remaining_lease,
    SUM(resale_price IS NULL OR TRIM(resale_price) = '') AS missing_price
FROM hdb_resale_raw;

-- Create the cleaned table
CREATE TABLE hdb_resale (
	transaction_id INT AUTO_INCREMENT PRIMARY KEY,
	sale_month DATE NOT NULL,
    town VARCHAR(50) NOT NULL,
    flat_type VARCHAR (30),
    block VARCHAR(10),
    street_name VARCHAR(100),
    storey_range VARCHAR(20),
    floor_area_sqm DECIMAL (8,2),
    flat_model VARCHAR(50),
    lease_commence_year SMALLINT,
    remaining_lease VARCHAR(30),
    resale_price DECIMAL(12,2),
    price_per_sqm DECIMAL(10,2)
);

INSERT INTO hdb_resale (
	sale_month,
    town,
    flat_type,
    block,
    street_name,
    storey_range,
    floor_area_sqm,
    flat_model,
    lease_commence_year,
    remaining_lease,
    resale_price,
    price_per_sqm
)
SELECT
	STR_TO_DATE(CONCAT(TRIM(month), '-01'), '%Y-%m-%d'),
    UPPER(TRIM(town)),
    UPPER(TRIM(flat_type)),
    TRIM(block),
    UPPER(TRIM(street_name)),
    UPPER(TRIM(storey_range)),
    CAST(floor_area_sqm AS DECIMAL(8,2)),
    UPPER(TRIM(flat_model)),
    CAST(lease_commence_date AS UNSIGNED),
    TRIM(remaining_lease),
    CAST(resale_price AS DECIMAL(12,2)),
    ROUND(
		CAST(resale_price AS DECIMAL(12,2))
        / CAST(floor_area_sqm AS DECIMAL(8,2)),
        2
	)
FROM hdb_resale_raw;
