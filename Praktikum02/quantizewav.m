function quantizewav(file)
v=ver;
v=v.Name;
if numel(findstr(v,'Octave'))
	b_octave=1;
else
	b_octave=0;
end
file=char(file);
if strcmp(file(end-3:end),'.wav')
	file=file(1:end-4);
end
file_quantized = [file '_quantized.wav'];
file_mu_quantized = [file '_mu_quantized.wav'];
file = [file '.wav'];

if b_octave
	[Y, FS, BPS] = wavread(file);
else
	[Y, FS] = audioread(file);
end

Y_quantized=quantizer(Y,256);
try
    Y_mu_quantized=inv_mulaw(quantizer(mulaw(Y),256));
end

if b_octave
	wavwrite(Y_quantized, FS, BPS, file_quantized);
	if exist('Y_mu_quantized','var')
        wavwrite(Y_mu_quantized, FS, BPS, file_mu_quantized);
    end
else
	audiowrite(file_quantized, Y_quantized, FS);
	if exist('Y_mu_quantized','var')
        audiowrite(file_mu_quantized, Y_mu_quantized, FS);
    end
end
