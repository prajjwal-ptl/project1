# Support Ticket Triage and Analytics Dashboard

A portfolio project for analyzing customer-support tickets, measuring service-level agreement (SLA) performance, and exploring ticket classification with Python, PostgreSQL, scikit-learn, and Streamlit.

> **Project status:** Initial repository setup. The database schema is provisional until the selected Hugging Face dataset's actual files, columns, and data quality have been inspected. No model metrics or business findings are claimed yet.

## Goals

- Inspect and clean a public support-ticket dataset with reproducible Python code.
- Store ticket records and supporting reference data in PostgreSQL.
- Analyze ticket volume by category, resolution time, SLA performance, and busy periods.
- Build and honestly evaluate a ticket category/priority classifier.
- Present useful filters, metrics, and charts in a Streamlit dashboard.
- Document decisions, limitations, tests, and reproducible run instructions.

## Planned stack

- Python 3.11+
- pandas and NumPy
- PostgreSQL
- scikit-learn
- Streamlit
- pytest

## Repository structure

```text
.
├── docs/
│   └── design-decisions.md
├── sql/
│   └── schema.sql
├── src/                 # Data pipeline, analysis, model, and dashboard will be added in later stages
├── tests/               # Tests will be added alongside implementation
├── .gitignore
├── requirements.txt
└── README.md
```

## Data source

Selected candidate: [Hugging Face support-ticket dataset](https://huggingface.co/datasets/s2pidape/support-ticket-dataset).

Before using it for analysis, inspect the dataset card, available configurations/files, schema, licensing, missingness, duplicates, timestamp validity, and whether SLA labels/targets are present. Do not assume all expected columns exist. Use a manageable sample first rather than loading a potentially large dataset into memory at once.

## Initial database design

The provisional schema in [sql/schema.sql](sql/schema.sql) contains:

- `categories`: normalized category lookup
- `agents`: agent/team lookup
- `sla_rules`: response and resolution targets by priority
- `tickets`: ticket-level source and derived fields
- `sla_evaluations`: auditable, separate first-response and resolution SLA evaluations

The schema must be revised after inspecting the real dataset. Preserve source-provided SLA fields separately from independently calculated results.

## Planned workflow

1. Inspect the dataset and confirm its license and actual columns.
2. Adapt and validate the PostgreSQL schema.
3. Build a documented cleaning and loading pipeline.
4. Write and explain the core SQL analytics.
5. Train and evaluate a leakage-aware classifier.
6. Build the Streamlit dashboard.
7. Record evidence-backed business insights.
8. Add tests, screenshots, and complete run instructions.
9. Deploy the dashboard and document its live URL.

## Setup

Create and activate a virtual environment, then install dependencies:

```bash
python -m venv .venv
# Windows PowerShell:
.venv\Scripts\Activate.ps1
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
```

Set PostgreSQL connection details through environment variables or a local, untracked `.env` file. Never commit passwords, API keys, tokens, or real customer data.

## Current limitations

- Dataset fields and licensing have not yet been verified in code.
- SQL schema is a starting design, not a validated mapping to the source dataset.
- Cleaning, analytics, model training, dashboard, tests, and deployment are not implemented yet.
- No performance numbers or business conclusions should be reported until measured from the data.
