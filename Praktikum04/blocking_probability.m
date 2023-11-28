function P=blocking_probability(k,N)
% Fuegen Sie hier Ihren Code ein

prob = poisscdf(N,mean(k));
P = 1 - prob;
