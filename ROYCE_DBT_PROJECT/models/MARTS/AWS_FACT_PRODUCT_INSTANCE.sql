{{ config(
    materialized = 'table',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}

with transaction_items as (

    select *
    from {{ ref('STG_PRODUCT_DATA') }}

),

fact_instance as (

    select
        transaction_id,

        --Unique instance within the transaction 
        plu_code_partitioner                       as instance_id,
        plu_code_parent_bucket                     as plu_code_parent,

        --Get ITEM_ID only from the parent row 
        max(
            case
                when plu_code_child = plu_code_parent_bucket
                then item_id
            end
        )                                          as parent_item_id,

        max(member_id)                             as member_id,
        max(store_id)                              as store_id,
        max(transaction_date)                      as transaction_date,
        max(transaction_time_binned_30)            as transaction_time_binned_30,
        -- max(transaction_time)                      as transaction_time,

        --Quantity must only come from the parent row
        sum(
            case
                when plu_code_child = plu_code_parent_bucket
                then quantity
                else 0
            end
        )                                          as quantity,

        --Includes parent price plus charged modifiers
        sum(amount_gross)                          as amount_gross,
        sum(amount_gst)                            as amount_gst,
        sum(amount_net)                            as amount_net,

        max(sales_type)                            as sales_type,
        max(sales_channel)                         as sales_channel
        -- max(pos_user)                              as pos_user

    from transaction_items

    group by
        transaction_id,
        plu_code_partitioner,
        plu_code_parent_bucket

)

select *
from fact_instance
-- where transaction_id = 94072205 --TESTING