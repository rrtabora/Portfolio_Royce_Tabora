{{ config(
    materialized = 'table',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}


    select *
    from {{ ref('STG_CUSTOMER_REVIEWS_SENTIMENT') }}
