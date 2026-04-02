---- MODULE RefinedGossip ----
EXTENDS FiniteSets, Naturals

CONSTANTS Proc, Data

VARIABLES knowledge, network

vars == << knowledge, network >>

Init ==
    /\ knowledge \in [Proc -> SUBSET Data]
    /\ UNION {knowledge[p] : p \in Proc} = Data
    /\ network = [p \in Proc |-> [t \in Proc |-> {}]]

-------------------------------

Send(p, t) ==
    /\ p \in Proc
    /\ t \in Proc
    /\ p # t
    /\ network[p][t] = {}
    /\ knowledge[p] # {}
    /\ network' = [network EXCEPT ![p][t] = knowledge[p]]
    /\ UNCHANGED knowledge
    
Receive(p, t) ==
    /\ p \in Proc
    /\ t \in Proc
    /\ p # t
    /\ network[p][t] # {}
    /\ LET data == network[p][t] IN
        /\ knowledge' = [knowledge EXCEPT ![t] = @ \cup data]
        /\ network' = [network EXCEPT ![p][t] = {}]

Next ==
    \/ \E p, t \in Proc: 
        /\ Send(p, t)
    \/ \E p, t \in Proc: Receive(p, t)

Spec ==
    Init /\ [][Next]_vars
    /\ (\A p, t \in Proc: WF_vars(Send(p, t)))
    /\ (\A p, t \in Proc: WF_vars(Receive(p, t)))

-------------------------------

TypeInvariant ==
    /\ knowledge \in [Proc -> SUBSET Data]
    /\ network \in [Proc -> [Proc -> SUBSET Data]]

Convergence ==
    <> (\A p \in Proc: knowledge[p] = Data)

====