# Distributed Queue

## Goal
The goal of this model is to represent a queue system and verify that it preserves FIFO (First-In, First-Out) behaviour while ensuring that no tasks are lost or duplicated.

## Problem
This model describes a system where multiple processes interact with a shared queue.

Each process can:
- produce tasks (enqueue)
- consume tasks (dequeue)

The main requirement is that tasks must be processed in the same order in which they were inserted into the queue.

## Model
The system is defined by three state variables:
- **queue**: contains the tasks currently waiting to be processed
- **dequeue**: contains the tasks that have already been removed from the queue
- **history**: records all tasks that have been inserted into the system, preserving their insertion order

The ```history``` variable represents the complete sequence of produced tasks. The variables ```queue``` and ```dequeue``` partition this sequence into pending and processed tasks.

## Actions
The system evolves through two types of transitions:
- **Enqueue**: a task is added to the system. The task is appended to both ```queue``` and ```history```.
- **Dequeue**: the task at the front of the queue is removed. The task is removed from ```queue``` and appended to ```dequeue```.

## Properties Checked

### Type Invariant
All state variables are sequences of valid tasks:
- ```queue ∈ Seq(Task)```
- ```history ∈ Seq(Task)```
- ```dequeue ∈ Seq(Task)```

### Task Preservation (FIFO)
The following invariant is enforced:
```
dequeue \o queue = history
```
This property ensures that:
- no tasks are lost
- no tasks are duplicated
- the order of tasks is preserved

This implies ```FIFO``` behaviour because ```dequeue``` must always correspond to the prefix of ```history```, meaning elements are removed in the exact order they were inserted.

## Exploration
An initial attempt to express FIFO behaviour using subsequences proved insufficient, as it allowed invalid behaviours where elements could be skipped.

The correct formulation was achieved by recognizing that FIFO requires the sequence of dequeued elements to be a prefix of the sequence of inserted elements. This insight led to a stronger invariant based on sequence concatenation.

Removing the update of ```history``` in the ```Enqueue``` action leads to a violation of the invariant. This demonstrates that the model relies on ```history``` to correctly track the insertion order and highlights the importance of explicitly updating all state variables.

## Limitations
This model represents an abstract queue and does not capture realistic distributed system aspects such as communication delays, message passing, or concurrent conflicts.

Additionally, fairness and liveness properties are not enforced, so starvation is still possible.

To ensure a finite state space for TLC model checking, the model is bounded by limiting the size of ```history```. As a consequence, the system may reach terminal states where no further actions are enabled. These states are reported as deadlocks by TLC, but they are artifacts of the imposed bounds rather than violations of the system's correctness.

Deadlock checking is therefore disabled when verifying invariants.

## Lessons Learned
- FIFO is not equivalent to subsequence inclusion
- Correct properties require an appropriate state representation
- Strong structural invariants can replace multiple weaker properties
- Simpler models can require deeper reasoning than more complex systems