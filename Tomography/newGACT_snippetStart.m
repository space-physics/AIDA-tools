%% Automatic triangulation function to determine the peak altitude of 
% the emissions and hence the first guess for the tomography reconstruction
% of ALIS.
% to be called in tomography script
% Bjorn Gustavsson (c) 2012
% mod. C. Simon Wedlund Jan. 2012


%%## Clunky-fix of lookup-things for tomo_setup4reduced2D:
stns(1).obs.optpar = stns(1).optpar;
stns(2).obs.optpar = stns(2).optpar;
stns(3).obs.optpar = stns(3).optpar;
%%## That function looks for the optpars in stns.obs.optpar - I
%%## dont dare to fidget around too much at the moment to change
%%## this... 

OPS4red2D = tomo_setup4reduced2D;
OPS4red2D.PlotStuff = 1;  % plots activated or not
OPS4red2D.ds = 1;
OPS4red2D.zmax = 115;
%% Determines the directions of the plane intersecting the two first
% stations and parallel to the B-field, as a reference plane for future
% projections. First station is Skibotn and is the reference station.
% 1D slices/cuts of the intensity distribution in this plane will be used
% to determine the altitude/energy/intensity for the first guess of the
% tomography reconstruction
[M2Dto1D_12,U12,V12,X12,Y12,Z12] = tomo_setup4reduced2D(stns(1:2),OPS4red2D);
[M2Dto1D_13,U13,V13,X13,Y13,Z13] = tomo_setup4reduced2D(stns([1,3]),OPS4red2D);

%NEEEEEEEEEEEEEeeeeeeeeeeeewwwwwwwwwwwwwwsssssssssss! 20120220
% Am we need for calculations in the 2-D slice, that has its own
% altitude grid - I know, this will force us to more
% reinterpolations and mess...
z2D = squeeze(Z12(1,1,:)); % This is the altitude grid we need to
                           % calculate the auroral production
                           % matrices for.

% Just to get an MSIS at the right altitudes:
% [nHe,nO,nN2,nO2,nAr,Mass,nH,nN,Tex,Tn] = msis(dateNtime4MSIS,z2D,69.2,21,70,87,3);
f107a = MSISpars_f107af107pap(1);
f107p = MSISpars_f107af107pap(2);
ap = MSISpars_f107af107pap(3);
% Currently broken f-mexing of msis.mex [nHe,nO,nN2,nO2,nAr,Mass,nH,nN,Tex,Tn] = msis(stns(1).obs.time,z2D,stns(1).obs.longlat(2),stns(1).obs.longlat(1),f107a,f107p,ap);
load MSISE_00_day64_F70_Ap15.dat
h_msis = MSISE_00_day64_F70_Ap15(:,1);
nHe = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,6)*1e6,z2D,'linear','extrap');
nO =  interp1(h_msis,MSISE_00_day64_F70_Ap15(:,7)*1e6,z2D,'linear','extrap');
nN2 = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,8)*1e6,z2D,'linear','extrap');
nO2 = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,9)*1e6,z2D,'linear','extrap');
nAr = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,10)*1e6,z2D,'linear','extrap');
nH =  interp1(h_msis,MSISE_00_day64_F70_Ap15(:,11)*1e6,z2D,'linear','extrap');
nN =  interp1(h_msis,MSISE_00_day64_F70_Ap15(:,12)*1e6,z2D,'linear','extrap');
Mass = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,14)*1e3,z2D,'linear','extrap');
Tex =  interp1(h_msis,MSISE_00_day64_F70_Ap15(:,15),z2D,'linear','extrap');
Tn  = interp1(h_msis,MSISE_00_day64_F70_Ap15(:,16),z2D,'linear','extrap');
semilogx([nN2,nO2,nO,Mass],z2D)
%%## Removed, due to no clue about opts4ISR2IeofE: Am = ionization_profile_matrix(z2D,Energy,nO,nN2,nO2,Mass,opts4ISR2IeofE);
Am = ionization_profile_matrix(z2D,Energy,nO,nN2,nO2,Mass);
%%## Change here to more real altitude
%production-profile-matrices... (If even needed, it is needed for
%getting a physical intepretation of the starttguesses' electron
%spectra, not necessarily otherwise...)
Ie2H5577 = Am;
Ie2H4278 = Am;
Ie2H = {Ie2H5577,Ie2H5577}; % This one will be used by the
                            % err_GACT-function...
