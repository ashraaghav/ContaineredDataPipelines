-- create a schema for the 'datastore' database
CREATE SCHEMA store;
SET SCHEMA 'store';

-- create table based on the structure of "./sample_data/testset_B.tsv"
CREATE TABLE products(
   id             TEXT    NOT NULL,
   brand          TEXT    NOT NULL,
   RAM_GB         INT,
   HDD_GB         INT,
   GHz            REAL,
   price          INT,
   CONSTRAINT products_pkey PRIMARY KEY (id));

-- create a temp table to avoid duplicate rows
CREATE TEMP TABLE tmp_table
AS
SELECT *
FROM products
WITH NO DATA;

-- copy file from TSV into temp table
COPY tmp_table
FROM '/docker-entrypoint-initdb.d/sample_data/testset_B.tsv'
DELIMITER E'\t'
CSV HEADER;

-- copy from temp table, ignoring duplicate rows
INSERT INTO products
SELECT DISTINCT ON (id) *
FROM tmp_table;

