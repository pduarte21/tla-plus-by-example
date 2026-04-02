---- MODULE MutualExclusion ----

CONSTANTS Proc, State

VARIABLE pc

vars == << pc >>

--------------------------------

Init ==
    /\ pc = [p \in Proc |-> "thinking"]

Try(p) ==
    /\ p \in Proc
    /\ pc[p] = "thinking"
    /\ pc' = [pc EXCEPT ![p] = "waiting"]
    
Enter(p) ==
    /\ p \in Proc
    /\ \A x \in Proc: pc[x] # "critical"
    /\ pc[p] = "waiting"
    /\ pc' = [pc EXCEPT ![p] = "critical"]
    
Exit(p) ==
    /\ p \in Proc
    /\ pc[p] = "critical"
    /\ pc' = [pc EXCEPT ![p] = "thinking"]
    
Next ==
    \/ \E p \in Proc: 
        \/ Try(p)
        \/ Enter(p)
        \/ Exit(p)
    
Spec ==
    Init /\ [][Next]_vars

--------------------------------

TypeInvariant ==
    /\ pc \in [Proc -> State]
    
MutualExclusion ==
    \A x, y \in Proc: 
        x # y => ~(pc[x] = "critical" /\ pc[y] = "critical")

====