---
title: Roosts & cursors
description: One runtime, many nests, across one or more chains - one isolated cursor per chain.
order: 2
---

A **roost** is one runtime hosting many nests. A **cursor** is a single chain's follow position - the
thing that reads the tip, tracks finality, and handles reorgs. The relationship between them is the
whole story.

## The single-cursor law

A **cursor is single-chain, single-writer, one observable failure boundary.** One cursor tracks exactly
one chain's canonical history - never two. Chains reorg, finalize, and advance on independent clocks, so
sharing a cursor between two of them is incoherent, not merely inadvisable. This law is
non-negotiable: nuthatch never multiplexes two chains behind one cursor.

## One chain, many nests

Nests on the **same chain** co-located in one roost share **one cursor**: a single `getLogs` per window,
fanned out to the owning nests. So N nests cost roughly one nest's worth of RPC chatter - the density
win. Per-nest tables stay byte-identical to running each nest solo, because the same per-window code
runs either way.

Isolation is by construction: each nest keeps its own directory (`nests/<name>/` - its own hot store,
segments, and views), so one nest's bad view or runaway factory can't touch another's data.

## Many chains, one runtime

A roost can also span **multiple chains** - one Base nest and one Arbitrum nest in a single process - by
running **one isolated cursor per distinct chain**. Each cursor has its own RPC source, tip-follow loop,
finality view, reorg boundary, and hot-store partition. A reorg on one chain touches only that chain's
cursor; another chain's data is left byte-identical.

```toml
# roost.toml - multichain form: declare each chain's RPC, nests carry their own chain.
[roost]
name = "my-roost"
nests = ["base-pool", "arb-pool"]

[[chains]]
chain = "base"
chain_id = 8453
rpc_urls = ["https://base-rpc"]

[[chains]]
chain = "arbitrum-one"
chain_id = 42161
rpc_urls = ["https://arb-rpc"]
```

> **A capability, not a mandate.** One-chain-per-roost stays fully valid and is the simplest default.
> Multichain is there for operators who want the density; the runtime enables the option, it never forces
> co-location.

## The footprint budget

The footprint budget is **per active-chain cursor: ≤2 GB RAM**. A single-chain roost is one cursor
(≤2 GB); a multichain roost's total is the sum of its cursors. Each chain's cursor is held to the budget
independently - a cursor whose *projected* footprint would exceed it is refused before it starts. Density
is RAM-bounded, not free.

## Failure boundaries

Each cursor is one observable failure boundary. One chain stalling or reorging cannot harm another
chain's nests; the roost fate-shares its serving with *every* cursor, so a dead cursor fails the whole
roost loudly rather than serving stale data as if healthy.

## Next

- [Run a roost](/docs/operate/roosts/) - the operational guide
- [Reorgs &amp; finality](/docs/concepts/reorgs/) - how a cursor handles a reorg
- [Storage &amp; sealing](/docs/concepts/storage/) - what a cursor writes
