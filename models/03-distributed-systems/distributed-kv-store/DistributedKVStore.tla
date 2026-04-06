---- MODULE DistributedKVStore ----
EXTENDS FiniteSets, Naturals

CONSTANTS Node, Key, Value, None, MaxVersion

VARIABLE store, network

Messages ==
    {
        [from |-> f, to |-> t, data |-> d]:
            f \in Node,
            t \in Node,
            d \in [Key -> [val : Value \cup {None}, ver : 0..MaxVersion]]
    }

vars == << store, network >>

Init ==
    /\ store = [n \in Node |-> [k \in Key |-> [val |-> None, ver |-> 0]]]
    /\ network = {}

-----------------------------------

Get(n, k) ==
    /\ n \in Node
    /\ k \in Key
    /\ UNCHANGED vars

Put(n, k, v) ==
    /\ n \in Node
    /\ k \in Key
    /\ v \in Value
    /\ store[n][k].ver < MaxVersion
    /\ store' = [store EXCEPT ![n][k].val = v, ![n][k].ver = @ + 1]
    /\ UNCHANGED network

Send(f, t) ==
    /\ f \in Node
    /\ t \in Node
    /\ f # t
    /\ \E k \in Key: store[f][k].val # None
    /\ LET m == [from |-> f, to |-> t, data |-> store[f]] IN 
        /\ network' = network \cup {m}
        /\ UNCHANGED store
    
Receive(m) ==
    /\ m \in network
    /\ store' = [store EXCEPT ![m.to] = [k \in Key |-> 
        IF (m.data[k].ver > store[m.to][k].ver) \/ (m.data[k].ver = store[m.to][k].ver /\ m.from > m.to) 
        THEN m.data[k]
        ELSE store[m.to][k]]]
    /\ network' = network \ {m}

Next ==
    \/ \E n \in Node, k \in Key: Get(n, k)
    \/ \E n \in Node, k \in Key, v \in Value: Put(n, k, v)
    \/ \E f, t \in Node: Send(f, t)
    \/ \E m \in network: Receive(m)

Spec ==
    Init /\ [][Next]_vars
    /\ \A f, t \in Node:
        WF_vars(Send(f, t))
    /\ \A m \in Messages:
        WF_vars(Receive(m))

-----------------------------------

TypeInvariant ==
    /\ store \in [Node -> [Key -> [val : Value \cup {None}, ver : 0..MaxVersion]]]
    /\ network \subseteq Messages

Agreement ==
    \A p, q \in Node, k \in Key:
        store[p][k] = store[q][k]

PutStep ==
    \E n \in Node, k \in Key, v \in Value:
        Put(n, k, v)

NoMorePuts ==
    <>[] ~ENABLED PutStep

EventuallyStableAgreement ==
    <>[] Agreement

ConditionalConvergence ==
    NoMorePuts => EventuallyStableAgreement

====