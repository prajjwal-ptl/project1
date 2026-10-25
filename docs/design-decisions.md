# Design Decisions

## Status

This is the initial design record. Decisions that depend on the source data remain provisional until the selected dataset is inspected.

## Dataset choice

The current candidate is the [Hugging Face support-ticket dataset](https://huggingface.co/datasets/s2pidape/support-ticket-dataset). Before implementing the pipeline, verify the dataset card, license, configurations and files, field names, row counts, and whether labels and SLA information are genuinely present. Record any changes here.

## PostgreSQL model

The initial relational design separates:

- **categories** so category names can be referenced consistently;
- **agents** for agent/team reporting, if the source contains usable agent fields;
- **sla_rules** for response and resolution targets;
- **tickets** for ticket-level source data and selected derived values;
- **sla_evaluations** for separately auditable first-response and resolution outcomes.

The model is deliberately normalized for lookups. It may be simplified or altered if the real dataset lacks these concepts or contains different identifiers.

## Source values versus derived values

Source-provided values should not be silently overwritten. In particular, keep source SLA flags distinct from independently calculated SLA evaluations. Record formulas, assumptions, and any disagreements between them.

Durations should be checked against timestamp differences. Negative durations, impossible timestamp order, missing values, duplicates, and inconsistent status values must be investigated rather than blindly coerced or dropped.

## SLA interpretation

The provisional labels are:

- `met`: sufficient evidence shows elapsed time is within the target;
- `breached`: sufficient evidence shows the target was exceeded;
- `pending`: the ticket remains open and its deadline has not passed;
- `unknown`: required evidence is missing or unreliable.

The first implementation may use elapsed calendar minutes only if that matches the dataset's semantics. Business hours, holidays, paused tickets, and time-zone policies must not be assumed without evidence.

## Machine-learning safeguards

- Establish a simple baseline before choosing a more complex model.
- Split data before fitting preprocessing steps to avoid leakage.
- Keep post-outcome fields (such as resolution time, resolved timestamp, or final status when inappropriate) out of features that would not be available at prediction time.
- Report class balance and suitable metrics, not accuracy alone.
- Do not claim sentiment ground truth if the dataset does not provide trustworthy sentiment labels. Any generated labels must be identified as weak/provisional labels and evaluated separately.

## Data minimization

Avoid generating or displaying customer names, emails, or other personal details unless essential. Prefer synthetic/public data and aggregated reporting. Never commit secrets or local environment files.

## Reproducibility

Keep dependency versions in `requirements.txt`, add tests as pipeline components are implemented, and document commands and measured results in the README. Do not add made-up metrics, screenshots, or business findings.
