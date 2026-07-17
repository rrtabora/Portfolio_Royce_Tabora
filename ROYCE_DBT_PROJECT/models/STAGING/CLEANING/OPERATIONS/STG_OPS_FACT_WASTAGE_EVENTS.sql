{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_WASTAGE_EVENTS') }}

),

renaming_columns as (

    select
        "wastage_event_id" as wastage_event_id,
        "event_date"        as event_date,
        "restaurant_id"     as restaurant_id,
        "product_id"        as product_id,
        "wastage_reason"    as wastage_reason,
        "wastage_qty"       as wastage_qty,
        "unit_cost"         as unit_cost,
        "wastage_cost"      as wastage_cost
    from source

)

select *
from renaming_columns