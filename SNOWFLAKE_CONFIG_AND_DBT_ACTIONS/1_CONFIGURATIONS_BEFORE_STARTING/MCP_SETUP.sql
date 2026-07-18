USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE MCP SERVER
    PORTFOLIO_DB.PUBLIC.PORTFOLIO_ROYCE_TABORA_MCP_SERVER
FROM SPECIFICATION
$$
tools:

  - title: "Portfolio Executive Summary"
    name: "portfolio-executive-summary"
    type: "CORTEX_ANALYST_MESSAGE"
    identifier: "PORTFOLIO_DB.SEMANTIC.SV_EXECUTIVE_SUMMARY"
    description: >
      Answers business questions about restaurant sales,
      transactions, members, products, stores, channels,
      customer reviews and executive performance metrics
      using the approved semantic view.

  - title: "Products Summary"
    name: "portfolio-products-summary"
    type: "CORTEX_ANALYST_MESSAGE"
    identifier: "PORTFOLIO_DB.SEMANTIC.SV_PRODUCTS_SUMMARY"
    description: >
      Answers natural-language questions about product sales,
      product quantities, parent products, child modifiers,
      gross sales, net sales, GST, transactions, members,
      sales channels, and product performance.

  - title: "Operations Summary"
    name: "portfolio-operations-summary"
    type: "CORTEX_ANALYST_MESSAGE"
    identifier: "PORTFOLIO_DB.SEMANTIC.SV_OPERATIONS_SUMMARY"
    description: >
      Answers natural-language questions about restaurant operations,
      store performance, transactions, trading periods, staffing,
      labour, inventory, suppliers, operational KPIs, and trends.
$$;


show mcp server PORTFOLIO_ROYCE_TABORA_MCP_SERVER

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE SECURITY INTEGRATION PORTFOLIO_ROYCE_TABORA_MCP_OAUTH
    TYPE = OAUTH
    OAUTH_CLIENT = CUSTOM
    ENABLED = TRUE
    OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
    OAUTH_REDIRECT_URI = 'https://claude.ai/api/mcp/auth_callback'
    OAUTH_ISSUE_REFRESH_TOKENS = TRUE
    OAUTH_REFRESH_TOKEN_VALIDITY = 86400
    OAUTH_USE_SECONDARY_ROLES = NONE
    COMMENT = 'OAUTH INTEGRATION FOR PORTFOLIO MCP SERVER';


SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS(
    'PORTFOLIO_ROYCE_TABORA_MCP_OAUTH'
);
