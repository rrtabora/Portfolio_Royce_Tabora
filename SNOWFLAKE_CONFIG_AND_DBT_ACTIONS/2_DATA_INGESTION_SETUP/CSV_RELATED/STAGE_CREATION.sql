use role ROYCE_DATA_INGESTOR;
use database PORTFOLIO_DB_RAW;
use schema RAW;

create or replace stage CSV_LOAD_STAGE;


ALTER STAGE CSV_LOAD_STAGE REFRESH;