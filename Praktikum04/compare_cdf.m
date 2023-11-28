function compare_cdf(k)
xi=0.9*min(k):0.01:1.1*max(k);
% Fuegen Sie hier einen Code ein, der die kumulative Verteilungsfunktion
% aus dem Vektor aus Realisierungen k schaetzt und plottet.
% (Falls Sie nicht Matlab, sonden GNU Octave verwenden: rufen Sie die 
% Octave-Funktion empirical_cdf mit den o.g. Stuetzstellen xi auf.)

cdfplot(k);


% Ende des zu ergaenzenden Bereichs
hold on % Der naechste Plot-Befehl soll ins gleiche Diagramm plotten
% Fuegen Sie hier einen Code ein, der den Parameter lambda einer
% Poisson-Verteilung aus dem Vektor von Realisierungen k schaetzt
% und anschliessend die kumulative Verteilungsfunktion der
% Poisson-Verteilung mit Parameter lambda an den o.g. Stellen xi plottet.
lambda = mean(k);
plot(xi, poisscdf(xi,lambda));

% Ende des zu ergaenzenden Bereichs
hold off % Der naechste Plot-Befehl soll nicht ins gleiche Diagramm plotten
legend('empirical','Poisson','Location','SouthEast')
h=get(gca,'Children');set(h(1),'Color',[1,0,0])
xlabel('x')
ylabel('F_K(x)')

