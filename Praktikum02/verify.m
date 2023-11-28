function verify(n,quiet)
str_WarGegeben='Dies war in der Datei schon korrekt vorgegeben. Haben Sie versehentlich etwas daran verändert?\n';
str_Bildschirm='%s: Ihre Funktion hat eine Bildschirmausgabe erzeugt.\nUnterdruecken Sie Bildschirmausgaben bei Zuweisungen, indem Sie die jeweilige Zeile mit einem Strichpunkt beenden.\n';
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
files = dir(char(strcat(n, '*.m')));
if length(files) == 1
   n = files.name(1:end-2);
elseif length(files) > 1
    fprintf('Der Funktionsname ist nicht eindeutig!\n');
    return
end
dat=load('verifydata.mat');
if strcmp(n,'mulaw')
    profile clear;profile on;v=mulaw(dat.x);profile off;s=profile('info');
    if (numel(find(size(v)-size(dat.x))))
    	fprintf('Fehler in %s: Der Rückgabewert hat nicht die richtige Dimension.\n',n);
    elseif mean(abs(v-dat.xmu))>1e-12 && mean(abs(v-max(min(dat.xmu,1),-1)))>1e-12
		fprintf('Fehler in %s: Die Funktion berechnet nicht die korrekten Werte.\n',n);
	else
		if ~quiet
			if (b_octave)
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+s.FunctionTable(i).NumCalls;end
            else
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+sum(s.FunctionTable(i).ExecutedLines(:,2));end
            end
            if (sumcalls>length(dat.x))
				fprintf('Die Funktion %s ist nicht effizient implementiert. Vermeiden Sie insbesondere Schleifen.\n',n);
            else
                T=evalc_wrapper('mulaw(dat.x);');
                if numel(T)>0
                    fprintf(str_Bildschirm,n)
                else
                    fprintf('%s: Test erfolgreich :-).\n',n);
                end
			end
		end
	end
elseif strcmp(n,'inv_mulaw')
	profile clear;profile on;v=inv_mulaw(dat.xmu);profile off;s=profile('info');
    if (numel(find(size(v)-size(dat.xmu))))
    	fprintf('Fehler in %s: Der Rückgabewert hat nicht die richtige Dimension.\n',n);
    elseif mean(abs(v-dat.x))>1e-12 && mean(abs(v-max(min(dat.x,1),-1)))>1e-12
		fprintf('Fehler in %s: Die Funktion berechnet nicht die korrekten Werte.\n',n);
	else
		if ~quiet
			if (b_octave)
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+s.FunctionTable(i).NumCalls;end
            else
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+sum(s.FunctionTable(i).ExecutedLines(:,2));end
            end
            if (sumcalls>length(dat.xmu))
				fprintf('Die Funktion %s ist nicht effizient implementiert. Vermeiden Sie insbesondere Schleifen.\n',n);
			else
				T=evalc_wrapper('inv_mulaw(dat.xmu);');
                if numel(T)>0
                    fprintf(str_Bildschirm,n)
                else
                    fprintf('%s: Test erfolgreich :-).\n',n);
                end
			end
		end
	end
elseif strcmp(n,'deriv_mulaw')
	profile clear;profile on;v=deriv_mulaw(dat.x);profile off;s=profile('info');
	if (numel(find(size(v)-size(dat.x))))
    	fprintf('Fehler in %s: Der Rückgabewert hat nicht die richtige Dimension.\n',n);
    elseif  mean(abs(v-dat.dfmu))>1e-12 && mean(abs(v-dat.dfmu2))>1e-12
		fprintf('Fehler in %s: Die Funktion berechnet nicht die korrekten Werte.\n',n);
	else
		if ~quiet
			if (b_octave)
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+s.FunctionTable(i).NumCalls;end
            else
                sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+sum(s.FunctionTable(i).ExecutedLines(:,2));end
            end
			if (sumcalls>length(dat.x))
				fprintf('Die Funktion %s ist nicht effizient implementiert. Vermeiden Sie insbesondere Schleifen.\n',n);
			else
				T=evalc_wrapper('deriv_mulaw(dat.x);');
                if numel(T)>0
                    fprintf(str_Bildschirm,n)
                else
                    fprintf('%s: Test erfolgreich :-).\n',n);
                end
			end
		end
	end
elseif strcmp(n,'sample_voice')
	x=sample_voice(1e5,.58,.2);
    y=sample_voice(1e5,1,.5);
    if b_octave
		xi=(-3:0.05:3)';
		mse = mean(abs(empirical_cdf(xi,x)-(0.5+0.5*sign(xi).*gamcdf(abs(xi),.58,.2))).^2);
		mse2 = mean(abs(empirical_cdf(xi,y)-(0.5+0.5*sign(xi).*gamcdf(abs(xi),1,.5))).^2);
	else
		[cdf,xi]=ecdf(x);
		mse = mean(abs(cdf(xi<=3)-(0.5+0.5*sign(xi(xi<=3)).*gamcdf(abs(xi(xi<=3)),.58,.2))).^2);
		edge = abs(0.5+0.5*sign(xi(1)).*gamcdf(abs(xi(1)),.58,.2))+abs(0.5+0.5*sign(xi(end)).*gamcdf(abs(xi(end)),.58,.2)-1);
		[cdf,xi]=ecdf(y);
		mse2 = mean(abs(cdf(xi<=3)-(0.5+0.5*sign(xi(xi<=3)).*gamcdf(abs(xi(xi<=3)),1,.5))).^2);
        edge2 = abs(0.5+0.5*sign(xi(1)).*gamcdf(abs(xi(1)),.58,.2))+abs(0.5+0.5*sign(xi(end)).*gamcdf(abs(xi(end)),.58,.2)-1);
    end	
    if mse>1e-4 || mse2>1e-4 || (~b_octave && (edge>1e-2 || edge2>1e-2))
		fprintf('Fehler in %s: Die Funktion generiert nicht Realisierungen einer Zufallsvariable X mit der geforderten Verteilung.\n',n);
	else
        if ~quiet
            T=evalc_wrapper('sample_voice(1e5,1,.5);');
            if numel(T)>0
                fprintf(str_Bildschirm,n)
            else
                fprintf('%s: Test erfolgreich :-).\n',n);
            end
        end
	end
elseif strcmp(n,'plot_pdf_inout')
	verify('mulaw',1)
	verify('inv_mulaw',1)
	verify('deriv_mulaw',1)
	T=evalc_wrapper('plot_pdf_inout(dat.k,dat.t);');
    disp(T);
    if numel(T)>0
        if ~quiet, fprintf(str_Bildschirm,n), end
    end
    pos=get(get(gcf,'children'),'Position');
    if (~iscell(pos))
        fprintf('Fehler in %s: Die figure enthaelt nicht zwei Subplots.\n',n)
        fprintf(str_WarGegeben)
        return
    end
    pos=cell2mat(pos);
    if (numel(find(size(pos)-[2,4])))
        fprintf('Fehler in %s: Die figure enthaelt nicht zwei Subplots.\n',n)
		fprintf(str_WarGegeben)
        return
    end
    pos=pos(:,2);
    [~,ind]=sort(pos,'descend');
    plotlines=get(get(gcf,'children'),'children');
    if (~iscell(plotlines) || numel(find(size(plotlines)-[2,1])))
        fprintf('Fehler in %s: Die figure enthaelt nicht zwei Subplots.\n',n);
		fprintf(str_WarGegeben)
        return
    end
    xd=cellfun(@(x) get(x,'xdata'),plotlines,'UniformOutput',0);
    xd=xd(ind);
    yd=cellfun(@(x) get(x,'ydata'),plotlines,'UniformOutput',0);
    yd=yd(ind);
    if (iscell(xd{1}))
        fprintf('Fehler in %s: Im ersten Plot sind zu viele Linien enthalten.\n',n);
        return
    end
    if (iscell(xd{2}))
        fprintf('Fehler in %s: Im zweiten Plot sind zu viele Linien enthalten.\n',n);
        return
    end
    if (numel(xd{1})==0)
        fprintf('Fehler in %s: Im ersten Plot ist keine Linie enthalten.\n',n);
        return
    end
    if (numel(xd{2})==0)
        fprintf('Fehler in %s: Im zweiten Plot ist keine Linie enthalten.\n',n);
        return
    end
    xd{1}=xd{1}(:);
	xd{2}=xd{2}(:);
	yd{1}=yd{1}(:);
	yd{2}=yd{2}(:);
    xl=cellfun(@(x) get(x,'string'),get(get(gcf,'children'),'xlabel'),'UniformOutput',0);
    xl=xl(ind);
	yl=cellfun(@(x) get(x,'string'),get(get(gcf,'children'),'ylabel'),'UniformOutput',0);
    yl=yl(ind);
	if length(xd{1})~=401 || length(xd{end})~=401
		fprintf('Fehler in %s: Falsche Anzahl an Stuetzstellen.\n',n);
		fprintf(str_WarGegeben)
	elseif min(xd{1})~=-1 || min(xd{end})~=-1
		fprintf('Fehler in %s: Eine untere Intervallgrenze ist falsch.\n',n);
		fprintf(str_WarGegeben)
	elseif max(xd{1})~=1 || max(xd{end})~=1
		fprintf('Fehler in %s: Eine obere Intervallgrenze ist falsch.\n',n);
		fprintf(str_WarGegeben)
	elseif mean(abs(2*yd{1}(xd{1}~=0)-gampdf(abs(xd{1}(xd{1}~=0)),dat.k,dat.t)))>1e-12 || yd{1}(xd{1}==0)~=Inf
		fprintf('Fehler in %s: Die Funktionswerte von f_X(xi) sind nicht korrekt.\n',n);
	elseif mean(abs(2*yd{end}(xd{end}~=0).*deriv_mulaw(inv_mulaw(xd{end}(xd{end}~=0)))-gampdf(abs(inv_mulaw(xd{end}(xd{end}~=0))),dat.k,dat.t)))>1e-12 || yd{end}(xd{end}==0)~=Inf
		fprintf('Fehler in %s: Die Funktionswerte von f_Y(eta) sind nicht korrekt.\n',n);
	elseif (~strcmp(xl(1),dat.s{1})) || (~strcmp(xl(end),dat.s{2}))
		fprintf('Fehler in %s: Die Beschriftung einer x-Achse ist nicht korrekt.\n',n)
		fprintf(str_WarGegeben)
	elseif (~strcmp(yl(1),dat.s{5})) || (~strcmp(yl(end),dat.s{6}))
		fprintf('Fehler in %s: Die Beschriftung einer y-Achse ist nicht korrekt.\n',n)
		fprintf(str_WarGegeben)
	else
		if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
	end 
elseif strcmp(n,'plot_quantizer')
	T=evalc_wrapper('plot_quantizer;');
    disp(T);
    if numel(T)>0
        if ~quiet, fprintf(str_Bildschirm,n), end
    end
    pos=get(get(gcf,'children'),'Position');
    if (~iscell(pos))
        fprintf('Fehler in %s: Die figure enthaelt nicht drei Subplots.\n',n)
        fprintf(str_WarGegeben)
        return
    end
    pos=cell2mat(pos);
    if (numel(find(size(pos)-[3,4])))
        fprintf('Fehler in %s: Die figure enthaelt nicht drei Subplots.\n',n)
        fprintf(str_WarGegeben)
        return
    end
    pos=pos(:,2);
    [~,ind]=sort(pos,'descend');
    plotlines=get(get(gcf,'children'),'children');
    if (~iscell(plotlines) || numel(find(size(plotlines)-[3,1])))
        fprintf('Fehler in %s: Die figure enthaelt nicht drei Subplots.\n',n);
        fprintf(str_WarGegeben)
        return
    end
    xd=cellfun(@(x) get(x,'xdata'),plotlines,'UniformOutput',0);
    xd=xd(ind);
    yd=cellfun(@(x) get(x,'ydata'),plotlines,'UniformOutput',0);
    yd=yd(ind);
    if (iscell(xd{1}))
        fprintf('Fehler in %s: Im ersten Plot sind zu viele Linien enthalten.\n',n);
        return
    end
    if (iscell(xd{2}))
        fprintf('Fehler in %s: Im zweiten Plot sind zu viele Linien enthalten.\n',n);
        return
    end
    if (iscell(xd{3}))
        fprintf('Fehler in %s: Im dritten Plot sind zu viele Linien enthalten.\n',n);
        return
    end
    if (numel(xd{1})==0)
        fprintf('Fehler in %s: Im ersten Plot ist keine Linie enthalten.\n',n);
        return
    end
    if (numel(xd{2})==0)
        fprintf('Fehler in %s: Im zweiten Plot ist keine Linie enthalten.\n',n);
        return
    end
    if (numel(xd{3})==0)
        fprintf('Fehler in %s: Im dritten Plot ist keine Linie enthalten.\n',n);
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
    yli=get(get(gcf,'children'),'ylim');
    yli=yli(ind);

    for iPlot = 1:3
        if min(xd{iPlot})~=-1.5 || max(xd{iPlot})~=1.5
            fprintf('Fehler in %s: Der Bereich der x-Werte im %01d. Plot stimmt nicht.\n',n,iPlot);
            return
        elseif numel(xd{iPlot})~=30001 || mean(mean(abs(xd{iPlot}(2:end)-xd{iPlot}(1:end-1)-0.0001)))>1e-12
            fprintf('Fehler in %s: Der Abstand zwischen den Stuetzstellen (x-Werten) im %01d. Plot stimmt nicht.\n',n,iPlot);
            return
        elseif mean(mean(abs(yd{iPlot}(:)-dat.xQ{iPlot}(:))))>1e-12
            fprintf('Fehler in %s: Sie haben im %01d. Plot nicht die richtigen Funktionswerte (y-Werte) geplottet.\n',n,iPlot);
            return
        elseif sum(abs(yli{iPlot}-[-1,1]))>1e-12
            fprintf('Fehler in %s: Der Ausschnitt der y-Achse ist im %01d. Plot nicht richtig gewaehlt.\n',n,iPlot);
            return
        elseif ~strcmp(xl{iPlot},dat.s{7})
            fprintf('Fehler in %s: Die Beschriftung der x-Achse im %01d. Plot ist nicht korrekt.\n',n,iPlot)
            return
        elseif ~strcmp(yl{iPlot},dat.s{8})
            fprintf('Fehler in %s: Die Beschriftung der y-Achse im %01d. Plot ist nicht korrekt.\n',n,iPlot)
            return
        end
    end
	if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
elseif strcmp(n,'plot_gampdf')
	figure;
    dat.xi=dat.xi(:);
    dat.fG=dat.fG(:);
    T=evalc_wrapper('plot_gampdf(dat.k,dat.t);');
    disp(T);
    if numel(T)>0
        if ~quiet, fprintf(str_Bildschirm,n), end
    end
    xd=get(get(gca,'Children'),'xdata');
    yd=get(get(gca,'Children'),'ydata');
    yl=get(gca,'ylim');
    xd=xd(:);
    yd=yd(:);
    if numel(xd)==0
        fprintf('Fehler in %s: Es wurde nichts geplottet.\n',n);
    elseif min(xd)~=min(dat.xi) || max(xd)~=max(dat.xi)
        fprintf('Fehler in %s: Der Bereich der x-Werte stimmt nicht.\n',n);
    elseif numel(xd)~=length(dat.xi) || mean(mean(abs(xd(2:end)-xd(1:end-1)-(dat.xi(2)-dat.xi(1)))))>1e-12
        fprintf('Fehler in %s: Der Abstand zwischen den Stuetzstellen (x-Werten) stimmt nicht.\n',n);
	elseif mean(mean(abs(yd(dat.xi~=0)-dat.fG(dat.xi~=0))))>1e-12 || yd(dat.xi==0)~=Inf
        fprintf('Fehler in %s: Sie haben nicht die richtigen Funktionswerte (y-Werte) geplottet.\n',n);
	elseif ~strcmp(get(get(gca,'xlabel'),'string'),dat.s{1})
		fprintf('Fehler in %s: Die Beschriftung der x-Achse ist nicht korrekt.\n',n)
	elseif ~strcmp(get(get(gca,'ylabel'),'string'),dat.s{9})
		fprintf('Fehler in %s: Die Beschriftung der y-Achse ist nicht korrekt.\n',n)
	else
        if ~quiet, fprintf('%s: Test erfolgreich :-).\n',n); end
    end
else
    fprintf('Für diese Funktion steht kein Verifikationsskript zur Verfuegung.\n');
    fprintf('Bitte den Funktionsnamen auf Schreibfehler ueberpruefen.\n');
end

function T = evalc_wrapper(x)
b_octave = evalin('caller','b_octave');
dat = evalin('caller','dat');
if b_octave
    T='';
    eval(x);
else
    T = evalc(x);
end
