---
title: Determinism
description: Decode, derivation, and reorg handling are deterministic and re-executable — LLM output never sits in the data path.
order: 5
---

Determinism is a non-negotiable in nuthatch's core, not a nice-to-have. Anything that feeds stored state
— ABI decoding, entity derivation, reorg handling — must be **deterministic and re-executable**: the
same inputs at the same block always produce the same output, on any machine, on any run.

## Why it matters

- **Verifiability without heavy machinery.** Because everything is re-executable, you verify a nest by
  *re-running* it — no TEE attestation, no zk proofs. Verifiability = deterministic re-execution of pure
  logic plus content-addressed segments. Nothing heavier.
- **Content-addressing works.** A sealed segment is a `sha256` over its bytes; determinism is what makes
  the same range yield the same hash everywhere. That's the basis for segment reuse across upgrades and
  for a verifiable shared cache.
- **Reorgs become retractions.** A deterministic derivation can be *un-applied* — a reorg re-feeds the
  same facts with negative weight and the state converges. Non-determinism would make that impossible.

## Where the line is drawn

- **ABI decoding** — deterministic Rust, topic0-keyed, versioned (history is never retroactively
  re-decoded).
- **Entity derivation** — incremental views over decoded events (DBSP/IVM), or pure WASM components.
- **Contract state** — where nuthatch *derives* a read (see [Recipes](/docs/build/recipes/)) it's pure
  SQL over indexed events. Where it must *fetch* one, the call is pinned to a historical block hash
  (EIP-1898) so it's a pure function of `(code, storage, block, calldata)` — never `latest` in the data
  path.

## LLMs generate code, never data

Nuthatch is AI-native, but with a bright line: **LLMs generate code and tests; LLM output never sits in
the runtime data path.** An agent can scaffold a nest, write a view, or author a test — all reviewed like
any code — but nothing an LLM produces at runtime feeds stored state. The data path stays deterministic;
the AI stays at the authoring layer.

> This is also why effectful WASM components (HTTP enrichers, say) may produce **annotations only**,
> never canonical entities — only zero-capability, deterministic components can feed entity derivation.
> See [Authoring modes](/docs/concepts/authoring/).

## Next

- [Reorgs &amp; finality](/docs/concepts/reorgs/) — determinism in action
- [Authoring modes](/docs/concepts/authoring/) — the purity rule for handlers
