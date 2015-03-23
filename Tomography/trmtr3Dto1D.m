function [trmtr,fi_out,debug_m] = trmtr3Dto1D(X,Y,Z,r0,e_pix,dL,OPS)
% trmtr3Dto1D - make projection matrix from 3-D to 1-D image cuts
% 
% The representation of the volume emission is based on smooth
% overlapping base functions rather than voxels. This
% representation is better suited for representing smooth
% distributions, See Rydesater and Gustavsson,
% Int. J. Img. Sys. Tech. In press. Though the basis functions here
% are rather cos(dx*pi/2)^2*cos(dy*pi/2)^2. For the use of SVD in
% tomographic applications see Gustavsson 'Three dimensional
% imaging of aurora and airglow, 2000. PhD thesis Uea univ Sweden
% 

% Copyright � Bj�rn Gustavsson 2012-01-23, <bjorn.gustavsson@irf.se>
% This is free software, licensed under GNU GPL version 2 or later


% load precalculated base function contributions
% This for table lookup of base fcn contributions as a function of
% angle and nearest distance to be used along the line of sight
load bfcn_contr_integr_new.mat

% Default options...
dOPS.plotIndx = 0;
dOPS.disp = 0;
if nargin > 6 
  % ...are combined with the supplied options
  dOPS = catstruct(dOPS,OPS);
elseif nargin == 0
  % or, if function called without input arguments, returned out of
  % the function.
  trmtr = dOPS;
  return
end
%rescale everything to simplify, straightforward use of and floor:
X = X/dL;
Y = Y/dL;
Z = Z/dL;
r0 = r0/dL;

% the transfer matrix from I(X,Y) -> d
ls = length(e_pix); % Number of lines-of-sight
lR = length(Y(:));  % number of bobs in the slice
sZ = size(Z);       % and the dimensions of the slice

% Allocate memory for the forward matrix
trmtr = sparse([],[],[],ls,lR,14*sZ(2)*ls);
eqnr = 1;
% Distance to the farthest corner of the slice-of-blobs
maxL = max( (r0(1)-X(:)).^2 + (r0(2)-Y(:)).^2 + (r0(3)-Z(:)).^2 ).^(1/2);

% if we want to plot the proceedings...
if any( dOPS.plotIndx > 0 )
  plot3(X(:),Y(:),Z(:),'b.')
  hold on
  plot3(r0(1),r0(2),r0(3),'r.','markersize',20)
  view(180+45,0)
  drawnow
end
% If we want to display the proceedings...
if dOPS.disp
  disp([sprintf('0, 0%%'),' ',datestr(now,'HH:MM:SS')])
end
EqNr = [];
Contrib_I = [];
Coeffs = [];
%Coeffs2 = [];

r1 = r0;%[r0(2) r0(3)];
% Blob position...
R = [X(:) Y(:) Z(:)];
% ...relative to the observation point:
R(:,1) = R(:,1)-r1(1);
R(:,2) = R(:,2)-r1(2);
R(:,3) = R(:,3)-r1(3);


for i1 = 1:length(e_pix),
  
  % Calculate the contributions along the line of sight in direction
  % of e_pix(i1,:)
  r2 = point_on_line(r0,e_pix(i1,:),maxL);
  %line of sight unit vector.
  r12 = r2-r1;
  e12 = r12/norm(r12);
  e12b = e_pix(i1,:); % TODO: check that these are equal!
  if any(i1 == dOPS.plotIndx )
    plot3(r2(1),r2(2),r2(3),'g.','markersize',15)
    xlabel('push any button')
    %pause(0.1)
  end
  % line-of-sight angle
  fi_out(eqnr) = atan2(e12(2),e12(1));
  
  % Length along the line-of-sight to the point with
  % shortest distance to the basis function in R. This is done with
  % the dot-product between the line-of-sight vector and the vectors
  % to R.
  lmin = sum([e12(1)*R(:,1) e12(2)*R(:,2) e12(3)*R(:,3)],2);
  
  % Shortest distance vector from (or to) the blob/base fcn in R to
  % the line-of-sight
  Rmin = R-[e12(1)*lmin e12(2)*lmin e12(3)*lmin];
  % Shortest distance
  dmin = sum(Rmin.^2,2).^.5;
  
  % The base fcns that contribute are closer to the line-of-sight
  % than 2^0.5 (scaled away dL above...)
  contrib_i = find( ( dmin < 2^.5 ) ...
                    & ( 0 <= lmin) ... 
                    & ( lmin < dot(r12,r12)^.5 ) );
  if ~isempty(contrib_i)
    
    dmin = dmin(contrib_i);
    lmin = lmin(contrib_i);
    
    % Hell knows which one of these are the correct one! BG 20120123
    phi12 = abs(atan(e12(3)/(e12(2).^2+e12(1).^2).^(1/2)));
    phi12 = abs(atan(e12(3)/e12(2)));
    % One can debate which interpolation method is the better here...
    base_fcn_contr = interp2(phi_angle,x,lint',phi12*ones(size(dmin)),dmin,'spline');
    I_line = [];
    % Scale the contribution with the blob-size:
    coeffs = base_fcn_contr'*dL;
    
    % Combine the current coefficients with others, this is done to
    % reduce the calls to sparse - that becomes very time-consuming.
    EqNr = [EqNr;eqnr*ones(size(contrib_i))];
    Contrib_I = [Contrib_I;contrib_i];
    Coeffs = [Coeffs;coeffs'];
    add_new_coeffs = 1;
  end
  % Here we increase the number of non-zero components of trmtr,
  % but only every 50 steps in i1 (roughly altitude).
  if rem(i1,50) == 0 && ~isempty(Coeffs)
    trmtr = trmtr + sparse(EqNr,Contrib_I,Coeffs,ls,lR);
    EqNr = [];
    Contrib_I = [];
    Coeffs = [];
    if dOPS.disp
      disp(i1)
    end
    add_new_coeffs = 0;
  end
  debug_m = 0;
  % If we want to plot this line-of-sight, here we plot the
  % contributions:
  if any(i1 == dOPS.plotIndx )
    if exist('contrib_i') && ~isempty(contrib_i)
      scatter3(X(contrib_i(base_fcn_contr>0)),...
               Y(contrib_i(base_fcn_contr>0)),...
               Z(contrib_i(base_fcn_contr>0)),...
               6*(floor(10*base_fcn_contr(base_fcn_contr>0))+10),...
               repmat(rand(1,3),sum(base_fcn_contr>0),[]),'.')
    end
    axis tight
    axis([-40 40 -58 58 0 100])
    view(180+45,0)
    %drawnow
  end
  %debug_m(eqnr,:) = [xs(i) ys(i) xs(j) ys(j)];

  eqnr = eqnr + 1;
  
end

% If there are additional coefficients to add (last i1 did not have
% rem(i1,50) == 0, then we have to add those coefficients here:
if add_new_coeffs
  trmtr = trmtr + sparse(EqNr,Contrib_I,Coeffs,ls,lR);
end
