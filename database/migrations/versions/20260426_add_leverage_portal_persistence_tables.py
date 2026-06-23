"""add_leverage_portal_persistence_tables

Revision ID: c3f8a2b91042
Revises: be8f7ea708b2
Create Date: 2026-04-26 12:00:00.000000+04:00

Creates four new tables in the `leverage` schema for portal-facing features:
  - leverage_reward_ledger          : Local mirror of reward grant/consume events
  - leverage_damages_worksheets     : Saved PI damages worksheets per case
  - leverage_disbursement_worksheets: Saved disbursement worksheets per case
  - leverage_case_deadlines         : Saved deadline calculations per case

Architecture notes:
  - All tables live in the `leverage` schema (separate from `draft`).
  - case_id is UUID type (MDM is the issuing authority).
  - tenant_id scopes every row per law firm (Clerk org ID).
  - Worksheets are versioned (append-only); old versions are never deleted.
  - Reward ledger mirrors events from Billing Service so the portal can
    display transaction history without calling Billing Service every time.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "c3f8a2b91042"
down_revision = "be8f7ea708b2"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # =========================================================================
    # TABLE: leverage_reward_ledger
    # Local mirror of reward grant/consume events for portal display.
    # The Billing Service owns the canonical ledger; this table is a read-optimized
    # projection so the Customer Portal can show transaction history without
    # calling the Billing Service on every page load.
    # =========================================================================
    op.create_table(
        "leverage_reward_ledger",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("credits", sa.Integer(), nullable=False, comment="Number of credits in this transaction (+ for grant, -1 for consume)"),
        sa.Column("source", sa.String(50), nullable=False,
                  comment="welcome_bonus | settlement | consumed"),
        sa.Column("status", sa.String(20), nullable=False, server_default="active",
                  comment="active | used | expired"),
        sa.Column("reference_case_id", postgresql.UUID(as_uuid=True), nullable=True,
                  comment="Case ID that triggered this transaction (if applicable)"),
        sa.Column(
            "granted_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "expires_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When this credit expires (3 months from grant by default)"),
        sa.Column(
            "consumed_at",
            sa.DateTime(timezone=True),
            nullable=True,
            comment="When this credit was consumed (FIFO, oldest first)"),
        schema="leverage",
    )
    op.create_index(
        "idx_reward_ledger_tenant_status",
        "leverage_reward_ledger",
        ["tenant_id", "status"],
        schema="leverage",
    )
    op.create_index(
        "idx_reward_ledger_tenant_source",
        "leverage_reward_ledger",
        ["tenant_id", "source"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_damages_worksheets
    # Saved PI damages worksheets per case. Versioned, append-only.
    # The portal workflow: calculate (stateless) -> review -> save to case.
    # =========================================================================
    op.create_table(
        "leverage_damages_worksheets",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False,
                  comment="Auto-incremented per (case_id, tenant_id)"),
        sa.Column("input_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment="Full DamagesRequest payload — preserves legal artifact"),
        sa.Column("result_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment="Full DamagesResponse payload"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.UniqueConstraint(
            "case_id", "tenant_id", "version",
            name="uq_leverage_damages_worksheets_case_tenant_version",
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_damages_worksheets_case_tenant",
        "leverage_damages_worksheets",
        ["case_id", "tenant_id"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_disbursement_worksheets
    # Saved disbursement / costs worksheets per case. Versioned, append-only.
    # =========================================================================
    op.create_table(
        "leverage_disbursement_worksheets",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False,
                  comment="Auto-incremented per (case_id, tenant_id)"),
        sa.Column("input_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment="Full DisbursementRequest payload"),
        sa.Column("result_json", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment="Full DisbursementResponse payload"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.UniqueConstraint(
            "case_id", "tenant_id", "version",
            name="uq_leverage_disbursement_worksheets_case_tenant_version",
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_disbursement_worksheets_case_tenant",
        "leverage_disbursement_worksheets",
        ["case_id", "tenant_id"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_case_deadlines
    # Saved deadline calculations per case. Allows the portal to show
    # upcoming deadlines across all cases without recalculating each time.
    # =========================================================================
    op.create_table(
        "leverage_case_deadlines",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("deadline_type", sa.String(50), nullable=False,
                  comment="sol | eeoc | demand_letter | right_to_sue"),
        sa.Column("deadline_date", sa.Date(), nullable=False),
        sa.Column("days_remaining", sa.Integer(), nullable=False),
        sa.Column("urgency", sa.String(20), nullable=False,
                  comment="OK | WARNING | CRITICAL | OVERDUE"),
        sa.Column("source_state", sa.String(2), nullable=True,
                  comment="Two-letter state code used in calculation"),
        sa.Column("calculation_input_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True,
                  comment="Full input used for this calculation"),
        sa.Column("calculation_result_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True,
                  comment="Full DeadlineItem result"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_case_deadlines_case_tenant",
        "leverage_case_deadlines",
        ["case_id", "tenant_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_case_deadlines_tenant_urgency",
        "leverage_case_deadlines",
        ["tenant_id", "urgency"],
        schema="leverage",
    )
    op.create_index(
        "idx_case_deadlines_tenant_deadline_date",
        "leverage_case_deadlines",
        ["tenant_id", "deadline_date"],
        schema="leverage",
    )


def downgrade() -> None:
    op.drop_index("idx_case_deadlines_tenant_deadline_date", table_name="leverage_case_deadlines", schema="leverage")
    op.drop_index("idx_case_deadlines_tenant_urgency", table_name="leverage_case_deadlines", schema="leverage")
    op.drop_index("idx_case_deadlines_case_tenant", table_name="leverage_case_deadlines", schema="leverage")
    op.drop_table("leverage_case_deadlines", schema="leverage")

    op.drop_index("idx_disbursement_worksheets_case_tenant", table_name="leverage_disbursement_worksheets", schema="leverage")
    op.drop_table("leverage_disbursement_worksheets", schema="leverage")

    op.drop_index("idx_damages_worksheets_case_tenant", table_name="leverage_damages_worksheets", schema="leverage")
    op.drop_table("leverage_damages_worksheets", schema="leverage")

    op.drop_index("idx_reward_ledger_tenant_source", table_name="leverage_reward_ledger", schema="leverage")
    op.drop_index("idx_reward_ledger_tenant_status", table_name="leverage_reward_ledger", schema="leverage")
    op.drop_table("leverage_reward_ledger", schema="leverage")
