"""Add assessments table

Revision ID: 20260109_add_assessments
Revises: f3b1c9a2d4e6
Create Date: 2026-01-09 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "20260109_add_assessments"
down_revision = "f3b1c9a2d4e6"
branch_labels = None
depends_on = None


def upgrade():
    # PostgreSQL UUID extension if needed
    try:
        op.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')
    except Exception:
        pass

    op.create_table(
        "assessment",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("question", sa.Text(), nullable=False),
        sa.Column("level", sa.String(length=8), nullable=False),
        sa.Column("major", sa.String(length=16), nullable=False),
        sa.Column("difficulty_score", sa.Integer(), nullable=True),
        sa.Column("advice", sa.Text(), nullable=True),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["owner_id"], ["user.id"], name="fk_assessment_owner_id_user_id", ondelete="SET NULL"),
    )
    op.create_index(op.f("ix_assessment_owner_id"), "assessment", ["owner_id"]) 


def downgrade():
    op.drop_index(op.f("ix_assessment_owner_id"), table_name="assessment")
    op.drop_table("assessment")
