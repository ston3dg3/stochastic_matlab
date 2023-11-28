function verify(n,quiet)
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
if strcmp(n,'plot_x_squared')
	fi=figure;
    dat.x=dat.x(:);
    dat.sq=dat.sq(:);
    for a = dat.a(:)'
		plot_x_squared(a);
        xd=get(get(gca,'Children'),'xdata');
		yd=get(get(gca,'Children'),'ydata');
		xl=get(gca,'xlim');
		xd=xd(:);
		yd=yd(:);
        if numel(xd)==0
            fprintf('Fehler in plot_x_squared: Es wurde nichts geplottet.\n');
        elseif min(xd)~=-a || max(xd)~=a
        	fprintf('Fehler in plot_x_squared: Der Bereich der x-Werte (-a bis a) stimmt nicht.\n');
        elseif numel(xd)~=2*a*100+1 || mean(mean(abs(xd(2:end)-xd(1:end-1)-0.01)))>1e-12
        	fprintf('Fehler in plot_x_squared: Der Abstand zwischen den Stuetzstellen (x-Werten) stimmt nicht.\n');
        elseif mean(mean(abs(xd-dat.x(dat.x >= -a & dat.x<= a))))>1e-12
        	fprintf('Fehler in plot_x_squared: Die Stuetzstellen (x-Werten) stimmen nicht.\n');
        elseif mean(mean(abs(yd-dat.sq(dat.x >= -a & dat.x<= a))))>1e-12
            fprintf('Fehler in plot_x_squared: Sie haben nicht die richtigen Funktionswerte (y-Werte) geplottet.\n');
        elseif ~strcmp(get(get(gca,'xlabel'),'string'),'x')
            fprintf('Fehler in plot_x_squared: Die Beschriftung der x-Achse ist nicht korrekt.\n')
            fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
            fprintf('Die Beschriftung war dort schon vorgegeben (xlabel).\n')
        elseif ~strcmp(get(get(gca,'ylabel'),'string'),'x^2')
            fprintf('Fehler in plot_x_squared: Die Beschriftung der y-Achse ist nicht korrekt.\n')
            fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
            fprintf('Die Beschriftung war dort schon vorgegeben (ylabel).\n')
		else
			continue
        end
        return
    end
    if ~quiet
		T=evalc_wrapper('plot_x_squared(dat.a(end));');
		if numel(T)>0
			fprintf(str_Bildschirm,n)
		else
			fprintf('%s: Test erfolgreich :-).\n',n);
		end
    end
elseif strcmp(n,'my_pdf')
    v=my_pdf(dat.x);
	if (~numel(find(size(v')-size(dat.m))))
    	fprintf('Fehler in my_pdf: Die Ausgangsdaten haben nicht die gleiche Dimension wie die Eingangsdaten.\n');
    	fprintf('Moeglicherweise wurden Sie faelschlicherweise transponiert.\n');
    elseif (numel(find(size(v(:))-size(dat.m(:)))))
    	fprintf('Fehler in my_pdf: Die Ausgangsdaten haben nicht die gleiche Dimension wie die Eingangsdaten.\n');
    	fprintf('Die Anzahl der Elemente ist nicht gleich.\n');
    elseif (numel(find(size(v)-size(dat.m))))
    	fprintf('Fehler in my_pdf: Die Ausgangsdaten haben nicht die gleiche Dimension wie die Eingangsdaten.\n');
    elseif mean(mean(abs(v-dat.m)))>1e-12
        fprintf('Fehler in my_pdf: Die Funktion berechnet nicht die korrekten Werte.\n');
		if mean(mean(abs(v/v(ceil(length(v)/2))*dat.m(ceil(length(v)/2))-dat.m)))<1e-12
            fprintf('Der Vorfaktor vor der Exponentialfunktion ist falsch.\n');
            fprintf('(Oder es steht eine additive Konstante innerhalb der Exponentialfunktion, die dort nicht hingehoert.)\n');
        elseif abs(v(ceil(length(v)/2))-dat.m(ceil(length(v)/2)))<1e-12
            fprintf('Der Ausdruck in der Exponentialfunktion ist falsch.\n');
        end
	elseif ~quiet
		profile clear;profile on;my_pdf(dat.x);profile off;s=profile('info');
		if (b_octave)
            sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+s.FunctionTable(i).NumCalls;end
        else
            sumcalls=0;for i=1:length(s.FunctionTable),sumcalls=sumcalls+sum(s.FunctionTable(i).ExecutedLines(:,2));end
        end
		if (sumcalls>length(dat.x))
			fprintf('my_pdf: Die Funktion ist nicht effizient implementiert. Vermeiden Sie insbesondere Schleifen und verwenden Sie stattdessen Operationen, die auf ganze Vektoren angewendet werden koennen.\n');
		else
			T=evalc_wrapper('my_pdf(dat.x);');
			if numel(T)>0
				fprintf(str_Bildschirm,n)
			else
				fprintf('%s: Test erfolgreich :-).\n',n);
				fprintf('Weiter geht es in der zweiten Praktikumswoche mit dem naechsten Abschnitt in der Versuchsbeschreibung.\n');
			end
		end
    end
elseif strcmp(n,'hist_rand')
	fi=figure;
    for iTry=1:length(dat.hist_N)
        hist_rand(dat.hist_N(iTry));
        centers=0+1/40:1/20:1-1/40;
        xd=get(get(gca,'Children'),'xdata');
        yd=get(get(gca,'Children'),'ydata');
        if (~b_octave) && size(xd,1)>=3
            xd=(xd(3,:)+xd(2,:))/2;
            yd=yd(2,:);
        end
        xd=xd(:);
        yd=yd(:);
        if length(xd)~=length(centers)
            fprintf('Fehler in hist_rand: Die Anzahl der Balken im Histogramm stimmt nicht.\n');
            fprintf('Haben Sie einen Teil der Funktion veraendert, der schon vorgegeben war?\n')
            fprintf('Die korrekten Balkenmitten waren schon vorgegeben (Variable centers).\n')
        elseif sum(abs(xd-centers(:)))>1e-5
            fprintf('Fehler in hist_rand: Die Positionen der Balken im Histogramm stimmen nicht.\n');
            fprintf('Haben Sie einen Teil der Funktion veraendert, der schon vorgegeben war?\n')
            fprintf('Die korrekten Balkenmitten waren schon vorgegeben (Variable centers).\n')
        elseif var(yd/sum(yd)*20)>dat.hist_maxvar(iTry) || var(yd/sum(yd)*20)<dat.hist_minvar(iTry) || numel(find(yd))<length(yd)
            fprintf('Fehler in hist_rand: Das Histogramm ist nicht korrekt.\n');
            fprintf('Moeglicherweise stimmt die Anzahl der Realisierungen nicht,\n');
            fprintf('oder Sie haben Realisierungen einer falschen Zufallsvariable erzeugt.\n');
        elseif sum(yd) > 2*length(centers) && sum(yd)~=dat.hist_N(iTry)
            fprintf('Fehler in hist_rand: Das Histogramm ist nicht korrekt.\n');
            fprintf('Moeglicherweise stimmt die Anzahl der Realisierungen nicht (Aufgabe 1.10),\n');
            fprintf('oder Sie haben das Histogramm falsch normiert (Aufgabe 1.11).\n');
        elseif mean(mean(abs(yd/sum(yd)*20-1).^2))>dat.hist_meantol(iTry)
            fprintf('Fehler in hist_rand: Das Balkenhoehen im Histogramm sind nicht korrekt.\n');
        elseif abs(sum(yd)-1)<1e-12
            fprintf('Fehler in hist_rand: Die Normierung des Histogramms ist nicht korrekt.\n');
            fprintf('Sie haben ein Histogramm mit relativen Haeufigkeiten erstellt.\n');
            fprintf('(Summe der Balkenhoehen gleich 1)\n');
            fprintf('Lesen Sie in der Versuchsbeschreibung nach, wie das Histogramm stattdessen normiert sein soll.\n');
            fprintf('(Gesamtflaeche gleich 1)\n');
        elseif sum(yd) <= 2*length(centers) && abs(sum(yd)-length(centers))>1e-12
            fprintf('Fehler in hist_rand: Die Normierung des Histogramms ist nicht korrekt.\n');
        elseif ~strcmp(get(get(gca,'xlabel'),'string'),'x')
            fprintf('Fehler in hist_rand: Die Beschriftung der x-Achse ist nicht korrekt.\n')
            fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
            fprintf('Die Beschriftung war dort schon vorgegeben (xlabel).\n')
        elseif ~strcmp(get(get(gca,'ylabel'),'string'),'h(x)')
            fprintf('Fehler in hist_rand: Die Beschriftung der y-Achse ist nicht korrekt.\n')
            fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
            fprintf('Die Beschriftung war dort schon vorgegeben (ylabel).\n')
        else
            continue
        end
        return
    end
    if sum(yd)==dat.hist_N(iTry)
        fprintf('Fuer Aufgabe 1.10 sieht das Histogramm richtig aus. :-)\n')
        fprintf('Fuer Aufgabe 1.11 muss es noch modifiziert werden.\n')
    else
        fprintf('Fuer Aufgabe 1.11 sieht das Histogramm richtig aus. :-)\n')
    end
elseif strcmp(n,'plot_unifpdf')
	fi=figure;
    dat.x=dat.x(:);
    dat.u=dat.u(:);
    plot_unifpdf;
    xd=get(get(gca,'Children'),'xdata');
    yd=get(get(gca,'Children'),'ydata');
    yl=get(gca,'ylim');
    xd=xd(:);
    yd=yd(:);
    if numel(xd)==0
        fprintf('Fehler in plot_unifpdf: Es wurde nichts geplottet.\n');
    elseif min(xd)~=-1 || max(xd)~=2
        fprintf('Fehler in plot_unifpdf: Der Bereich der x-Werte (-1 bis 2) stimmt nicht.\n');
    elseif numel(xd)~=301 || mean(mean(abs(xd(2:end)-xd(1:end-1)-0.01)))>1e-12
        fprintf('Fehler in plot_unifpdf: Der Abstand zwischen den Stuetzstellen (x-Werten) stimmt nicht.\n');
    elseif mean(mean(abs(yd-dat.u(dat.x >= -1 & dat.x<= 2))))>1e-12
        fprintf('Fehler in plot_unifpdf: Sie haben nicht die richtigen Funktionswerte (y-Werte) geplottet.\n');
    elseif sum(abs(yl-[-0.5,1.5]))>1e-12
        fprintf('Fehler in plot_unifpdf: Der Ausschnitt der y-Achse ist nicht richtig gewaehlt.\n');
	elseif ~strcmp(get(get(gca,'xlabel'),'string'),'x')
		fprintf('Fehler in plot_unifpdf: Die Beschriftung der x-Achse ist nicht korrekt.\n')
		fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
		fprintf('Die Beschriftung war dort schon vorgegeben (xlabel).\n')
	elseif ~strcmp(get(get(gca,'ylabel'),'string'),'f_X(x)')
		fprintf('Fehler in plot_unifpdf: Die Beschriftung der y-Achse ist nicht korrekt.\n')
		fprintf('Haben Sie die letzten Zeilen der Funktion veraendert?\n')
		fprintf('Die Beschriftung war dort schon vorgegeben (ylabel).\n')
	else
		if ~quiet
			T=evalc_wrapper('plot_unifpdf;');
            if numel(T)>0
				fprintf(str_Bildschirm,n)
			else
				fprintf('%s: Test erfolgreich :-).\n',n);
			end
		end
    end
elseif strcmp(n,'plot_my_pdf')
	verify('my_pdf',1);
    figure
	plot_my_pdf;
	xd=get(get(gca,'Children'),'xdata');
	yd=get(get(gca,'Children'),'ydata');
	xd=xd(:);
	yd=yd(:);
	if numel(xd)==0
        fprintf('Fehler in plot_my_pdf: Es wurde nichts geplottet.\n');
    elseif min(xd)~=-4 || max(xd)~=4
        fprintf('Fehler in plot_my_pdf: Der Bereich der x-Werte (-4 bis 4) stimmt nicht.\n');
	elseif length(xd)<400
		fprintf('Fehler in plot_my_pdf: Zu wenige Stützstellen.\n');
    elseif mean(abs(yd-normpdf(xd)))>1e-12
		fprintf('Fehler in plot_my_pdf: Die Funktionswerte (y-Werte) im Plot sind nicht korrekt.\n');
	elseif ~strcmp(get(get(gca,'xlabel'),'string'),'x')
		fprintf('Fehler in plot_my_pdf: Die Beschriftung der x-Achse ist nicht korrekt.\n')
	elseif ~strcmp(get(get(gca,'ylabel'),'string'),'f_X(x)')
		fprintf('Fehler in plot_my_pdf: Die Beschriftung der y-Achse ist nicht korrekt.\n')
	else
		if ~quiet
			T=evalc_wrapper('plot_my_pdf;');
            if numel(T)>0
				fprintf(str_Bildschirm,n)
			else
				fprintf('%s: Test erfolgreich :-).\n',n);
				fprintf('Weiter geht es mit den Beispielfragen in der Versuchsbeschreibung.\n');
			end
		end
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
