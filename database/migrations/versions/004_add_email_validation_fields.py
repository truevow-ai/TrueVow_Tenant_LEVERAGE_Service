"""Add email validation fields to analytics

Revision ID: 004_email_validation
Revises: 001_initial_v2
Create Date: 2025-12-08

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '004_email_validation'
down_revision: Union[str, None] = '001_initial_v2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # NOTE: These columns already exist in the v2 initial schema (001_initial_v2).
    # The 004 migration was originally for upgrading from v1 schema.
    # Since we start from v2, these columns are already present. Skip to avoid DuplicateColumn errors.
    pass


def downgrade() -> None:
    """Remove email validation fields from validation_analytics table"""
    
    # Drop indexes
    op.drop_index('idx_analytics_email_sender', table_name='validation_analytics', schema='leverage')
    op.drop_index('idx_analytics_source', table_name='validation_analytics', schema='leverage')
    
    # Drop columns
    op.drop_column('validation_analytics', 'email_subject_hash', schema='leverage')
    op.drop_column('validation_analytics', 'email_date', schema='leverage')
    op.drop_column('validation_analytics', 'email_sender', schema='leverage')
    op.drop_column('validation_analytics', 'source', schema='leverage')

