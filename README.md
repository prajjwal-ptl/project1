# Support Ticket Triage and Analytics Dashboard

A portfolio project for analyzing customer-support tickets, measuring service-level agreement (SLA) performance, and exploring ticket classification with Python, PostgreSQL, scikit-learn, and Streamlit.

> **Current stage:** A runnable Streamlit demo is available using a small, hand-authored synthetic dataset. It is not the selected Hugging Face dataset, and its metrics are illustrative only. The database schema remains provisional until the real dataset is inspected.

## Try the demo locally

Requirements: Python 3.11+.

```bash
git clone https://github.com/prajjwal-ptl/project1.git
cd project1
python -m venv .venv

# Windows PowerShell
.venv\Scripts\Activate.ps1

# macOS/Linux (use this instead of the Windows command)
source .venv/bin/activate

pip install -r requirements.txt
streamlit run app.py
```

Streamlit will print a local address (usually `http://localhost:8501`) to open in your browser. No PostgreSQL connection or dataset download is required for this demo.

## Demo features

- Filters for category, priority, status, and created-date range
- KPI cards for tickets in view, illustrative SLA breach-flag rate, average resolution time, and average first-response time
- Ticket volume by category
- Average resolution time by category
- SLA breach-flag rate by priority
- Ticket volume by hour of day
- Filtered ticket table

## Demo-data warning

The bundled `data/demo_tickets.csv` contains synthetic examples created for interface demonstration. It is not extracted from the Hugging Face dataset and does not establish real customer-support performance. Do not present these values as measured business findings. The sample SLA flag is illustrative and is not a contractual SLA calculation.

## Repository structure

```text
.
├── app.py
├── data/
│   └── demo_tickets.csv
├── docs/
│   └── design-decisions.md
├── sql/
│   └── schema.sql
├── tests/
│   └── test_demo_data.py
├── .gitignore
├── requirements.txt
└── README.md
```

## Project goals

1. Inspect the selected public support-ticket dataset and confirm its actual files, fields, license, and quality.
2. Adapt and validate the PostgreSQL schema.
3. Build a documented cleaning and loading pipeline.
4. Write and explain SQL analytics.
5. Train and evaluate a leakage-aware category/priority classifier.
6. Extend the dashboard to use validated data.
7. Record evidence-backed business insights.
8. Add tests, screenshots, and complete run instructions.
9. Deploy the dashboard and document the live URL.

## Data source candidate

[Hugging Face support-ticket dataset](https://huggingface.co/datasets/s2pidape/support-ticket-dataset). Its available files, schema, license, row count, and labels must be inspected before use. Do not assume the source contains every field in the provisional SQL design.

## Tests

```bash
pytest
```

## Safety and reproducibility

- Never commit passwords, API keys, tokens, or local `.env` files.
- Avoid personal details unless essential; use public or synthetic data.
- Preserve source-provided SLA fields separately from independently calculated evaluations.
- Do not claim model performance or business findings until they are measured and documented.
