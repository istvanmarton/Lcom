
This repository contains an implementation of a branch-and-bound algorithm solving
a generalized version of the integer *K_m,n* quadratic optimization problem.


# Problem description


Let *A* be block matrix of integers, i.e. an integer matrix partitioned by horizontal and vertical lines, like the following:


    +----------+-------+
    | -1  0  0 |  1  0 |        1-1
    |  0  0  0 |  0  0 |        1-2
    +----------+-------+
    |  0 -1  0 |  0  0 |        2-1
    |  0  0  0 | -1  0 |        2-2
    +----------+-------+
    |  0  0 -1 |  0  0 |        3-1
    |  0  0  0 | -1  0 |        3-2
    +----------+-------+

      1-         2-
       1  2  3    1  2


This example matrix has 3 row blocks, each containing 2 rows, and it has 2 column blocks containing 3 and 2 columns, respectively.
The numberings of rows and columns are shown on the side and below of the matrix.

## L1 norm

Do the following steps:

1.  Select a row from each row block and select a column from each column block.
2.  Add together the elements in the intersections of the selected rows and columns.

For example, selecting rows 1-1, 2-2, 3-1 and columns 1-1, 2-1 creates the following submatrix:

    -1   1
     0  -1
     0   0

The sum of the elements is -1.

Let us call **L1 norm** the maximal number we can get in step 2. when we have a free choice in step 1.

Let *k* be a positive natural number (*k* = 1, 2, 3, ...).

## Lk norm

Do the following steps:

1.  Partition the row blocks into *k* groups.
2.  Calculate the L1 norm of each group.
3.  Sum the calculated L1 norms.

For example, a possible 2-partition of the row blocks of the example block matrix is

    +----------+-------+
    | -1  0  0 |  1  0 |    \__________ 1st group
    |  0  0  0 |  0  0 |    /       /
    +----------+-------+           /
    |  0 -1  0 |  0  0 |    \_____/____ 2nd group
    |  0  0  0 | -1  0 |    /    /
    +----------+-------+        /
    |  0  0 -1 |  0  0 |    \__/
    |  0  0  0 | -1  0 |    /
    +----------+-------+

So we get two block matrices for the two groups:

    +----------+-------+
    | -1  0  0 |  1  0 |
    |  0  0  0 |  0  0 |
    +----------+-------+
    |  0  0 -1 |  0  0 |
    |  0  0  0 | -1  0 |
    +----------+-------+

    +----------+-------+
    |  0 -1  0 |  0  0 |
    |  0  0  0 | -1  0 |
    +----------+-------+

The L1 norm of the two matrices are 1 and 0, respectively.
The sum of the L1 norms is 1.

Let us call **Lk norm** the maximal number we can get in step 3. when we have a free choice in step 1.

`lkbit` calculates the Lk norm of a block matrix.



# Installation

1.  You need the GHC Haskell compiler and the Cabal Haskell package manager.
    If you do not have them, follow the instructions at [https://www.haskell.org/ghcup/](https://www.haskell.org/ghcup/).

2.  Clone this repository with git:

        git clone https://github.com/istvanmarton/Lcom.git

3.  Run the following command in the `Lcom/generic` folder:

        cabal install --overwrite-policy=always


# Usage

`matrices/pironio3.mat` contains the example block matrix above.

The most basic usage is to print the L2 norm and the row numbers in the partitions corresponding to the norm:

    $ lkbit matrices/pironio3.mat 
    Row numbers in the partitions:
      1-1 3-1
      2-2
    L2 norm:
      1

(The corresponding column numbers can be calulated from the row numbers.)

A different *k* value can be given by the `--order` option.  
For example, the L1 norm can be calulated with `--order 1`:

    $ lkbit --order 1 matrices/pironio3.mat 
    Row numbers in the partitions:
      1-1 2-1 3-1
    L1 norm:
      0

You can transpose the matrix before computation:

    $ lkbit --order 1 --transpose matrices/pironio3.mat 
    Row numbers in the partitions:
      1-1 2-1
    L1 norm:
      0

You can enable parallel computation with the `+RTS -N` options *at the end of the command line*:

    lkbit --order 3 chsh3.mat +RTS -N

It is also possible to limit the computations to a given number of CPU cores.  
For example, the next command do the computation with maximum 2 cores:

    lkbit --order 3 chsh3.mat +RTS -N2


## Pretty printing of block matrices

You can pretty print block matrices with the `print` subcommand.  
The input file may or may not contain vertical and/or horizontal bars.

Example usages:

    $ lkbit print matrices/pironio3.mat 
    -1  0  0 |  1 0
     0  0  0 |  0 0
    ---------+-----
     0 -1  0 |  0 0
     0  0  0 | -1 0
    ---------+-----
     0  0 -1 |  0 0
     0  0  0 | -1 0


    $ lkbit print --rows 3,1,2 --columns 2,3 matrices/pironio3.mat 
    -1  0 |  0  1 0
     0  0 |  0  0 0
     0 -1 |  0  0 0
    ------+--------
     0  0 |  0 -1 0
    ------+--------
     0  0 | -1  0 0
     0  0 |  0 -1 0



# Limitations

There may be an overflow during the calculations, because the calculations are done with machine-sized integers.

If there is an overflow in the parsing of the matrix, the program halts with an error.

If an overflow may happen during the calculations (because the absolute values of the elements are too high),
the program prints a warning.

