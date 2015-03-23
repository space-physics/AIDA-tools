OPS4red2D = tomo_setup4reduced2D;
OPS4red2D.PlotStuff = 0;
OPS4red2D.ds = 1;
[trmtrs,U,V,X,Y,Z] = tomo_setup4reduced2D(stns(1:2),OPS4red2D);
[trmtrs{[1,3]},U{[1,3]},V{[1,3]}] = tomo_setup4reduced2D(stns([1,3]),...
                                                  OPS4red2D);


for i2 = length(i_T):-1:1,
  
  i_stns = [1,2,3,6];

  for i3 = 1:length(i_stns)
    [d,h,o] = inimg(dFiles{i_stns(i3)}(i_T(i2),:),POs(i_stns(i3)));
    stns(i3).img = d;
    if i3 == 3
      stns(i3).img(227,195:197) = mean(stns(i3).img(227,[193,199])); 
      stns(i3).img(228,195:197) = mean(stns(i3).img(228,[193,199])); 
      stns(i3).img(229,195:197) = mean(stns(i3).img(229,[193,199])); 
      stns(i3).img(230,195:197) = mean(stns(i3).img(230,[193,199])); 
    end
    disp([i3 i_stns(i3) o.time, o.filter])
    if i3 < 4
      I_cuts{i3} = interp2(stns(i3).img,U{i3},V{i3});
    end
  end
  %%% Too difficult!
  % * Identify local maxima in image cuts here
  %for i3 = [1, 2/3],
  %  iPeaks = peakfinder(I_cuts{i3});
  %  % Determine line-of-sight to all local maxima
  %  epix{i3} = inv_project_LineOfSightVectors(U{i3}(iPeaks),...
  %                                            U{i3}(iPeaks),...
  %                                            stns(i3).img,1,...
  %                                            stns(i3).obs.optpar(9),...
  %                                            stns(i3).optpar,...
  %                                            [0 0 1],10,...
  %                                            stns.obs.trmtr);%'?, or eye(3))
  %end
  % * triangulate those to get rough altitude estimate
  % for i3 = [1,2/or/3]
  %   [r,l,mindiff] = stereoscopic(r1,e1,r2,e2);
  %   iPeaks = peakfinder(I_cuts{i3});
  % Determine line-of-sight to all local maxima
  %   epix{i3} = inv_project_LineOfSightVectors(U{i3}(iPeaks),...
  %                                          V{i3}(iPeaks),...
  %                                          stns(i3).img,1,...
  %                                          stns(i3).obs.optpar(9),...
  %                                          stns(i3).optpar,...
  %                                          [0 0 1],10,...
  %                                          stns.obs.trmtr);%'?, or eye(3))
  % end
  % Simpler just project the local peaks to the approximate
  % altitude and use those positions for the horizontal start guess
  % :
  i3 = 1;
  [iPeaks,IPeaks] = peakfinder(I_cuts{i3});
  [xx,yy,zz] = inv_project_points(U{i3}(iPeaks),...
                                  V{i3}(iPeaks),...
                                  stns(i3).img,...
                                  stns(i3).obs.xyz,...
                                  stns(i3).obs.optpar(9),...
                                  stns(i3).optpar,...
                                  [0 0 1],peakAlt(iFilter),...
                                  stns.obs.trmtr);%'?, or eye(3))
  I0 = zeros(length(yy)+1,9);
  I0(1:end-1,1) = IPeaks; % let the peak electron flux vbe
                          % proportional to the peak brightness
  I0(1:end-1,2) = yy;     % north-south position, km.
  I0(1:end-1,3) = 3;      % Width in km
  I0(1:end-1,4) = 2;      % Gaussian exponent
  I0(1:end-1,5) = 2;      % E0, Gaussian centre energy
  I0(1:end-1,6) = 0.4;    % width in energy
  I0(1:end-1,7) = 2;      % Gaussian exponent, energy
  I0(1:end-1,8) = 0;      % dDy
  I0(1:end-1,9) = 0.5;    % E-exponent
  % Diffuse precipitation differently parameterized:
  I0(end,:) = [min(IPeaks),0,0,0,1,0,2,0,0];
  
  
  v_p = zeros(size(I0));
  v_p(end,[1,5,7]) = 1;
  v_p(1:end-1,[1 2 3 5 6]) = 1;
  Iconst = I0;
  I0 = I0(logical(v_p));
  [Ip{i2},fv(i2),exitflag(i2)] = fminsearchbnd(@(I) tomo_err4sliceGACT(I,v_p,Iconst,...
                                                    M2Dto1D,Ie2H,E,...
                                                    ImgCuts,X,Y,Z,...
                                                    [],[],1,z_max),...
                                               I0,Ilower,Iupper,fmsOPS);
  I2D{i2} = tomo_err4sliceGACT(Ip{i2},v_p,Iconst,...
                               M2Dto1D,Ie2H,E,...
                               ImgCuts,X,Y,Z,...
                               [],[],1,z_max);
end
