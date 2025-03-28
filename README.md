# Lcom

This repository accompanies the publication

> I. Márton, E. Bene, P. Diviánszky, T. Vértesi, ["Beating one bit of communication with and without quantum pseudo-telepathy"](https://www.nature.com/articles/s41534-024-00874-1?utm_source=rct_congratemailt&utm_medium=email&utm_campaign=oa_20240822&utm_content=10.1038/s41534-024-00874-1), npj Quantum Information **10**, 79 (2024).

There are two independent directories:

- `1bit2out` contains functions for heuristic optimization of the computation of the one-bit classical bound *L1bit* for a correlation Bell-type inequality defined by an $m\times n$ integer matrix *A*. 

- `generic` contains functions for a branch-and-bound optimization of the so-called Lk norm, which is the classical bound augmented by *log<sub>2 </sub>k* bits of communication of a bipartite Bell-type inequality. For *k=2* we have the classical one-bit bound. Note that the Bell-type coefficients must be given as integers, the setup can have an arbitrary number of outcomes, and the optimization gives the exact value of the Lk norm.
