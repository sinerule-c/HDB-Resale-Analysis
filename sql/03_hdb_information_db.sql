USE hdb_resale_analysis;

-- Prepare to import the CSV
CREATE TABLE hdb_information_raw (
	blk_no VARCHAR(10),
    street VARCHAR(100),
    max_floor_lvl VARCHAR(10),
    year_completed VARCHAR(10),
    residential VARCHAR(10),
    commercial VARCHAR(10),
    market_hawker VARCHAR(10),
    miscellaneous VARCHAR(10),
    multistorey_carpark VARCHAR(10),
    precinct_pavilion VARCHAR(10),
    bldg_contract_town VARCHAR(10),
    total_dwelling_units VARCHAR(10),
    `1room_sold` VARCHAR(10),
    `2room_sold` VARCHAR(10),
    `3room_sold` VARCHAR(10),
    `4room_sold` VARCHAR(10),
    `5room_sold` VARCHAR(10),
    exec_sold VARCHAR(10),
    multigen_sold VARCHAR(10),
    studio_apartment_sold VARCHAR(10),
    `1room_rental` VARCHAR(10),
    `2room_rental` VARCHAR(10),
    `3room_rental` VARCHAR(10),
    other_room_rental VARCHAR(10)
);

--
SELECT *
FROM hdb_information_raw
LIMIT 10;

-- Check missing values
SELECT
	SUM(blk_no IS NULL OR TRIM(blk_no) = '') AS missing_blk_no,
    SUM(street IS NULL OR TRIM(street) = '') AS missing_street,
    SUM(max_floor_lvl IS NUll OR TRIM(max_floor_lvl) = '') AS missing_max_floor_lvl,
    SUM(year_completed IS NULL OR TRIM(year_completed) = '') AS missing_year_completed,
    SUM(residential IS NULL OR TRIM(residential) = '') AS missing_residential,
    SUM(commercial IS NULL OR TRIM(commercial) = '') AS missing_commercial,
    SUM(market_hawker IS NULL OR TRIM(market_hawker) = '') AS missing_market_hawker,
    SUM(miscellaneous IS NULL OR TRIM(miscellaneous) = '') AS missing_miscellaneous,
    SUM(multistorey_carpark IS NULL OR TRIM(multistorey_carpark) = '') AS missing_multistorey_carpark,
    SUM(precinct_pavilion IS NULL OR TRIM(precinct_pavilion) = '') AS missing_precinct_pavilion,
    SUM(bldg_contract_town IS NULL OR TRIM(bldg_contract_town) = '') AS missing_bldg_contract_town,
    SUM(total_dwelling_units IS NULL OR TRIM(total_dwelling_units) = '') AS missing_total_dwelling_units,
    SUM(`1room_sold` IS NULL OR TRIM(`1room_sold`) = '') AS missing_1room_sold,
    SUM(`2room_sold` IS NULL OR TRIM(`2room_sold`) = '') AS missing_2room_sold,
    SUM(`3room_sold` IS NULL OR TRIM(`3room_sold`) = '') AS missing_3room_sold,
    SUM(`4room_sold` IS NULL OR TRIM(`4room_sold`) = '') AS missing_4room_sold,
    SUM(`5room_sold` IS NULL OR TRIM(`5room_sold`) = '') AS missing_5room_sold,
    SUM(exec_sold IS NULL OR TRIM(exec_sold) = '') AS missing_exec_sold,
    SUM(multigen_sold IS NULL OR TRIM(multigen_sold) = '') AS missing_multigen_sold,
    SUM(studio_apartment_sold IS NULL OR TRIM(studio_apartment_sold) = '') AS missing_studio_apartment_sold,
    SUM(`1room_rental` IS NULL OR TRIM(`1room_rental`) = '') AS missing_1room_rental,
    SUM(`2room_rental` IS NULL OR TRIM(`2room_rental`) = '') AS missing_2room_rental,
    SUM(`3room_rental` IS NULL OR TRIM(`3room_rental`) = '') AS missing_3room_rental,
    SUM(other_room_rental IS NULL OR TRIM(other_room_rental) = '') AS missing_other_room_rental
FROM hdb_information_raw;

-- Create the cleaned table
CREATE TABLE hdb_information (
	property_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	blk_no VARCHAR(10) NOT NULL,
    street VARCHAR(100) NOT NULL,
    max_floor_lvl SMALLINT,
    year_completed SMALLINT,
    residential CHAR(1),
    commercial CHAR(1),
    market_hawker CHAR(1),
    miscellaneous CHAR(1),
    multistorey_carpark CHAR(1),
    precinct_pavilion CHAR(1),
    bldg_contract_town VARCHAR(10),
    total_dwelling_units INT UNSIGNED,
    one_room_sold INT UNSIGNED,
    two_room_sold INT UNSIGNED,
    three_room_sold INT UNSIGNED,
    four_room_sold INT UNSIGNED,
    five_room_sold INT UNSIGNED,
    exec_sold INT UNSIGNED,
    multigen_sold INT UNSIGNED,
    studio_apartment_sold INT UNSIGNED,
    one_room_rental INT UNSIGNED,
    two_room_rental INT UNSIGNED,
    three_room_rental INT UNSIGNED,
    other_room_rental INT UNSIGNED,
    INDEX idx_hdb_address (blk_no, street)
);

--
INSERT INTO hdb_information (
	blk_no,
    street,
    max_floor_lvl,
    year_completed,
    residential,
    commercial,
    market_hawker,
    miscellaneous,
    multistorey_carpark,
    precinct_pavilion,
    bldg_contract_town,
    total_dwelling_units,
    one_room_sold,
    two_room_sold,
    three_room_sold,
    four_room_sold,
    five_room_sold,
    exec_sold,
    multigen_sold,
    studio_apartment_sold,
    one_room_rental,
    two_room_rental,
    three_room_rental,
    other_room_rental
)
SELECT
	TRIM(blk_no),
    UPPER(TRIM(street)),
    CAST(NULLIF(TRIM(max_floor_lvl), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(year_completed), '') AS UNSIGNED),
    UPPER(TRIM(residential)),
    UPPER(TRIM(commercial)),
    UPPER(TRIM(market_hawker)),
    UPPER(TRIM(miscellaneous)),
    UPPER(TRIM(multistorey_carpark)),
    UPPER(TRIM(precinct_pavilion)),
    UPPER(TRIM(bldg_contract_town)),
    CAST(NULLIF(TRIM(total_dwelling_units), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`1room_sold`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`2room_sold`), '') AS UNSIGNED),
	CAST(NULLIF(TRIM(`3room_sold`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`4room_sold`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`5room_sold`), '') AS UNSIGNED),
	CAST(NULLIF(TRIM(exec_sold), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(multigen_sold), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(studio_apartment_sold), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`1room_rental`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`2room_rental`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(`3room_rental`), '') AS UNSIGNED),
    CAST(NULLIF(TRIM(other_room_rental), '') AS UNSIGNED)
FROM hdb_information_raw;