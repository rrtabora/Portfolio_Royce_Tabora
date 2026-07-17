{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_DATE') }}

),

RENAMING_COLUMNS as (

    select
        DATEKEY             AS DATE_KEY,
        DAYOFWEEKNAME       AS DAY_OF_WEEK_NAME,
        DAYINWEEK           AS DAY_IN_WEEK,
        WEEKENDINGSUNDAY    AS WEEK_ENDING_SUNDAY,
        -- FYWEEKNUM           
        FY                  AS FY,
        FYWEEKID            AS FY_WEEK_ID,
        -- FYWEEKNAMELONG      
        FYQUARTER           AS FY_QUARTER,
        -- WEEKOFQUARTER     
        FYMONTHNAME         AS FY_MONTH_NAME, 
        FYMONTHID           AS FY_MONTH_ID
        -- FYWEEKNAMESHORT    
        -- MONTHNAME_ORDERED

    from source

)

select *
from RENAMING_COLUMNS