% Einstellbare Parameter:
N=1e4; % Anzahl Realisierungen
L=40; % Kantellänge
muX=10; % X-Koordinate des Hotspots
muY=5; % Y-Koordinate des Hotspots
sigma=5; % Ausdehnung des Hotspots
q=0.5; % Wahrscheinlichkeit, dass ein Nutzer am Hotspot ist
nBS=[4,9,16,25,36]; % Liste der Basisstationsanzahlen, die simuliert werden sollen
exponents=[2,3,4]; % Liste der Pfadverlustexponenten, die simuliert werden sollen.
% Ende der einstellbaren Parameter

P=zeros(length(nBS),length(exponents)); % Matrix für Leistungen initialisieren (wird später gefüllt)
pos=mixed_positions(N,L,muX,muY,sigma,q); % Positionen der Nutzer samplen
for i=1:length(nBS) % für jede Basisstationsanzahl
    fprintf('%0d Basisstationen\n',nBS(i));
    b=get_basestations(L,nBS(i)); 
    for j=1:length(exponents) % für jeden zu simulierenden Exponent
        fprintf('gamma = %0.1f\n',exponents(j));
        powers = transmitpowers(pos,b,exponents(j)); % Realisierungen der Sendeleistung berechnen
        P(i,j) = mean(powers); % Erwartungswert schätzen
    end
end
figure
plot(nBS,10*log10(P));
set(gca,'XTick',nBS)
xlabel('Anzahl Basisstationen')
ylabel('Mittlere Sendeleistung pro aktivem Nutzer [dB]')
legend([repmat('\gamma = ',length(exponents),1) num2str(exponents(:))])
