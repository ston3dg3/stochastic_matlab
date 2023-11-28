function plotpdf_out(p,sigma)
figure
xi=-2:0.01:3;

subplot(311)
plot(xi,(1-p)*normpdf(xi,0,sigma)+p*normpdf(xi,1,sigma))
xlabel('y')
ylabel('f_Y(y)')
ylim([0 2])


subplot(312)
plot(xi,normpdf(xi,1,sigma),xi,normpdf(xi,0,sigma))
xlabel('y')
legend('f_{Y|X}(y|1)','f_{Y|X}(y|0)')
ylim([0 2])


subplot(313)
plot(xi,p*normpdf(xi,1,sigma),xi,(1-p)*normpdf(xi,0,sigma))
xlabel('y')
legend('p f_{Y|X}(y|1)','(1-p) f_{Y|X}(y|0)')
ylim([0 2])
