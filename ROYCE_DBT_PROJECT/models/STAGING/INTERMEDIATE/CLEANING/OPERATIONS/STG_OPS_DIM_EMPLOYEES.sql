{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_DIM_EMPLOYEES') }}

),

RENAMING_COLUMNS as (
    SELECT
         "employee_id"     as employee_id,
        "restaurant_id"   as restaurant_id,
        "first_name"      as first_name,
        "last_name"       as last_name,
        "job_role"        as job_role,
        "employment_type" as employment_type,
        "hire_date"       as hire_date,
        "hourly_rate"     as hourly_rate,
        "active_flag"     as active_flag
    from source

)

select *
from RENAMING_COLUMNS