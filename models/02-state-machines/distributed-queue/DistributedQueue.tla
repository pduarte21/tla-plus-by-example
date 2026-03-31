---- MODULE DistributedQueue ----
EXTENDS Sequences, Naturals

CONSTANT Proc, Task, MaxQueue

VARIABLES queue, dequeue, history

vars == << queue, dequeue, history >>

Init ==
    /\ queue = << >>
    /\ history = << >>
    /\ dequeue = << >>

---------------------------------

Enqueue(p, t) ==
    /\ p \in Proc
    /\ t \in Task
    /\ Len(queue) < MaxQueue
    /\ Len(history) < MaxQueue
    /\ queue' = Append(queue, t)
    /\ history' = Append(history, t)
    /\ UNCHANGED dequeue
    
Dequeue(p) ==
    /\ p \in Proc
    /\ Len(queue) # 0
    /\ dequeue' = Append(dequeue, Head(queue))
    /\ queue' = Tail(queue)
    /\ UNCHANGED history
    
Next ==
    \/ \E p \in Proc, t \in Task: Enqueue(p, t)
    \/ \E p \in Proc: Dequeue(p)
    
Spec ==
    Init /\ [][Next]_vars

---------------------------------

TypeInvariant ==
    /\ queue \in Seq(Task)
    /\ history \in Seq(Task)
    /\ dequeue \in Seq(Task)

FIFO ==
    dequeue = SubSeq(history, 1, Len(dequeue))

TaskPreservation ==
    dequeue \o queue = history

====