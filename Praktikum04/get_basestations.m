function BS=get_basestations(L,M)
M=sqrt(M);
if floor(M)~=M
    error('In diesem Versuch sind für die Anzahl der Basisstationen nur Quadratzahlen vorgesehen.')
end
pos = L/M/2:L/M:L;
BS=[reshape(repmat(pos,M,1),M^2,1), reshape(repmat(pos,M,1)',M^2,1)];