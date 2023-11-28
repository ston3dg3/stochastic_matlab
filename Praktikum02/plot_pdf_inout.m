function plot_pdf_inout(k,t)
figure
subplot(211)
xi=(-1:0.005:1)';
% Ergaenzen Sie hier den Code der die Funktions f_X(xi) berechnet und die
% Ergebnisse als Vektor f_X speichert

f_X = (1/2)*gampdf(abs(xi),k,t);

% Ende des zu ergaenzenden Bereichs
plot(xi,f_X)
xlabel('\xi');
ylabel('f_X(\xi)');

subplot(212)
eta=(-1:0.005:1)';
% Ergaenzen Sie hier den Code der die Funktions f_Y(eta) berechnet und die
% Ergebnisse als Vektor f_Y speichert

f_Y = (1/2)*gampdf(abs(inv_mulaw(eta)),k,t)./(abs(deriv_mulaw(inv_mulaw(eta))));

% Ende des zu ergaenzenden Bereichs
plot(eta,f_Y);
xlabel('\eta=T_\mu(\xi)');
ylabel('f_Y(\eta)');
