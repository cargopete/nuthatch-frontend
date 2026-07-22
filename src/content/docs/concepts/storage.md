---
title: Storage & sealing
description: A hot redb tip store, content-addressed Parquet sealed past finality, unified behind DuckDB SQL.
order: 3
---

Nuthatch stores data in two tiers, split at the finality boundary — and glues them behind one SQL
surface.

## Hot: the redb tip store

Recent, still-reorgable blocks live in an embedded **redb** key-value store — one table per event table,
keyed by `(block_number, log_index)` so a reorg rollback is a cheap range-delete. This is the mutable
tier: it's the *only* place a reorg ever lands. Entity point-reads (`/entity/{id}`) hit it directly.

## Cold: content-addressed Parquet

Once a block range passes finality (a conservative depth), its rows are **sealed** to an immutable,
**content-addressed** (`sha256`) Snappy **Parquet** segment under `segments/`, catalogued in
`manifest.json` with block bounds and row count. A monotonic `sealed_through` watermark advances so each
range seals exactly once, and the sealed rows are then pruned from the hot store.

Because a segment's identity is a hash over its bytes, the same range always produces the same segment —
on any machine, on any run. That's what makes segments *reusable* across nest versions (see
[Upgrading a nest](/docs/operate/upgrades/)) and shareable as a verifiable cache.

> **Sealed is immutable, forever.** Segments are sealed strictly *past finality*, so the columnar layer
> is append-only. If a change would require mutating a sealed segment, the design is wrong — go back. A
> reorg can never reach a sealed segment, by construction.

## The union: DuckDB over hot ∪ cold

Analytical SQL (`/sql`, `nuthatch sql`) runs over an embedded **DuckDB** that attaches the sealed
segments **read-only** and unions them with the hot tip — so a query spans all of history seamlessly,
hot and cold. DuckDB is single-writer by design: only the ingestion thread writes; queries attach
read-only. Never design around concurrent DuckDB writers.

A point-read for a pruned id transparently falls back to the cold path, so `/entity/{id}` works across
the hot→cold seam without the caller knowing where the row lives.

## Big integers

Values wider than 64 bits (a `uint256`) are stored as canonical big-endian bytes, with derived
`{col}_dec` DECIMAL views for numeric use. A column over 38 digits exceeds DECIMAL(38,0) — cast it to
`DOUBLE` or `HUGEINT` in SQL when you need arithmetic. See [The SQL surface](/docs/reference/sql/).

## Next

- [Reorgs &amp; finality](/docs/concepts/reorgs/) — the boundary this split is built on
- [Determinism](/docs/concepts/determinism/) — why content-addressing matters
- [The SQL surface](/docs/reference/sql/) — querying the union
