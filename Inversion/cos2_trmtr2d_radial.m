function [trmtr,fi_out] = cos2_trmtr2d_radial(r0,theta0,phi0,X,Z,dl)
% COS2_TRMTR_RADIAL - transfer matrix from X,Z onto fan beam R,PHI 
%   COS2_TRMTR_RADIAL uses cos^2(dl)*cos^2(dl) shaped basis functions at
%   all points (X(:),Z(:)), precautions have to be made to
%   guarantee that DL agrees with the spacing in (X,Y). R0 is
%   assumed to be outside (X,Z).
% 
% Calling:
% [trmtr,fi_out] = cos2_trmtr_radial(r0,phi,X,Z,dl)
% 
% Input:
%   R0  - radial distance from [x0,z0] of camera/fan-beam
%   THETA0 - direction to fan beam loci.
%   PHI0 - local elevation angles, in radians
%   X   - NxM array of horizontal position of basis functions, not
%         restricted to be plaid.
%   Z   - NxM array of vertical position of basis functions, not
%         restricted to be plaid.
%   DL  - Size of basis functions
%
%  See also TOMOGRAPHY


%   Copyright © 20010805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% load precalculated base function contributions
% This for table lookup of base fcn contributions as a function of
% angle and nearest distance to be used along the line of sight
load bfcn_contr_integr.mat


% rescale everything base-function separation of 1 (one), in order
% to simplify, straightforward use of ceil and floor 
X = X/dl;
Z = Z/dl;
r0 = r0/dl;


% the transfer matrix from I(X,Z) -> d
ls = length(phi0);
lR = length(X(:));
trmtr = sparse([],[],[],ls,lR,0);

eqnr = 1;

for jndx = 1:length(theta0),
  phi = pi/2+phi0+theta0(jndx);
  for indx = 1:length(phi0),
    
    e12 = [cos(phi(indx)) sin(phi(indx))];
  %r12 = -r1;
  
  % line-of-sight angle
  fi_out(eqnr) = atan2(e12(2),e12(1));
  
  R = [X(:) Z(:)];
  R(:,1) = R(:,1)-r0*cos(theta0(jndx));
  R(:,2) = R(:,2)-r0*sin(theta0(jndx));
  
  %Length along line between s(i) and s(j) to the point with
  %shortest distance to the basis function in R.
  lmin = sum([e12(1)*R(:,1) e12(2)*R(:,2)],2);
  
  % Shortest distance vector from (or to) the base fcn in R to
  % the line between s(i) and s(j)
  Rmin = R-[e12(1)*lmin e12(2)*lmin];
  % Shortest distance
  dmin = sum(Rmin.^2,2).^.5;
  
  % The base fcns that contribute are closer to the line between
  % s(i) & s(j) than 2^0.5 and _betweent_ 
  contrib_i = find( ( dmin < 2^.5 ) ...
                    & ( 0 <= lmin)); % ... 
                    %%%& ( lmin < dot(r12,r12)^.5 ) );
  dmin = dmin(contrib_i);
  lmin = lmin(contrib_i);
  
  phi12 = abs(atan(e12(2)/e12(1)));
  base_fcn_contr = interp2(fi,x,lint',phi12*ones(size(dmin)),dmin,'*cubic');
  trmtr(eqnr,contrib_i) = base_fcn_contr'*dl;
  
  eqnr = eqnr + 1;
  
  end
end

%i = find(~isfinite(trmtr(:)));
%trmtr(i) = 0;
trmtr(~isfinite(trmtr(:))) = 0;
