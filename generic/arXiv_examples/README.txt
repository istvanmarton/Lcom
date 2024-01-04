

The scenario [mA mB oA oB] is defined by Alice's inputs x = 1,...,mA and outputs a = 1,...,oA and Bob's inputs y = 1,...,mB and outputs b = 1,...,oB.

Note that for matrix M the number of rows = mA*oA and the number of columns = mB*oB.

Here an (i,j) element of M is given by

i = (x-1)*oA + (a-1) + 1;
j = (y-1)*oB + (b-1) + 1;

if direction == 0 => partition on Alice side (rows)
if direction == 1 => partition on Bob side (columns), which amounts to transposing the matrix M

if order == 1: no partition (computation of the local bound)
if order == 2: bipartition  (computation of the one-bit bound)
if order == 3: tripartition (computation of the one-trit bound) 
if order == 4: four partititions (computation of the two-bit bound) 
etc.

Examples (see Table I in the paper)

                 scenario        direction     L   L2   L3  L4  L5  L6  L7  L8            
 1) CHSH^3        [8 8 8 8]          0         31  40   44  48  52  56  60  64
 2) Magic^2       [9 9 16 16]        0         66  75   81  81
 3) Magic^2_s     [7 7 16 16]        0         44  48   49  49
 4) Magic^2_a     [7 3 16 16]        0         18  20   21  21 
 5) Magic^2_a     [7 3 16 16]        1         18  21   21  21
 6) CGLMP^2_10    [4 4 100 100]      0         10  12   14  16
 7) CGLMP^2_38_a  [3 2 38^2 38^2]    0          4   5    6   6
 8) CGLMP^2_38_a  [3 2 38^2 38^2]    1          4   6    6   6
 9) CGLMP^2_283_s [3 3 283^2 283^2]  0          7?  8    9   9 => too big for matlab, and also for Lkbit

simple test examples
                 scenario        direction     L   L2   L3  L4 
 1) CHSH         [2 2 2 2]          0          3    4    4   4
 2) Magic        [3 3 4 4]          0          8    9    9   9

*3) Pironio3     [[2 2 2], [3 2]]   0          0    1    1   1  
*4) Prionio4     [[2 2 2 2], [4 2]] 0          0    1    1   1   

