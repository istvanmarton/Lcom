M=load('W90.txt');
strategy0=load('S90_0.txt')
strategy1=load('S90_1.txt')
partition = load('P90.txt')

M0=M(partition==0,:);
M1=M(partition==1,:);

L1_0 = sum(abs(strategy0' * M0))
L1_1 = sum(abs(strategy1' * M1))

S_max = L1_0 + L1_1

strategyB0 = sign(strategy0'*M0+0.0001);
strategyB1 = sign(strategy1'*M1+0.0001);

E1bit = zeros(90,90);

% compute strategy A
strategyA = zeros(90,1);
step0 = 0;
step1 = 0;
for i=1:90
    if partition(i)==0,
        step0 = step0 + 1;
        a=strategy0(step0);
        E1bit(i,:)=a*strategyB0';
    end;
    if partition(i)==1,
        step1 = step1 + 1;
        a=strategy1(step1);
        E1bit(i,:)=a*strategyB1';
    end;
end;

disp('L1bit=')
L1bit=trace(E1bit*M');
disp(L1bit)
%563*2

EQ = M/2;
disp('Q=')
Q=trace(EQ*M');
disp(Q)
%567*2

dlmwrite('E1bit_90.txt', E1bit, ' ')
