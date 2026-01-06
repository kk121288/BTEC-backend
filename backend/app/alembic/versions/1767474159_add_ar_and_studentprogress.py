"""add ar_model_url to item and create studentprogress table

Revision ID: 1767474159_add_ar_and_studentprogress
Revises: 
Create Date: 2026-01-04 00:02:45+03:00

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "1767474159_add_ar_and_studentprogress"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Add new column to item table (nullable)
    # Use IF NOT EXISTS to avoid duplicate-column errors across DB states
    op.execute(
        "ALTER TABLE item ADD COLUMN IF NOT EXISTS ar_model_url VARCHAR(2048);"
    )
    # NOTE: studentprogress table is created in a later, canonical
    # migration to avoid duplicate table definitions and datatype
    # mismatches. This migration only adds the `ar_model_url` column.


def downgrade():
    op.drop_table("studentprogress")
    op.drop_column("item", "ar_model_url")
