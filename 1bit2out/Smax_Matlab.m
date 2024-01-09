prompt = 'Please give me the name of the file containing the matrix! ';
fileName = input(prompt, 's')
prompt = 'Give me the number of iterations. Write "inf" if you want to optimize endlessly! ';
numofIterations = input(prompt, 's')
prompt = 'Give me the number of cores as the power of 2! If you want to use 2^n cores then write n! '
numofCores = input(prompt, 's');

x = 0;
counter_max = 0;
if(strcmp(lower(numofIterations), 'inf'))
	x = 1;
	counter_max = 1;
else
	counter_max = str2num(numofIterations);
	x = 0;
	if(length(counter_max) == 0)
		counter_max = 100;
	end
end
	
A=load(fileName);
fid = fopen('partition.txt','w');
S_max = 0;

counter = 0;
while((x==1) || (counter < counter_max))
partition = randi(2,1,size(A,1));
part_1 = sum(partition==1);
part_2 = sum(partition==2);
%if((part_1 < 48) && (part_2 < 48))
A1=A(partition==1,:);
A2=A(partition==2,:);

dlmwrite('A1.txt', A1, ' ')
dlmwrite('A2.txt', A2, ' ')

systemCall1 = sprintf('./kmn-programming A1.txt --partial */2^%d | tail -2 | head -1 | awk ''{print $1} {print $2}'' ', numofCores);
systemCall2 = sprintf('./kmn-programming A2.txt --partial */2^%d | tail -2 | head -1 | awk ''{print $1} {print $2}'' ', numofCores);
[status, output1] = system (systemCall1);
[status, output2] = system (systemCall2);
[strategy1, L11_str]=strtok(output1);
[strategy2, L12_str]=strtok(output2);

b1=hex2dec(strategy1);
f1=dec2base(b1,2);
f1 = f1-'0';
g1 = 2 * (f1) - 1;
h1 = [1,-ones(1,size(A1,1) - length(g1) - 1),g1];

b2=hex2dec(strategy2);
f2=dec2base(b2,2);
f2 = f2-'0';
g2 = 2 * (f2) - 1;
h2 = [1,-ones(1,size(A2,1) - length(g2) - 1),g2];

L11 = str2num(L11_str);
L12 = str2num(L12_str);
S_max_next = L11 + L12;
%S_max_next = sum(abs(h1*A1)) + sum(abs(h2*A2));
if(S_max_next > S_max)
	S_max = S_max_next;
	s = int2str(partition);
	printf('S_max = %d, L11 = %d, L12 = %d\n%s\n', S_max, L11, L12, s);
	fprintf(fid,'S_max = %d, L11 = %d, L12 = %d\n%s\n', S_max, L11, L12, s);
end

do
S_max_local = S_max_next;
strategyB1 = sign(h1*A1);
strategyB2 = sign(h2*A2);
p=ones(size(A,1),1);
s=0;
for i = 1:size(A,1)
	s1i=abs(A(i,:)*strategyB1');
	s2i=abs(A(i,:)*strategyB2');
	if(s1i > s2i), p(i) = 2;
	end
	s=s+max(s1i,s2i);
end
partition = p';
part_1 = sum(partition==1);
part_2 = sum(partition==2);
A1=A(partition==1,:);
A2=A(partition==2,:);

dlmwrite('A1.txt', A1, ' ')
dlmwrite('A2.txt', A2, ' ')

systemCall1 = sprintf('./kmn-programming A1.txt --partial */2^%d | tail -2 | head -1 | awk ''{print $1} {print $2}'' ', numofCores);
systemCall2 = sprintf('./kmn-programming A2.txt --partial */2^%d | tail -2 | head -1 | awk ''{print $1} {print $2}'' ', numofCores);
[status, output1] = system (systemCall1);
[status, output2] = system (systemCall2);
[strategy1, L11_str]=strtok(output1);
[strategy2, L12_str]=strtok(output2);

b1=hex2dec(strategy1);
f1=dec2base(b1,2);
f1 = f1-'0';
g1 = 2 * (f1) - 1;
h1 = [1,-ones(1,size(A1,1) - length(g1) - 1),g1];

b2=hex2dec(strategy2);
f2=dec2base(b2,2);
f2 = f2-'0';
g2 = 2 * (f2) - 1;
h2 = [1,-ones(1,size(A2,1) - length(g2) - 1),g2];

L11 = str2num(L11_str);
L12 = str2num(L12_str);
S_max_next = L11 + L12;
if(S_max_next > S_max)
	S_max = S_max_next;
	s = int2str(partition);
	printf('S_max = %d, L11 = %d, L12 = %d\n%s\n', S_max, L11, L12, s);
	fprintf(fid,'S_max = %d, L11 = %d, L12 = %d\n%s\n', S_max, L11, L12, s);
end
%S_max_next
%S_max_local
until(S_max_local == S_max_next)
%counter
counter = counter+1;
end
fclose(fid);
