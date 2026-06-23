"""add_leverage_persistence_tables

Revision ID: be8f7ea708b2
Revises: 004_email_validation
Create Date: 2026-03-09 11:17:31.357605+04:00

Creates the `leverage` schema and three persistence tables:
  - leverage_case_profiles       : minimal MDM case snapshot per case
  - leverage_validation_results  : versioned, append-only compliance run results
  - leverage_case_events         : append-only event log for audit/timeline

Architecture notes:
  - `leverage` schema is separate from `draft` (different domain).
  - case_id is UUID type (MDM is the issuing authority).
  - SOL rules are read from draft.validation_rules (no duplication).
  - leverage_case_events is append-only (no UPDATE/DELETE).
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "be8f7ea708b2"
down_revision = "004_email_validation"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # =========================================================================
    # Create leverage schema
    # =========================================================================
    op.execute("CREATE SCHEMA IF NOT EXISTS leverage")

    # =========================================================================
    # TABLE: leverage_case_profiles
    # Minimal MDM case snapshot — one row per (case_id, tenant_id).
    # Updated when MDM emits case.updated events (phase 2).
    # =========================================================================
    op.create_table(
        "leverage_case_profiles",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("incident_type", sa.Text(), nullable=True),
        sa.Column("incident_date", sa.Date(), nullable=True),
        sa.Column("county", sa.Text(), nullable=True),
        sa.Column("state", sa.String(2), nullable=True),
        sa.Column("injury_category", sa.Text(), nullable=True),
        sa.Column("medical_specials_band", sa.Text(), nullable=True),
        sa.Column("policy_limit_band", sa.Text(), nullable=True),
        sa.Column("insurer", sa.Text(), nullable=True),
        sa.Column("liability_strength", sa.Text(), nullable=True),
        sa.Column("litigation_stage", sa.Text(), nullable=True),
        # MDM traceability
        sa.Column("mdm_snapshot_version", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("snapshot_source_event", sa.Text(), nullable=True,
                  comment="Event that created/last updated this snapshot: case.created | case.updated | manual"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.UniqueConstraint("case_id", "tenant_id", name="uq_leverage_case_profiles_case_tenant"),
        schema="leverage",
    )
    op.create_index(
        "idx_leverage_case_profiles_case_tenant",
        "leverage_case_profiles",
        ["case_id", "tenant_id"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_validation_results
    # Append-only versioned compliance run results.
    # Each run produces a new row; old rows are never updated.
    # rules_snapshot stores full rule objects used, so audit is self-contained.
    # =========================================================================
    op.create_table(
        "leverage_validation_results",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False,
                  comment="Auto-incremented per (case_id, tenant_id). Set by application."),
        # Statute check
        sa.Column("statute_status", sa.Text(), nullable=True,
                  comment="safe | warning | critical | overdue | sol_rule_missing"),
        sa.Column("days_remaining", sa.Integer(), nullable=True),
        # Demand letter check
        sa.Column("demand_status", sa.Text(), nullable=True,
                  comment="complete | incomplete"),
        sa.Column("missing_items", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        # Compliance flags
        sa.Column("flags", postgresql.JSONB(astext_type=sa.Text()), nullable=True,
                  comment="List of ComplianceFlag objects produced by this run"),
        # Legal traceability — required for malpractice defensibility
        sa.Column("rules_snapshot", postgresql.JSONB(astext_type=sa.Text()), nullable=True,
                  comment="Full rule objects (validator_config) that ran — preserves legal artifact even if rules change later"),
        sa.Column("validation_engine_version", sa.String(20), nullable=False,
                  comment="leverage_case.py engine version at time of run, e.g. 1.0.0"),
        sa.Column("rules_version_hash", sa.String(64), nullable=True,
                  comment="SHA-256 of sorted active rule IDs used in this run"),
        sa.Column(
            "validated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.UniqueConstraint(
            "case_id", "tenant_id", "version",
            name="uq_leverage_validation_results_case_tenant_version",
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_leverage_validation_results_case_tenant",
        "leverage_validation_results",
        ["case_id", "tenant_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_leverage_validation_results_case_version",
        "leverage_validation_results",
        ["case_id", "version"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_case_events
    # Append-only event store — never update or delete rows.
    # Provides timeline reconstruction, analytics, and legal audit trail.
    # =========================================================================
    op.create_table(
        "leverage_case_events",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("event_type", sa.Text(), nullable=False,
                  comment="case_snapshot_updated | validation_run | settlement_recorded"),
        sa.Column("event_source", sa.Text(), nullable=True,
                  comment="portal | mdm_event | billing"),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column(
            "occurred_at",
            sa.DateTime(timezone=True),
            nullable=False,
        ),
        sa.Column(
            "recorded_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_leverage_case_events_case_tenant",
        "leverage_case_events",
        ["case_id", "tenant_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_leverage_case_events_type_occurred",
        "leverage_case_events",
        ["event_type", "occurred_at"],
        schema="leverage",
    )

    # =========================================================================
    # Trigger: auto-update updated_at on leverage_case_profiles
    # =========================================================================
    op.execute("""
        CREATE OR REPLACE FUNCTION leverage.update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
    """)
    op.execute("""
        CREATE TRIGGER trigger_leverage_case_profiles_updated_at
            BEFORE UPDATE ON leverage.leverage_case_profiles
            FOR EACH ROW
            EXECUTE FUNCTION leverage.update_updated_at_column();
    """)


def downgrade() -> None:
    op.execute("DROP TRIGGER IF EXISTS trigger_leverage_case_profiles_updated_at ON leverage.leverage_case_profiles")
    op.execute("DROP FUNCTION IF EXISTS leverage.update_updated_at_column()")
    op.drop_index("idx_leverage_case_events_type_occurred", table_name="leverage_case_events", schema="leverage")
    op.drop_index("idx_leverage_case_events_case_tenant", table_name="leverage_case_events", schema="leverage")
    op.drop_table("leverage_case_events", schema="leverage")
    op.drop_index("idx_leverage_validation_results_case_version", table_name="leverage_validation_results", schema="leverage")
    op.drop_index("idx_leverage_validation_results_case_tenant", table_name="leverage_validation_results", schema="leverage")
    op.drop_table("leverage_validation_results", schema="leverage")
    op.drop_index("idx_leverage_case_profiles_case_tenant", table_name="leverage_case_profiles", schema="leverage")
    op.drop_table("leverage_case_profiles", schema="leverage")
    op.execute("DROP SCHEMA IF EXISTS leverage CASCADE")
