function [xML,xMAP,rML,rMAP,y] = test_detectors(x,p,sigma)
% Fuegen Sie hier Ihren Code ein

y = awgn_channel(x, sigma);
xML = ml_detector(y);
xMAP = map_detector(y,p,sigma);
rML = bit_error_rate(x,xML);
rMAP = bit_error_rate(x,xMAP);

