function image_simul(file,p,sigma)
if strcmp(file(end-3:end),'.gif')
	file=file(1:end-4);
end
file = [file '.gif'];
[I,cmap]=imread(file);
x=double(I(:));

[xML,xMAP,rML,rMAP] = test_detectors(x,p,sigma);

figure
imshow(reshape(x,size(I)));
colormap(cmap)
title('Originalbild ohne Rauschen');

figure
imshow(reshape(xML,size(I)));
colormap(cmap)
title(sprintf('ML-Detektion: Bitfehlerrate %0.4f',rML));

figure
imshow(reshape(xMAP,size(I)));
colormap(cmap)
title(sprintf('MAP-Detektion mit p=%0.3f: Bitfehlerrate %0.4f',p,rMAP));
