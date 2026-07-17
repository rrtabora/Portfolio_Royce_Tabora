{{ config(
    materialized = 'view',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}


    select *
    from {{ ref('STG_DIM_SALES_CHANNEL') }}
