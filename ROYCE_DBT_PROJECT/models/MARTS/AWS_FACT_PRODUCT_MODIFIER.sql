{{ config(
    materialized = 'table',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}
with transaction_items as (

    select *
    from {{ ref('STG_PRODUCT_DATA') }}
    -- FROM PORTFOLIO_DB.STAGING.STG_PRODUCT_DATA -- FOR TESTING
),

fact_modifier as (

    select
        transaction_id,

        --Links modifier back to FACT_INSTANCE
        plu_code_partitioner                       as instance_id,

        plu_code_parent_bucket                     as plu_code_parent,
        plu_code_child                             as plu_code_child,

        item_id                                    as modifier_item_id,

        member_id,
        store_id,
        transaction_date,
        transaction_time_binned_30,
        -- transaction_time,

        quantity                                   as modifier_quantity,
        price                                      as modifier_price,
        amount_gross                               as amount_gross,
        amount_gst                                 as amount_gst,
        amount_net                                 as amount_net,

        sales_type,
        sales_channel
        -- pos_user

    from transaction_items

    /* Exclude the parent product row */
    where plu_code_child <> plu_code_parent_bucket

)

select *
from fact_modifier
-- WHERE transaction_id = 94072205 -- FOR TESTING