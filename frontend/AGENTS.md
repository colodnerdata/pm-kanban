# Frontend Agent Guide

## Purpose

This folder contains the current React Next.js Kanban frontend. It is a frontend-only demo built with local state and client-side interactivity. The main goal is to keep the existing Kanban UI intact while enabling later backend integration.

## What it does today

- Renders a single Kanban board at `/`
- Shows 5 fixed columns that can be renamed inline
- Supports drag-and-drop card movement using `@dnd-kit`
- Allows adding new cards with title + details
- Allows removing cards
- Uses an in-memory board state initialized from `src/lib/kanban.ts`

## Key files

- `src/app/page.tsx`
  - Entry point for the Next.js page
  - Renders `KanbanBoard`

- `src/components/KanbanBoard.tsx`
  - Full board container and state owner
  - Handles column renaming, card creation, deletion, and drag/drop events
  - Uses `DndContext` and `DragOverlay` from `@dnd-kit/core`

- `src/components/KanbanColumn.tsx`
  - Column layout and drop target
  - Renders column header, card list, and new card form
  - Uses `SortableContext` from `@dnd-kit/sortable`

- `src/components/KanbanCard.tsx`
  - Individual draggable card component
  - Supports delete button and drag interaction styling

- `src/components/KanbanCardPreview.tsx`
  - Drag overlay preview shown while dragging a card

- `src/components/NewCardForm.tsx`
  - Form for adding a card inside a column
  - Toggles expand/collapse state locally

- `src/lib/kanban.ts`
  - Board data shape and initial sample data
  - `moveCard` logic for intra-column and inter-column reordering
  - `createId` helper for new cards

## Data model

The board uses the following core types:

- `Card`
  - `id`, `title`, `details`
- `Column`
  - `id`, `title`, `cardIds`
- `BoardData`
  - `columns`, `cards`

This structure is already suitable for backend persistence and later API syncing.

## Tests

- `src/components/KanbanBoard.test.tsx`
  - Verifies rendering of the board
  - Confirms column rename works
  - Confirms card add/remove flow works

## Build and runtime

- `npm run dev` — starts Next.js development server
- `npm run build` — builds production assets
- `npm run start` — serves built production app
- `npm run test:unit` — runs unit tests with Vitest

## Notes for future work

- The current app is entirely client-side stateful; backend persistence does not yet exist
- Adding auth, API sync, and AI sidebar should be done without changing the current board shape
- `src/lib/kanban.ts` is the right place to centralize board modeling and migration logic
