---- MODULE VectorClocks ----
EXTENDS Naturals, FiniteSets

CONSTANTS Node, MaxNet, MaxClock

VARIABLES vc, network, vc_prev

vars == << vc, network, vc_prev >>

Messages ==
    {
        [from |-> f, to |-> t, data |-> d]:
            f \in Node,
            t \in Node,
            d \in [Node -> 0..MaxClock]
    }

Init == 
    /\ vc = [f \in Node |-> [t \in Node |-> 0]]
    /\ vc_prev = vc
    /\ network = {}

----------------------------- 

Put(n) ==
    /\ n \in Node
    /\ vc[n][n] < MaxClock
    /\ vc_prev' = vc
    /\ vc' = [vc EXCEPT ![n][n] = @ + 1]
    /\ UNCHANGED network
    
Send(f, t) ==
    /\ f \in Node
    /\ t \in Node
    /\ Cardinality(network) < MaxNet
    /\ vc[f][f] < MaxClock
    /\ f # t 
    /\ LET d == [n \in Node |-> IF n = f THEN vc[f][n] + 1 ELSE vc[f][n]] IN
        /\ LET m == [from |-> f, to |-> t, data |-> d] IN 
            /\ network' = network \cup {m}
            /\ vc_prev' = vc
            /\ vc' = [vc EXCEPT ![f] = d]
    
Receive(m) ==
    /\ m \in network
    /\ LET d == [n \in Node |-> IF vc[m.to][n] > m.data[n] THEN vc[m.to][n] ELSE m.data[n]] IN 
        /\ d[m.to] < MaxClock
        /\ LET local_inc == [n \in Node |-> IF n = m.to THEN d[m.to] + 1 ELSE d[n]] IN
            /\ vc_prev' = vc
            /\ vc' = [vc EXCEPT ![m.to] = local_inc]
            /\ network' = network \ {m}

Next ==
    \/ \E n \in Node: Put(n)
    \/ \E f, t \in Node: Send(f, t)
    \/ \E m \in network: Receive(m)
    
    
Spec ==
    Init /\ [][Next]_vars

-----------------------------

TypeInvariant ==
    /\ vc \in [Node -> [Node -> 0..MaxClock]]
    /\ network \subseteq Messages
    /\ vc_prev \in [Node -> [Node -> 0..MaxClock]]

Leq(v1, v2) ==
    \A i \in Node: v1[i] <= v2[i]

HappensBefore(v1, v2) ==
    /\ Leq(v1, v2)
    /\ v1 # v2

Concurrent(v1, v2) ==
    ~Leq(v1, v2) /\ ~Leq(v2, v1)

ReceivePreservesKnowledge ==
    \A m \in Messages:
        Receive(m) => Leq(m.data, vc'[m.to])

Monotonic ==
    \A n \in Node:
        Leq(vc_prev[n], vc[n])

ConcurrencyState ==
    \E n1, n2 \in Node:
        n1 # n2 /\ Concurrent(vc[n1], vc[n2])

====