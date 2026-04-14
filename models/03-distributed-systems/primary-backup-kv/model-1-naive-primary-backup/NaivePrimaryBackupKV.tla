---- MODULE NaivePrimaryBackupKV ---- 
EXTENDS FiniteSets, Naturals

CONSTANTS Node, Key, Val

VARIABLES store, role, network, alive

vars == << store, role, network, alive >>

Role ==
    {"Primary", "Backup"}
        
Messages ==
    {
        [type |-> "Update", from |-> f, to |-> t, key |-> k, val |-> v]:
            f \in Node, t \in Node, k \in Key, v \in Val
    }
    
Init ==
    /\ store = [n \in Node |-> [k \in Key |-> 0]]
    /\ role = [n \in Node |-> "Backup"]
    /\ network = {}
    /\ alive = [n \in Node |-> TRUE]

--------------------------------

Promote(p) ==
    /\ \A q \in Node:
        role[q] = "Primary" => ~alive[q]
    /\ alive[p]
    /\ role[p] = "Backup"
    /\ LET all_backup == [n \in Node |-> "Backup"] IN 
        /\ role' = [all_backup EXCEPT ![p] = "Primary"]    
        /\ UNCHANGED << network, store, alive >>
    
ClientRequest(p, k, v) ==
    /\ k \in Key
    /\ v \in Val
    /\ role[p] = "Primary"
    /\ alive[p]
    /\ store' = [store EXCEPT ![p][k] = v]
    /\ network' =
        network \cup {
            [type |-> "Update", from |-> p, to |-> t, key |-> k, val |-> v] :
            t \in Node \ {p}
        }
    /\ UNCHANGED << role, alive >>
        
ApplyUpdate(m) ==
    /\ m \in network
    /\ m.type = "Update"
    /\ m.to # m.from
    /\ alive[m.to]
    /\ store' = [store EXCEPT ![m.to][m.key] = m.val]
    /\ network' = network \ {m}
    /\ UNCHANGED << role, alive >>

Crash(p) ==
    /\ p \in Node
    /\ alive[p]
    /\ alive' = [alive EXCEPT ![p] = FALSE]
    /\ role' = [role EXCEPT ![p] = "Backup"]
    /\ UNCHANGED << store, network >>

Next ==
    \/ \E p \in Node: Promote(p)
    \/ \E p \in Node, k \in Key, v \in Val: ClientRequest(p, k, v)
    \/ \E m \in network: ApplyUpdate(m)
    \/ \E p \in Node: Crash(p)
    

Spec ==
    Init /\ [][Next]_vars

--------------------------------

TypeInvariant ==
    /\ store \in [Node -> [Key -> Val]]
    /\ role \in [Node -> Role]
    /\ network \subseteq Messages
    /\ alive \in [Node -> BOOLEAN]

SinglePrimary ==
    Cardinality({p \in Node : role[p] = "Primary"}) <= 1

PrimaryAlive ==
    \A p \in Node:
        role[p] = "Primary" => alive[p]

====