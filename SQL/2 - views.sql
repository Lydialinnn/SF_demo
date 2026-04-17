use role accountadmin;
use warehouse compute_wh;
use schema SNOWFLAKE_LEARNING_DB.public;


-- standard view
create or replace view vw_customer as select * from customers

insert into customers values(1, 'dq', 55), (2, 'peter', 60),(3,'maria',55);

select * from vw_customer

-- secure view
create or replace secure view svw_customer as select *, 'lydia' as "last_touch_by" from customers

select * from svw_customer

-- role vs user

create user marketing_manager;
create user accounting_manager;

show users

-- create new role
create role marketing_analytics;
create role sales_analytics;

-- add the role to the user
grant role marketing_analytics to user ZHENGYAN
grant role sales_analytics to user ZHENGYAN

select current_role()
select current_secondary_roles()

-- grant role with databae and schema
grant usage on database SNOWFLAKE_LEARNING_DB to role marketing_analytics
grant usage on schema SNOWFLAKE_LEARNING_DB.public to role marketing_analytics


-- grant access to the secure view
grant select on view SNOWFLAKE_LEARNING_DB.public.svw_customer to role marketing_analytics

select * from SNOWFLAKE_LEARNING_DB.public.svw_customer

-- switch role to see the new rolw's access:
use role marketing_analytics
select * from SNOWFLAKE_LEARNING_DB.public.svw_customer
select get_ddl('view', 'SNOWFLAKE_LEARNING_DB.public.svw_customer')

-- now this role can still see the secure view
use role sales_analytics
select * from SNOWFLAKE_LEARNING_DB.public.svw_customer

-- remove the default secondary role for the account admin, and then log out
alter user ZHENGYAN set default_secondary_roles = ();

-- now run this, this role cannot see the secure view anymore
use role sales_analytics
select * from SNOWFLAKE_LEARNING_DB.public.svw_customer



-- Materilized view: physical storage, fast, pre-compute, one-to-one map to the table (cannot join)