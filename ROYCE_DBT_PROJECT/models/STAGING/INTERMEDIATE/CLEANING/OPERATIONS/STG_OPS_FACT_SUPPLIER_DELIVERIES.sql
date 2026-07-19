

{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_SUPPLIER_DELIVERIES') }}

),

RENAMING_COLUMNS as (
SELECT
    "delivery_id"                 as delivery_id,
"purchase_order_id"           as purchase_order_id,
"supplier_id"                 as supplier_id,
"restaurant_id"               as restaurant_id,
"product_id"                  as product_id,
"promised_delivery_date"      as promised_delivery_date,
"actual_delivery_date"        as actual_delivery_date,
"ordered_qty"                 as ordered_qty,
"received_qty"                as received_qty,
"rejected_qty"                as rejected_qty,
"accepted_qty"                as accepted_qty,
"delivery_delay_days"         as delivery_delay_days,
"on_time_flag"                as on_time_flag,
"in_full_flag"                as in_full_flag,
"otif_flag"                   as otif_flag,
"quality_score"               as quality_score
    from source

)

select *
from RENAMING_COLUMNS