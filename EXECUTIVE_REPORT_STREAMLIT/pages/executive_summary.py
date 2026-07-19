# Executive Sales Overview page with KPIs, trends, and performance visuals
# Co-authored with CoCo
import streamlit as st
import pandas as pd
import altair as alt

st.set_page_config(page_title="Executive Summary", layout="wide")
st.title("Executive Sales Overview")

conn = st.connection("snowflake")
session = conn.session()

# --- Load data ---
@st.cache_data(ttl=600)
def load_summary_data():
    df = session.sql("""
        SELECT
            f.TRANSACTION_DATE,
            f.STORE_ID,
            f.STATE,
            f.SALES_CHANNEL,
            f.SALES_TYPE,
            COALESCE(st.SALES_TYPE_NAME, CAST(f.SALES_TYPE AS VARCHAR)) AS SALES_TYPE_NAME,
            f.AMOUNT_NET,
            f.AMOUNT_NET_MEMBER,
            f.TRANSACTION_COUNT,
            f.TRANSACTION_COUNT_MEMBER
        FROM PORTFOLIO_DB.MARTS.AWS_FACT_STATS_SUMMARY f
        LEFT JOIN PORTFOLIO_DB.MARTS.V_DIM_SALES_TYPE st
            ON f.SALES_TYPE = st.SALES_TYPE_ID
    """).to_pandas()
    df["TRANSACTION_DATE"] = pd.to_datetime(df["TRANSACTION_DATE"])
    return df

df = load_summary_data()

# --- Date filter ---
min_date = df["TRANSACTION_DATE"].min().date()
max_date = df["TRANSACTION_DATE"].max().date()
col_f1, col_f2 = st.columns(2)
with col_f1:
    start_date = st.date_input("Start Date", value=min_date, min_value=min_date, max_value=max_date)
with col_f2:
    end_date = st.date_input("End Date", value=max_date, min_value=min_date, max_value=max_date)

filtered = df[(df["TRANSACTION_DATE"] >= pd.Timestamp(start_date)) & (df["TRANSACTION_DATE"] <= pd.Timestamp(end_date))]

# --- KPI Cards ---
total_net_sales = filtered["AMOUNT_NET"].sum()
total_transactions = filtered["TRANSACTION_COUNT"].sum()
avg_transaction_value = total_net_sales / total_transactions if total_transactions > 0 else 0
member_sales_pct = (filtered["AMOUNT_NET_MEMBER"].sum() / total_net_sales * 100) if total_net_sales > 0 else 0
member_txn_pct = (filtered["TRANSACTION_COUNT_MEMBER"].sum() / total_transactions * 100) if total_transactions > 0 else 0
active_stores = filtered["STORE_ID"].nunique()

# Previous period calculation
period_days = (pd.Timestamp(end_date) - pd.Timestamp(start_date)).days + 1
prev_start = pd.Timestamp(start_date) - pd.Timedelta(days=period_days)
prev_end = pd.Timestamp(start_date) - pd.Timedelta(days=1)
prev = df[(df["TRANSACTION_DATE"] >= prev_start) & (df["TRANSACTION_DATE"] <= prev_end)]
prev_net_sales = prev["AMOUNT_NET"].sum()
prev_transactions = prev["TRANSACTION_COUNT"].sum()
sales_growth = ((total_net_sales - prev_net_sales) / prev_net_sales * 100) if prev_net_sales > 0 else 0
txn_growth = ((total_transactions - prev_transactions) / prev_transactions * 100) if prev_transactions > 0 else 0

st.divider()
k1, k2, k3, k4 = st.columns(4)
k1.metric("Total Net Sales", f"${total_net_sales:,.0f}", f"{sales_growth:+.1f}% vs prev period")
k2.metric("Total Transactions", f"{total_transactions:,.0f}", f"{txn_growth:+.1f}% vs prev period")
k3.metric("Avg Transaction Value", f"${avg_transaction_value:,.2f}")
k4.metric("Active Stores", f"{active_stores}")

k5, k6, k7, k8 = st.columns(4)
k5.metric("Member Sales %", f"{member_sales_pct:.1f}%")
k6.metric("Member Transaction %", f"{member_txn_pct:.1f}%")
k7.metric("Net Sales vs Prev Period", f"{sales_growth:+.1f}%")
k8.metric("Transaction Growth %", f"{txn_growth:+.1f}%")

st.divider()

# --- 1. Net Sales and Transactions Trend (Combo Chart) ---
st.subheader("1. Net Sales and Transactions Trend")
daily = filtered.groupby("TRANSACTION_DATE").agg(
    TOTAL_NET_SALES=("AMOUNT_NET", "sum"),
    TOTAL_TRANSACTIONS=("TRANSACTION_COUNT", "sum")
).reset_index()

base = alt.Chart(daily).encode(x=alt.X("TRANSACTION_DATE:T", title="Date"))
bars = base.mark_bar(opacity=0.6, color="#4C78A8").encode(
    y=alt.Y("TOTAL_NET_SALES:Q", title="Net Sales ($)", axis=alt.Axis(titleColor="#4C78A8"))
)
line = base.mark_line(color="#E45756", strokeWidth=2).encode(
    y=alt.Y("TOTAL_TRANSACTIONS:Q", title="Transactions", axis=alt.Axis(titleColor="#E45756"))
)
combo = alt.layer(bars, line).resolve_scale(y="independent").properties(height=350)
st.altair_chart(combo, use_container_width=True)

# --- 2. Sales by State (Horizontal Bar) ---
st.subheader("2. Sales by State")
state_df = filtered.groupby("STATE").agg(
    TOTAL_NET_SALES=("AMOUNT_NET", "sum"),
    TOTAL_TRANSACTIONS=("TRANSACTION_COUNT", "sum"),
    MEMBER_SALES=("AMOUNT_NET_MEMBER", "sum")
).reset_index()
state_df["AVG_TXN_VALUE"] = state_df["TOTAL_NET_SALES"] / state_df["TOTAL_TRANSACTIONS"]
state_df["MEMBER_SALES_PCT"] = state_df["MEMBER_SALES"] / state_df["TOTAL_NET_SALES"] * 100

state_chart = alt.Chart(state_df).mark_bar().encode(
    y=alt.Y("STATE:N", sort="-x", title="State"),
    x=alt.X("TOTAL_NET_SALES:Q", title="Net Sales ($)"),
    tooltip=[
        alt.Tooltip("STATE:N"),
        alt.Tooltip("TOTAL_NET_SALES:Q", title="Net Sales", format="$,.0f"),
        alt.Tooltip("TOTAL_TRANSACTIONS:Q", title="Transactions", format=","),
        alt.Tooltip("AVG_TXN_VALUE:Q", title="Avg Txn Value", format="$,.2f"),
        alt.Tooltip("MEMBER_SALES_PCT:Q", title="Member Sales %", format=".1f")
    ]
).properties(height=300)
st.altair_chart(state_chart, use_container_width=True)

# --- 3. Sales by Sales Type ---
st.subheader("3. Sales by Sales Type")
type_df = filtered.groupby("SALES_TYPE_NAME").agg(
    TOTAL_NET_SALES=("AMOUNT_NET", "sum")
).reset_index()

type_chart = alt.Chart(type_df).mark_arc(innerRadius=50).encode(
    theta=alt.Theta("TOTAL_NET_SALES:Q"),
    color=alt.Color("SALES_TYPE_NAME:N", title="Sales Type"),
    tooltip=[
        alt.Tooltip("SALES_TYPE_NAME:N", title="Sales Type"),
        alt.Tooltip("TOTAL_NET_SALES:Q", title="Net Sales", format="$,.0f")
    ]
).properties(height=350)
st.altair_chart(type_chart, use_container_width=True)

# --- 4. Member vs Non-Member Sales (Stacked Column) ---
st.subheader("4. Member vs Non-Member Sales")
member_daily = filtered.groupby("TRANSACTION_DATE").agg(
    MEMBER_NET_SALES=("AMOUNT_NET_MEMBER", "sum"),
    TOTAL_NET_SALES=("AMOUNT_NET", "sum")
).reset_index()
member_daily["NON_MEMBER_NET_SALES"] = member_daily["TOTAL_NET_SALES"] - member_daily["MEMBER_NET_SALES"]
member_melt = member_daily[["TRANSACTION_DATE", "MEMBER_NET_SALES", "NON_MEMBER_NET_SALES"]].melt(
    id_vars="TRANSACTION_DATE", var_name="Category", value_name="Net Sales"
)
member_melt["Category"] = member_melt["Category"].map({
    "MEMBER_NET_SALES": "Member",
    "NON_MEMBER_NET_SALES": "Non-Member"
})

member_chart = alt.Chart(member_melt).mark_bar().encode(
    x=alt.X("TRANSACTION_DATE:T", title="Date"),
    y=alt.Y("Net Sales:Q", title="Net Sales ($)"),
    color=alt.Color("Category:N", scale=alt.Scale(domain=["Member", "Non-Member"], range=["#4C78A8", "#E45756"])),
    tooltip=[
        alt.Tooltip("TRANSACTION_DATE:T", title="Date"),
        alt.Tooltip("Category:N"),
        alt.Tooltip("Net Sales:Q", format="$,.0f")
    ]
).properties(height=350)
st.altair_chart(member_chart, use_container_width=True)

# --- 5. Top 10 Stores (Horizontal Bar) ---
st.subheader("5. Top 10 Stores")
store_df = filtered.groupby("STORE_ID").agg(
    TOTAL_NET_SALES=("AMOUNT_NET", "sum")
).reset_index().nlargest(10, "TOTAL_NET_SALES")
store_df["STORE_ID"] = store_df["STORE_ID"].astype(str)

store_chart = alt.Chart(store_df).mark_bar().encode(
    y=alt.Y("STORE_ID:N", sort="-x", title="Store ID"),
    x=alt.X("TOTAL_NET_SALES:Q", title="Net Sales ($)"),
    tooltip=[
        alt.Tooltip("STORE_ID:N", title="Store"),
        alt.Tooltip("TOTAL_NET_SALES:Q", title="Net Sales", format="$,.0f")
    ]
).properties(height=350)
st.altair_chart(store_chart, use_container_width=True)

# --- 6. Executive Performance Matrix ---
st.subheader("6. Executive Performance Matrix")
matrix_df = filtered.groupby(["STATE", "STORE_ID"]).agg(
    TOTAL_NET_SALES=("AMOUNT_NET", "sum"),
    TOTAL_TRANSACTIONS=("TRANSACTION_COUNT", "sum"),
    MEMBER_SALES=("AMOUNT_NET_MEMBER", "sum")
).reset_index()
matrix_df["AVG_TXN_VALUE"] = matrix_df["TOTAL_NET_SALES"] / matrix_df["TOTAL_TRANSACTIONS"]
matrix_df["MEMBER_SALES_PCT"] = matrix_df["MEMBER_SALES"] / matrix_df["TOTAL_NET_SALES"] * 100
active_days = filtered.groupby("STORE_ID")["TRANSACTION_DATE"].nunique().reset_index()
active_days.columns = ["STORE_ID", "ACTIVE_DAYS"]
matrix_df = matrix_df.merge(active_days, on="STORE_ID", how="left")
matrix_df["SALES_PER_ACTIVE_DAY"] = matrix_df["TOTAL_NET_SALES"] / matrix_df["ACTIVE_DAYS"]

display_matrix = matrix_df[["STATE", "STORE_ID", "TOTAL_NET_SALES", "TOTAL_TRANSACTIONS",
                             "AVG_TXN_VALUE", "MEMBER_SALES_PCT", "SALES_PER_ACTIVE_DAY"]].sort_values(
    "TOTAL_NET_SALES", ascending=False
)
display_matrix.columns = ["State", "Store ID", "Net Sales ($)", "Transactions",
                           "Avg Txn Value ($)", "Member Sales %", "Sales per Active Day ($)"]

st.dataframe(
    display_matrix.style.background_gradient(subset=["Net Sales ($)", "Avg Txn Value ($)", "Sales per Active Day ($)"], cmap="Greens")
                        .background_gradient(subset=["Member Sales %"], cmap="Blues"),
    use_container_width=True,
    height=400
)
