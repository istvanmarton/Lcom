This repository contains an implementation of estimating the Smax value of a matrix. The code was used to calculate the numerical results of the article "Beating one bit of communication with and without quantum pseudo-telepathy, István Márton, Erika Bene, Péter Diviánszky, Tamás Vértesi, arXiv: 2308.10771".

Introduction
Integer Smax problem
Let A be an mxn matrix of integer values. The goal is to compute the maximal value of the sum of the two L1 values of the two matrices derived from the original A matrix.

The code is written in Matlab (Smax_Matlab.m) and Octave (Smax_Octave.m) programming languages. The code uses the 'kmn-programming' program (https://github.com/divipp/kmn-programming) and therefore before usage, it must be installed into your working directory. The 'kmn-programming' and therefore the 'Smax_Matlab.m' and 'Smax_Octave.m' work on Linux environment.

Usage
After invoking the 'Smax_Matlab.m' or 'Smax_Octave.m' scripts it will asks for three questions:
1. The name of the file containing the matrix. The entries of the input matrix must be integers.
2. The number of iterations. The code randomly partitions the input matrix by rows and calculates the two L1 values of the resulting partitioned matrices and therefore the possible Smax value as well. Then the code optimizes the partitioning of the matrix and the corresponding possible Smax value with a greedy algorithm until it converges to its maximal value belonging to the particular partition. The number of iterations means the number of times the code partitions the input matrix and optimizes the corresponding possible Smax value. In case the user writes 'inf', the program will work endlessly. The code will write out the best Smax value, the L1 values of the two partitioned matrices, and the corresponding partition strategy as well. The strategy is a vector having the same number of elements as many rows the incoming matrix has and it consists of two numbers (one and two). The two numbers refer to the two partitions of the input matrix. When the i th element of a vector is one it means the i th row of the input matrix belongs to the first partitioned matrix.
3. The number of cores as the power of 2. The 'kmn-programming' can work parallel and can use several cores/threads. In case the user writes '0' to this question, it means the 'kmn-programming' will use 2^0 = 1 core. If there are several cores in the user's computer, parallelism can speed up the execution time.
