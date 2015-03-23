function [Vem,I2D,Ie2D] = tomo_start_guessGACT(stns,Energy,Ie2H,Xslice,Yslice,Zslice,M2Dto1D,U,V,I_cuts,iPeaks,X3D,Y3D,Z3D,ops)
% tomo_start_guessGACT - makes 3-D distribution of volume emission rates
%  TOMO_START_GUESSGACT does a "generalized-auroral-comp-
%  tomographic" reconstruction of auroral volume emission rates in
%  a plane between 2 imaging stations parallel to the magnetic
%  field by adjusting electron precipitation parameterized into
%  energy and flux for a layer of diffuse precipitation and
%  position, width, energy and flux for a number of identified
%  local maxima in the image-cuts in the given plane, giving
%  altitude distributions of volume emission rates. The parameters
%  are then adjusted to minimize the difference between the
%  image-cuts and the calculated images from the modeled volume
%  emission distributions.
%
% Calling:
%  [Vem,I2D] = tomo_start_guessGACT(stns,...
%                                   Energy,Ie2H,...
%                                   Xslice,Yslice,Zslice,...
%                                   M2Dto1D,...
%                                   U,V,I_cuts,iPeaks,...
%                                   X3D,Y3D,Z3D,...
%                                   ops)
%  OPS      = tomo_start_guessGACT 
% Input:
%   stns    - stations struct array [1 x n], stns([1,2]) are the
%             two stations that are used.
%   Energy  - Energy grid to calculate electron spectra on [1 x nE]
%             (eV)
%   Ie2H    - Cell array of monoenergetic-to-production-altitude-
%             profiles for the image emissions (i.e. 5577), [nZs x nE]
%   Xslice  - West-East coordinates of 2-D slice [1 x nH x nZ] (km)
%   Yslice  - South-North coordinates of 2-D slice [1 x nH x nZ] (km)
%   Zslice  - Altitude coordinates of 2-D slice [1 x nH x nZ] (km)
%   M2Dto1D - Cell array of projection matrices from 2-D slice of
%             blobs to image cuts {[nI1 x ( nH * nZ)],[nI2 x ( nH * nZ)]
%   U       - Cell array of horizontal image coordinates of image
%             projections of 2-D slice.
%   V       - Cell array of vertical image coordinates of image
%             projections of 2-D slice.
%   I_cuts  - Cell array with image cuts {interp1(stns(1).img,U{1},V{1}),...}
%   iPeaks  - Cell array with indices to local maxima in I_cuts
%   X3D     - West-East array of coordinates of 3-D block-of-blobs
%             for the 3-D volume emission rates to guess, [NX x NY
%             x NZ] (km)
%   Y3D     - South-North array of coordinates of 3-D block-of-blobs
%             for the 3-D volume emission rates to guess, [NX x NY
%             x NZ] (km)
%   Z3D     - Altitude array of coordinates of 3-D block-of-blobs
%             for the 3-D volume emission rates to guess, [NX x NY
%             x NZ] (km)
%   ops     - options struct, default options returned if function
%             called without input arguments.
% Output:
%   Vem     - Guestimate of 3-D distribution of volume emission
%             rates [NX x NY x NZ]
%   I2D     - Struct with fields:
%              Vem - cell-array with 2-D volume emission rates in
%                    the slice. [nH x nZ]
%              Ie  - 2-D electron spectra (horizontal x Energy)
%                    [nH x nE]
%              cutImg - cell array with image cuts, 
%              cutProj - cell-array with 1-D projection of the 2-D
%                        volume emission distribution
% Example:
%  % 1 Calculate the geometric projection matrices and image-cut-coordinates:
%  OPS4red2D = tomo_setup4reduced2D;
%  OPS4red2D.ds = 1;
%  [M2Dto1D_12,U12,V12,X12,Y12,Z12] = tomo_setup4reduced2D(stns(1:2),OPS4red2D);
%  % Get altitude for atmospheric profiles
%  z2D = squeeze(Z12(1,1,:));
%  % Get atmospheric profiles
%  [nHe,nO,nN2,nO2,nAr,Mass,nH,nN,Tex,Tn] = msis(Obstime,z2D,stns(1).obs.longlat(2),stns(1).obs.longlat(1),f107a,f107p,ap);
%  % Calculate monoenergetic-precipitation-2-altitude-profile matrices:
%  Am = ionization_profile_matrix(z2D,Energy,nO,nN2,nO2,Mass);
%  Ie2H = {Am,Am};
%  % Get local maxima - to identify arc positions and intensities.
%  [I_cuts,iPeaks] = tomo_arcpeakfinderinslice(stns,U12,V12,OPS)
%  % Do the GACT-in-slice-2-3D-bob-guess:
%  [Vem,I2D] = tomo_start_guessGACT(stns,...
%                                   Energy,Ie2H,...
%                                   X12,Y12,Z12,...
%                                   M2Dto1D_12,...
%                                   U12,V12,I_cuts,iPeaks,...
%                                   X3D,Y3D,Z3D);
% 
% SEE also: tomo_setup4reduced2D, tomo_arcpeakfinderinslice, tomo_err4sliceGACT


%   Copyright � 20120405 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

dops.zmax = 110;       % Default guess of altitude of peak volume emission (km)
dops.iplot = 1;        % plots or not
dops.ipng = 0;         % saves plots in png files in folder
dops.analys_dir = pwd; % Where to save the png-files.
dops.twoDfig = 42;       % Figure to plot the GACT-results 
dops.threeDfig = 43;       % Figure to plot the 3-D guess
dops.ftsz = 14;        % Fontsizes for axis-labels.
%% These two are used in tomo_err4sliceGACT
dops.transpVem = 1;
try
  dops.normregs = {[],[25 length(I_cuts{2})]}; % normalization regions just like for tomo_steps!
catch
  dops.normregs = {[],[25 220]}; % normalization regions just like for tomo_steps!
end

if nargin == 0
  Vem = dops;
  return
elseif nargin > 14
  dops = merge_structs(dops,ops);
end
% If number of Arcs/maxima is one then do the triangulation
% If there is only one peak/arc in
% each/both/either of the cuts/stasions! So, then we should be able
% to use part of this stuff down here, to triangulate the
% altitude and horizontal position of the 
% arc.
if (length(iPeaks{1}) == 1) && (length(iPeaks{1}) == 1),
  for iStn = [1, 2], % iStn - station index
    % Determine line-of-sight to the local maxima for each station
    % Index of the selected peak
    cmtr = stns(iStn).obs.trmtr;  % Rotation matrix from local
                                  % coordinates to central-station coordinates
    e_pix{iStn} = inv_project_LineOfSightVectors(U{iStn}(iPeaks{iStn}),...
                                                 V{iStn}(iPeaks{iStn}),...
                                                 stns(iStn).img,1,...
                                                 stns(iStn).optpar(9),...
                                                 stns(iStn).optpar,...
                                                 [0 0 1],10,...
                                                 cmtr);
  end
  % Triangulation to get the position:
  [r,l,mindiff] = stereoscopic(stns(1).obs.xyz,e_pix{1},stns(2).obs.xyz,e_pix{2}); % Cycl.
  xx = r(1); yy = r(2);zz = r(3);
  % Take the intensity of the image to be equal to the image
  % intensity.
  IntPeaks = I_cuts{1}(iPeaks{1});
  
  % Then we start to build a start-guess for the minimization of the 2-D
  % modeled arcs
  I0 = zeros(length(yy)+1,9);
  I0(1:end-1,1) = IntPeaks; % let the peak electron flux be
                            % proportional to the peak brightness
  I0(1:end-1,2) = yy;       % north-south position, km.
  I0(1:end-1,3) = 3;        % Width in km
  I0(1:end-1,4) = 2;        % Gaussian exponent for horizontal variations
  I0(1:end-1,5) = 2;        % E0 (keV), Gaussian centre energy, here if triangulation,
                            % then pick energy that has peak production at
                            % alt. use A-matrices
  I0(1:end-1,6) = 0.4;      % width in energy, Absolutely arbitrary. keV
  I0(1:end-1,7) = 2;        % Gaussian exponent, energy, "same" as for #4
  I0(1:end-1,8) = 0;        % dDy
  I0(1:end-1,9) = 0.5;      % E-exponent, change as you see fit.
  
  % Diffuse precipitation differently parameterized: allways last row
  %            Ie_x         y0  dy gx E0 dE gE1 dDy gE2
  I0(end,:) = [min(IntPeaks),0,inf, 0, 1, 1,  2,  0,  0];
else
  % Then we have multiple local maxima <=> multiple arcs. To
  % automatically align them (an arc in one cut might be outside
  % the field-of-view in the other) properly and do the
  % triangulation is a bit difficult so we simply start with
  % projecting the line-of-sights directions of all local maxima to
  % one and the same altitude, then the minimization will have a
  % bit more work to do (, but we get off the hook...).
  iStn = 1;
  % Should give: iPeaks = 119   156 for our example
  [xx,yy,zz] = inv_project_points(U{1}(iPeaks{iStn}),...
                                  V{1}(iPeaks{iStn}),...
                                  stns(iStn).img,...
                                  stns(iStn).obs.xyz,...
                                  3,stns(iStn).obs.optpar,...
                                  [0 0 1],dops.zmax,stns(iStn).obs.trmtr);

  % Then we start to build a start-guess for the minimization of the 2-D
  % modeled arcs
  IntPeaks = I_cuts{iStn}(iPeaks{iStn});
  I0 = zeros(length(yy)+1,9);
  I0(1:end-1,1) = IntPeaks;
  I0(1:end-1,2) = yy;
  I0(1:end-1,3) = 3;      % Width in km
  I0(1:end-1,4) = 2;      % Gaussian exponent for horizontal variations
  I0(1:end-1,5) = 2;      % E0 (keV), Gaussian centre energy, here if triangulation,
                          % then pick energy that has peak production at
                          % alt. use A-matrices
  I0(1:end-1,6) = 0.4;    % width in energy, Absolutely arbitrary. keV
  I0(1:end-1,7) = 2;      % Gaussian exponent, energy, "same" as for #4
  I0(1:end-1,8) = 0;      % dDy
  I0(1:end-1,9) = 0.5;    % E-exponent, change as you see fit.
  
  % Diffuse precipitation differently parameterized: allways last row
  %            Ie_x         y0  dy gx E0 dE gE1 dDy gE2
  I0(end,:) = [min(IntPeaks),0,inf, 0, 5, 1,  2,  0,  0];
  
end % end here for test on one case


%% Cut out the variable parameters, set lower and upper bounds on everything...
[I0v,Iconst,v_p,Iupper,Ilower] = reorder_pars4GACT(I0,1);


fmsOPS = optimset('fminsearch');
fmsOPS.Display = 'quiet';
%%
% The first three arguments are the variable input parameters
% (I), the array with indices of where to sort these into the
% full array of all the input parameters. So the first thing
% that happens inside the tomo_err4sliceGACT function is:
% Iconst(v_p) = I,
% This makes it possible to have a function that has a lot of
% parameters, but only optimize over any (small) subset of them
% by changing the indices in v_p. The rest of the parameters
% are "normal" input arguments
%I2D =                                tomo_err4sliceGACT(I0v,v_p,Iconst(:),...
%                                                 M2Dto1D,Ie2H,Energy/1e3,...
%                                                 I_cuts,Xslice,Yslice,Zslice,...
%                                                 [],[],2,mean(zz),dops);

% Run fminsearchbnd a few times to optimize the fit.
[Ip,fv,exitflag] = fminsearchbnd(@(I) tomo_err4sliceGACT(I,v_p,Iconst,...
                                                  M2Dto1D,Ie2H,Energy/1e3,...
                                                  I_cuts,Xslice,Yslice,Zslice,...
                                                  [],[],1,mean(zz),dops),...
                                 I0v,Ilower,Iupper,fmsOPS);
[Ip,fv,exitflag] = fminsearchbnd(@(I) tomo_err4sliceGACT(I,v_p,Iconst,...
                                                  M2Dto1D,Ie2H,Energy/1e3,...
                                                  I_cuts,Xslice,Yslice,Zslice,...
                                                  [],[],1,mean(zz),dops),...
                                 Ip,Ilower,Iupper,fmsOPS);
[Ip,fv,exitflag] = fminsearchbnd(@(I) tomo_err4sliceGACT(I,v_p,Iconst,...
                                                  M2Dto1D,Ie2H,Energy/1e3,...
                                                  I_cuts,Xslice,Yslice,Zslice,...
                                                  [],[],1,mean(zz),dops),...
                                 Ip,Ilower,Iupper,fmsOPS);
[Ip,fv,exitflag] = fminsearchbnd(@(I) tomo_err4sliceGACT(I,v_p,Iconst,...
                                                  M2Dto1D,Ie2H,Energy/1e3,...
                                                  I_cuts,Xslice,Yslice,Zslice,...
                                                  [],[],1,mean(zz),dops),...
                                 Ip,Ilower,Iupper,fmsOPS);
% Then calculate the corresponding solution, containing electron
% spectra (E) above all BOB-columns (Y), the volume distribution of
% the emissions (Y x Z) and both the image cuts and the cuts ofd
% the projection:
I2D = tomo_err4sliceGACT(Ip,v_p,Iconst,...
                         M2Dto1D,Ie2H,Energy/1e3,...
                         I_cuts,Xslice,Yslice,Zslice,...
                         [],[],2,mean(zz),dops);


%% Extrapolate the volume emission rates from the slice to the volume - Attempt #1 

%% 1 Get the altitude index for "a good altitude" 
% (room for improvment here, but this should hopefully not be too
% bad, maybe one could use the altitudes of the peak volume emission
% rate field line by field line for the altitude index of the
% slice, but then one has to be  bit cunninger when extracting the
% [x,y,z] curve.)
%
% So for now we just take flat horisontal projections.
[dz,indZcut] = min(abs(squeeze(Zslice(1,1,:))-mean(zz)));
[dz,indxZ3D] = min(abs(squeeze(Z3D(1,1,:))-mean(zz)));

%% 2 Image intensities for each blob in the horizontal layers
% a The slice
[I1Cut_p4SG] = inv_project_img_surf(stns(1).img,stns(1).obs.xyz,stns(1).optpar(9),stns(1).optpar,...
                                    squeeze(Xslice(:,:,indZcut)),...
                                    squeeze(Yslice(:,:,indZcut)),...
                                    squeeze(Zslice(:,:,indZcut)),...
                                    stns(1).obs.trmtr);
%%
% b the 3-D volume:
[I1Hor_p4SG] = inv_project_img_surf(stns(1).img,stns(1).obs.xyz,stns(1).optpar(9),stns(1).optpar,...
                                    squeeze(X3D(:,:,indxZ3D)),...
                                    squeeze(Y3D(:,:,indxZ3D)),...
                                    squeeze(Z3D(:,:,indxZ3D)),...
                                    stns(1).obs.trmtr);
%% Remove nans and negatives
medianI1Hor_p4SG = nanmedian(I1Hor_p4SG(:));
I1Hor_p4SG(1,:) = medianI1Hor_p4SG;
I1Hor_p4SG(end,:) = medianI1Hor_p4SG;
I1Hor_p4SG(:,end) = medianI1Hor_p4SG;
I1Hor_p4SG(:,1) = medianI1Hor_p4SG;
I1Hor_p4SG = max(1,inpaint_nans(I1Hor_p4SG));                             
%% Image intensity lookup
% for each blob use its image projection, take the image
% intensity of that pixel, find the closest matching pixel
% intensity in the projection of the slice, then take the
% corresponding altitude variation along the altitude column of the
% 3-D block-of-blobs.
zSlice = squeeze(Zslice(1,1,:));
zVem   = squeeze(Z3D(1,1,:));
for i1 = 1:size(I1Hor_p4SG,1),
  
  for i2 = 1:size(I1Hor_p4SG,2),
    
    %squeeze(Y3D(:,:,indxZ3D)),...
    [dInts,i4VolEmCol] = min(abs(I1Hor_p4SG(i1,i2) - I1Cut_p4SG) + ...
                             (squeeze(Xslice(:,:,indZcut)) - squeeze(X3D(i1,i2,indxZ3D))).^2/50^2 + ...
                             (squeeze(Yslice(:,:,indZcut)) - squeeze(X3D(i1,i2,indxZ3D))).^2/50^2 );
    Vem(i1,i2,:) = interp1(zSlice, I2D.Vem{1}(:,i4VolEmCol) * ...        % Should be the column with the closes corresponding pixel intensity
                           I1Hor_p4SG(i1,i2)./I1Cut_p4SG(i4VolEmCol), ...% To take into account possible brighter arc regions outside we scale with the ratio
                           zVem,'pchip',0.01); % Extrapolate with something ridiculously faint
    if nargout == 3
      % if we have 3 output arguments then also extract the
      % electron flux estimate
      Ie2D(i1,i2,:) = I2D.Ie2D(:,i4VolEmCol)*I1Hor_p4SG(i1,i2)./I1Cut_p4SG(i4VolEmCol);
    end
  end
  
end

% If desired plot the start-guess proceedings:
if dops.iplot ==1,
  
  figure(dops.twoDfig);
  clf
  subplot(3,1,1)
  pcolor(squeeze(Yslice(:,:,indZcut)),Energy/1e3,log10(I2D.Ie2D)),shading flat
  caxis([-10 0]+max(caxis))
  set(gca,'yscale','log')
  ylabel('Energy (keV)','fontsize',dops.ftsz)
  caxis([-6 0]+max(caxis))
  subplot(3,1,2)
  pcolor(squeeze(Yslice(:,:,indZcut)),squeeze(Zslice(1,1,:)),I2D.Vem{1}),shading flat
  ylabel('Height (km)','fontsize',dops.ftsz)
  xlabel('Distance South (km)','fontsize',dops.ftsz)
  subplot(3,2,5)
  plot(I2D.cutImg{1},'linewidth',2)
  plot(I2D.cutProj{1},'r','linewidth',2)
  subplot(3,2,6)
  plot(I2D.cutImg{2},'linewidth',2)
  plot(I2D.cutProj{2},'r','linewidth',2)
  if dops.ipng == 1,
    cd(dops.analys_dir);
    print('-dpng',['GACT-slice_',sprintf('%dA_%dh%dm%ds',...
                                         stns(1).obs.filter,stns(1).obs.time(4:end)),'.png']);
  end
  figure(dops.threeDfig)
  clf
  subplot(1,2,1)
  tomo_slice_i(X3D,Y3D,Z3D,Vem,[],[],indxZ3D),shading flat,view(0,90)
  subplot(1,2,2)
  tomo_slice_i(X3D,Y3D,Z3D,Vem,round(size(Vem,1)/2),round(size(Vem,2)/2),indxZ3D),shading flat,view(0,90)
  if dops.ipng == 1,
    cd(dops.analys_dir);
    print('-dpng',['Start-Guess_',sprintf('%dA_%dh%dm%ds',...
                                         stns(1).obs.filter,stns(1).obs.time(4:end)),'.png']);
  end
  
end


function [I0v,I0,v_p,Iupper,Ilower] = reorder_pars4GACT(I0,verNr)
% ARC_SPLIT_REORDER_I0VPNBIAS - 
%   
% Calling:
%   [I0,v_p,Iupper,Ilower] = arc_split_reorder_I0vpNbias(I0 [,verNr])
%


%I0 = IstartGuess600{iT}
%  I0  y0  dy       g_y       E0   dE   g_E  Ddx   gE2
%  I0L I0R xSwitch  dxSwitch  E0_L E0_R dE   DdE   unused
% Set the variable parameters:

%% Set the constant parameter array:
Iconst = I0;

if nargin == 1 || verNr == 1

  v_p = zeros(size(I0)); % Initialize the array that selects the
                         % elements that we optimize over, those
                         % that are zero will be kept at the values
                         % in Iconst
  
  % Then set the inices to the variable parameters to 1
  v_p(end,[1,5,7]) = 1;  % For the diffuse layer we only let the
                         % peak intensity, the peak energy and the
                         % energy exponent g1 vary.
  v_p(1:end-1,[1 2 3 5 6 7]) = 1; % For the discrete arcs we also let
                                  % their horizontal position, widths
                                  % in horizontal distance and energy
                                  % and energy exponent vary.
  v_p = v_p';
  v_p = logical(v_p(:));
  
  Ilower = I0;
  Iupper = I0;
  %% Set reasonable values for the lower bounds: 
  Ilower(:,1) = 0; % Minimum peak electron flux
  Ilower(:,2) = I0(:,2) - 10; % minimum Y (km) position of each arc centre
  Ilower(:,3) = 0.1; % minimum width of arcs, dy in exp(-(y-y0)^g/dy^g)
  Ilower(:,4) = 1; % minimum exponent, "g" in expression above
  Ilower(:,5) = 0; % minimum value of energy parameter E0
  Ilower(:,6) = 0; % minimum energy width, dE
  Ilower(:,7) = 1; % minimum exponent of energy, g1 in E^g1*exp(-(E-E0)^g2/dE^g2)
  Ilower(:,9) = 0; % 2nd minimum exponent of energy, g2 in expression above 
  Ilower(:,8) = 0; % This was something cunny, a parameter for
                   % giving the spatial Gaussian one width on
                   % either side of the peak, unless we fit for
                   % this parameter we can ignore it here

  %% Set reasonable values for the upper bounds: 
  Iupper(:,1) = inf;% Maximum peak electron flux, have no idea, so
                    % just keep it unconstrained
  Iupper(:,2) = I0(:,2) + 10; % max Y (km) position of each arc cetre
  Iupper(:,3) = 30; % maximum width of arcs, dy in exp(-(y-y0)^g/dy^g)
  Iupper(:,4) = 3;  % maximum exponent, "g" in expression above
  Iupper(:,5) = 25; % maximum value of energy parameter E0, keV
  Iupper(:,6) = 20; % maximum energy width, dE, keV
  Iupper(:,7) = 2.5;% maximum exponent of energy, g1 in E^g2*exp(-(E-E0)^g1/dE^g1)
  Iupper(:,9) = 1;  % 2nd maximum exponent of energy, g2 in expression above 
  Iupper(:,8) = 0;  % This was something cunny, a parameter for
                    % giving the spatial Gaussian one width on
                    % either side of the peak, unless we fit for
                    % this parameter we can ignore it here

  
  % Special treatment of diffuse layer, identically parameterized:
  % allways last row special hard settings...
  %            Ie_x         y0  dy gx  E0  dE  gE1 dDy gE2
  Ilower(end,:) = [        0 0 inf  1 0.1  0     1   0   0];
  Iupper(end,:) = [      inf,0 inf  4  20 10     5,  0   5];
  % Transposem to make (:) sort them sensibly so that I(iArc,:)
  % lies adjacent to each other!
  I0 = I0';
  I0 = I0(:);
  Ilower = Ilower';
  Ilower = Ilower(:);
  Iupper = Iupper';
  Iupper = Iupper(:);
  % Var pars:
  I0v = I0(v_p);
  Ilower = Ilower(v_p);
  Iupper = Iupper(v_p);
  
elseif nargin == 1 || verNr == 2

  v_p = zeros(size(I0)); % Initialize the array that selects the
                         % elements that we optimize over, those
                         % that are zero will be kept at the values
                         % in Iconst
  
  % Then set the inices to the variable parameters to 1
  v_p(end,[1,5,7]) = 1;  % For the diffuse layer we only let the
                         % peak intensity, the peak energy and the
                         % energy exponent g1 vary.
  v_p(1:end-1,[1 2 3 5 6 7]) = 1; % For the discrete arcs we also let
                                  % their horizontal position, widths
                                  % in horizontal distance and energy
                                  % and energy exponent vary.
  v_p(1,8) = 1;
  v_p = v_p';
  v_p = logical(v_p(:));
  
  Ilower = I0;
  Iupper = I0;
  %% Set reasonable values for the lower bounds: 
  Ilower(:,1) = 0; % Minimum peak electron flux
  Ilower(:,2) = I0(:,2) - 10; % minimum Y (km) position of each arc centre
  Ilower(:,3) = 0.1; % minimum width of arcs, dy in exp(-(y-y0)^g/dy^g)
  Ilower(:,4) = 1; % minimum exponent, "g" in expression above
  Ilower(:,5) = 0; % minimum value of energy parameter E0
  Ilower(:,6) = 0; % minimum energy width, dE
  Ilower(:,7) = 1; % minimum exponent of energy, g1 in E^g1*exp(-(E-E0)^g2/dE^g2)
  Ilower(:,9) = 0; % 2nd minimum exponent of energy, g2 in expression above 
  Ilower(:,8) = -1; % This was something cunny, a parameter for
                   % giving the spatial Gaussian one width on
                   % either side of the peak, unless we fit for
                   % this parameter we can ignore it here

  %% Set reasonable values for the upper bounds: 
  Iupper(:,1) = inf;% Maximum peak electron flux, have no idea, so
                    % just keep it unconstrained
  Iupper(:,2) = I0(:,2) + 10; % max Y (km) position of each arc cetre
  Iupper(:,3) = 30; % maximum width of arcs, dy in exp(-(y-y0)^g/dy^g)
  Iupper(:,4) = 3;  % maximum exponent, "g" in expression above
  Iupper(:,5) = 25; % maximum value of energy parameter E0, keV
  Iupper(:,6) = 20; % maximum energy width, dE, keV
  Iupper(:,7) = 2.5;% maximum exponent of energy, g1 in E^g2*exp(-(E-E0)^g1/dE^g1)
  Iupper(:,9) = 1;  % 2nd maximum exponent of energy, g2 in expression above 
  Iupper(:,8) = 1;  % This was something cunny, a parameter for
                    % giving the spatial Gaussian one width on
                    % either side of the peak, unless we fit for
                    % this parameter we can ignore it here

  
  % Special treatment of diffuse layer, identically parameterized:
  % allways last row special hard settings...
  %            Ie_x         y0  dy gx  E0  dE  gE1 dDy gE2
  Ilower(end,:) = [        0 0 inf  1 0.1  0     1   0   0];
  Iupper(end,:) = [      inf,0 inf  4  20 10     5,  0   5];
  % Transposem to make (:) sort them sensibly so that I(iArc,:)
  % lies adjacent to each other!
  I0 = I0';
  I0 = I0(:);
  Ilower = Ilower';
  Ilower = Ilower(:);
  Iupper = Iupper';
  Iupper = Iupper(:);
  % Var pars:
  I0v = I0(v_p);
  Ilower = Ilower(v_p);
  Iupper = Iupper(v_p);
  
end
