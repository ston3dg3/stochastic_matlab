function r=bit_error_rate(x,xhat)
% Fuegen Sie hier Ihren Code ein

r = mean(x~=xhat);