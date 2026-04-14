# Primary-Backup KV Store with Failover

## Goal
The goal of this project is to model and analyze a **Primary-Backup key-value store with failover**.

Rather than implementing a production-ready protocol, the objective is to:
- understand how replication behaves under failures
- explore the gap between **local state updates** and **globally consistent state**
- identify what guarantee are (and are not) provided by simple replication strategies

This model is used as a stepping stone toward reasoning about stonger coordination mechanisms such as consensus.

## Problem
In distributed systems, replication is often used to improve availability and fault tolerance.

A common approach is the **Primary-Backup model**, where:
- a primary node handles client requests
- updates are propagated to backup replicas
- a backup is promoted if the primary fails

However, this raises a fundamental question:
> What does it mean for a write to be "safe" in the presence of failures?

Naively:
- the primary may apply a write locally before replication
- or replication may occur asynchronously

This leads to subtle failure scenarios:
- writes may be **lost** if the primary crashes too early
- or writes may be **partially applied** across replicas

The goal of this model is to make these behaviours explicit and analyze their consequences.

## Model
The system consists of:
- A set of nodes (```Node```)
- A key-value store per node (```store```)
- A role assignment (```Primary``` or ```Backup```)
- A network of in-flight messages (```network```)
- A crash model (```alive```)
- A pending write per node (```pending```)

The model captures two versions of the protocol:

### Version 1 - Naive Replication
- the primary applies writes immediately
- updates are sent asynchronously

### Version 2 - Replication with Acknowledgment
- writes are first marked as **pending**
- backups apply updates and send acknowledgments
- the primary only commits after receiving an acknowledgment

This introduces a distinction between:
- **pending state** (in-progress writes)
- **commited state** (writes confirmed via replication)

## Actions
The protocol is modeled through the following actions:
- **Promote(p)**
    
    Promotes a backup to primary when no primary is alive.

- **ClientRequest(p, k, v)**

    A client request handled by the primary.
    In the refined model, this creates a pending write and sends update messages.

- **ApplyUpdate(m)**

    A backup receives and applies an update from the network, and sends an acknowledgement.

- **ReceiveAck(m)**

    The primary receives an acknowledgement and commits the corresponding write.

- **Crash(p)**

    A node crashes and becomes inactive.

The network is modeled as a set of messages, allowing:
- arbitrary delays
- non-deterministic delivery
- reordering of messages

## Properties Checked
The following safety properties were verified using TLC:
- **Type Invariant**

    Ensures all variables remain within their expected domains.

- **Single Primary**

    At most one node is in the ```Primary``` role at any time.

- **Primary Alive**

    Any node acting as primary must be alive.

These properties ensure structural correctness of the model.

Notably, stronger properties such as immediate consistency across replicas are intentionally **not enforced**, as the model is asynchronous.

## Exploration
Model checking reveals several important behaviours.

### Naive Model
In the initial version:
- the primary applies writes immediately
- replication happens asynchronously

This leads to the classic failure:
> A write may be lost if the primary crashes before replication.

### Refined Model with Acknowledgement
The refined model introduces:
- pending writes
- acknowledgement-based commit

This prevents writes from being considered committed too early.

However, exploration reveals a more subtle issue:
> A backup may apply an update and later be promoted to primary, even though the write was never committed by the original primary.

This creates a situation where:
- different nodes disagree on what constitutes committed state
- the new primary may reflect **uncommitted data**

## Limitations
The model intentionally omits several mechanisms required for full correctness:
- no notion of **quorum or majority agreement**
- no ordering of operations (no log or sequence numbers)
- no concept of **epochs, terms, or views**
- no guarantee that promoted nodes are up-to-date

As a result:
> Replication alone is insufficient to guarantee correct failover behaviour.

Even with acknowledgments, the protocol lacks a global notion of commitment.

## Lessons Learned
This project highlights several key insights:
- **Replication is not the same as agreement**

    Having multiple copies of data does not guarantee consistency.

- **Local correctness does not imply global correctness**

    Each node may behave correctly in isolation while the system remains inconsistent.

- **Acknowledgment improves durability but does not solve failover safety**

    It introduces a notion of commit, but not a consistent global one.

- **Failover requires stronger coordination**

    Selecting a new primary safely requires knowledge about the global state.

- **Formal modeling exposes subtle behaviours**

    Many of these issues are not obvious without exploring all possible interleavings.

Ultimately, this model illustrates why more advanced protocols (such as those based on consensus) are necessary for building reliable distributed systems. 
