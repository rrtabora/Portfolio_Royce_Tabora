{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_EMPLOYEE_SHIFTS') }}

),

RENAMING_COLUMNS as (
SELECT
    "shift_id"                    as shift_id,
"shift_date"                  as shift_date,
"restaurant_id"               as restaurant_id,
"employee_id"                 as employee_id,
"job_role"                    as job_role,
"scheduled_start_time"        as scheduled_start_time,
"scheduled_end_time"          as scheduled_end_time,
"scheduled_hours"             as scheduled_hours,
"actual_hours"                as actual_hours,
"regular_hours"               as regular_hours,
"overtime_hours"              as overtime_hours,
"hourly_rate"                 as hourly_rate,
"labour_cost"                 as labour_cost,
"absence_flag"                as absence_flag,
"no_show_flag"                as no_show_flag
    from source

)

select *
from RENAMING_COLUMNS