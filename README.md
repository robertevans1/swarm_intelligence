# Swarm Intelligence

A demonstration emergent flocking behaviour using the boids algorithm

## Why?

Swarm intelligence is phenomenon where a group as able to achieve a common and sometimes complex goal, even though each individual follows a simple set of rules.
In nature organisms such as bees, ants, birds and fish, display swarm intelligence when building hives or nests, or flocking together.
Swarm intelligence is of interest in robotics, as there some advantages to using many small, simple robots to accomplish a task rather than one larger one, amongst these advantages are reduced cost and complexity, parallelisation of work, and robustness to any single robot failure.

## What?

This repo builds a flutter app that simulates a shoal of fish swimming together. The direction each fish swims is affected by looking at it's nearset neighbours. The factors that influence with way the fish should swim to remain in the shoal are:

- What is the general direction my close neighbors are swimming, try to align
- Are any neighbors very close, turn away to give some space if so.
- In which direction are neighbors more densely packed, try to swim toward this to keep in middle of the shoal
- Is the edge of the swimming area close, turn away if so

Modifying the relative strength of these different factors changes the behaviour of the shoal. This program allows the user to play around with each component.
