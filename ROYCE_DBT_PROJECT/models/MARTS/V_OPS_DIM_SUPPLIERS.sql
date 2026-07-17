{{ config(
    materialized = 'view',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}


    select *
    from {{ ref('STG_OPS_DIM_SUPPLIERS') }}
