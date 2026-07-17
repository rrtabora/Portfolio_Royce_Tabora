{{ config(
    materialized = 'table',
    database = 'PORTFOLIO_DB',
    schema = 'MARTS'
) }}



WITH MAPPER_ AS (

    SELECT
        TRY_TO_DATE(D.DATE_KEY) AS DATE_KEY,
        R.STORE_ID,
        R.STATE
    FROM {{ ref('STG_DIM_DATE') }} D
    CROSS JOIN {{ ref('STG_DIM_RESTAURANTS') }} R
    WHERE TRY_TO_DATE(D.DATE_KEY)
          BETWEEN DATE '2024-01-01' AND DATE '2026-12-31'

)

, MAPPED_HOLIDAY AS (
    SELECT
        m.*,
        p.holiday_name
    FROM mapper_ m
    LEFT JOIN {{ ref('STG_DIM_PUBLIC_HOLIDAYS') }} p
        ON 
        m.date_key = TRY_TO_DATE(p.holiday_date, 'DD/MM/YYYY')
        AND 
        m.state = p.state
)




SELECT 
M.*,
SUM(P.AMOUNT_NET) AS AMOUNT_NET,
SUM(P.AMOUNT_GROSS) AS AMOUNT_GROSS,
SUM(P.AMOUNT_GST) AS AMOUNT_GST,
COUNT(DISTINCT P.TRANSACTION_ID) AS TRANSACTION_COUNT
FROM MAPPED_HOLIDAY M
LEFT JOIN {{ ref('STG_PRODUCT_DATA') }} P
ON 
P.STORE_ID = M.STORE_ID
AND
P.TRANSACTION_DATE = M.DATE_KEY
GROUP BY
M.DATE_KEY,
M.STORE_ID,
M.STATE,
M.HOLIDAY_NAME