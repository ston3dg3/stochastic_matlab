function verify(n,quiet)
v=ver;
v=v.Name;
if numel(findstr(v,'Octave'))
	b_octave=1;
else
	b_octave=0;
end
if (~exist('quiet','var')), quiet=0; end
n = char(n);
if length(n)>2 && strcmp(n(end-1:end),'.m')
    n=n(1:end-2);
end
if length(n)>2 && strcmp(n(end),'.')
    n=n(1:end-1);
end
files = dir(char(strcat(n, '*.m')));
if length(files) == 1
   n = files.name(1:end-2);
elseif length(files) > 1
    fprintf('Der Funktionsname ist nicht eindeutig!\n');
    return
end
dat=load('verifydata.mat');
if strcmp(n,'awgn_channel')
    x=randn(dat.N,1)*5;
    y=awgn_channel(x,dat.sigma);
	if (numel(find(size(y)-size(x))))
    	fprintf('Fehler in awgn_channel: Der Rueckgabewert hat nicht die richtige Dimension.\n');
    else
        n=y-x;
        sigma=sqrt(var(n));
        sigma_y=sqrt(var(y));
        if b_octave
    		xi=(-3:0.05:3)';
        	mse = mean(abs(empirical_cdf(xi,n)-normcdf(xi,0,sigma)).^2);
    		mse2 = mean(abs(empirical_cdf(xi,n)-normcdf(xi,0,dat.sigma)).^2);
        	mse_y = mean(abs(empirical_cdf(xi,y)-normcdf(xi,0,sigma_y)).^2);
    		mse2_y = mean(abs(empirical_cdf(xi,y)-normcdf(xi,0,dat.sigma)).^2);
        else
            [cdf,xi]=ecdf(n);
            mse = mean(abs(cdf-normcdf(xi,0,sigma)).^2);
    		mse2 = mean(abs(cdf-normcdf(xi,0,dat.sigma)).^2);
            [cdf_y,xi]=ecdf(y);
            mse_y = mean(abs(cdf_y-normcdf(xi,0,sigma_y)).^2);
    		mse2_y = mean(abs(cdf_y-normcdf(xi,0,dat.sigma)).^2);
        end
        if (abs(sigma_y-dat.sigma)<2e-3 && mse_y<1e-5 && mse2_y<1e-5 )
            fprintf('Fehler in awgn_channel: Das Rauschen hat die richtige Verteilung, aber der Signalanteil x fehlt im Empfangssignal.\n');
        elseif (abs(sigma-dat.sigma)>2e-3 && mse<1e-5)
            fprintf('Fehler in awgn_channel: Der Parameter sigma wird nicht richtig verwendet.\n');
        elseif mse>1e-5 || mse2>1e-5 || abs(sigma-dat.sigma)>2e-3
            fprintf('Fehler in awgn_channel: Die Verteilung des Rauschens ist nicht korrekt.\n');
        else
            if ~quiet, fprintf('awgn_channel: Test erfolgreich :-).\n'); end
        end
	end
elseif strcmp(n,'ml_detector')
	v=ml_detector(dat.x);
	if (numel(find(size(v)-size(dat.x))))
    	fprintf('Fehler in ml_detector: Der Rueckgabewert hat nicht die richtige Dimension.\n');
    elseif mean(abs(v-dat.xML))>1e-12
		fprintf('Fehler in ml_detector: Die Funktion berechnet nicht die korrekten Werte.\n');
	else
        if ~quiet, fprintf('ml_detector: Test erfolgreich :-).\n'); end
    end
elseif strcmp(n,'map_detector')
	v=map_detector(dat.x,dat.p,dat.sigma);
	if (numel(find(size(v)-size(dat.x))))
    	fprintf('Fehler in map_detector: Der Rueckgabewert hat nicht die richtige Dimension.\n');
    elseif mean(abs(v-dat.xMAP))>1e-4
		fprintf('Fehler in map_detector: Die Funktion berechnet nicht die korrekten Werte.\n');
    else
	    if ~quiet, fprintf('map_detector: Test erfolgreich :-).\n'); end
    end
elseif strcmp(n,'bit_error_rate')
	v=bit_error_rate(dat.xML,dat.xMAP);
	v2=bit_error_rate(dat.xMAP,dat.xML);
	if (numel(find(size(v)-[1,1])))
    	fprintf('Fehler in bit_error_rate: Der Rueckgabewert muss ein Skalar sein.\n');
    elseif mean(abs(v/length(dat.xML)-dat.r))<1e-12
		fprintf('Fehler in bit_error_rate: Die Funktion berechnet nicht die korrekten Werte.\n');
		fprintf('Vermutlich wird richtig summiert, aber nicht korrekt durch die Anzahl N geteilt.\n');
		fprintf('Beachten Sie bei der Bestimmung von N, dass Spaltenvektoren an die Funktion uebergeben werden.\n');
    elseif mean(abs(v2/length(dat.xML)-dat.r))<1e-12
		fprintf('Fehler in bit_error_rate: Die Funktion berechnet nicht die korrekten Werte.\n');
		fprintf('Vermutlich wird richtig summiert, aber nicht korrekt durch die Anzahl N geteilt.\n');
		fprintf('Beachten Sie bei der Bestimmung von N, dass Spaltenvektoren an die Funktion uebergeben werden.\n');
    elseif mean(abs(v-dat.r))>1e-12
		fprintf('Fehler in bit_error_rate: Die Funktion berechnet nicht die korrekten Werte.\n');
	elseif mean(abs(v2-dat.r))>1e-12
		fprintf('Fehler in bit_error_rate: Die Funktion berechnet nicht die korrekten Werte.\n');
    else
	    if ~quiet, fprintf('bit_error_rate: Test erfolgreich :-).\n'); end
    end
elseif strcmp(n,'test_detectors')
	verify('awgn_channel',1)
	verify('ml_detector',1)
	verify('map_detector',1)
	verify('bit_error_rate',1)
    x=binornd(1,dat.p,1e6,1);
	[a,b,c,d,y] = test_detectors(x,dat.p,dat.sigma);
	if (numel(find(size(y)-size(x))))
    	fprintf('Fehler in test_detectors: Der Rueckgabewert y hat nicht die richtige Dimension.\n');
    elseif (numel(find(size(a)-size(x))))
    	fprintf('Fehler in test_detectors: Der Rueckgabewert xML hat nicht die richtige Dimension.\n');
    elseif (numel(find(size(b)-size(x))))
    	fprintf('Fehler in test_detectors: Der Rueckgabewert xMAP hat nicht die richtige Dimension.\n');
    elseif (numel(find(size(c)-[1,1])))
    	fprintf('Fehler in test_detectors: Der Rueckgabewert rML muss ein Skalar sein.\n');
    elseif (numel(find(size(d)-[1,1])))
    	fprintf('Fehler in test_detectors: Der Rueckgabewert rMAP muss ein Skalar sein.\n');
    elseif mean(abs(a-ml_detector(y)))>1e-12
		fprintf('Fehler in test_detectors: Die Funktion berechnet fuer xML nicht die korrekten Werte.\n');
    elseif mean(abs(b-map_detector(y,dat.p,dat.sigma)))>1e-12
		fprintf('Fehler in test_detectors: Die Funktion berechnet fuer xMAP nicht die korrekten Werte.\n');
	elseif mean(abs(c-bit_error_rate(x,a)))>1e-12
		fprintf('Fehler in test_detectors: Die Funktion berechnet fuer rML nicht die korrekten Werte.\n');
	elseif mean(abs(d-bit_error_rate(x,b)))>1e-12
		fprintf('Fehler in test_detectors: Die Funktion berechnet fuer rMAP nicht die korrekten Werte.\n');
    else
        n=y-x;
        sigma=sqrt(var(n));
        sigma_y=sqrt(var(y));
        if b_octave
    		xi=(-3:0.05:3)';
        	mse = mean(abs(empirical_cdf(xi,n)-normcdf(xi,0,sigma)).^2);
    		mse2 = mean(abs(empirical_cdf(xi,n)-normcdf(xi,0,dat.sigma)).^2);
        	mse_y = mean(abs(empirical_cdf(xi,y)-normcdf(xi,0,sigma_y)).^2);
    		mse2_y = mean(abs(empirical_cdf(xi,y)-normcdf(xi,0,dat.sigma)).^2);
        else
            [cdf,xi]=ecdf(n);
            mse = mean(abs(cdf-normcdf(xi,0,sigma)).^2);
    		mse2 = mean(abs(cdf-normcdf(xi,0,dat.sigma)).^2);
            [cdf_y,xi]=ecdf(y);
            mse_y = mean(abs(cdf_y-normcdf(xi,0,sigma_y)).^2);
    		mse2_y = mean(abs(cdf_y-normcdf(xi,0,dat.sigma)).^2);
        end
        if (abs(sigma_y-dat.sigma)<2e-3 && mse_y<1e-5 && mse2_y<1e-5 )
            fprintf('Fehler in test_detectors: Das Rauschen in y hat die richtige Verteilung, aber der Signalanteil x fehlt in y.\n');
        elseif (abs(sigma-dat.sigma)>2e-3 && mse<1e-5)
            fprintf('Fehler in test_detectors: Der Parameter sigma wird nicht richtig verwendet.\n');
        elseif mse>1e-5 || mse2>1e-5 || abs(sigma-dat.sigma)>2e-3
            fprintf('Fehler in test_detectors: Die Verteilung von y ist nicht korrekt.\n');
        else
            if ~quiet, fprintf('test_detectors: Test erfolgreich :-).\n'); end
        end
    end
elseif strcmp(n,'hist_out')
	verify('awgn_channel',1)
	hist_out(dat.N,dat.p,dat.sigma)
    pos=get(get(gcf,'children'),'Position');
    if (~iscell(pos))
        fprintf('Fehler: Die figure enthaelt nicht drei Subplots.\n')
        return
    end
    pos=cell2mat(pos);
    if (numel(find(size(pos)-[3,4])))
        fprintf('Fehler: Die figure enthaelt nicht drei Subplots.\n')
        return
    end
    pos=pos(:,2);
    [~,ind]=sort(pos,'descend');
    plotlines=get(get(gcf,'children'),'children');
    if (~iscell(plotlines) || numel(find(size(plotlines)-[3,1])))
        fprintf('Fehler: Die figure enthaelt nicht drei Subplots.\n');
        return
    end
    xd=cellfun(@(x) get(x,'xdata'),plotlines,'UniformOutput',0);
    xd=xd(ind);
    yd=cellfun(@(x) get(x,'ydata'),plotlines,'UniformOutput',0);
    yd=yd(ind);
    if (iscell(xd{1}))
        fprintf('Fehler: Im ersten Plot sind zu viele Linien enthalten.\n');
        return
    end
    if (iscell(xd{2}))
        fprintf('Fehler: Im zweiten Plot sind zu viele Linien enthalten.\n');
        return
    end
    if (iscell(xd{3}))
        fprintf('Fehler: Im dritten Plot sind zu viele Linien enthalten.\n');
        return
    end
    if (numel(xd{1})==0)
        fprintf('Fehler: Im ersten Plot ist keine Linie enthalten.\n');
        return
    end
    if (numel(xd{2})==0)
        fprintf('Fehler: Im zweiten Plot ist keine Linie enthalten.\n');
        return
    end
    if (numel(xd{3})==0)
        fprintf('Fehler: Im dritten Plot ist keine Linie enthalten.\n');
        return
    end
	if (~b_octave) && size(xd{1},1)>=3
		xd{1}=(xd{1}(3,:)+xd{1}(2,:))/2;
		yd{1}=yd{1}(2,:);
	end
	if (~b_octave) && size(xd{2},1)>=3
		xd{2}=(xd{2}(3,:)+xd{2}(2,:))/2;
		yd{2}=yd{2}(2,:);
    end
    if (~b_octave) && size(xd{3},1)>=3
		xd{3}=(xd{3}(3,:)+xd{3}(2,:))/2;
		yd{3}=yd{3}(2,:);
	end
    xd{1}=xd{1}(:);
	xd{2}=xd{2}(:);
	xd{3}=xd{3}(:);
	yd{1}=yd{1}(:);
	yd{2}=yd{2}(:);
	yd{3}=yd{3}(:);
    xl=cellfun(@(x) get(x,'string'),get(get(gcf,'children'),'xlabel'),'UniformOutput',0);
    xl=xl(ind);
	yl=cellfun(@(x) get(x,'string'),get(get(gcf,'children'),'ylabel'),'UniformOutput',0);
    yl=yl(ind);
    b=dat.centers(:);

	N=zeros(3,1);
	for i=1:length(N)
		[~,D]=rat(yd{i}(yd{i}~=0)*(b(2)-b(1)),1e-14);
		N(i)=D(1);
		for j=2:length(D)
			N(i)=lcm(N(i),D(j));
		end
	end
 	if abs(length(xd{1})-length(b(:)))~=0 || abs(length(xd{2})-length(b(:)))~=0 || abs(length(xd{3})-length(b(:)))~=0
		fprintf('Die Anzahl der Teilintervalle ist nicht korrekt!\n');
	elseif mean(abs(xd{1}(2:end-1)-b(2:end-1)))>1e-10 || mean(abs(xd{2}(2:end-1)-b(2:end-1)))>1e-10 || mean(abs(xd{3}(2:end-1)-b(2:end-1)))>1e-10
		fprintf('Die Teilintervalle sind nicht korrekt!\n');
	elseif mean(abs(cumsum(yd{1})/sum(yd{1})-dat.p*normcdf(b,1,dat.sigma)-(1-dat.p)*normcdf(b,0,dat.sigma)).^2)>5e-5
		fprintf('Die Daten im ersten Histogramm sind nicht korrekt!\n');
    elseif mean(abs(cumsum(yd{2})/sum(yd{2})-normcdf(b,1,dat.sigma)).^2)>5e-5
		fprintf('Die Daten im zweiten Histogramm sind nicht korrekt!\n');
    elseif mean(abs(cumsum(yd{3})/sum(yd{3})-normcdf(b,0,dat.sigma)).^2)>5e-5
		fprintf('Die Daten im dritten Histogramm sind nicht korrekt!\n');
	elseif abs(N(1)-dat.N)>1e-12
		fprintf('Die Anzahl der Realisierungen im ersten Histogramm ist nicht korrekt!\n');
	elseif abs(N(2)-dat.N)>1e-12
		fprintf('Die Anzahl der Realisierungen im zweiten Histogramm ist nicht korrekt!\n');
	elseif abs(N(3)-dat.N)>1e-12
		fprintf('Die Anzahl der Realisierungen im dritten Histogramm ist nicht korrekt!\n');
    elseif abs(sum(yd{1})*(b(2)-b(1))-1)>1e-12
		fprintf('Das erste Histogramm ist nicht korrekt normiert!\n');
    elseif abs(sum(yd{2})*(b(2)-b(1))-1)>1e-12
		fprintf('Das zweite Histogramm ist nicht korrekt normiert!\n');
    elseif abs(sum(yd{3})*(b(2)-b(1))-1)>1e-12
		fprintf('Das dritte Histogramm ist nicht korrekt normiert!\n');
	elseif (~strcmp(xl(1),dat.s{1})) || (~strcmp(xl(2),dat.s{1})) || (~strcmp(xl(3),dat.s{1}))
		fprintf('Die Beschriftung einer x-Achse ist nicht korrekt.\n')
	elseif (~strcmp(yl(1),dat.s{2})) || (~strcmp(yl(2),dat.s{3})) || (~strcmp(yl(3),dat.s{4}))
		fprintf('Die Beschriftung einer y-Achse ist nicht korrekt.\n')
	else
		if ~quiet, fprintf('hist_out: Test erfolgreich :-).\n'); end
	end 
else
    fprintf('Fuer diese Funktion steht kein Verifikationsskript zur Verfuegung.\n');
    fprintf('Bitte den Funktionsnamen auf Schreibfehler ueberpruefen.\n');
end
