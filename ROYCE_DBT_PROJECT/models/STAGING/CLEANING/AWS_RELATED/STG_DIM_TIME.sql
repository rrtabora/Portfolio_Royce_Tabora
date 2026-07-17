{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_UNI_TIME') }}

),

RENAMING_COLUMNS as (
SELECT
    "TIME"          AS TIME_KEY,
    -- HOUR
    -- MINUTE
    -- SECOND
    -- -- AM_PM
    -- -- HOURLABEL
    -- -- MINUTELABEL
    -- -- SECONDLABEL
    -- TIMEKEY
    -- HOURBIN12
    -- HOURBIN8
    -- HOURBIN6
    -- HOURBIN4
    -- HOURBIN3
    -- HOURBIN2
    MINUTEBIN30     AS BIN_30_MINUTE,
    MINUTEBIN15     AS BIN_15_MINUTE,
    MINUTEBIN10     AS BIN_10_MINUTE,
    PARTOFTHEDAY    AS TIME_PART_OF_THE_DAY
    -- MINUTEBIN30V2
    from source

)

select *
from RENAMING_COLUMNS