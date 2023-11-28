function y = awgn_channel(x, sigma)
% Fuegen Sie hier ihren codeeein

z = sigma*randn(length(x),1);
y = x + z;