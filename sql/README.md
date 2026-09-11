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

**The groups are far too imbalanced for a strong conclusion.**
The market/hawker group has:
- A much lower total resale price
- Approximately 19.4% higher price per sqm
- Only 22 transactions

Lower total price but higher price per sqm usually suggests that these flats are smaller.
