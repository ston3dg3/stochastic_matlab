p=0.3;
sigma=0.25;
N=1e6;
x=binornd(1,p,N,1);
[xML,xMAP,rML,rMAP] = test_detectors(x,p,sigma);
fprintf('ML: r = %0.4f\n',rML);
fprintf('MAP: r = %0.4f\n',rMAP);