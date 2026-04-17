



use role accountadmin;
use warehouse compute_wh;
use schema SNOWFLAKE_LEARNING_DB.public;


-- load data from S3 to snowflake tables, and snowflake tables to s3:

-- 1. directly load from external stage to TABLE (in aws, this step is created with user)
COPY INTO SNOWFLAKE_LEARNING_DB.PUBLIC.po_list_init 
from 's3://sf-2603-0415/ext_stage/po_list_short_init.csv'
CREDENTIALS = (AWS_KEY_ID = id,  AWS_SECRET_KEY = key)
FILE_FORMAT = SNOWFLAKE_LEARNING_DB.PUBLIC.CSV_FILEFORMAT; 


-- 2. import the stage (external), create table, copy into ...table... from ... the imported stage...
CREATE OR REPLACE STAGE SNOWFLAKE_LEARNING_DB.PUBLIC.my_s3_stage
  URL = 's3://sf-2603-0415/ext_stage/'
CREDENTIALS = (AWS_KEY_ID = id,  AWS_SECRET_KEY = key)
  -- STORAGE_INTEGRATION = s3_integration
  FILE_FORMAT = SNOWFLAKE_LEARNING_DB.PUBLIC.CSV_FILEFORMAT; 

CREATE OR REPLACE TABLE SNOWFLAKE_LEARNING_DB.PUBLIC.po_list_init (
    ID STRING,
    BlindReceipt BOOLEAN,
    OrderNumber STRING,
    Status STRING,
    OrderDate date,
    InvoiceDate date,
    Supplier STRING,
    SupplierID STRING,
    InvoiceNumber STRING,
    InvoiceAmount NUMBER,
    PaidAmount NUMBER,
    BaseCurrency STRING,
    SupplierCurrency STRING,
    OrderStatus STRING,
    StockReceivedStatus STRING,
    UnstockStatus STRING,
    InvoiceStatus STRING,
    LastUpdatedDate  date,
    Type STRING,
    CombinedInvoiceStatus STRING,
    CombinedPaymentStatus STRING,
    CombinedReceivingStatus  STRING,
    db_refreshed_at TIMESTAMP
);

CREATE OR REPLACE TEMPORARY FILE FORMAT 
SNOWFLAKE_LEARNING_DB.PUBLIC.temp_raw_ff 
TYPE = 'CSV' FIELD_DELIMITER = 'NONE' SKIP_HEADER = 0

ALTER FILE FORMAT SNOWFLAKE_LEARNING_DB.PUBLIC.CSV_FILEFORMAT 
SET FIELD_OPTIONALLY_ENCLOSED_BY = '"' ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE

COPY INTO SNOWFLAKE_LEARNING_DB.PUBLIC.po_list_init 
FROM @SNOWFLAKE_LEARNING_DB.PUBLIC.my_s3_stage FILES = ('po_list_short_init.csv') FORCE = TRUE

-- truncate SNOWFLAKE_LEARNING_DB.PUBLIC.po_list_init


-- 3. load the snowflake table to the external stage ()
copy into @SNOWFLAKE_LEARNING_DB.PUBLIC.my_s3_stage/download
from SNOWFLAKE_LEARNING_DB.PUBLIC.po_list_init 
file_format = SNOWFLAKE_LEARNING_DB.PUBLIC.CSV_FILEFORMAT
header = TRUE
overwrite = True


list @SNOWFLAKE_LEARNING_DB.PUBLIC.my_s3_stage


-- even better approach:  Storage Integration

-- 1. create an AWS service role
-- 2. create a S3 integration/ Storage Integration (The "IAM Bridge")


-- This is a one-time "Account-level" object that tells Snowflake how to authenticate with your AWS account without using secrets.
-- Run this as ACCOUNTADMIN or a role with CREATE INTEGRATION privileges
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://sf-2603-0415/ext_stage/')
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::644724502277:role/sf2603-service-role';

-- After running this, run DESC STORAGE INTEGRATION s3_integration;. You will need to take the STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID and paste them into your AWS IAM Role's Trust Relationship. This is exactly like setting up a cross-account service account in GCP.
DESC STORAGE INTEGRATION s3_integration

-- 3. link them together: update aws role - trust relationship - edit: STORAGE_AWS_IAM_USER_ARN, STORAGE_AWS_EXTERNAL_ID based on snowflake's info

-- 4. use integration to create the stage
create or replace stage SNOWFLAKE_LEARNING_DB.PUBLIC.stg_s3_integration
url = 's3://sf-2603-0415/ext_stage/'
storage_integration = s3_integration

list @SNOWFLAKE_LEARNING_DB.PUBLIC.stg_s3_integration