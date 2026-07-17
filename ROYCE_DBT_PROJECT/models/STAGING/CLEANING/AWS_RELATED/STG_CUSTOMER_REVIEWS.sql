{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_RESTAURANT_REVIEWS') }}

),

RENAMING_COLUMNS as (

    select
        REVIEW_ID           AS REVIEW_ID,
        STORE_ID            AS STORE_ID,
        REVIEW_TEXT         AS REVIEW_TEXT,
        RATING              AS REVIEW_RATING,
        "SOURCE"            AS REVIEW_SOURCE,
        REVIEW_DATE         AS REVIEW_DATE

    from source

)

select *
from RENAMING_COLUMNS