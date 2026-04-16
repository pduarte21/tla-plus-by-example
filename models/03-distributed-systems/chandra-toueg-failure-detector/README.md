# Chandra-Toueg Failure Detector

## Goal
The goal of this project is to model a **failure detector abstraction** inspired by the work of Chandra and Toueg, and to understand how assumptions about failure detection impact the ability to achieve agreement in distributed systems.

Rather than implementing a concrete mechanism, the focus is on modeling **per-process suspicion** and exploring under which conditions a system can converge to a common leader.

## Problem
In asynchronous distributed systems, it is impossible to reliably distinguish between a slow process and a crashed one.

This leads to a fundamental question:
> processes cannot know with certainty which nodes are alive.

However , many algorithms (e.g. consensus) require coordination around a leader. This raises a key question:
> how can processes agree on a leader without reliable failure detection?

## Model
The system consist of:
- A set of processes (```Node```)
- A ground-truth failure state (```alive```)
- A per-process suspicion function (```suspected```)
- A per-process leader choice (```leader```)

Key ideas:
- ```alive``` represents **reality**
- ```suspected[p]``` represents **what process p believes**
- ```leader[p]``` is chosen based on ```suspected[p]```

Each process makes decisions **locally**, based only on its own view of the system.

No communication, time, or network behaviour is explicitly modeled.

## Actions
The model evolves through the following actions:
- **Crash(p)**

    A process fails. This affects the ground truth (alive) but does not directly update any process’s beliefs.

- **Suspect(p, q)**

    Process p starts suspecting q. This may be correct or incorrect.

- **Restore(p, q)**

    Process p stops suspecting q, correcting a previous mistake.

- **Elect(p)**

    Process p selects a leader from the set of nodes it does not suspect.

All actions are **local** and independent. There is no coordination between processes.

## Properties Checked
The main property of interest is:
- **CommonLeader**

    Eventually, all alive processes agree on the same leader, and that leader is alive.

Formally, this captures the intuition of an **eventual correct leader**.

This property is not included in the default model checking configuration, as it is expected to fail under arbitrary suspicion.

## Exploration
When ```CommonLeader``` is checked with TLC, the model produces counterexamples.

A typical behavior is:
- processes select leaders independently
- some processes crash
- the remaining processes may continue to follow a leader that has already crashed
- no action forces re-election or correction

As a result, the system can reach a state where:
- all remaining processes agree on a leader
- but that leader is no longer alive

or:
- processes never converge due to continuously changing suspicions

This demonstrates that **agreement on a correct leader is not guaranteed**.

## Limitations
The model allows:
- arbitrary changes in suspected
- infinite oscillation of beliefs
- lack of progress (stuttering)

There is no assumption ensuring that:
- suspicions become accurate
- or that they eventually stabilize

Therefore, the model represents a **generic failure detector**, not a specific one like Ω.

## Introducing Ω
The previous exploration shows that, under arbitrary suspicion, the system cannot guarantee convergence to a correct leader.

This is not a limitation of the model, but a fundamental limitation of asynchronous systems.

Chandra and Toueg address this by introducing **failure detectors** as abstractions, and in particular the **Ω failure detector**.

Ω does not eliminate uncertainty. Instead, it provides a minimal guarantee:

> there exists a correct process that is eventually trusted by all correct processes.

In terms of this model, this can be expressed as:
- there exists a process p such that:
    - p is alive
    - eventually, no correct process suspects p

Under this assumption:
- all processes will eventually consider p as a valid candidate
- since leader selection is deterministic, they will all choose the same process
- and that process is guaranteed to be alive

This transforms the system from one where convergence is not guaranteed, to one where convergence becomes inevitable.

Importantly, Ω is not implemented in this model.

It is treated as an **assumption about the environment**, not as a mechanism within the system.

This reflects a key idea in distributed systems:

> correctness depends not only on the algorithm, but on the assumptions under which it operates.

## Lessons Learned
This model highlights a fundamental insight:

> agreement in distributed systems does not come from algorithms alone, but from assumptions about the environment.

Without additional guarantees, processes cannot reliably converge to a correct leader.

By introducing the Ω failure detector, which ensures that eventually all processes trust the same correct process, convergence becomes possible.

The key takeaway is:

> correctness is not derived from perfect knowledge, but from eventual consistency in local views.