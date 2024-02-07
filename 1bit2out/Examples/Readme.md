The following files can be found in this directory:

- The text files `W63.txt` and `W90.txt` text contain the respective $63\times 63$ and $90\times 90$ integer matrices defining the correlation Bell-type expressions.

- The text files `P63.txt` and `P90.txt` consist of the respective partitions of the above $W$ matrices to maximize the sum of the local bounds of the Bell inequalities corresponding to the two partitioned matrices.

- `S63_0.txt`, `S63_1.txt`, `S90_0.txt`, `S90_1.txt` are strategy vectors belonging to the partitioned matrices.

- The Matlab script `check.m` with the above matrices and vectors as input, which calculates the best $S_{max}$ value (i.e. a lower bound to $L1\text{bit}$).

- The Matlab scripts `strategies_63.m` and `strategies_90.m` which generate the respective text files `E1bit_63.txt` and `E1bit_90.txt` from the original matrices, partitions and strategies.

- The gnuplot script `oneBit.gnu` plots the $W$ matrices on the left and the $E1bit$ matrices on the right. The output file is `oneBit.eps`.
