use role accountadmin;
use warehouse compute_wh;
use schema sf2603.public;


CREATE OR REPLACE TASK copy_task
--  WAREHOUSE = my_wh
  SCHEDULE = '1 MINUTE'
AS
copy into sf2603.public.customers
from @sf2603.public.dq_stg_integration_s3_external
file_format = 'CSV_FILEFORMAT';
show tasks;
ALTER TASK copy_task RESUME;
ALTER TASK copy_task SUSPEND;


create pipe sf2603.public.pipe_customers auto_ingest=true as
copy into sf2603.public.customers
from @sf2603.public.dq_stg_integration_s3_external
file_format = 'CSV_FILEFORMAT';

show file formats;
show stages;
desc pipe sf2603.public.pipe_customers;
-- notification_channel arn:aws:sqs:us-east-1:612990353424:sf-snowpipe-AIDAY5OISQAINJR5HS2H7-ldXWbFvXTvC92F-qYoSw9A


select * from sf2603.public.customers;
truncate table sf2603.public.customers;