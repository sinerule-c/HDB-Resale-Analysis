-- 1. Do transactions in HDB blocks with a market or hawker facility have different average prices?
SELECT
	i.market_hawker,
    COUNT(*) AS total_transactions,
    ROUND(AVG(r.resale_price), 2) AS average_resale_price,
    ROUND(AVG(r.price_per_sqm), 2) As average_price_per_sqm
FROM hdb_resale AS r
JOIN hdb_information AS i
	ON r.block = i.blk_no
		AND r.street_name = i.street
GROUP BY i.market_hawker
ORDER BY average_price_per_sqm DESC;

-- Investigate the 22 transactions
SELECT
	r.town,
    r.flat_type,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT CONCAT(i.blk_no, '|', i.street)) AS number_of_blocks,
    ROUND(AVG(r.floor_area_sqm), 2) AS average_floor_area,
    ROUND(AVG(r.resale_price), 2) AS average_resale_price,
    ROUND(AVG(r.price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale r
JOIN hdb_information i
	ON r.block = i.blk_no
		AND r.street_name = i.street
WHERE i.market_hawker = 'Y'
GROUP BY r.town, r.flat_type
ORDER BY total_transactions DESC;

-- Are flats in taller HDB buildings associated with higher resale prices per square metre?
SELECT
	CASE
		WHEN i.max_floor_lvl <= 12 THEN '12 floors and below'
        WHEN i.max_floor_lvl <= 24 THEN '13-24 floors'
        ELSE '25 floors and above'
	END AS building_height_group,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT CONCAT(i.blk_no, '|', i.street)) AS number_of_blocks,
    ROUND(AVG(r.floor_area_sqm), 2) AS average_floor_area,
    ROUND(AVG(r.resale_price), 2) AS average_resale_price,
    ROUND(AVG(r.price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale r
JOIN hdb_information i
	ON r.block = i.blk_no
		AND r.street_name = i.street
GROUP BY building_height_group
ORDER BY MIN(i.max_floor_lvl);

-- Compare only 4-room Model A flats sold in 2025:
SELECT
    CASE
        WHEN i.max_floor_lvl <= 12 THEN '12 floors and below'
        WHEN i.max_floor_lvl <= 24 THEN '13-24 floors'
        ELSE '25 floors and above'
    END AS building_height_group,
    COUNT(*) AS total_transactions,
    COUNT(
        DISTINCT CONCAT(i.blk_no, '|', i.street)
    ) AS number_of_blocks,
    ROUND(AVG(r.floor_area_sqm), 2) AS average_floor_area,
    ROUND(
        AVG(YEAR(r.sale_month) - r.lease_commence_year),
        2
    ) AS average_property_age,
    ROUND(
        AVG(
            (
                CAST(
                    SUBSTRING_INDEX(r.storey_range, ' TO ', 1)
                    AS UNSIGNED
                )
                +
                CAST(
                    SUBSTRING_INDEX(r.storey_range, ' TO ', -1)
                    AS UNSIGNED
                )
            ) / 2
        ),
        2
    ) AS average_storey,
    ROUND(AVG(r.resale_price), 2) AS average_resale_price,
    ROUND(AVG(r.price_per_sqm), 2) AS average_price_per_sqm
FROM hdb_resale r
JOIN hdb_information i
    ON r.block = i.blk_no
   AND r.street_name = i.street
WHERE r.flat_type = '4 ROOM'
  AND r.flat_model = 'MODEL A'
  AND r.sale_month >= '2025-01-01'
  AND r.sale_month < '2026-01-01'
GROUP BY building_height_group
ORDER BY MIN(i.max_floor_lvl);