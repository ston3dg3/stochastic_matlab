function p=transmitpowers(pos,BS,exponent)
p=zeros(size(pos,1),1); % Vektor für die berechneten Leistungen initialisieren
for i=1:size(pos,1) % Für jede Realisierung einer Nutzer-Position
    r = repmat(pos(i,:),size(BS,1),1)-BS; % Berechnet jeweils den Vektor zwischen dem Nutzer und jeder Basisstation
    [d,~] = min(sqrt(sum(r.*r,2))); % Berechnet die Länge aller dieser Vektoren und wählt die kürzeste Länge aus
    % Ergänzen Sie hier Code, der aus einer Realisierung d des Abstands
    % eine Realisierung p_S der notwendigen Sendeleistung berechnet.
    
    p_e = 1;
    p_S = p_e * 1/(d.^(-exponent));

    % Ende des zu ergänzenden Bereichs
    p(i) = p_S;
end
