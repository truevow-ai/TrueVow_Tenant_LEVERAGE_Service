"""add_leverage_intelligence_features_tables

Revision ID: d7e9b3c01845
Revises: c3f8a2b91042
Create Date: 2026-04-26 18:00:00.000000+04:00

Creates five new tables in the `leverage` schema for intelligence features:
  - leverage_notification_subscriptions : Webhook/in-app notification subscriptions
  - leverage_notification_log           : Notification delivery audit log
  - leverage_valuation_multipliers      : Jurisdiction-aware PI valuation multiplier configs
  - leverage_settlement_details         : Detailed settlement data capture per case
  - leverage_settlement_windows         : Estimated settlement timelines by incident_type + state

Also alters:
  - leverage.leverage_case_profiles     : Add estimated_settle_by DATE column

Architecture notes:
  - Notification system is SOL/compliance-urgency-specific (not general case management).
  - Valuation multipliers are derived from comparative fault rules per state.
  - Settlement details capture enriches the existing record_settlement flow.
  - Settlement windows drive the nudge system (prompt attorneys after estimated window passes).
  - LEVERAGE captures settlement data; SETTLE service processes it via event-driven loose coupling.
  - All tables follow existing patterns: leverage schema, UUID case_id, tenant_id scoping.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "d7e9b3c01845"
down_revision = "c3f8a2b91042"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # =========================================================================
    # ALTER: Add estimated_settle_by to leverage_case_profiles
    # =========================================================================
    op.add_column(
        "leverage_case_profiles",
        sa.Column(
            "estimated_settle_by",
            sa.Date(),
            nullable=True,
            comment="Estimated date by which this case should settle, based on settlement_windows lookup at case open time",
        ),
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_notification_subscriptions
    # Stores webhook / in-app notification preferences per tenant user.
    # Scope: SOL urgency, compliance flags, settlement nudges only.
    # =========================================================================
    op.create_table(
        "leverage_notification_subscriptions",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("user_id", sa.String(255), nullable=False, comment="Clerk user ID"),
        sa.Column("channel", sa.String(20), nullable=False,
                  comment="webhook | in_app"),
        sa.Column("webhook_url", sa.Text(), nullable=True,
                  comment="Required when channel=webhook"),
        sa.Column("event_types", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment='List of event types to subscribe to, e.g. ["deadline.critical", "settlement.nudge"]'),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
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
        schema="leverage",
    )
    op.create_index(
        "idx_notification_subs_tenant_user",
        "leverage_notification_subscriptions",
        ["tenant_id", "user_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_notification_subs_tenant_active",
        "leverage_notification_subscriptions",
        ["tenant_id", "is_active"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_notification_log
    # Append-only audit log of all notifications sent (or attempted).
    # =========================================================================
    op.create_table(
        "leverage_notification_log",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        sa.Column("user_id", sa.String(255), nullable=True),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("event_type", sa.String(50), nullable=False,
                  comment="deadline.critical | deadline.overdue | compliance.flag_added | settlement.nudge"),
        sa.Column("severity", sa.String(20), nullable=False,
                  comment="info | warning | critical"),
        sa.Column("payload", postgresql.JSONB(astext_type=sa.Text()), nullable=False,
                  comment="Event-specific data (days_remaining, state, etc.)"),
        sa.Column("channel", sa.String(20), nullable=False,
                  comment="webhook | in_app"),
        sa.Column("delivery_status", sa.String(20), nullable=False,
                  comment="pending | sent | failed"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "delivered_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
        schema="leverage",
    )
    op.create_index(
        "idx_notification_log_tenant",
        "leverage_notification_log",
        ["tenant_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_notification_log_tenant_case",
        "leverage_notification_log",
        ["tenant_id", "case_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_notification_log_event_type",
        "leverage_notification_log",
        ["event_type", "created_at"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_valuation_multipliers
    # Jurisdiction-aware PI valuation multiplier configs, one row per state.
    # Derived from comparative fault rules and industry settlement data.
    # =========================================================================
    op.create_table(
        "leverage_valuation_multipliers",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("state", sa.String(2), nullable=False, unique=True,
                  comment="Two-letter state code"),
        sa.Column("medical_multiplier_low", sa.Float(), nullable=False,
                  comment="Conservative estimate multiplier (e.g., 1.5 for contributory states)"),
        sa.Column("medical_multiplier_high", sa.Float(), nullable=False,
                  comment="Aggressive estimate multiplier (e.g., 4.0 for pure comparative states)"),
        sa.Column("comparative_fault_rule", sa.String(30), nullable=False,
                  comment="pure | modified_50 | modified_51 | contributory"),
        sa.Column("typical_contingency_pct", sa.Float(), nullable=False,
                  server_default=sa.text("33.33"),
                  comment="Standard contingency fee percentage for this jurisdiction"),
        sa.Column("notes", sa.Text(), nullable=True,
                  comment="E.g., 'CA: pure comparative allows recovery even at 99% fault'"),
        sa.Column("source", sa.Text(), nullable=True,
                  comment="Legal citation for the multiplier range"),
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
        schema="leverage",
    )
    op.create_index(
        "idx_valuation_multipliers_state",
        "leverage_valuation_multipliers",
        ["state"],
        unique=True,
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_settlement_details
    # Detailed settlement data capture per case. Enriches the basic
    # record_settlement flow with negotiation context, legal details,
    # and attorney assessment. One row per (case_id, tenant_id).
    # =========================================================================
    op.create_table(
        "leverage_settlement_details",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("case_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("tenant_id", sa.String(255), nullable=False),
        # Settlement outcome
        sa.Column("settlement_amount", sa.Float(), nullable=True,
                  comment="Actual settlement amount (optional - attorney may opt for band only)"),
        sa.Column("settlement_band", sa.String(20), nullable=True,
                  comment="0-10k | 10-25k | 25-50k | 50-100k | 100-250k | 250k+"),
        sa.Column("settlement_date", sa.Date(), nullable=True),
        sa.Column("settlement_method", sa.String(30), nullable=True,
                  comment="pre_suit_negotiation | mediation | arbitration | trial_verdict | other"),
        # Case context at settlement
        sa.Column("insurer", sa.String(255), nullable=True),
        sa.Column("adjuster_name", sa.String(255), nullable=True,
                  comment="Optional, for intelligence network enrichment"),
        sa.Column("litigation_stage", sa.String(30), nullable=True,
                  comment="pre_suit | suit_filed | mediation | trial"),
        sa.Column("negotiation_rounds", sa.Integer(), nullable=True),
        sa.Column("demand_amount", sa.Float(), nullable=True,
                  comment="Initial demand amount"),
        sa.Column("first_offer_amount", sa.Float(), nullable=True,
                  comment="Insurer's first offer"),
        sa.Column("final_counter_amount", sa.Float(), nullable=True,
                  comment="Final counter-offer before settlement"),
        # Legal context
        sa.Column("comparative_fault_pct", sa.Float(), nullable=True,
                  comment="Plaintiff's percentage of fault (if assessed)"),
        sa.Column("policy_limit", sa.Float(), nullable=True,
                  comment="Policy limit (if known)"),
        sa.Column("medical_specials_total", sa.Float(), nullable=True,
                  comment="Total medical specials"),
        sa.Column("lost_wages_total", sa.Float(), nullable=True,
                  comment="Total lost wages"),
        # Attorney assessment
        sa.Column("outcome_satisfaction", sa.String(20), nullable=True,
                  comment="satisfied | neutral | dissatisfied"),
        sa.Column("key_factors", sa.Text(), nullable=True,
                  comment="Freeform: 'Strong liability, clear causation, aggressive insurer'"),
        # Intelligence network consent
        sa.Column("council_contribution_consent", sa.Boolean(), nullable=False,
                  server_default=sa.text("false"),
                  comment="Attorney consents to anonymous data sharing with SETTLE intelligence network"),
        sa.Column("fingerprint_hash", sa.String(64), nullable=True,
                  comment="Deterministic SHA-256 hash for SETTLE dedup (billing_service.build_case_fingerprint)"),
        # Metadata
        sa.Column("nudge_sent_at", sa.DateTime(timezone=True), nullable=True,
                  comment="When the settlement nudge was sent"),
        sa.Column("captured_at", sa.DateTime(timezone=True), nullable=True,
                  comment="When attorney actually filled in the settlement details"),
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
        sa.UniqueConstraint("case_id", "tenant_id",
                            name="uq_leverage_settlement_details_case_tenant"),
        schema="leverage",
    )
    op.create_index(
        "idx_settlement_details_case_tenant",
        "leverage_settlement_details",
        ["case_id", "tenant_id"],
        schema="leverage",
    )
    op.create_index(
        "idx_settlement_details_tenant_consent",
        "leverage_settlement_details",
        ["tenant_id", "council_contribution_consent"],
        schema="leverage",
    )

    # =========================================================================
    # TABLE: leverage_settlement_windows
    # Estimated settlement timelines by incident_type + state.
    # Drives the nudge system: if a case exceeds estimated_days_to_settle,
    # LEVERAGE prompts the attorney to record settlement details.
    # =========================================================================
    op.create_table(
        "leverage_settlement_windows",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column("incident_type", sa.String(50), nullable=False,
                  comment="slip_fall | auto_accident | dog_bite | premises_liability | general_pi"),
        sa.Column("state", sa.String(2), nullable=False),
        sa.Column("estimated_days_to_settle", sa.Integer(), nullable=False,
                  comment="Median days from retained to settled"),
        sa.Column("p25_days", sa.Integer(), nullable=True,
                  comment="25th percentile (fast settlements)"),
        sa.Column("p75_days", sa.Integer(), nullable=True,
                  comment="75th percentile (slow settlements)"),
        sa.Column("source", sa.Text(), nullable=True,
                  comment="industry_benchmark | internal_data"),
        sa.Column("notes", sa.Text(), nullable=True),
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
        sa.UniqueConstraint("incident_type", "state",
                            name="uq_leverage_settlement_windows_type_state"),
        schema="leverage",
    )
    op.create_index(
        "idx_settlement_windows_type_state",
        "leverage_settlement_windows",
        ["incident_type", "state"],
        schema="leverage",
    )

    # =========================================================================
    # Trigger: auto-update updated_at on new tables
    # =========================================================================
    for table_name in [
        "leverage_notification_subscriptions",
        "leverage_valuation_multipliers",
        "leverage_settlement_details",
        "leverage_settlement_windows",
    ]:
        op.execute(f"""
            CREATE TRIGGER trigger_{table_name}_updated_at
                BEFORE UPDATE ON leverage.{table_name}
                FOR EACH ROW
                EXECUTE FUNCTION leverage.update_updated_at_column();
        """)


def downgrade() -> None:
    # Drop triggers
    for table_name in [
        "leverage_notification_subscriptions",
        "leverage_valuation_multipliers",
        "leverage_settlement_details",
        "leverage_settlement_windows",
    ]:
        op.execute(f"DROP TRIGGER IF EXISTS trigger_{table_name}_updated_at ON leverage.{table_name}")

    # Drop tables (reverse order)
    op.drop_index("idx_settlement_windows_type_state", table_name="leverage_settlement_windows", schema="leverage")
    op.drop_table("leverage_settlement_windows", schema="leverage")

    op.drop_index("idx_settlement_details_tenant_consent", table_name="leverage_settlement_details", schema="leverage")
    op.drop_index("idx_settlement_details_case_tenant", table_name="leverage_settlement_details", schema="leverage")
    op.drop_table("leverage_settlement_details", schema="leverage")

    op.drop_index("idx_valuation_multipliers_state", table_name="leverage_valuation_multipliers", schema="leverage")
    op.drop_table("leverage_valuation_multipliers", schema="leverage")

    op.drop_index("idx_notification_log_event_type", table_name="leverage_notification_log", schema="leverage")
    op.drop_index("idx_notification_log_tenant_case", table_name="leverage_notification_log", schema="leverage")
    op.drop_index("idx_notification_log_tenant", table_name="leverage_notification_log", schema="leverage")
    op.drop_table("leverage_notification_log", schema="leverage")

    op.drop_index("idx_notification_subs_tenant_active", table_name="leverage_notification_subscriptions", schema="leverage")
    op.drop_index("idx_notification_subs_tenant_user", table_name="leverage_notification_subscriptions", schema="leverage")
    op.drop_table("leverage_notification_subscriptions", schema="leverage")

    # Drop added column
    op.drop_column("leverage_case_profiles", "estimated_settle_by", schema="leverage")
