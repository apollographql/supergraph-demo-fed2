This example was mostly created to show an initial inefficiency of the process that generates the plan.
It creates a case where, from subgraph A, we need to do: 1) a fetch to B followed by a fetch to D and 2) a fetch to C.
Initial code was generating a plan where essentially the fetch to D had to wait on the fetch to C, this example shows
it's not the case anymore.
