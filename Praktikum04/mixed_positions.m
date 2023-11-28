function M=mixed_positions(N,L,muX,muY,sigma,q)
M=zeros(N,2); % Matrix initialisieren
% Fuegen Sie hier Ihren Code ein
M = zeros(N,2);
H = hotspot_positions(N,L,muX, muY, sigma);
U = uniform_positions(N,L);
B = binornd(1,q,N,1);

M(B==1,:) = H(B==1,:);
M(B==0,:) = U(B==0,:);

