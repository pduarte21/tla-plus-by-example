# tla-plus-by-example
A curated collection of TLA+ specifications for modeling and formally verifying distributed systems, designed as both a learning resource and a professional portfolio.

This repository serves as:
- A learning resource for TLA+
- A collection of formally specified system models
- A practical guide to using TLC for model checking

## Goals
- Learn TLA+ through concrete examples
- Understand how to model system behaviour
- Define and verify invariants
- Explore bugs using model checking
- Build intuition for distributed systems

## Repository Structure
Projects are organised in the ```models/``` folder by increasing complexity:

```bash
01-basics/
02-state-machines/
03-distributed-systems/
04-consensus/
```

Each project contains:
- A TLA+ specification (```.tla```)
- A TLC configuration (```.cfg```)
- A detailed explanation

## What You'll Find in Each Project
Every project is structured to emphasize **understanding over syntax**:
- Problem description
- Model explanation (state variables and design choices)
- Actions (state transitions)
- Invariants and safety properties
- Bugs discovered via TLC (when applicable)
- Exploration of counterexamples
- Lessons learned

## How to Use This Repository
1. Start from ```models/01-basics```
2. Run models using TLC
3. Explore state spaces and invariants
4. Read explanations and compare with your intuition
5. Modify the models and experiment

## Setup & Execution

### Requirements
- Java 17 or higher
- Make (recommended for convenience)

### Run all models
```bash
make check-all
```
This will run the TLC model checker on all specifications in the repository.

### Run a specific model
```bash
make run MODEL=models/02-state-machines/mutual-exclusion/MutualExclusion.tla
```

### List available models
```bash
make list
```

### Clean TLC artifacts
```bash
make clean
```

### Using TLC directly
Alternatively, you can run TLC manually:
```bash
java -jar tools/tla2tools.jar path/to/model.tla -config path/to/model.cfg
```

## Continuous Verification

All models are automatically checked using TLC via GitHub Actions.

Every push and pull request automatically triggers:
- exhaustive state-space exploration (within finite bounds)
- invariant checking
- detection of safety violations and deadlocks

This ensures that all models remain correct as the repository evolves and prevents regressions.

## Philosophy
This repository follows the approach advocated by Leslie Lamport:
> Model behavior, not implementation.

This repository focuses on describing system behavior abstractly and exploring all possible executions, rather than simulating concrete implementations.

The focus is on:
- clarity over complexity
- minimal models
- explicit state
- reasoning about correctness

## Design Principles

Each model in this repository follows a consistent approach:

- Start with a minimal specification
- Make all state explicit
- Define type invariants early
- Verify safety properties before introducing liveness properties
- Incrementally refine the model

This reflects best practices for using TLA+ in real-world system design.

## Topics Covered
- State machines
- Mutual exclusion
- Distributed protocols
- Message passing systems
- Consistency models
- Consensus

## Why This Exists
This repository was created as part of a systematic study of TLA+ and formal methods, with the goal of:
- mastering system modeling
- developing strong reasoning skills
- building reliable distributed systems

## Prerequisites
- Basic programming knowledge
- Interest in distributed systems

## Contributions
This is primarily a personal learning project, but suggestions and discussions are welcome.

## Final Note
TLA+ is not about writing code - it's about thinking precisely.

If this repository helps you think better about systems, it has achieved its goal.

## License

This project is licensed under the MIT License.