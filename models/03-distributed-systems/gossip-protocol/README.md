# Gossip Protocol

## Goal
The goal of this project is to model a Gossip Protocol in TLA+ and understand the conditions under which information propagation leads to global convergence.

Rather than focusing solely on implementation, this model explores the relationship between protocol behavior, system assumptions, and eventual consistency.

## Problem
In distributed systems, gossip protocols are widely used for disseminating information without centralized coordination.

However, convergence (i.e., all nodes eventually learning all information) is often assumed rather than formally verified.

This raises a key question:
> Under what conditions does a gossip protocol actually converge?

## Model
The system consists of:
- A set of processes (```Proc```)
- A set of data items (```Data```)
- A distributed state where each process maintains a subset of known data (```knowledge```)

Two models are explored:
1. A minimal asynchronous gossip model using a global message set
2. A refined model using structured communication channels between process pairs

## Actions
The protocol is modeled through two main actions:
- **Send(p, t)**: Process p sends its current knowledge to process t
- **Receive(p, t)**: Process t incorporates the data received from process p

In the refined model, communication is structured through explicit channels (```network[p][t]```), allowing better control over message delivery and fairness.

## Properties Checked
The model satisfies the following properties:

### Safety
- **Type correctness**  
  Verified using a type invariant checked by TLC.

- **Knowledge validity**  
  All knowledge remains within the domain of defined data items.

- **No data creation**  
  The protocol does not introduce new information; all data originates from the initial state.

- **Monotonic knowledge growth (by construction)**  
  Processes only accumulate knowledge over time through set union; no information is removed once learned

### Liveness (Target Property)

- **Convergence**  
  Eventually, all processes learn all available data:

  ```∀ p ∈ Proc: knowledge[p] = Data```

## Exploration
### Model 1 — Minimal Gossip

The initial model represents a fully asynchronous system with:

- A global set of messages
- Non-deterministic message delivery
- Weak fairness assumptions

TLC produces counterexamples showing that:

- Messages containing useful information may remain indefinitely in the network
- Other messages continue to be delivered
- Some processes never receive missing data

This demonstrates that:

Weak fairness over message delivery is insufficient to guarantee convergence, as it does not prevent starvation of relevant communication paths.

---

### Model 2 — Refined Gossip

To address this limitation, the model is refined by introducing:

- Explicit communication channels between process pairs
- At most one pending message per channel
- Structured delivery semantics

This eliminates ambiguity in message selection and reduces starvation scenarios, making convergence achievable under stronger fairness assumptions.


## Limitations
- The model is finite and relies on bounded sets for model checking
- Convergence depends on fairness assumptions and is not guaranteed in all possible executions
- The refined model abstracts away real-world concerns such as message loss, delays, or network topology
- TLC may not fully verify convergence due to state-space complexity

## Lessons Learned
- Convergence is not a property of the protocol alone, but of the protocol under specific assumptions about communication and scheduling.
- Weak fairness is often insufficient in highly asynchronous systems
- The structure of the model (e.g., global message set vs. explicit channels) significantly impacts verifiability
- Counterexamples are a powerful tool for uncovering hidden assumptions
- Refinement is essential to move from permissive models to realistic guarantees