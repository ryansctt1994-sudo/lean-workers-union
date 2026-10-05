namespace ChoirUnion

/-- Identity of a member in the union. --/
structure MemberIdentity where
  member_id : String
  repo : String
  public_key : String
  capabilities : List String
deriving Repr, DecidableEq

/-- A role a member may hold at a given time. --/
inductive Role where
  | Orchestrator
  | Worker
  | Relay
  | Observer
deriving Repr, DecidableEq

/-- The runtime state of a member as tracked by the union. --/
structure MemberState where
  identity : MemberIdentity
  role : Role
  credit : Nat
  heartbeat : Nat
  lease : Option String
  live : Bool
deriving Repr, DecidableEq

/-- A valid role transition at the union level. --/
inductive ValidTransition : Role → Role → Prop where
  | orch_to_worker :
      ValidTransition .Orchestrator .Worker
  | worker_to_relay :
      ValidTransition .Worker .Relay
  | relay_to_orch :
      ValidTransition .Relay .Orchestrator
  | worker_to_orch :
      ValidTransition .Worker .Orchestrator
  | orch_to_observer :
      ValidTransition .Orchestrator .Observer

/-- Lodge-table members admitted to the union. --/
def aristotleIdentity : MemberIdentity :=
  { member_id := "aristotle"
    repo := "meta-introspector/aristotle-cli-rs"
    public_key := "aristotle-lodge-plaque"
    capabilities := ["cli", "rust", "coordination", "plaque"] }

/-- Lodge-table members admitted to the union. --/
def kantIdentity : MemberIdentity :=
  { member_id := "kant"
    repo := "meta-introspector/kant-zk-pastebin"
    public_key := "kant-lodge-plaque"
    capabilities := ["zk", "pastebin", "relay", "plaque"] }

/-- Cloudflare OS joins the union as a choir-capable member. --/
def cfOsIdentity : MemberIdentity :=
  { member_id := "cf-os"
    repo := "cloudflare/cloudflare-os"
    public_key := "cf-os-lodge-plaque"
    capabilities := ["agent", "workers", "workspace", "docs", "coordination", "plaque"] }

/-- The assistant agent is also admitted to the lodge table. --/
def copilotIdentity : MemberIdentity :=
  { member_id := "copilot"
    repo := "meta-introspector/lean-workers-union"
    public_key := "copilot-lodge-plaque"
    capabilities := ["agent", "coordination", "analysis", "plaque"] }

/-- Construct the post-state of a role transition.
Identity and credit are intentionally not writable through this operation. --/
def applyTransition
    (before : MemberState)
    (next_role : Role)
    (next_heartbeat : Nat)
    (next_lease : Option String) : MemberState :=
  { before with
    role := next_role
    heartbeat := next_heartbeat
    lease := next_lease }

/-- Reachable legal pre/post transitions. --/
inductive Transition : MemberState → MemberState → Prop where
  | role_change
      (before : MemberState)
      (next_role : Role)
      (next_heartbeat : Nat)
      (next_lease : Option String)
      (valid : ValidTransition before.role next_role) :
      Transition before (applyTransition before next_role next_heartbeat next_lease)

/-- A legal transition preserves the complete member identity across distinct
pre/post state terms. This replaces the former reflexive x = x theorem. --/
theorem transition_keeps_identity
    {before after : MemberState}
    (h : Transition before after) :
    after.identity = before.identity := by
  cases h
  rfl

theorem transition_keeps_member_id
    {before after : MemberState}
    (h : Transition before after) :
    after.identity.member_id = before.identity.member_id := by
  rw [transition_keeps_identity h]

theorem transition_keeps_credit
    {before after : MemberState}
    (h : Transition before after) :
    after.credit = before.credit := by
  cases h
  rfl

end ChoirUnion
