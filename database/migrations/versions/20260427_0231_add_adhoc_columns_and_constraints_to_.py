"""add_adhoc_columns_and_constraints_to_validation_rules

Revision ID: 079a76848bbc
Revises: d7e9b3c01845
Create Date: 2026-04-27 02:31:09.438802+04:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = "079a76848bbc"
down_revision = "d7e9b3c01845"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add ad-hoc columns that were added during seeding but not in original migration
    op.add_column('validation_rules', sa.Column('citation_id', sa.Integer(), nullable=True), schema='leverage')
    op.add_column('validation_rules', sa.Column('sub_specialization_type', sa.String(length=100), nullable=True), schema='leverage')
    op.add_column('validation_rules', sa.Column('jurisdiction_code', sa.String(length=10), nullable=True), schema='leverage')
    
    # Add notes column to rule_citations (referenced by remediate seed files)
    op.add_column('rule_citations', sa.Column('notes', sa.Text(), nullable=True), schema='leverage')
    
    # Add soft-delete / workflow columns referenced by SQLAlchemy model but not in original schema
    op.add_column('validation_rules', sa.Column('updated_by', sa.String(length=255), nullable=True), schema='leverage')
    op.add_column('validation_rules', sa.Column('deleted_at', sa.DateTime(timezone=True), nullable=True), schema='leverage')
    op.add_column('validation_rules', sa.Column('deleted_by', sa.String(length=255), nullable=True), schema='leverage')
    
    # Add updated_at to api_keys (referenced by model but not in original schema)
    op.add_column('api_keys', sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=True), schema='leverage')
    
    # Add CHECK constraints that were dropped during seeding and restored with corrected logic
    # check_template_has_template_name: templates must have a template_name
    op.create_check_constraint(
        'check_template_has_template_name',
        'validation_rules',
        "(is_template = TRUE AND template_name IS NOT NULL) OR is_template = FALSE",
        schema='leverage'
    )
    
    # check_validator_level: validator levels must be between 1 and 5
    op.create_check_constraint(
        'check_validator_level',
        'validation_rules',
        "validator_level BETWEEN 1 AND 5",
        schema='leverage'
    )
    
    # check_template_has_no_tenant: templates cannot have a tenant_id
    op.create_check_constraint(
        'check_template_has_no_tenant',
        'validation_rules',
        "(is_template = TRUE AND tenant_id IS NULL) OR is_template = FALSE",
        schema='leverage'
    )
    
    # check_tenant_rule_has_tenant: CORRECTED - allows global rules (tenant_id NULL for non-templates)
    # Original constraint required tenant_id for ALL non-template rules, which broke global seeded rules
    # Revised: allows non-template rules with NULL tenant_id (they have jurisdiction_scope set)
    op.create_check_constraint(
        'check_tenant_rule_has_tenant',
        'validation_rules',
        "is_template = TRUE OR tenant_id IS NOT NULL OR jurisdiction_scope IN ('state', 'federal', 'local')",
        schema='leverage'
    )
    
    # Add unique constraint for rule_name (used by ON CONFLICT in seed files)
    # Note: unique_active_state_sol was added ad-hoc, now formalized
    op.create_unique_constraint(
        'unique_active_state_sol',
        'validation_rules',
        ['rule_name'],
        schema='leverage'
    )


def downgrade() -> None:
    # Drop soft-delete / workflow columns
    op.drop_column('api_keys', 'updated_at', schema='leverage')
    op.drop_column('validation_rules', 'deleted_by', schema='leverage')
    op.drop_column('validation_rules', 'deleted_at', schema='leverage')
    op.drop_column('validation_rules', 'updated_by', schema='leverage')
    
    # Drop CHECK constraints
    op.drop_constraint('unique_active_state_sol', 'validation_rules', schema='leverage', type_='unique')
    op.drop_constraint('check_tenant_rule_has_tenant', 'validation_rules', schema='leverage', type_='check')
    op.drop_constraint('check_template_has_no_tenant', 'validation_rules', schema='leverage', type_='check')
    op.drop_constraint('check_validator_level', 'validation_rules', schema='leverage', type_='check')
    op.drop_constraint('check_template_has_template_name', 'validation_rules', schema='leverage', type_='check')
    
    # Drop ad-hoc columns
    op.drop_column('rule_citations', 'notes', schema='leverage')
    op.drop_column('validation_rules', 'jurisdiction_code', schema='leverage')
    op.drop_column('validation_rules', 'sub_specialization_type', schema='leverage')
    op.drop_column('validation_rules', 'citation_id', schema='leverage')