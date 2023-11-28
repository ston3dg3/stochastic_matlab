function x=quantizer(x,nbins)
minval=-1;maxval=1;
x=min(x,maxval-1e-12);
x=max(x,minval);
binwidth=(maxval-minval)/nbins;
x=(round((x-minval)/binwidth+0.5)-0.5)*binwidth+minval;
