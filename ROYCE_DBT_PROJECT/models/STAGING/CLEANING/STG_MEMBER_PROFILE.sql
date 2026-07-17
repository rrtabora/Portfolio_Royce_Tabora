{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('RAW_DATA', 'AWS_ROYCE_SAMPLE_MEMBERS') }}

),

RENAMING_COLUMNS as (

    select
        RECID               AS MEMBER_ID,
        DATEOFBIRTH         AS DATE_BIRTH,
        REGISTRATIONDATE    AS DATE_REGISTRATION,
        CREATIONDATE        AS DATE_CREATION,
        EXPIRYDATE          AS DATE_EXPIRY,
        "NAME"              AS MEMBER_NAME

    from source

)

select *
from RENAMING_COLUMNS