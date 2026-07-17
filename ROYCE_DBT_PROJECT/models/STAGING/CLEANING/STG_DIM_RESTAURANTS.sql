{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_RESTAURANTS') }}

),

RENAMING_COLUMNS as (

    select
        STORE_ID            AS STORE_ID,
        ORIGINAL_NAME       AS STORE_NAME,
        REGION              AS STATE,
        OWNERSHIP_TYPE      AS OWNERSHIP_TYPE,
        LATITUDE            AS LATITUDE,
        LONGITUDE           AS LONGITUDE

    from source

)

select *
from RENAMING_COLUMNS