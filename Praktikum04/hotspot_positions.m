function H=hotspot_positions(N,L,muX,muY,sigma)
x=sigma*randn(N,1)+muX;
y=sigma*randn(N,1)+muY;
xh=x;
yh=y;
while any(xh<0) || any(xh>L)
    x=sigma*randn(N,1)+muX;
    % Der folgende Code ersetzt die Eintraege in xh,
    % die nicht innerhalb des gewuenschten Bereichs liegen,
    % durch die entsprechenden Eintraege von x.
    xh(xh<0)=x(xh<0);
    xh(xh>L)=x(xh>L);
end
% Ergaenzen Sie hier den entsprechenden Code zur Generierung von y
while any(yh<0) || any(yh>L)
    y = sigma*randn(N,1)+muY;
    yh(yh<0)=y(yh<0);
    yh(yh>L)=y(yh>L);
end

% Ende des zu ergaenzenden Bereichs
H = [xh yh];
