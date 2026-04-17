use role accountadmin;
use warehouse compute_wh;
use schema SNOWFLAKE_LEARNING_DB.public;


show stages;
list @STG_SF2603_INTERNAL;

-- copy from table to stage
copy into @STG_SF2603_INTERNAL/customer
from SNOWFLAKE_LEARNING_DB.PUBLIC.CUSTOMERS
file_format = (
    type = "csv"
    field_delimiter = ","
    compression = 'NONE'
)
header = TRUE
OVERWRITE = True

-- or define the file format first:
create or replace file format csv_fileformat
type = "csv"
field_delimiter = ","
compression = 'NONE'
skip_header = 1

-- truncate the table first
truncate table SNOWFLAKE_LEARNING_DB.PUBLIC.CUSTOMERS

-- copy from stage to table
copy into SNOWFLAKE_LEARNING_DB.PUBLIC.CUSTOMERS
from @STG_SF2603_INTERNAL/customer
file_format = (format_name = 'csv_fileformat')

-- direct select from the stage file (all values are string type)
select $1 as ID, $2 as Name, $3 as Age
from @STG_SF2603_INTERNAL/customer
(file_format => 'csv_fileformat');


-- snowsql in CLI (to get/ put stage from/ to local to snowflake stage)