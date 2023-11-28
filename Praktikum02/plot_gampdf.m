function plot_gampdf(k,t)
% Fuegen Sie hier Ihren Code ein

figure;
xi = (-1:0.005:1);
plot(xi, gampdf(xi, k, t));
xlabel("\xi");
ylabel("f_G(\xi)");
