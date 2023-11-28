function d=deriv_mulaw(x)
% Fuegen Sie hier Ihren Code ein

mu = 255;
d = mu./((1+mu*abs(x))*log(1+mu));

