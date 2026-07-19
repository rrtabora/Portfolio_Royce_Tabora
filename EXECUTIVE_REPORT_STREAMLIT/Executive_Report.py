# Front page for the Executive Report Streamlit app with navigation buttons
# Co-authored with CoCo
import streamlit as st

st.set_page_config(page_title="Executive Report", layout="wide")

st.title("Executive Report")
st.write("This report serves as executive summary of the business performance.")

st.divider()

col1, col2 = st.columns(2)

with col1:
    if st.button("Executive Summary", use_container_width=True):
        st.switch_page("pages/executive_summary.py")
    if st.button("Customer Member Analysis", use_container_width=True):
        st.switch_page("pages/customer_member_analysis.py")
    if st.button("Trading Time Analysis", use_container_width=True):
        st.switch_page("pages/trading_time_analysis.py")

with col2:
    if st.button("Store Performance", use_container_width=True):
        st.switch_page("pages/store_performance.py")
    if st.button("Channel and Sales Types Analysis", use_container_width=True):
        st.switch_page("pages/channel_and_sales_type_analysis.py")
    if st.button("Holiday Impact Analysis", use_container_width=True):
        st.switch_page("pages/holiday_impact_analysis.py")
