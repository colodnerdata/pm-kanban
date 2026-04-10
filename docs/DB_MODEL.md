# Database model

SQLite database, created automatically on first startup if it does not exist.

## Goals
- Support multiple users in the schema (future-ready).
- Enforce one board per user for the MVP.
- Keep ordering stable and deterministic for columns and cards.

## Tables

### users
- Stores account records.
- `username` is unique.
- `password_hash` is nullable — MVP uses hardcoded credential validation in the frontend, not server-side hashing.

### boards
- One board per user, enforced by `UNIQUE (user_id)`.
- `title` stored for future multi-board expansion.

### columns
- Ordered by integer `position` within a board.
- Renaming updates `title` and `updated_at`.

### cards
- Linked to a column, ordered by integer `position` within that column.
- `details` is a required text field (empty string is allowed).
- `archived` is a soft-delete flag (default 0); intended for future archive/restore UI.

## Ordering strategy
- `position` is a zero-based integer.
- On every move or insert, affected positions are resequenced in full (no gaps).
- Resequencing is scoped to the parent entity (board for columns, column for cards).

## FK enforcement
`PRAGMA foreign_keys = ON` is set on every connection in `connect_db()`. Without this SQLite ignores FK constraints at runtime, so the pragma is required for data integrity.

## Indexes
| Index | Table | Columns | Purpose |
|---|---|---|---|
| `idx_boards_user_id` | boards | user_id | Board lookup by user |
| `idx_columns_board_id` | columns | board_id | Columns lookup by board |
| `idx_columns_board_position` | columns | board_id, position | Ordered column fetch |
| `idx_cards_column_id` | cards | column_id | Cards lookup by column |
| `idx_cards_column_position` | cards | column_id, position | Ordered card fetch |

## Migration approach
- Schema is applied via `CREATE TABLE IF NOT EXISTS` and `CREATE INDEX IF NOT EXISTS` in `init_db()`.
- `init_db()` is called once at startup via the FastAPI lifespan hook.
- Forward-only: add new migrations as additional `IF NOT EXISTS` statements.
- For breaking changes, use `PRAGMA user_version` to track schema version and run conditional DDL.

## File location
Default path: `backend/data/pm.db`. Override via the `PM_DB_PATH` environment variable.

## JSON schema reference
See `docs/kanban-schema.json` for the full machine-readable schema definition.
