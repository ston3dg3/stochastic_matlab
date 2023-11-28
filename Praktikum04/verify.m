function verify(n,quiet)
str_WarGegeben='Dies war in der Datei schon korrekt vorgegeben. Haben Sie versehentlich etwas daran veraendert?\n';
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
if strcmp(n,'uniform_positions')
    pos=eval('uniform_positions(dat.N,dat.L)');
    if (numel(find(size(pos)-[dat.N,2])))
    	fprintf('Fehler in %s: Der Rueckgabewert hat nicht die richtige Dimension.\n',n);
    else
        if b_octave
    		xi=(-10:0.1:50)';
        	mse = mean(abs(empirical_cdf(xi,pos(:,1))-unifcdf(xi,0,dat.L)).^2);
    		mse2 = mean(abs(empirical_cdf(xi,pos(:,2))-unifcdf(xi,0,dat.L)).^2);
        else
            [cdf,xi]=ecdf(pos(:,1));
            [cdf2,xi2]=ecdf(pos(:,2));
            mse = mean(abs(cdf-unifcdf(xi,0,dat.L)).^2);
    		mse2 = mean(abs(cdf2-unifcdf(xi2,0,dat.L)).^2);
        end
        v=var(pos);
        if max(max(abs(corr(pos)-eye(2))))>0.005
            fprintf('Fehler in %s: Die X- und Y-Koordinate sind nicht stochastisch unabhaengig.\n',n);
        elseif mse>1e-6 || abs(v(1)-dat.L^2/12)>1
            fprintf('Fehler in %s: Die Verteilung der X-Koordinate ist nicht korrekt.\n',n);
        elseif mse2>1e-6 || abs(v(2)-dat.L^2/12)>1
            fprintf('Fehler in %s: Die Verteilung der Y-Koordinate ist nicht korrekt.\n',n);
        else
            if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
        end
	end
elseif strcmp(n,'hotspot_positions')
    pos=eval('hotspot_positions(dat.N,dat.L,dat.muX,dat.muY,dat.sigma)');
    if (numel(find(size(pos)-[dat.N,2])))
    	fprintf('Fehler in %s: Der Rueckgabewert hat nicht die richtige Dimension.\n',n);
    else
        for N=1:2
            if b_octave
                xi=(-10:0.1:50)';
                mse = mean(abs(empirical_cdf(xi,pos(:,1))-truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
                mse2 = mean(abs(empirical_cdf(xi,pos(:,2))-truncnormcdf(xi,dat.muY,dat.sigma,0,dat.L)).^2);
            else
                [cdf,xi]=ecdf(pos(:,1));
                [cdf2,xi2]=ecdf(pos(:,2));
                mse = mean(abs(cdf-truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
                mse2 = mean(abs(cdf2-truncnormcdf(xi2,dat.muY,dat.sigma,0,dat.L)).^2);
            end
            v=var(pos);
            if max(max(abs(corr(pos)-eye(2))))>0.005
                fprintf('Fehler in %s: Die X- und Y-Koordinate sind nicht stochastisch unabhaengig.\n',n);
            elseif mse>1e-5 || abs(v(1)-dat.hotspot_v(1))>1
                fprintf('Fehler in %s: Die Verteilung der X-Koordinate ist nicht korrekt.\n',n);
                fprintf(str_WarGegeben)
            elseif mse2>1e-5 || abs(v(2)-dat.hotspot_v(2))>1
                fprintf('Fehler in %s: Die Verteilung der Y-Koordinate ist nicht korrekt.\n',n);
            else
                if (N==1)
                    dat.muX=dat.L-dat.muX;
                    dat.muY=dat.L-dat.muY;
                    pos=eval('hotspot_positions(dat.N,dat.L,dat.muX,dat.muY,dat.sigma)');
                end
                continue
            end
            return
        end
        if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
	end
elseif strcmp(n,'mixed_positions')
    verify('uniform_positions',1)
    verify('hotspot_positions',1)
    pos=mixed_positions(dat.N,dat.L,dat.muX,dat.muY,dat.sigma,dat.q);
    pos_comp=mixed_positions(dat.N,dat.L,dat.muX,dat.muY,dat.sigma,1-dat.q);
    if (numel(find(size(pos)-[dat.N,2])))
    	fprintf('Fehler in %s: Der Rueckgabewert hat nicht die richtige Dimension.\n',n);
    else
        if b_octave
    		xi=(-10:0.1:50)';
        	mse = mean(abs(empirical_cdf(xi,pos(:,1))-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
    		mse2 = mean(abs(empirical_cdf(xi,pos(:,2))-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muY,dat.sigma,0,dat.L)).^2);
        	mse_comp = mean(abs(empirical_cdf(xi,pos_comp(:,1))-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
    		mse2_comp = mean(abs(empirical_cdf(xi,pos_comp(:,2))-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muY,dat.sigma,0,dat.L)).^2);
        else
            [cdf,xi]=ecdf(pos(:,1));
            [cdf2,xi2]=ecdf(pos(:,2));
            mse = mean(abs(cdf-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
    		mse2 = mean(abs(cdf2-(1-dat.q)*unifcdf(xi2,0,dat.L)-dat.q*truncnormcdf(xi2,dat.muY,dat.sigma,0,dat.L)).^2);
            [cdf,xi]=ecdf(pos_comp(:,1));
            [cdf2,xi2]=ecdf(pos_comp(:,2));
            mse_comp = mean(abs(cdf-(1-dat.q)*unifcdf(xi,0,dat.L)-dat.q*truncnormcdf(xi,dat.muX,dat.sigma,0,dat.L)).^2);
    		mse2_comp = mean(abs(cdf2-(1-dat.q)*unifcdf(xi2,0,dat.L)-dat.q*truncnormcdf(xi2,dat.muY,dat.sigma,0,dat.L)).^2);
        end
        v=var(pos);
        v_comp=var(pos_comp);
        if mse_comp<=1e-4 && abs(v_comp(1)-dat.mixed_v(1))<=1 && mse2_comp<=1e-4 && abs(v_comp(2)-dat.mixed_v(2))<=1 && abs(max(max(abs(corr(pos_comp)-eye(2))))-dat.mixed_corr)<=0.01
            fprintf('Fehler in %s: Der Parameter q wird nicht richtig verwendet.\n',n);
            fprintf('Moeglicherweise haben Sie die Faelle B=1 und B=0 verwechselt.\n');
        elseif mse>1e-4 || abs(v(1)-dat.mixed_v(1))>1
            fprintf('Fehler in %s: Die Verteilung der X-Koordinate ist nicht korrekt.\n',n);
        elseif mse2>1e-4 || abs(v(2)-dat.mixed_v(2))>1
            fprintf('Fehler in %s: Die Verteilung der Y-Koordinate ist nicht korrekt.\n',n);
        elseif abs(max(max(abs(corr(pos)-eye(2))))-dat.mixed_corr)>0.01
            fprintf('Fehler in %s: Die gemeinsame Verteilung von X- und Y-Koordinate ist nicht richtig.\n',n);
            fprintf('Hinweis: Die Entscheidung zwischen Gleichverteilung und Hotspot muss immer fuer Paare\n');
            fprintf('von Realisierungen von X und Y getroffen werden (also fuer Zeilen der Matrix)\n');
            fprintf('und nicht fuer X und Y einzeln (also fuer einzelne Elemente der Matrix).\n');
        else
            if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
        end
	end
elseif strcmp(n,'transmitpowers')
	v=transmitpowers(dat.pos,dat.BS,dat.exponent);
	if (numel(find(size(v)-size(dat.p))))
    	fprintf('Fehler in %s: Der Rueckgabewert hat nicht die richtige Dimension.\n',n);
    elseif mean(abs(v-dat.p))>1e-12
		fprintf('Fehler in %s: Die Funktion berechnet nicht die korrekten Werte.\n',n);
	else
        if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
    end
elseif strcmp(n,'blocking_probability')
	v=blocking_probability(dat.k,dat.K);
	if (numel(find(size(v)-[1,1])))
    	fprintf('Fehler in %s: Der Rueckgabewert hat nicht die richtige Dimension.\n',n);
    elseif mean(abs(v-dat.P_B))>1e-12
		fprintf('Fehler in %s: Die Funktion berechnet nicht die korrekten Werte.\n',n);
    else
	    if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
    end
elseif strcmp(n,'compare_cdf')
	figure
	for N=[2 1];
        compare_cdf(dat.k*N)
		xd=get(get(gca,'Children'),'xdata');
		yd=get(get(gca,'Children'),'ydata');
		xl=get(gca,'xlim');
        xname=get(get(gca,'Children'),'DisplayName');
		if (numel(xd)~=2)
            fprintf('Fehler in %s: Es sind nicht zwei Kurven im Plot vorhanden.\n',n)
        else
            xd{1}=xd{1}(:);
            xd{2}=xd{2}(:);
            yd{1}=yd{1}(:);
            yd{2}=yd{2}(:);
            ind_poiss=0;
            if strcmp(xname{1},'Poisson')
                ind_poiss=1;
            elseif strcmp(xname{2},'Poisson')
                ind_poiss=2;
            end
            ind_emp=3-ind_poiss;
            if ~ind_poiss
                fprintf('Fehler in %s: Es wurde keine Kurve gefunden, die mit "Poisson" beschriftet ist.\n',n)
                fprintf(str_WarGegeben)
            elseif (numel(find(size(xd{ind_poiss}(:))-size(dat.xi{N}(:))))) || mean(abs(xd{ind_poiss}(:)-dat.xi{N}(:)))>1e-12
                fprintf('Fehler in %s: Die Stuetzstellen des Plots der Poisson-KVF sind nicht richtig.\n',n)
                fprintf(str_WarGegeben)
            elseif mean(abs(yd{ind_poiss}-dat.FP{N}(:)))>1e-12
                fprintf('Fehler in %s: Die Werte der Poisson-KVF sind nicht richtig.\n',n)
                mean(abs(yd{ind_poiss}-dat.FP{N}(:)))
            elseif ~b_octave && ((numel(find(size(xd{ind_emp}(2:2:end-1))-size(dat.kappa{N}(2:end))))) || mean(abs(xd{ind_emp}(2:2:end-1)-dat.kappa{N}(2:end)))>1e-6 || mean(abs(yd{ind_emp}(2:2:end)-dat.FK{N}(:)))>1e-6)
                fprintf('Fehler in %s: Der Plot der geschaetzten KVF ist nicht richtig.\n',n)
            elseif b_octave && ((numel(find(size(xd{ind_emp}(:))-size(dat.xi{N}(:))))) || mean(abs(yd{ind_emp}(:)-empirical_cdf(dat.xi{N}(:),dat.k*N)))>1e-6)
                fprintf('Fehler in %s: Der Plot der geschaetzten KVF ist nicht richtig.\n',n)
            elseif ~strcmp(get(get(gca,'xlabel'),'string'),'x')
                fprintf('compare_cdf: Die Beschriftung der x-Achse ist nicht korrekt.\n')
                fprintf(str_WarGegeben)
            elseif ~strcmp(get(get(gca,'ylabel'),'string'),'F_K(x)')
                fprintf('compare_cdf: Die Beschriftung der y-Achse ist nicht korrekt.\n')
                fprintf(str_WarGegeben)
    		else
    			continue
            end 
        end
		return
	end
	if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
else
    fprintf('Fuer diese Funktion steht kein Verifikationsskript zur Verfuegung.\n');
    fprintf('Bitte den Funktionsnamen auf Schreibfehler ueberpruefen.\n');
end
end

function F=truncnormcdf(x,mu,sigma,a,b)
    F=(normcdf((x-mu)/sigma)-normcdf((a-mu)/sigma))./(normcdf((b-mu)/sigma)-normcdf((a-mu)/sigma));
    F(x<a)=0;
    F(x>b)=1;
end

