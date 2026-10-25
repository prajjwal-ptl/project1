from pathlib import Path

import pandas as pd
import streamlit as st

st.set_page_config(
    page_title="Support Ticket Triage Demo",
    page_icon="🎫",
    layout="wide",
)

st.title("🎫 Support Ticket Triage & Analytics")
st.caption("Interactive portfolio demo • synthetic sample data only")

st.warning(
    "DEMO DATA ONLY: These rows are hand-authored synthetic examples, not records "
    "from the selected Hugging Face dataset. Metrics are illustrative and must not "
    "be presented as real company or dataset findings."
)

DATA_PATH = Path(__file__).parent / "data" / "demo_tickets.csv"


@st.cache_data
def load_demo_data(path: str) -> pd.DataFrame:
    """Load the bundled sample and derive simple, reproducible time dimensions."""
    data = pd.read_csv(path, parse_dates=["created_at"])
    data["created_hour"] = data["created_at"].dt.hour
    data["created_date"] = data["created_at"].dt.date
    data["sla_breached"] = data["sla_breached"].astype(bool)
    return data


df = load_demo_data(str(DATA_PATH))

with st.sidebar:
    st.header("Filters")
    categories = sorted(df["category"].dropna().unique().tolist())
    selected_categories = st.multiselect("Category", categories, default=categories)
    priorities = sorted(df["priority"].dropna().unique().tolist())
    selected_priorities = st.multiselect("Priority", priorities, default=priorities)
    statuses = sorted(df["status"].dropna().unique().tolist())
    selected_statuses = st.multiselect("Status", statuses, default=statuses)
    min_date = df["created_date"].min()
    max_date = df["created_date"].max()
    date_range = st.date_input(
        "Created date range",
        value=(min_date, max_date),
        min_value=min_date,
        max_value=max_date,
    )

filtered = df[
    df["category"].isin(selected_categories)
    & df["priority"].isin(selected_priorities)
    & df["status"].isin(selected_statuses)
].copy()

if isinstance(date_range, tuple) and len(date_range) == 2:
    start_date, end_date = date_range
    filtered = filtered[
        (filtered["created_date"] >= start_date)
        & (filtered["created_date"] <= end_date)
    ]

if filtered.empty:
    st.info("No tickets match these filters. Change the filters to see results.")
    st.stop()

resolved = filtered[filtered["resolution_minutes"].notna()]
breach_rate = filtered["sla_breached"].mean() * 100
avg_resolution = resolved["resolution_minutes"].mean() if not resolved.empty else None
avg_response = filtered["first_response_minutes"].mean()

col1, col2, col3, col4 = st.columns(4)
col1.metric("Tickets in view", f"{len(filtered):,}")
col2.metric("SLA breach flag rate", f"{breach_rate:.1f}%")
col3.metric(
    "Avg. resolution time",
    f"{avg_resolution:.0f} min" if pd.notna(avg_resolution) else "N/A",
)
col4.metric(
    "Avg. first response",
    f"{avg_response:.0f} min" if pd.notna(avg_response) else "N/A",
)

st.divider()
left, right = st.columns(2)

with left:
    st.subheader("Ticket volume by category")
    volume = (
        filtered.groupby("category", as_index=False)
        .agg(ticket_count=("ticket_id", "count"))
        .sort_values("ticket_count", ascending=False)
        .set_index("category")
    )
    st.bar_chart(volume)

with right:
    st.subheader("Average resolution time by category")
    if resolved.empty:
        st.info("No resolved tickets in the current selection.")
    else:
        resolution = (
            resolved.groupby("category", as_index=False)
            .agg(avg_resolution_minutes=("resolution_minutes", "mean"))
            .sort_values("avg_resolution_minutes", ascending=False)
            .set_index("category")
        )
        st.bar_chart(resolution)

left, right = st.columns(2)
with left:
    st.subheader("SLA breach-flag rate by priority")
    priority_sla = (
        filtered.groupby("priority", as_index=False)
        .agg(
            ticket_count=("ticket_id", "count"),
            breach_rate=("sla_breached", "mean"),
        )
    )
    priority_sla["breach_rate_percent"] = priority_sla["breach_rate"] * 100
    st.bar_chart(priority_sla.set_index("priority")[["breach_rate_percent"]])

with right:
    st.subheader("Tickets by hour of day")
    hourly = (
        filtered.groupby("created_hour", as_index=False)
        .agg(ticket_count=("ticket_id", "count"))
        .set_index("created_hour")
        .reindex(range(24), fill_value=0)
    )
    hourly.index.name = "Hour (24-hour clock)"
    st.line_chart(hourly)

with st.expander("View filtered ticket records"):
    st.dataframe(
        filtered.sort_values("created_at", ascending=False),
        use_container_width=True,
        hide_index=True,
    )

st.caption(
    "Interpretation note: the sample's SLA flag is illustrative. This demo does not "
    "calculate contractual SLA compliance or account for business hours, pauses, or holidays."
)
