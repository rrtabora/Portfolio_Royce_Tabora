{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_DIM_SUPPLIERS') }}

),

RENAMING_COLUMNS as (
SELECT
    "supplier_id"                 as supplier_id,
"supplier_name"               as supplier_name,
"supplier_category"           as supplier_category,
"state"                       as state,
"standard_lead_time_days"     as standard_lead_time_days,
"supplier_rating"             as supplier_rating,
"active_flag"                 as active_flag
    from source

)

select *
from RENAMING_COLUMNS