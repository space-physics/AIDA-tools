% stdposEISCAT2_200506 - ALIS fields-of-view for position: EISCAT2

%% Designing an ALIS position

% In order to make good use of ALIS multi-view-point imaging it is
% sometimes necessary to have the cameras look at the same portion
% of the sky. To get as good an overlap as possible there is some
% tweaking involved. But we are not left alone to toil away with
% pen and paper (and eraser) scribling away geometry and
% trigonometry. The ALIS toolbox contain a function
% |alis_visiblevol| that calculates the approximate field of view
% of the ALIS stations with any camera rotation at any selected
% altitude.

%% Set the options.
% (As most functions will eventually) |alis_visiblevol| produces a
% struct with the default options when called with no input
% parameters and one output.
OPS = aida_visiblevol;
%%
% |OPS.LL| make the plot in Latitude-Longitude when 1. Otherwise
% the plot will be in km relative Kiruna.
OPS.LL = 1;
%% 
% |OPS.linewidth| is the linewidth of the plot. If it is kept at
% its default value (1) it looks a little bit skinny in plots with
% the background map.
OPS.linewidth = 2;
%%
% Here we remove the field |clrs| - most stations have a designated
% color and then it is unnecessary to include this.
OPS = rmfield(OPS,'clrs');

axis([15 26 67 71])
set(gca,'fontsize',12)
xlabel('Longitude','fontsize',16)
ylabel('Latitude','fontsize',16) 
hold on
%% The common volume
% as seen by the ALIS stations. The input parameters and working of
% aida_visiblevol are well explained by the help of the function:
% help aida_visiblevol
%%
% Stations are given by the "depreciated" numbers:
%
% * 1 - Kiruna IRF/Optics lab, dome 6
% * 2 - Merasjarvi
% * 3 - Silkkimuotka
% * 4 - Tjautjas
% * 5 - Abisko
% * 6 - Nikkaluokta
% * 7 - Knutstorp
% * 10 - Skibotn
% * 11 - Ramfjordmoen (EISCAT)
stnNR = [7,   3,  4,  5, 10, 11];
% Set the corresponding AZIMUTH
AZstn = [0, 340,  0, 20,180,183];
% and ZENITH angles
ZEstn = [39, 40, 45, 35,  0, 12];
% and approximate field of view
FOVstn = [60,60,60,60,90,1];
% Altitude to view the visible regions
ALTstn = 100*ones(size(stnNR));

%% Finalized common field-of-view
% The final fields-of-view overlap well. It might take some
% tweaking and adjustments before a good enough overlap is
% obtained. But in al with this script as basis it should not take
% more than a few 10s of minutes - at the most.
hndl = ALISstdpos_visvol(stnNR,AZstn,ZEstn,ALTstn,FOVstn,OPS);
%% Background map
% This is a good thing to include, it helps the eye when it comes
% to judging the field-of-view and comparing it to possible
% stellite passes.
PH = nscand_map('l');
axis([15 26 67 71 -5 1.5e3*max(ALTstn)])

