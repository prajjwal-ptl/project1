from pathlib import Path

import pandas as pd

DATA_PATH = Path(__file__).parents[1] / "data" / "demo_tickets.csv"


def test_demo_dataset_has_expected_columns_and_rows():
    data = pd.read_csv(DATA_PATH)
    expected = {
        "ticket_id",
        "created_at",
        "category",
        "priority",
        "status",
        "first_response_minutes",
        "resolution_minutes",
        "sla_breached",
        "sentiment",
        "agent",
    }
    assert expected.issubset(data.columns)
    assert len(data) >= 20
    assert data["ticket_id"].is_unique


def test_demo_durations_are_not_negative():
    data = pd.read_csv(DATA_PATH)
    for column in ["first_response_minutes", "resolution_minutes"]:
        values = pd.to_numeric(data[column], errors="coerce").dropna()
        assert (values >= 0).all()
