function hist_rand(N)
% Erster zu ergaenzender Code:
% Erstellen Sie hier einen Vektor x mit N Realisierungen von X

x = rand(N, 1);

% Ende des ersten zu ergaenzenden Bereichs
% Lesen Sie die folgenden Zeilen und versuchen Sie mit der Matlab-Hilfe
% zu verstehen, was diese Zeilen bewirken.

centers=0+1/40:1/20:1-1/40;
counts=hist(x,centers);

% Zweiter zu ergaenzender Code:
% Skalieren Sie hier die Variable counts gemaess den Vorgaben in der
% Versuchsbeschreibung.

counts = counts/N;
counts = counts*20;

% Ende des zweiten zu ergaenzenden Bereichs
% Lesen Sie die folgenden Zeilen und betrachten Sie im Plot,
% was diese Zeilen bewirken.
bar(centers,counts);
xlabel('x')
ylabel('h(x)')
title(sprintf('N = %01d',N));