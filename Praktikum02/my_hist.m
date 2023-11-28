function my_hist(x)
figure
centers=(-127.5:127.5)/128;
counts=hist(x,centers);
counts=counts/length(x)*256/2;
bar(centers,counts);
xlabel('x')
ylabel('h(x)')