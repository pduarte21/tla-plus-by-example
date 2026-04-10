# Vector Clocks

## Goal
The goal of this project is to model **vector clocks** and understand how they capture **causal relationships** in distributed systems.

Rather than enforcing consistency or convergence, vector clocks provide a mechanism to reason about causality.

## Problem
In distributed systems, there is no global clock to order events. Nodes operate independently, and messages may be delayed or reordered.

This raises a fundamental question:
> How can one determine whether an event happened before another, or whether two events are concurrent?

Without a proper mechanism, systems cannot distinguish between:
- causally related events
- independent (concurrent) events

## Model
The system consists of:
- A set of nodes (```Node```)
- A network of in-flight messages (```network```)

Each node maintains a **vector clock**:
```
Node -> [Node -> Nat]
```
Where:
- ```vc[n][i]``` represents node n's knowledge of i's logical time

Messages carry full vector clocks snapshots:
```
[from, to, data]
```
where ```data``` is the sender's vector clock.

To enable verification with TLC:
- clocks are bounded (```MaxClock```)
- the network size is bounded (```MaxNet```)

A helper variable ```vc_prev``` stores the previous global state to allow reasoning about monotonicity.

## Actions
The system evolves through three main actions:

- **Put(n)**
    - Increments the local component of node ```n``` 
    - Models a local event

- **Send(f, t)**
    - Node ```f``` increments its clock
    - Sends its updated vector clock to node ```t```

- **Receive(m)**
    - Node ```t``` merges its clock with the received one using a **pointwise maximum**
    - Then increments its own component

    This corresponds to the standard vector clock update rule:
    - merge: ```max(local, received)```
    - increment: local event after receive

## Properties Checked

### Type Correctness
Ensures:
- vector clocks stay within bounds
- messages have the correct structure

###  Monotonicity

```
Monotonic ==
    ∀ n ∈ Node:
        vc_prev[n] ≤ vc[n]
```
Vector clocks never decrease. This property guarantees that:
- knowledge is never lost
- all updates are monotonic

This invariant is checked with TLC

## Exploration

### Concurrency
A key aspect of vector clocks is the ability to detect concurrency.

Defined as:
```
Concurrent(v1, v2) ==
    ¬Leq(v1, v2) ∧ ¬Leq(v2, v1)
```

and explored using:
```
ConcurrencyState ==
    ∃ n1 ≠ n2:
        Concurrent(vc[n1], vc[n2])
```
This identifies states where two nodes have incomparable clocks.

Concurrency is **not guaranteed** in every execution, but the model allows such states to arise when nodes perform independent updates.

### Happens-Before Relation

```
HappensBefore(v1, v2) ==
    Leq(v1, v2) ∧ v1 ≠ v2
```
This captures causal ordering between events.

### Merge Semantics

Although not directly checked by TLC, the following property characterizes the correctness of ```Receive```:
```
Receive(m) => vc'[m.to] ≥ m.data
```
This ensures that receiving a message never loses causal information.

## Limitations
The model includes several simplifications:
- **Bounded clocks (MaxClock)**

    Real vector clocks are unbounded; bounding is used to keep the state space finite.

- **Bounded network (MaxNet)**

    Limits the number of in-flight messages.

- **No message loss or duplication**

    The network is reliable.

- **No fairness assumptions**

    The model explores possible behaviours but does not enforce eventual delivery.

These constraints are necessary for model checking but differ from real-world systems.

## Lessons Learned
This model highlights several key insights:
- **Vector clocks do not converge**

    Unlike replication protocols, vector clocks do not aim to reach a common state. Instead, they encode **causal structure**.

- **Causality is captured, not enforced**

    Vector clocks do not impose ordering on events. They only reflect the causal relationships that emerge from execution.

- **Concurrency is not enforced, only detected**

    The system does not guarantee that concurrent events occur. However, when independent events happen, vector clocks allow to detect them.

- **Monotonicity is fundamental**

    The correctness of vector clocks relies on:
    - monotonic growth
    - merge via maximum
    - local increments

- **Not all properties are invariants**

    Some important properties (e.g., merge correctness, causal propagation) are:
    - **local to actions**
    - not directly checkable by TLC
    
    This distinction is essential when working with TLA+.

- **Modeling enables understanding**

    Formal modeling makes it possible to reason precisely about:
    - what is guaranteed
    - what is possible
    - and what is not enforced