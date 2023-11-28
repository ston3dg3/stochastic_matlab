function hist_out(N,p,sigma)
binwidth=0.025;
centers=-2+binwidth/2:binwidth:3-binwidth/2;
figure

subplot(311)
% Erstellen Sie hier einen Vektor y mit N Realisierungen von Y



% Ende des zu ergaenzenden Bereichs
counts=hist(y,centers);
bar(centers,counts/(binwidth*sum(counts)),1);
ylim([0 2])
xlabel('y')
ylabel('h(y)')
title(sprintf('N=%01d',N))

subplot(312)
% Erstellen Sie hier einen Vektor y mit N Realisierungen von Y unter der 
% Bedingung, dass X=1



% Ende des zu ergaenzenden Bereichs
counts=hist(y,centers);
bar(centers,counts/(binwidth*sum(counts)),1);
ylim([0 2])
xlabel('y')
ylabel('h(y|x=1)')

subplot(313)
% Erstellen Sie hier einen Vektor y mit N Realisierungen von Y unter der 
% Bedingung, dass X=0



% Ende des zu ergaenzenden Bereichs
counts=hist(y,centers);
bar(centers,counts/(binwidth*sum(counts)),1);
ylim([0 2])
xlabel('y')
ylabel('h(y|x=0)')
