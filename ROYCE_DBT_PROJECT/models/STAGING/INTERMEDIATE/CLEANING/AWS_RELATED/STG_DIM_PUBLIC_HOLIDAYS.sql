{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_AU_HOLIDAYS') }}

),

RENAMING_COLUMNS as (

    select
        "DATE"                  AS HOLIDAY_DATE,
        STATE                   AS STATE,
        PUBLIC_HOLIDAY_NAME     AS HOLIDAY_NAME

    from source

)

select *
from RENAMING_COLUMNS