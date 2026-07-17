{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_PRODUCT_ITEMS') }}

),

RENAMING_COLUMNS as (

    select
        "plucode"           AS PLU_CODE,
        "plumodifier"       AS PLU_MODIFIER,
        "Product Name"      AS PLU_NAME,
        "Protein"           AS PLU_PROTEIN,
        "Level 1 Category"  AS CATEGORY_LEVEL_1,
        "Level 2 Category"  AS CATEGORY_LEVEL_2,
        "Level 3 Category"  AS CATEGORY_LEVEL_3,
        "Size"              AS PLU_SIZE

    from source

)

select *
from RENAMING_COLUMNS