---
title: Run a roost
description: One runtime hosting many nests across one or more chains — one isolated cursor per chain.
order: 3
---

_This page is a stub in the first documentation pass — the IA is in place; content is being filled in._

A **roost** is one runtime hosting many nests. Nests on the same chain share a single cursor and one
`getLogs` per window (N nests for roughly one nest's RPC cost); a roost can also span **multiple
chains**, running one isolated cursor per chain — a Base nest and an Arbitrum nest in one process. Each
cursor has its own tip, finality, and reorg boundary, and a per-cursor footprint budget.
