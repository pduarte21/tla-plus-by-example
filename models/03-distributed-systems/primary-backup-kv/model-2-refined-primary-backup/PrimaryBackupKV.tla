---- MODULE PrimaryBackupKV ---- 
EXTENDS FiniteSets, Naturals

CONSTANTS Node, Key, Val, None

VARIABLES store, role, network, alive, pending

vars == << store, role, network, alive, pending >>

Role ==
    {"Primary", "Backup"}
        
Messages ==
    {
        [type |-> "Update", from |-> f, to |-> t, key |-> k, val |-> v]:
            f \in Node, t \in Node, k \in Key, v \in Val
    }
    \cup
    {
        [type |-> "Ack", from |-> f, to |-> t, key |-> k, val |-> v]:
            f \in Node, t \in Node, k \in Key, v \in Val
    }
    
Init ==
    /\ store = [n \in Node |-> [k \in Key |-> 0]]
    /\ role = [n \in Node |-> "Backup"]
    /\ network = {}
    /\ alive = [n \in Node |-> TRUE]
    /\ pending = [p \in Node |-> None]

--------------------------------

Promote(p) ==
    /\ \A q \in Node:
        role[q] = "Primary" => ~alive[q]
    /\ alive[p]
    /\ role[p] = "Backup"
    /\ LET all_backup == [n \in Node |-> "Backup"] IN 
        /\ role' = [all_backup EXCEPT ![p] = "Primary"]    
        /\ UNCHANGED << network, store, alive, pending >>
    
ClientRequest(p, k, v) ==
    /\ k \in Key
    /\ v \in Val
    /\ role[p] = "Primary"
    /\ alive[p]
    /\ pending[p] = None
    /\ pending' = [pending EXCEPT ![p] = [key |-> k, val |-> v]]
    /\ network' =
        network \cup {
            [type |-> "Update", from |-> p, to |-> t, key |-> k, val |-> v] :
            t \in Node \ {p}
        }
    /\ UNCHANGED << store, role, alive >>
        
ApplyUpdate(m) ==
    /\ m \in network
    /\ m.type = "Update"
    /\ m.to # m.from
    /\ alive[m.to]
    /\ store' = [store EXCEPT ![m.to][m.key] = m.val]
    /\ network' = (network \ {m}) \cup {
            [type |-> "Ack", from |-> m.to, to |-> m.from, key |-> m.key, val |-> m.val]
        }
    /\ UNCHANGED << role, alive, pending >>

ReceiveAck(m) ==
    /\ m \in network
    /\ m.type = "Ack"
    /\ role[m.to] = "Primary"
    /\ alive[m.to]
    /\ pending[m.to] = [key |-> m.key, val |-> m.val]
    /\ store' = [store EXCEPT ![m.to][m.key] = m.val]
    /\ pending' = [pending EXCEPT ![m.to] = None]
    /\ network' = network \ {m}
    /\ UNCHANGED << role, alive >>
    

Crash(p) ==
    /\ p \in Node
    /\ alive[p]
    /\ alive' = [alive EXCEPT ![p] = FALSE]
    /\ role' = [role EXCEPT ![p] = "Backup"]
    /\ pending' = [pending EXCEPT ![p] = None]
    /\ UNCHANGED << store, network >>

Next ==
    \/ \E p \in Node: Promote(p)
    \/ \E p \in Node, k \in Key, v \in Val: ClientRequest(p, k, v)
    \/ \E m \in network: ApplyUpdate(m)
    \/ \E p \in Node: Crash(p)
    \/ \E m \in network: ReceiveAck(m)

Spec ==
    Init /\ [][Next]_vars

--------------------------------

TypeInvariant ==
    /\ store \in [Node -> [Key -> Val]]
    /\ role \in [Node -> Role]
    /\ network \subseteq Messages
    /\ alive \in [Node -> BOOLEAN]
    /\ pending \in [Node -> ({None} \cup [key : Key, val : Val])]

SinglePrimary ==
    Cardinality({p \in Node : role[p] = "Primary"}) <= 1

PrimaryAlive ==
    \A p \in Node:
        role[p] = "Primary" => alive[p]

====