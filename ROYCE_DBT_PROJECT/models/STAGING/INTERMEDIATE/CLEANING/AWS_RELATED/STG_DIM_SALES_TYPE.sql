{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_SALE_TYPE') }}

),

RENAMING_COLUMNS as (
    SELECT 
        SALE_TYPE           AS SALES_TYPE_ID,
        -- SALE_TYPE_LABEL    
        DESCRIPTION          AS SALES_TYPE_NAME

    from source

)

select *
from RENAMING_COLUMNS