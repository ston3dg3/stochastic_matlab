function plot_quantizer()
figure
subplot(311)
% Ergaenzen Sie hier den Code fuer den Plot mit 4 Teilintervallen

x = (-1.5 : 0.0001 : 1.5);
xq = quantizer(x, 4);
plot(x, xq);
xlabel("x");
ylabel("x_Q");
ylim([-1;1]);

% Ende des zu ergaenzenden Bereichs
title('4 Intervalle')
subplot(312)
% Ergaenzen Sie hier den Code fuer den Plot mit 16 Teilintervallen

xq = quantizer(x, 16);
plot(x, xq);
xlabel("x");
ylabel("x_Q");
ylim([-1;1]);


% Ende des zu ergaenzenden Bereichs
title('16 Intervalle')
subplot(313)
% Ergaenzen Sie hier den Code fuer den Plot mit 256 Teilintervallen

xq = quantizer(x, 256);
plot(x, xq);
xlabel("x");
ylabel("x_Q");
ylim([-1;1]);


% Ende des zu ergaenzenden Bereichs
title('256 Intervalle')
