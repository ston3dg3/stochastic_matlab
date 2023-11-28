function x=inv_mulaw(y)
% Fuegen Sie hier Ihren Code ein

mu = 255;
x = (1/mu)*sign(y).*((1+mu).^abs(y)-1);
