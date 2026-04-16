1 - tables.sql

use role accountadmin;
use warehouse compute_wh;
use schema SNOWFLAKE_LEARNING_DB.public;

show tables;

-- 1. table: time travel/ retention_date: max to 90 days, fail-save (7 days)
-- used for production data
create table customers (
id int,
name string,
age int
)


describe table customers

alter table SNOWFLAKE_LEARNING_DB.public.customers set data_retention_time_in_days = 30
-- only enterprice version can set the retention time to 30 days, this account cannot changed


-- 2. transient table: time travel/ retention_date: only 1 day, no fail-save
-- used for staging, intermediate models

create transient table trans_customers(
id int,
name string,
age int
)

alter table SNOWFLAKE_LEARNING_DB.public.customers set data_retention_time_in_days = 1
-- transient table can only have 1 day as retention date


-- 3. temporary table: no time travel, no fail-save
-- gone nice the session end
create temporary table temp_customers(
id int,
name string,
age int
)


-- external table