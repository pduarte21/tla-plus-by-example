# Mutual Exclusion

## Goal
Model a simple mutual exclusion system and verify its safety properties with TLC.

## Problem
This model describes a system in which multiple processes compete for access to a critical section. The main goal is to ensure that at most one process can be in the critical section at any time.

## Model

Each process is represented by its current state:
- **"thinking"**: the process is not trying to enter the critical section
- **"waiting"**: the process has requested access and is waiting
- **"critical"**: the process is currently inside the critical section

The global system state is defined by a function ```pc``` mapping each process to its current state.

## Actions
The system evolves through three types of transitions:
- **Try**: A process expresses interest in entering the critical section by moving from ```"thinking"``` to ```"waiting"```.

- **Enter**: A waiting process enters the critical section **only if no other process is currently in it**.

- **Exit**: A process leaves the critical section and returns to ```"thinking"```.

These actions define how the system state evolves over time.

## Properties Checked

### Type Invariant
The variable ```pc``` is always a function from ```Proc``` to the set of valid states.

### Mutual Exclusion
At most one process can be in the ```"critical"``` state any time.

This property is enforced by restricting the ```Enter``` action: a process can only enter the critical section if no other process is already inside.


## Exploration
To understand the role of the Enter guard, I removed the condition requiring that no process is already in the critical section.

TLC then finds a counterexample in which one process enters the critical section and another process is later allowed to enter as well, violating the mutual exclusion property.

This shows that safety depends not only on stating the invariant, but also on defining transitions that prevent invalid states from becoming reachable.

## Limitations
This is an abstract specification of mutual exclusion, not a concrete algorithm such as Peterson's or Lamport's Bakery algorithm.

The model guarantees safety, but it does not guarantee progress. A process may remain in the ```"waiting"``` state indefinitely, so starvation is still possible.

## Lessons Learned
- Safety properties must be enforced through transition guards
- The set of reachable states depends entirely on how actions are defined
- Model checking helps identify missing constraints quickly
- A correct invariant alone is not enough; the model must be constructed so that violations are unreachable