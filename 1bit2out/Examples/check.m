W63 = load('W63.txt');
W90 = load('W90.txt');

P63 = load('P63.txt');
P90 = load('P90.txt');

S63_0 = load('S63_0.txt');
S63_1 = load('S63_1.txt');
S90_0 = load('S90_0.txt');
S90_1 = load('S90_1.txt');

M63_0 = W63(P63 == 0, :);
M63_1 = W63(P63 == 1, :);
M90_0 = W90(P90 == 0, :);
M90_1 = W90(P90 == 1, :);

L63_0 = sum(abs(S63_0' * M63_0));
L63_1 = sum(abs(S63_1' * M63_1));
Smax_63 = L63_0 + L63_1;
L90_0 = sum(abs(S90_0' * M90_0));
L90_1 = sum(abs(S90_1' * M90_1));
Smax_90 = L90_0 + L90_1;

msg63 = ['The S max value of the 63 x 63 matrix is ', num2str(Smax_63), '.'];
msg90 = ['The S max value of the 90 x 90 matrix is ', num2str(Smax_90), '.'];

disp(msg63)
disp(msg90)