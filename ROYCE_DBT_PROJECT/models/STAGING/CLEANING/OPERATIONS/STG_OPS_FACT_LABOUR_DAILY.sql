{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_LABOUR_DAILY') }}

),

renaming_columns as (

    select
        "work_date"                as work_date,
        "restaurant_id"            as restaurant_id,
        "scheduled_hours"          as scheduled_hours,
        "actual_hours"             as actual_hours,
        "regular_hours"            as regular_hours,
        "overtime_hours"           as overtime_hours,
        "labour_cost"              as labour_cost,
        "absence_count"            as absence_count,
        "estimated_sales"          as estimated_sales,
        "labour_cost_pct_of_sales" as labour_cost_pct_of_sales,
        "sales_per_labour_hour"    as sales_per_labour_hour
    from source

)

select *
from renaming_columns