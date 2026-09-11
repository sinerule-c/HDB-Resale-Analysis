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

**The market/hawker indicator was unsuitable for price comparison because only 22 transactions matched the category, all involving small flats in the central area and concentrated in a single building. The observed price difference could not be separated from location and property-type effects.**
  <br>
  ### 2. Are flats in taller HDB buildings associated with higher resale price per sqm?

  
