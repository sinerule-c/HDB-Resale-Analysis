### 1. Do transactions in HDB blocks with a market or hawker facility have different average prices?

```
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
```
| market_hawker | total_transactions | average_resale_price | average_price_per_sqm |
|-|-|-|-|
| Y	| 22 | 373682.77 | 6676.36 |
| N |	240048 |	534769.12 |	5592.33 |

**The groups are far too imbalanced for a strong conclusion.**<br>
The market/hawker group has:
- A much lower total resale price
- Approximately 19.4% higher price per sqm
- Only 22 transactions

Lower total price but higher price per sqm usually suggests that these flats are smaller.
<br>

### Investigate the 22 transactions
```
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
```
| town | flat_type | total_transactions | number_of_blocks | average_floor_area | average_resale_price | average_price_per_sqm |
|-|-|-|-|-|-|-|
| CENTRAL AREA | 2 ROOM | 17 | 1 | 53.29 | 363001.24 | 6812.91 |
| CENTRAL AREA | 3 ROOM | 5 | 1 | 66.00 | 410000.00 | 6212.12 |

**The market/hawker group is not a fair comparison.**<br>
- All 22 transactions are in the central area.
- They represent only one building within each flat-type result, likely the same building.
- They are exclusively small 2-room and 3-room flats.
- Central area location likely explains the high price per sqm.
- Small floor area explains the lower total resale price.

*The market/hawker indicator was unsuitable for price comparison because only 22 transactions matched the category, all involving small flats in the central area and concentrated in a single building. The observed price difference could not be separated from location and property-type effects.*
<br>
### 2. Are flats in taller HDB buildings associated with higher resale price per sqm?

```
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
```
| building_height_group | total_transactions | number_of_blocks | average_floor_area | average_resale_price | average_price_per_sqm |
|-|-|-|-|-|-|
| 12 floors and below | 80059 | 4190 | 93.55 | 456731.95 | 4919.77 |
| 13-24 floors | 132212 | 4817 | 98.57 | 539240.47 | 5543.51 |
| 25 floors and above | 27799 | 736 | 96.76 | 738117.01	| 7762.34 |

**The tallest group has the highest average price per sqm, also has a substantial sample.**
<br>
However, we cannot yet conclude that taller buildings cause higher prices. Tall buildings may be:
- Located in more expensive towns.
- Newer
- Sold more recently
- More likely to contain high-floor units
- Different flat models

### Compare only 4-room Model A flats sold in 2025:
```
SELECT
    CASE
        WHEN i.max_floor_lvl <= 12 THEN '12 floors and below'
        WHEN i.max_floor_lvl <= 24 THEN '13-24 floors'
        ELSE '25 floors and above'
    END AS building_height_group,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT CONCAT(i.blk_no, '|', i.street)) AS number_of_blocks,
    ROUND(AVG(r.floor_area_sqm), 2) AS average_floor_area,
    ROUND(AVG(YEAR(r.sale_month) - r.lease_commence_year), 2) AS average_property_age,
    ROUND(
        AVG((CAST(SUBSTRING_INDEX(r.storey_range, ' TO ', 1) AS UNSIGNED)
			+ CAST(SUBSTRING_INDEX(r.storey_range, ' TO ', -1) AS UNSIGNED)) / 2
        ), 2) AS average_storey,
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
```
| building_height_group | total_transactions | number_of_blocks | average_floor_area | average_property_age | average_storey | average_resale_price | average_price_per_sqm |
|-|-|-|-|-|-|-|-|
| 12 floors and below | 1561 | 935 | 103.63 | 32.93 | 6.26 | 600742.68 | 5809.62 |
| 13-24 floors | 4415 | 1711 | 95.68 | 15.82 | 8.85 | 673194.26 | 7060.21 |
| 25 floors and above | 1204 | 349 | 92.55 | 13.46 | 16.69 | 898052.50 | 9736.83 |

The taller-building group is:
- Almost 20 years newer than the low-rise group
- Selling units approximately 10 floors higher
- Probably concentrated in different towns
- Slightly smaller in floor area
<br>
Therefore, the premium could be caused by location, property age or unit storey, rather than building height itself.
  
