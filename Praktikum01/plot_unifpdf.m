function plot_unifpdf
% Fuegen Sie hier Ihren Code ein


x = (-1:0.01:2);
plot(x, unifpdf(x));
ylim([-0.5, 1.5]);

% Ende des zu ergaenzenden Bereichs.
% Lesen Sie die folgenden Zeilen und betrachten Sie im Plot,
% was diese Zeilen bewirken.
xlabel('x')
ylabel('f_X(x)')
