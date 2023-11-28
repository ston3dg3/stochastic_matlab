function plot_my_pdf()
% Fuegen Sie hier Ihren Code ein

X = linspace(-4, 4, 400);
Y = my_pdf(X);
plot(X, Y);
xlabel('x');
ylabel('f_X(x)');