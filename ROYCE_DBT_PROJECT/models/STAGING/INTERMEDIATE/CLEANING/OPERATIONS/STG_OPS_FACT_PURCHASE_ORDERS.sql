

{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_PURCHASE_ORDERS') }}

),

RENAMING_COLUMNS as (
SELECT
    "purchase_order_id"           as purchase_order_id,
"order_date"                  as order_date,
"restaurant_id"               as restaurant_id,
"supplier_id"                 as supplier_id,
"product_id"                  as product_id,
"ordered_qty"                 as ordered_qty,
"unit_cost"                   as unit_cost,
"order_value"                 as order_value,
"promised_delivery_date"      as promised_delivery_date,
"purchase_order_status"       as purchase_order_status
    from source

)

select *
from RENAMING_COLUMNS