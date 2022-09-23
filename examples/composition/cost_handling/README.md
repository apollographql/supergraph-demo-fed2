This example is artificially creating subgraphs where there is, in theory, a lot of way to plan the query (and it's not
100% trivial how to compute the best plan). This is to ensure the cost-comparison part of the query planner (the query
planner essentially try to compute all the possible plan and pick the one with the lower cost; there is thus a cost
function, which currently mainly tries to limit the number of fetches and the depth of the pipeline) works reasonably
well.
