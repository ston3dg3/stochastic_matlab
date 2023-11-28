function xhat = map_detector(y,p,sigma)
% Fuegen Sie hier Ihren Code ein

xhat = (p*normpdf(y-1,0,sigma) > (1-p)*normpdf(y,0,sigma));
