---- MODULE ChandraTouegFailureDetector ----
EXTENDS FiniteSets, Naturals

CONSTANT Node

VARIABLES suspected, leader, alive

vars == << suspected, leader, alive >>

Init ==
    /\ suspected = [n \in Node |-> {}]
    /\ leader \in [Node -> Node]
    /\ alive = [n \in Node |-> TRUE]

-------------------------------------------- 

Suspect(p, q) ==
    /\ p \in Node
    /\ q \in Node
    /\ p # q
    /\ q \notin suspected[p]
    /\ suspected' = [suspected EXCEPT ![p] = @ \cup { q }]
    /\ UNCHANGED << leader, alive >>
    
Restore(p, q) ==
    /\ p \in Node
    /\ q \in Node
    /\ p # q
    /\ q \in suspected[p]
    /\ suspected' = [suspected EXCEPT ![p] = @ \ {q}]
    /\ UNCHANGED << leader, alive >>
    
Max(S) ==
    CHOOSE x \in S: 
        \A y \in S: x >= y

Elect(p) ==
    /\ p \in Node
    /\ LET possible_leaders == Node \ suspected[p] IN
        /\ possible_leaders # {}
        /\ leader' = [leader EXCEPT ![p] = Max(possible_leaders)
            ]
        /\ UNCHANGED << suspected, alive >>
    
Crash(p) ==
    /\ p \in Node
    /\ alive[p]
    /\ alive' = [alive EXCEPT ![p] = FALSE]
    /\ UNCHANGED << suspected, leader >>
    
Next ==
    \/ \E p \in Node: Crash(p)
    \/ \E p \in Node: Elect(p)
    \/ \E p, q \in Node: Suspect(p, q)
    \/ \E p, q \in Node: Restore(p, q)

Spec ==
    Init /\ [][Next]_vars

-------------------------------------------- 

TypeInvariant ==
    /\ suspected \in [Node -> SUBSET Node]
    /\ leader \in [Node -> Node]
    /\ alive \in [Node -> BOOLEAN]

SameLeader ==
    \A p, q \in Node:
        alive[p] /\ alive[q] => leader[p] = leader[q]

CorrectLeader ==
    \A p \in Node:
        alive[p] => alive[leader[p]]

CommonLeader ==
    <>[] (SameLeader /\ CorrectLeader)

Omega ==
    \E p \in Node:
        /\ alive[p]
        /\ <>[] (\A q \in Node:
                alive[q] => p \notin suspected[q])

====