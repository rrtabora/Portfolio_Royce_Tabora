-- Staging model for OPS_DIM_SUPPLIERS: selects and renames columns from raw supplier data
-- Co-authored with CoCo
{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_DIM_SUPPLIERS') }}

),

renaming_columns as (
    select
        supplier_id,
        supplier_name,
        supplier_category,
        state,
        standard_lead_time_days,
        supplier_rating,
        active_flag
    from source
)

select *
from renaming_columns