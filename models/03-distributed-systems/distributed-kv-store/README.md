# Distributed KV Store

## Goal
The goal of this project is to model a distributed key-value store and understand under what conditions replicas converge in an asynchronous system.

Rather than focusing on implementation details, the objective is to reason formally about replication, conflict resolution, and eventual consistency.

## Problem
In distributed systems, multiple nodes maintain local copies of shared data. Updates may occur concurrently and messages can be delivered in arbitrary order.

This raises a fundamental question:
> Under what conditions do replicas converge to the same state?

A naive replication strategy can lead to divergence due to:
- concurrent updates
- lack of ordering between values
- incomplete propagation of state

## Model
The system consists of:
- A set of nodes (```Node```)
- A set of keys (```Key```)
- A set of values (```Value```)
- A distributed store: 

    Each node maintains a local mapping: 

    ```Key -> (val, ver)``` 
    
    where:
    
    - ```val``` is the stored value (or ```None```)
    - ```ver``` is a monotonically increasing version number local to each node.
- A network modeled: 

    Each message contains: 
    
    ```[from, to, data]``` 
    
    where:
    - ```from``` and ```to``` are nodes
    - ```data``` is a full snapshot of the sender's local state:

    ```Key -> (val, ver)```

    This corresponds to a **state-based (CRDT-style) replication model**, where nodes exchange complete state rather than individual updates.

## Actions
The system evolves through the following actions:
- **Put(n, k, v)**

    Updates the value of key ```k``` at node ```n``` and increments its version.

- **Send(f, t)**

    Node ```f```sends its entire local state to node ```t```.

- **Receive(m)**

    Node ```t```merges received state with its own using a last-write-wins (LWW) rule:
    - Higher version wins
    - Higher node id is used as a deterministic tie-breaker

- **Get(n, k)**

    Read-only operation (does not affect state)

The merge operation is defined pointwise over all keys.

## Properties Checked

### Type Correctness
The model ensures that:
- the store maintains valid values and versions
- all messages conform to the expected structure

### Conditional Convergence
The main property verified is:
> If updates eventually stop, then all replicas eventually converge to a stable and identical state.

Formally:
- ```NoMorePuts```: eventually no further updates are enabled
- ```Agreement```: all nodes have identical state
- ```<>[] Agreement```: agreement is eventually reached and remains stable

This is expressed as:

```
NoMorePuts => <>[] Agreement
```

This property relies on fairness assumptions:
- messages between nodes are eventually delivered
- communication between nodes does not suffer from starvation

Under these conditions, state is guaranteed to propagate across all replicas, enabling convergence.

## Exploration
The model was developed incrementally:
1. **Naive replication**

    Propagating individual updates led to divergence.

2. **Versioning**

    Introducing versions allowed partial ordering of updates.

3. **Total ordering (LWW)**

    Adding a tie-breaker (```node```) resolved conflicts deterministically.

4. **State-based replication**

    Switching to full-state propagation ensured that all information is eventually disseminated.

This progression highlights that:
> Convergence is not guaranteed by communication alone, but by the combination of ordering, monotonicity, and propagation.

## Limitations
The model makes several simplifying assumptions:
- Versions are bounded (```MaxVersion```) to keep the state space finite
- Message delivery is guaranteed under fairness assumptions
- There is no message loss or duplication
- Network delays are arbitrary but finite

In real systems, additional mechanisms are required to handle failures, unbounded histories, and partial communication.

## Lessons Learned
This model demonstrates that convergence in distributed systems requires:
- A **total order** over updates
- A **monotonic merge function**
- **Eventual propagation** of state

Without a total order, concurrent updates may become incomparable, leading to permanent divergence.

The merge function is:
- idempotent
- commutative
- monotonic

These properties ensure that replicas converge regardless of message ordering.

More broadly, this project shows how formal modeling can uncover subtle issues in distributed protocols and provide precise guarantees about system behaviour.