# lean-workers-union

A registry and coordination layer for Lean workers and Choir members.

## Purpose

This repository defines the shared membership and role contract for distributed
formal agents. The union is intentionally not a task runner: it names the
identity, role, and capability model a member advertises, while Choir remains
responsible for orchestration and lifecycle decisions.

## Core design

A member is not permanently bound to a single role. The same runtime can act as:

- an orchestrator at one time
- a worker at another time
- a relay or observer in other phases

The registry records the identity of each member and enforces the valid role
transitions that preserve membership invariants.

## Membership contract

A member advertises:

- member id
- repo or runtime identity
- public key or signing identity
- capabilities
- current role
- credit / heartbeat / lease state

The registry stores members in a uniform shape so that downstream integrations
can query them without depending on a specific implementation.

## Role model

The union defines four fundamental roles:

- `Orchestrator`
- `Worker`
- `Relay`
- `Observer`

The same member may move between these states, but only via valid transitions.

## Integration story

The intended composition is:

- `Choir` = orchestration and task lifecycle
- `lean-workers-union` = registration, identity, and role coordination
- `lean-worker` = a formal member implementation with proofs
- `aristotle-cli-rs` / `kant-zk-pastebin` / `cloudflare/cloudflare-os` = capability-backed services that can
  register under the same union contract

## Files

- `Member.lean` — the core Lean definition of member identity, states, and
  transitions
- `Union.lean` — the registry contract for union membership and lookup

## Invariants

The union enforces the following concepts:

- member identity is stable across role transitions
- role changes are explicit and valid
- capabilities are part of the public member contract
- change in role is logged as a transition, not an implicit mutation
- each member can be looked up by identity, repo, or capability

## Status

This repository is intentionally small and protocol-first. The aim is to define
shared semantics before deciding how the adapters and worker implementations use
those semantics in their own repositories.


## Formal transition verification

The previous `transition_keeps_identity` theorem was reflexive: it proved a
member id equals itself without constructing a post-transition state.

The current candidate replaces that with:

- `applyTransition` — explicit pre-state → post-state construction;
- `Transition` — reachable legal transitions carrying a
  `ValidTransition` proof;
- `transition_keeps_identity` — complete identity preservation across the
  actual post-state;
- `transition_keeps_member_id` — member-id preservation;
- `transition_keeps_credit` — credit preservation.

Verification is pinned to Lean 4.22.0. CI rejects `sorry`, `admit`, and new
axioms, prints the theorem axiom inventory, and requires an identity-rewrite
mutation to fail compilation.

These theorems specify the Lean transition model. They do not by themselves
prove that an external orchestrator/runtime implements the model.
