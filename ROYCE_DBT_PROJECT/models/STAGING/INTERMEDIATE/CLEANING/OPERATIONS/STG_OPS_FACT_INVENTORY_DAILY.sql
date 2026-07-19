

{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'OPS_FACT_INVENTORY_DAILY') }}

),

RENAMING_COLUMNS as (
SELECT
   "snapshot_date"               as snapshot_date,
"restaurant_id"               as restaurant_id,
"product_id"                  as product_id,
"opening_stock_qty"           as opening_stock_qty,
"received_qty"                as received_qty,
"usage_qty"                   as usage_qty,
"wastage_qty"                 as wastage_qty,
"adjustment_qty"              as adjustment_qty,
"closing_stock_qty"           as closing_stock_qty,
"reorder_point_qty"           as reorder_point_qty,
"target_stock_qty"            as target_stock_qty,
"unit_cost"                   as unit_cost,
"inventory_value"             as inventory_value,
"stockout_flag"               as stockout_flag,
"below_reorder_flag"          as below_reorder_flag
    from source

)

select *
from RENAMING_COLUMNS