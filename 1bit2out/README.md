This repository contains an implementation of estimating the *S<sub>max</sub>* value of a *A* matrix (i.e., the one-bit classical bound *L1bit* of a correlation Bell inequality specified by the matrix *A*). The code was used to calculate the numerical results of Section V in the e-print [Beating one bit of communication with and without quantum pseudo-telepathy](https://arxiv.org/abs/2308.10771) by István Márton, Erika Bene, Péter Diviánszky, and Tamás Vértesi.


## Integer Smax (L1bit) problem

Let *A* be an $m\times n$ matrix of integer values. The goal is to compute the one-bit classical bound (L1bit) for correlation type Bell inequalities, where *A* is the matrix of coefficients of the correlation Bell expression. The program computes *S<sub>max</sub>*, i.e., the maximal value of the sum of the two *L<sub>1</sub>* values of the two matrices derived from the original *A* matrix, where the two matrices correspond to arbitrary bipartitions by rows of the matrix *A*.

The code is written in Matlab (Smax_Matlab.m) and Octave (Smax_Octave.m) programming languages. The code uses the 'kmn-programming' program (https://github.com/istvanmarton/kmn-programming) and therefore before usage, it must be installed into your working directory. The 'kmn-programming' and therefore the 'Smax_Matlab.m' and 'Smax_Octave.m' work on Linux environment.

## Usage

After invoking the 'Smax_Matlab.m' or 'Smax_Octave.m' scripts it will ask for three questions:

1. The name of the file containing the matrix. The entries of the input matrix must be integers.

2. The number of iterations. The code randomly partitions the input matrix by rows and calculates the two *L1* values of the resulting partitioned matrices and therefore the possible *S<sub>max</sub>* value as well. Then the code optimizes the partitioning of the matrix and the corresponding possible *S<sub>max</sub>* value with a greedy algorithm until it converges to its maximal value belonging to the particular partition. The number of iterations means the number of times the code partitions the input matrix and optimizes the corresponding possible *S<sub>max</sub>* value. In case the user writes 'inf', the program will work endlessly. The code will write out the best *S<sub>max</sub>* value, the *L1* values of the two partitioned matrices, and the corresponding partition strategy as well. The strategy is a vector having the same number of elements as many rows the incoming matrix has and it consists of two numbers (one and two). The two numbers refer to the two partitions of the input matrix. When the *i*-th element of a vector is one it means the *i*-th row of the input matrix belongs to the first partitioned matrix.

3. The number of cores as the power of 2. The 'kmn-programming' can work parallel and can use several cores/threads. In case the user writes '0' to this question, it means the 'kmn-programming' will use $2^0 = 1$ core. If there are several cores in the user's computer, parallelism can speed up the execution time.

## L1bit.cu

The L1bit.cu is the CUDA code calculating the *S<sub>max</sub>* of a matrix. The code can be compiled with the
    nvcc -o L1bit L1bit.cu
command and can be invoked with the
    ./L1bit filename
command, where filename is the name of the file containing the matrix. The program partitions the matrix according to the rows and every time it finds a better partition, it writes out the results to the file *Partition_strategy.txt*. In every iteration, the following information is provided:
      +The *L<sub>1</sub>* values of the two partitioned matrix along with the calculated *S<sub>max</sub>* value.
      +The corresponding partition. The partition consists of zeros and ones indicating how the original matrix is partitioned into two matrices according to it's rows.
