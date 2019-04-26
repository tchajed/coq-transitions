# Coq transition relations library

Transitions is a library for writing individual steps for transition systems
using a combinator-based approach. Transitions are represented in a
Kleene algebra + monad + error structure that can model functional programs,
non-determinism, state, and undefined behavior.

Some tools (which are work-inprogress) that can make use of this representation
include:

* Rewriting over Kleene algebra (in)equations, modulo associativity and monad laws.
* Representing a subset of transitions as deterministic functions, for proving
  concrete transitions.
* Writing or deriving reference interpreters for validating a specification.
