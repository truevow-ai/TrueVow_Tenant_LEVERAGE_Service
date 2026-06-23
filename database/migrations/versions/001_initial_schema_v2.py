"""Initial schema v2.0 - Correct architecture

Revision ID: 001_initial_v2
Revises: 
Create Date: 2025-12-10

Architecture:
- Global Rule Templates (SaaS Admin): is_template=TRUE, tenant_id=NULL
- Tenant-Specific Rules (Law Firms): is_template=FALSE, tenant_id=UUID
- Template Inheritance: Tenants inherit and customize templates
- Rule Selection: Tenants select which rules to validate against
- Zero-Knowledge: NO document content stored, only metadata
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '001_initial_v2'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create schema
    op.execute('CREATE SCHEMA IF NOT EXISTS leverage')
    
    # ========================================================================
    # TABLE: validation_rules
    # ========================================================================
    op.create_table(
        'validation_rules',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        
        # Tenant scoping & template flags
        sa.Column('tenant_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('is_template', sa.Boolean(), nullable=False, server_default='false'),
        
        # Template metadata
        sa.Column('template_name', sa.String(200), nullable=True),
        sa.Column('template_description', sa.Text(), nullable=True),
        
        # Rule metadata
        sa.Column('rule_name', sa.String(200), nullable=False),
        
        # Template inheritance
        sa.Column('inherited_from_template_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('is_customized', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('template_version', sa.Integer(), nullable=True),
        
        # Validator hierarchy
        sa.Column('validator_level', sa.Integer(), nullable=False),
        sa.Column('validator_name', sa.String(100), nullable=False),
        sa.Column('validator_type', sa.String(50), nullable=False),
        sa.Column('practice_area', sa.String(100), nullable=True),
        sa.Column('specialization', sa.String(100), nullable=True),
        sa.Column('document_type', sa.String(100), nullable=True),
        sa.Column('jurisdiction_state', sa.String(2), nullable=True),
        sa.Column('jurisdiction_county', sa.String(100), nullable=True),
        sa.Column('jurisdiction_court', sa.String(200), nullable=True),
        
        # Validator configuration
        sa.Column('validator_config', postgresql.JSONB(astext_type=sa.Text()), nullable=False, server_default='{}'),
        
        # Validation messages
        sa.Column('error_message', sa.Text(), nullable=True),
        sa.Column('warning_message', sa.Text(), nullable=True),
        sa.Column('info_message', sa.Text(), nullable=True),
        sa.Column('severity', sa.String(20), nullable=False, server_default='error'),
        
        # Rule status
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('is_required', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('is_enabled_for_validation', sa.Boolean(), nullable=False, server_default='true'),
        
        # Versioning
        sa.Column('version', sa.Integer(), nullable=False, server_default='1'),
        
        # Rule dependencies
        sa.Column('depends_on_rule_ids', postgresql.ARRAY(postgresql.UUID(as_uuid=True)), nullable=True),
        
        # Administrative
        sa.Column('created_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('archived_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        
        # Constraints
        sa.CheckConstraint('validator_level BETWEEN 1 AND 5', name='check_validator_level'),
        sa.CheckConstraint("severity IN ('error', 'warning', 'info')", name='check_severity'),
        sa.CheckConstraint(
            '(is_template = TRUE AND template_name IS NOT NULL) OR is_template = FALSE',
            name='check_template_has_template_name'
        ),
        sa.CheckConstraint(
            '(is_template = TRUE AND tenant_id IS NULL) OR is_template = FALSE',
            name='check_template_has_no_tenant'
        ),
        sa.CheckConstraint(
            '(is_template = FALSE AND tenant_id IS NOT NULL) OR is_template = TRUE',
            name='check_tenant_rule_has_tenant'
        ),
        sa.ForeignKeyConstraint(
            ['inherited_from_template_id'], 
            ['leverage.validation_rules.id'],
            name='fk_inherited_from_template',
            ondelete='SET NULL'
        ),
        
        schema='leverage'
    )
    
    # Indexes for validation_rules
    op.create_index('idx_validation_rules_tenant_id', 'validation_rules', ['tenant_id'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_is_template', 'validation_rules', ['is_template'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_inherited_from', 'validation_rules', ['inherited_from_template_id'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_level', 'validation_rules', ['validator_level'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_practice_area', 'validation_rules', ['practice_area'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_specialization', 'validation_rules', ['specialization'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_document_type', 'validation_rules', ['document_type'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_jurisdiction_state', 'validation_rules', ['jurisdiction_state'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_active', 'validation_rules', ['is_active'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_enabled', 'validation_rules', ['is_enabled_for_validation'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_created_at', 'validation_rules', ['created_at'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_updated_at', 'validation_rules', ['updated_at'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_tenant_document_type', 'validation_rules', ['tenant_id', 'document_type'], unique=False, schema='leverage')
    op.create_index('idx_validation_rules_template_practice_area', 'validation_rules', ['is_template', 'practice_area'], unique=False, schema='leverage')
    
    # ========================================================================
    # TABLE: api_keys
    # ========================================================================
    op.create_table(
        'api_keys',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('key_hash', sa.Text(), nullable=False, unique=True),
        sa.Column('key_prefix', sa.String(10), nullable=False),
        sa.Column('access_level', sa.String(20), nullable=False),
        sa.Column('tenant_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('last_used_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('usage_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('rate_limit_per_minute', sa.Integer(), nullable=False, server_default='60'),
        sa.Column('rate_limit_per_hour', sa.Integer(), nullable=False, server_default='1000'),
        sa.Column('created_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        sa.Column('revoked_at', sa.DateTime(timezone=True), nullable=True),
        
        sa.CheckConstraint("access_level IN ('tenant', 'admin', 'external')", name='check_access_level'),
        sa.CheckConstraint(
            "(access_level = 'tenant' AND tenant_id IS NOT NULL) OR access_level != 'tenant'",
            name='check_tenant_key_has_tenant'
        ),
        sa.CheckConstraint(
            "(access_level = 'admin' AND tenant_id IS NULL) OR access_level != 'admin'",
            name='check_admin_key_no_tenant'
        ),
        
        schema='leverage'
    )
    
    # Indexes for api_keys
    op.create_index('idx_api_keys_tenant_id', 'api_keys', ['tenant_id'], unique=False, schema='leverage')
    op.create_index('idx_api_keys_active', 'api_keys', ['is_active'], unique=False, schema='leverage')
    op.create_index('idx_api_keys_access_level', 'api_keys', ['access_level'], unique=False, schema='leverage')
    op.create_index('idx_api_keys_expires_at', 'api_keys', ['expires_at'], unique=False, schema='leverage')
    op.create_index('idx_api_keys_key_prefix', 'api_keys', ['key_prefix'], unique=False, schema='leverage')
    
    # ========================================================================
    # TABLE: validation_analytics
    # ========================================================================
    op.create_table(
        'validation_analytics',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        
        # Tenant scoping
        sa.Column('tenant_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=True),
        
        # Validation context
        sa.Column('practice_area', sa.String(100), nullable=True),
        sa.Column('specialization', sa.String(100), nullable=True),
        sa.Column('document_type', sa.String(100), nullable=False),
        sa.Column('jurisdiction_state', sa.String(2), nullable=True),
        sa.Column('jurisdiction_county', sa.String(100), nullable=True),
        
        # Validation source
        sa.Column('source_type', sa.String(50), nullable=False),
        
        # Validation result
        sa.Column('validation_passed', sa.Boolean(), nullable=False),
        sa.Column('errors_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('warnings_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('info_count', sa.Integer(), nullable=False, server_default='0'),
        
        # Rules used
        sa.Column('selected_rule_ids', postgresql.ARRAY(postgresql.UUID(as_uuid=True)), nullable=True),
        sa.Column('rules_checked', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('rules_passed', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('rules_failed', sa.Integer(), nullable=False, server_default='0'),
        
        # Validation metadata
        sa.Column('validation_duration_ms', sa.Integer(), nullable=True),
        sa.Column('document_size_bytes', sa.BigInteger(), nullable=True),
        sa.Column('document_format', sa.String(50), nullable=True),
        
        # Email-specific metadata
        sa.Column('email_message_id', sa.String(255), nullable=True),
        sa.Column('email_subject_hash', sa.String(64), nullable=True),
        sa.Column('attachment_filename', sa.String(255), nullable=True),
        sa.Column('attachment_mime_type', sa.String(100), nullable=True),
        sa.Column('attachment_size_bytes', sa.BigInteger(), nullable=True),
        
        # Client information
        sa.Column('client_type', sa.String(50), nullable=True),
        sa.Column('client_version', sa.String(20), nullable=True),
        sa.Column('device_id', sa.String(255), nullable=True),
        sa.Column('session_id', postgresql.UUID(as_uuid=True), nullable=True),
        
        # Timestamps
        sa.Column('validated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('now()')),
        
        # Zero-knowledge compliance
        sa.Column('content_uploaded', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('notes', sa.Text(), nullable=True),
        
        # Constraints
        sa.CheckConstraint('content_uploaded = FALSE', name='check_content_never_uploaded'),
        sa.CheckConstraint(
            "source_type IN ('browser_extension', 'desktop_app', 'word_addin', 'email_attachment', 'api')",
            name='check_source_type'
        ),
        
        schema='leverage'
    )
    
    # Indexes for validation_analytics
    op.create_index('idx_validation_analytics_tenant_id', 'validation_analytics', ['tenant_id'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_user_id', 'validation_analytics', ['user_id'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_document_type', 'validation_analytics', ['document_type'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_practice_area', 'validation_analytics', ['practice_area'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_validated_at', 'validation_analytics', ['validated_at'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_source_type', 'validation_analytics', ['source_type'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_validation_passed', 'validation_analytics', ['validation_passed'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_tenant_date', 'validation_analytics', ['tenant_id', 'validated_at'], unique=False, schema='leverage')
    op.create_index('idx_validation_analytics_tenant_document_type', 'validation_analytics', ['tenant_id', 'document_type'], unique=False, schema='leverage')
    
    # ========================================================================
    # MATERIALIZED VIEW: template_inheritance_stats
    # ========================================================================
    op.execute("""
        CREATE MATERIALIZED VIEW leverage.template_inheritance_stats AS
        SELECT 
            t.id AS template_id,
            t.template_name,
            t.practice_area,
            t.document_type,
            COUNT(DISTINCT r.tenant_id) AS inheritance_count,
            COUNT(r.id) AS total_inherited_rules,
            COUNT(CASE WHEN r.is_customized = TRUE THEN 1 END) AS customized_count,
            MAX(r.created_at) AS last_inherited_at
        FROM 
            leverage.validation_rules t
        LEFT JOIN 
            leverage.validation_rules r ON r.inherited_from_template_id = t.id
        WHERE 
            t.is_template = TRUE
        GROUP BY 
            t.id, t.template_name, t.practice_area, t.document_type
    """)
    
    op.create_index(
        'idx_template_inheritance_stats_template_id',
        'template_inheritance_stats',
        ['template_id'],
        unique=False,
        schema='leverage'
    )
    
    # ========================================================================
    # TRIGGERS
    # ========================================================================
    
    # Function: Update updated_at timestamp
    op.execute("""
        CREATE OR REPLACE FUNCTION leverage.update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
    """)
    
    # Trigger: Auto-update updated_at on validation_rules
    op.execute("""
        CREATE TRIGGER trigger_validation_rules_updated_at
            BEFORE UPDATE ON leverage.validation_rules
            FOR EACH ROW
            EXECUTE FUNCTION leverage.update_updated_at_column();
    """)
    
    # Function: Refresh materialized view
    op.execute("""
        CREATE OR REPLACE FUNCTION leverage.refresh_template_inheritance_stats()
        RETURNS VOID AS $$
        BEGIN
            REFRESH MATERIALIZED VIEW CONCURRENTLY leverage.template_inheritance_stats;
        END;
        $$ LANGUAGE plpgsql;
    """)


def downgrade() -> None:
    # Drop materialized view
    op.execute('DROP MATERIALIZED VIEW IF EXISTS leverage.template_inheritance_stats')
    
    # Drop functions
    op.execute('DROP FUNCTION IF EXISTS leverage.refresh_template_inheritance_stats()')
    op.execute('DROP FUNCTION IF EXISTS leverage.update_updated_at_column()')
    
    # Drop tables
    op.drop_table('validation_analytics', schema='leverage')
    op.drop_table('api_keys', schema='leverage')
    op.drop_table('validation_rules', schema='leverage')
    
    # Drop schema
    op.execute('DROP SCHEMA IF EXISTS leverage CASCADE')

