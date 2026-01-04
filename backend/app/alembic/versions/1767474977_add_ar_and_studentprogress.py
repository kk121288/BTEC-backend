"""add ar_model_url to item and create studentprogress table

Revision ID: 1767474977_add_ar_and_studentprogress
Revises: 
Create Date: 2026-01-04 00:16:19+03:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql as pg


# revision identifiers, used by Alembic.
revision = "1767474977_add_ar_and_studentprogress"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Add new column to item table (nullable)
    op.add_column(
        "item",
        sa.Column("ar_model_url", sa.String(length=2048), nullable=True),
    )

    # Create studentprogress table
    op.create_table(
        "studentprogress",
        sa.Column("id", pg.UUID(as_uuid=False), primary_key=True),
        sa.Column("user_id", pg.UUID(as_uuid=False), sa.ForeignKey("user.id"), nullable=False),
        sa.Column("module_name", sa.String(length=255), nullable=False),
        sa.Column("progress", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("struggling", sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column("last_active", sa.DateTime(), nullable=True),
    )


def downgrade():
    op.drop_table("studentprogress")
    op.drop_column("item", "ar_model_url")
