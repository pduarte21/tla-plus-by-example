---- MODULE BaseGossip ----
EXTENDS FiniteSets, Naturals

CONSTANTS Proc, Data, MaxNet

VARIABLES knowledge, network

vars == << knowledge, network >>

Message ==
    {
        [to |-> t, data |-> d]:
            t \in Proc,
            d \in SUBSET Data
    }

Init ==
    /\ knowledge \in [Proc -> SUBSET Data]
    /\ UNION {knowledge[p] : p \in Proc} = Data
    /\ network = {}

-------------------------------

Send(p, t) ==
    /\ p \in Proc
    /\ t \in Proc
    /\ p # t
    /\ Cardinality(network) < MaxNet
    /\ LET m == [to |-> t, data |-> knowledge[p]] IN
        /\ network' = network \cup {m}
        /\ UNCHANGED knowledge
    
Receive(m) ==
    /\ m \in network
    /\ LET p == m.to IN 
        /\ knowledge' = [knowledge EXCEPT ![p] = @ \cup m.data]
        /\ network' = network \ {m}

ReceiveSpec ==
    \E m \in network: Receive(m)

Next ==
    \/ \E p, t \in Proc: 
        /\ Send(p, t)
    \/ ReceiveSpec

Spec ==
    Init /\ [][Next]_vars
    /\ \A p, t \in Proc: WF_vars(Send(p, t))
    /\ WF_vars(ReceiveSpec)

-------------------------------

TypeInvariant ==
    /\ knowledge \in [Proc -> SUBSET Data]
    /\ network \subseteq Message

Convergence ==
    <> (\A p \in Proc: knowledge[p] = Data)

====