{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_SALE_CHANNEL') }}

),

RENAMING_COLUMNS as (

    select
        RECID           AS SALES_CHANNEL_ID,
        -- BITMASK
        -- PROVIDERCODE
        PROVIDERNAME    AS SALES_CHANNEL_NAME
        -- PKQ_PRIORITY

    from source

)

select *
from RENAMING_COLUMNS