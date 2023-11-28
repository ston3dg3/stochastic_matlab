function x=sample_voice(N,k,t)
% Fuegen Sie hier Ihren Code ein

g = gamrnd(k,t,N,1);
s = sign(rand(N,1)-0.5);
x = g.*s;
