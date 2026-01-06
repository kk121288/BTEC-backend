"""Add StudentProgress table

Revision ID: f3b1c9a2d4e6
Revises: d98dd8ec85a3
Create Date: 2026-01-03 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "f3b1c9a2d4e6"
down_revision = "d98dd8ec85a3"
branch_labels = None
depends_on = None


def upgrade():
    # Ensure UUID extension exists for PostgreSQL
    op.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')

    op.create_table(
        "student_progress",
        sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("course", sa.String(), nullable=False),
        sa.Column("progress", sa.Float(), nullable=False, server_default=sa.text("0.0")),
        sa.Column("last_updated", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["student_id"], ["user.id"], name="fk_student_progress_student_id_user_id", ondelete="CASCADE"),
    )
    op.create_index(op.f("ix_student_progress_student_id"), "student_progress", ["student_id"])
    op.create_index(op.f("ix_student_progress_course"), "student_progress", ["course"])


def downgrade():
    op.drop_index(op.f("ix_student_progress_course"), table_name="student_progress")
    op.drop_index(op.f("ix_student_progress_student_id"), table_name="student_progress")
    op.drop_table("student_progress")
