{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_PRODUCTS_DATA') }}

),

RENAMING_COLUMNS as (

    select
        cast(_COL_1 as number(38, 0))          as TRANSACTION_ID,
        cast(_COL_2 as number(38, 0))          as ITEM_ID,
        cast(_COL_3 as number(38, 0))          as MEMBER_ID,
        cast(_COL_4 as number(38, 0))          as STORE_ID,
        cast(_COL_5 as date)                   as TRANSACTION_DATE,
        cast(_COL_6 as time)                   as TRANSACTION_TIME_BINNED_30,
        cast(_COL_7 as time)                   as TRANSACTION_TIME,
        cast(_COL_8 as number(38, 0))          as PLU_CODE_CHILD,
        cast(_COL_9 as number(38, 0))          as PL_CODE_PARENT,
        cast(_COL_10 as number(38, 0))         as PLU_CODE_PARTITIONER,
        cast(_COL_11 as number(38, 0))         as PLU_CODE_PARENT_BUCKET,
        cast(_COL_12 as number(15, 5))         as QUANTITY_PARTITIONER,
        cast(_COL_13 as number(11, 2))         as PRICE,
        cast(_COL_14 as number(15, 5))         as QUANTITY,
        cast(_COL_15 as number(26, 7))         as AMOUNT_GROSS,
        cast(_COL_16 as number(17, 7))         as AMOUNT_GST,
        cast(_COL_17 as number(27, 7))         as AMOUNT_NET,
        cast(_COL_18 as number(38, 0))         as SALES_TYPE,
        cast(_COL_19 as number(38, 0))         as SALES_CHANNEL,
        cast(_COL_20 as number(38, 0))         as POS_USER

    from source

)

select *
from RENAMING_COLUMNS