-- Support Ticket Triage and Analytics Dashboard
-- PROVISIONAL: validate and adapt these fields after inspecting the chosen dataset.
-- PostgreSQL 14+ recommended.
-- Source-provided SLA fields must be preserved separately from calculated evaluations.

BEGIN;

CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS agents (
    agent_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_name VARCHAR(200) NOT NULL,
    team_name VARCHAR(150),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_agents_name_team UNIQUE (agent_name, team_name)
);

CREATE TABLE IF NOT EXISTS sla_rules (
    sla_rule_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    priority VARCHAR(20) NOT NULL UNIQUE,
    first_response_target_minutes INTEGER NOT NULL,
    resolution_target_minutes INTEGER NOT NULL,
    CONSTRAINT valid_sla_priority
        CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT positive_first_response_target
        CHECK (first_response_target_minutes > 0),
    CONSTRAINT positive_resolution_target
        CHECK (resolution_target_minutes > 0)
);

CREATE TABLE IF NOT EXISTS tickets (
    ticket_id VARCHAR(150) PRIMARY KEY,
    subject TEXT,
    description TEXT,
    category_id INTEGER REFERENCES categories(category_id),
    agent_id INTEGER REFERENCES agents(agent_id),
    sla_rule_id INTEGER REFERENCES sla_rules(sla_rule_id),

    -- Keep source and model outputs separate; do not overwrite source labels.
    original_priority VARCHAR(20),
    predicted_priority VARCHAR(20),
    predicted_category_id INTEGER REFERENCES categories(category_id),
    sentiment VARCHAR(20),

    created_at TIMESTAMPTZ,
    first_response_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    status VARCHAR(30),

    -- Durations may be derived from timestamps or provided by the source.
    -- Document which version is used once the dataset is inspected.
    first_response_minutes NUMERIC(12, 2),
    resolution_minutes NUMERIC(12, 2),

    -- This field is intended for the source-provided value, if available.
    source_sla_breached BOOLEAN,

    CONSTRAINT valid_original_priority
        CHECK (original_priority IS NULL OR original_priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT valid_predicted_priority
        CHECK (predicted_priority IS NULL OR predicted_priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT valid_sentiment
        CHECK (sentiment IS NULL OR sentiment IN ('positive', 'neutral', 'negative')),
    CONSTRAINT valid_ticket_status
        CHECK (status IS NULL OR status IN ('open', 'in_progress', 'pending', 'resolved', 'closed')),
    CONSTRAINT nonnegative_first_response
        CHECK (first_response_minutes IS NULL OR first_response_minutes >= 0),
    CONSTRAINT nonnegative_resolution
        CHECK (resolution_minutes IS NULL OR resolution_minutes >= 0),
    CONSTRAINT response_not_before_creation
        CHECK (first_response_at IS NULL OR created_at IS NULL OR first_response_at >= created_at),
    CONSTRAINT resolution_not_before_creation
        CHECK (resolved_at IS NULL OR created_at IS NULL OR resolved_at >= created_at)
);

CREATE TABLE IF NOT EXISTS sla_evaluations (
    evaluation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id VARCHAR(150) NOT NULL REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    sla_rule_id INTEGER REFERENCES sla_rules(sla_rule_id),
    evaluation_type VARCHAR(30) NOT NULL,
    target_minutes INTEGER,
    actual_minutes NUMERIC(12, 2),
    breach_status VARCHAR(20) NOT NULL,
    calculation_method TEXT NOT NULL,
    evaluated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT valid_evaluation_type
        CHECK (evaluation_type IN ('first_response', 'resolution')),
    CONSTRAINT valid_breach_status
        CHECK (breach_status IN ('breached', 'met', 'pending', 'unknown')),
    CONSTRAINT valid_evaluation_target
        CHECK (target_minutes IS NULL OR target_minutes > 0),
    CONSTRAINT valid_evaluation_actual
        CHECK (actual_minutes IS NULL OR actual_minutes >= 0)
);

CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON tickets(created_at);
CREATE INDEX IF NOT EXISTS idx_tickets_category_id ON tickets(category_id);
CREATE INDEX IF NOT EXISTS idx_tickets_priority ON tickets(original_priority);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_sla_evaluations_ticket_type
    ON sla_evaluations(ticket_id, evaluation_type);
CREATE INDEX IF NOT EXISTS idx_sla_evaluations_status
    ON sla_evaluations(breach_status);

COMMIT;

-- SLA evaluation guidance:
-- * met: observed elapsed time is at or under the target.
-- * breached: evidence establishes the target was exceeded.
-- * pending: the ticket is still open and its deadline has not passed.
-- * unknown: required timestamps, target, or trustworthy evidence are missing.
-- Calendar-time targets are only a starting assumption. If business hours,
-- pauses, holidays, or time zones matter, implement and document those rules.
-- Never use post-resolution fields as model features when predicting a label
-- that would have to be known before resolution (target leakage).
