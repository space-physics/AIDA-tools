function [SkMp,identstars,optpar] = trackemdown(SkMp)
% TRACKEMDOWN - makes an automatic starcalibration.
% Automatic meaning that it automatically finds possible or likelly
% stars in the image, sort them into intensity order, identifies
% (connects) them with stars from the star catalog and searches for
% an optimal set of optical parameters. TRACKEMDOWN needs a good
% starting guess for the optical parameters. SkM_STRUCT is a struct
% as optut from STARCAL. INFOVSTARS are a matrix with stars as
% output from STARCAL.
%
% Calling
%  [identstars,optpar] = trackemdown(SkMp,infovstars)
% 
% Notice: This function does not work (does not do anything useful)
% for the non-parametric optical models.
%

%   Copyright © 2001-11-05 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global s_prefs

warning off

if SkMp.optmod < 0
  identstars = SkMp.identstars;
  optpar = SkMp.optpar;
  return
end
s_prefs = SkMp.prefs;

mode = 3;
% bxy = size(SkMp.img);
% bx = bxy(2);
% by = bxy(1);

set(SkMp.figsky,'pointer','watch')
set(SkMp.figzoom,'pointer','watch')

[out_i,out_j,out_I] = find_the_stars(SkMp.img);
% Saa daer ja, nu har vi hittat moejliga stjaernor i bilden
% och sorterat dem efter hur intensiva de synes vara.

% Nu aaterstaar att saetta ihop dem med stjaernor fraan
% katalogen.
% Max antal stjaernor at gissa i foersta foersoeket
max_nrstars = 5;
% fraan bilden:              out_i, out_j & out_I
% fraan katalog och tmpopt:  kstars, uk & wk
tmpopt = SkMp.optpar(1:8);

infovstars = SkMp.plottstars;
[kstars,uk,wk] = set_up_stars(infovstars,SkMp.optpar,SkMp.optmod);
%Para ihop stjaernor med lokala maxima i bilden
I_tmp = out_I;
i_tmp = out_i;
j_tmp = out_j;

for ii = 1:min(max(size(out_I)),max_nrstars),
  
  [qw,indx] = min((i_tmp(1:min(ii+4,length(out_j)))-uk(ii)).^2+ ...
		  (j_tmp(1:min(ii+4,length(out_j)))-wk(ii)).^2);
  
  ids(ii) = indx;
  i_tmp(ids(ii)) = -1000;
  j_tmp(ids(ii)) = -1000;
  
end

clear identstars

identstars(:,1) = kstars(1:max_nrstars,1);
identstars(:,2) = kstars(1:max_nrstars,2);
identstars(:,3) = out_i(ids); 		%starpos in image(x)
identstars(:,4) = out_j(ids); 		%starpos in image(y)
identstars(:,5) = out_I(ids); 		%max count from star
identstars(:,6) = 0; 			%total counts from star
identstars(:,7) = 1; 			%good gaussian fit
identstars(:,8) = 0; 			%wide circular gausian

lockpar = [1e3 1e3 0 0 0 1e3 1e3 1e4];
startvec = tmpopt(1:8);
if exist('fminunc')==2
  optpar0 = fminunc('automat4',...
		    tmpopt(1:8),[0,1e-4],[],...
		    identstars,mode,tmpopt(1:8),lockpar);
else
  optpar0 = fminsearch('automat4',...
		       tmpopt(1:8),[0,1e-4],[],...
		       identstars,mode,tmpopt(1:8),lockpar);
end

max_nrstars = 30;


[kstars,uk,wk] = set_up_stars(infovstars,SkMp.optpar(1:8),SkMp.optmod);
%Para ihop stjaernor med lokala maxima i bilden
for ii = 1:min(max(size(out_I)),max_nrstars),
  
  [qw,indx] = min((out_i(ii)-uk(1:min(length(uk),30))).^2+(out_j(ii)-wk(1:min(length(uk),30))).^2);
  ids(ii) = indx;
  
end

clear identstars
identstars(:,1) = kstars(ids,1);
identstars(:,2) = kstars(ids,2);
identstars(:,3) = out_i(1:length(ids));	%starpos in image(x)
identstars(:,4) = out_j(1:length(ids));	%starpos in image(y)
identstars(:,5) = out_I(1:length(ids));	%max count from star
identstars(:,6) = 0; 			%total counts from star
identstars(:,7) = 1; 			%good gaussian fit
identstars(:,8) = 0; 			%wide circular gausian

[uuaa,wwaa] = project_directions(identstars(:,1)',identstars(:,2)',optpar0,mode);

uubb = identstars(:,3);
wwbb = identstars(:,4);
mindx = find(((uubb-uuaa').^2+(wwbb-wwaa').^2).^.5<40);
mids = identstars(mindx,:);

if exist('fminunc')==2
  optpar0 = fminunc('automat4',...
		    tmpopt(1:8),[0,1e-4],[],...
		    identstars,mode,tmpopt(1:8),lockpar);
else
  optpar0 = fminsearch('automat4',...
		       tmpopt(1:8),[0,1e-4],[],...
		       identstars,mode,tmpopt(1:8),lockpar);
end

clear plstars uk wk kstars identstars ids
[plstars] = plottablestars2(infovstars,6);
[plstars,uk,wk] = starsinimg(plstars,optpar0,mode);
[smagn,indx] = sort(plstars(:,4));

kstars(:,10) = plstars(indx,4);
kstars(:,9) = plstars(indx,3);
kstars(:,2) = plstars(indx,2);
kstars(:,1) = plstars(indx,1);
uk = uk(indx);
wk = wk(indx);

iii = 1;
for ii = 1:max(size(out_I)),
  
  rrr = min((out_i(ii)-uk).^2+(out_j(ii)-wk).^2);
  if ( rrr < 25 )
    
    [qw,indx] = min((out_i(ii)-uk).^2+(out_j(ii)-wk).^2);
    ids(iii) = indx;
    iindids(iii) = ii;
    iii = iii+1;
    
  end
  
end

identstars(:,1) = kstars(ids,1);
identstars(:,2) = kstars(ids,2);
identstars(:,3) = out_i(iindids); 	%starpos in image(x)
identstars(:,4) = out_j(iindids); 	%starpos in image(y)
identstars(:,5) = out_I(iindids); 	%max count from star
identstars(:,6) = 0; 			%total counts from star
identstars(:,7) = 1; 			%good gaussian fit
identstars(:,8) = 0; 			%wide circular gausian

if exist('fminunc')==2
  optpar0 = fminunc('automat4',...
		    tmpopt(1:8),[0,1e-4],[],...
		    identstars,mode,tmpopt(1:8),lockpar);
else
  optpar0 = fminsearch('automat4',...
		       tmpopt(1:8),[0,1e-4],[],...
		       identstars,mode,tmpopt(1:8),lockpar);
end

[uuaa,wwaa] = project_directions(identstars(:,1)',identstars(:,2)',optpar0,mode);
starplot2(infovstars,SkMp);
hold on,
plot(identstars(:,3),identstars(:,4),'r.','markersize',12),hold off
drawnow

uubb = identstars(:,3);
wwbb = identstars(:,4);
mindx = find(((uubb-uuaa').^2+(wwbb-wwaa').^2).^.5<5);
mids = identstars(mindx,:);

identstars = mids;

optpar = optpar0;

set(SkMp.figsky,'pointer','arrow')
set(SkMp.figzoom,'pointer','arrow')

if ~isfield(SkMp,'errorfig')
  
  SkMp = errorgui(SkMp);
  
end


function [kstars,uk,wk] = set_up_stars(infovstars,tmpopt,mode)

[plstars] = plottablestars2(infovstars,6);
[plstars,uk,wk] = starsinimg(plstars,tmpopt,mode);
% sortera dem map magn.
[smagn,indx] = sort(plstars(:,4));

% Haer ska jag boerja fixa till lite med identstars..
kstars(:,10) = plstars(indx,4);
kstars(:,9) = plstars(indx,3);
kstars(:,2) = plstars(indx,2);
kstars(:,1) = plstars(indx,1);
uk = uk(indx);
wk = wk(indx);
