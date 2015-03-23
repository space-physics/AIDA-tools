function [phi,theta] = camera_invmodel(u,v,optpar,optmod,imsiz)
% CAMERA_INVMODEL - line-of-sight azimuthal and polar angles PHI THETA
% relative to the optical axis of the camera.
%
% Calling:
% [phi,theta] = camera_invmodel(u,v,optpar,optmod,imsiz)
%
% Input:
%  [U,V]  - is the position in the image of the pixel. 
%  OPTPAR - is a vector caracterising the optical
%           transfer function, or an OPTPAR struct, with fields:
%           sinzecosaz, sinzesinaz, u, v that define the horizontal
%           components of a pixel l-o-s, and the pixel coordinates
%           for the corresponding horizontal l-o-s components,
%           respectively, and optionally a field rot (when used a
%           vector with 3 Tait-Bryant rotaion angles)
%  OPTMOD - is the optical model/transfer function to use:
%           1 - f*tan(theta),
%           2 - f*sin(alfa*theta),
%           3 - f(alfa*theta + (1-alfa)*tan(theta))
%           4 - f*theta 5 - f*tan(alfa*theta)
%           5 - f*tan(alfa*theta)
%          -1 - non-parametric, unrotated from zenith, with look-up
%               tables,
%          -2 - non-parametric, rotated from zenith, with look-up
%               tables,
%          11 - ASK camera model...
%  IMSIZ  - image size in pixels. 
%
%                   See also CAMERAMODEL


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin >= 5
  bx = imsiz(2);
  by = imsiz(1);
else
  
  disp('Calling: camera_model without ''imsiz'' argument this is _OBSOLETE_ and will no longer be supported')
  disp('Here is where it happened:')
  dbstack
  
end

U = u/bx;
V =  v/by;

if optmod == -1 || optmod == -2
  
  % Non-parametric surfaces approximations applied. Full
  % interpolation-lookup table implementation. Used for assymetric
  % (off-centered) mirror imaging and other assymetric
  % imaging set ups.
  % The normalized image coordinates are cnostrained to the
  % interval [0-1]
  u_i = linspace(0,1,50);
  v_i = linspace(0,1,50);
  sinzecosaz = interp2(u_i,v_i,optpar.sinzecosaz,U,V);
  sinzesinaz = interp2(u_i,v_i,optpar.sinzesinaz,U,V);
  theta = acos(interp2(u_i,v_i,optpar.cosze,U,V));
  phi = atan2(sinzesinaz,sinzecosaz);
  
elseif optmod == -3
  
  % Non-parametric surfaces approximations applied. Full
  % interpolation-lookup table implementation. Used for assymetric
  % (off-centered) mirror imaging and other assymetric
  % imaging set ups.
  % The normalized image coordinates are cnostrained to the
  % interval [0-1]
  sinzecosaz = griddata(optpar.u(:),...
                        optpar.v(:),...
                        sin(optpar.ze(:)).*cos(optpar.az(:)),...
                        U,V);
  sinzesinaz = griddata(optpar.u(:),optpar.v(:),...
                        sin(optpar.ze(:)).*sin(optpar.az(:)),...
                        U,V);
  
  theta = acos(griddata(optpar.u(:),optpar.v(:),...
                        cos(optpar.ze(:)),...
                            U,V));
  phi = atan2(sinzesinaz,sinzecosaz);
  
else

  f1 = optpar(1);
  f2 = optpar(2);
  du = optpar(6);
  dv = optpar(7);
  alpha = optpar(8);
  
  switch optmod
   case 1
    % U = f*tan(theta)
    theta = ( atan( ( ( (U-.50-du ) / f1 ).^2 + ( ( V-.50-dv ) / f2 ).^2 ).^.5 ) );
    phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
    
% $$$     if ( max(abs(( V-.50-dv ) )) > 1e-12 | max(abs( U-.50-du )) > 1e-12 )
% $$$       
% $$$       phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
% $$$       
% $$$     else
% $$$       
% $$$       phi = (0);
% $$$       
% $$$     end
   case 2  
    % ( u^2 + w^2 )^1/2 = f*sin(theta*alpha)
    % theta = 1/alpha*asin(1/f*( u^2 + w^2 )^1/2)
    r = ( ( ( U-.50-du ) / f1 ).^2 + ( ( V-.50-dv ) / f2 ).^2 ).^.5;
    theta = (asin( r )/alpha );
    % £££ Looks dodgy with the 2.0 factor, should be 1/alpha ?
    % Leave it as it is for the moment...
    phi = atan2((U-0.50-du)/(f1),(V-0.50-dv)/(f2));
% $$$     if ( max(abs(( 2.0*V-0.50-dv ) )) > 1e-12 | max(abs( 2.0*U-0.50-du )) > 1e-12 )
% $$$       
% $$$       phi = atan2((U-0.50-du)/(f1),(V-0.50-dv)/(f2));
% $$$       
% $$$     else
% $$$       
% $$$       phi = (0);
% $$$       
% $$$     end
   case 3
    % U = f*(1-a)*tan(theta)+f*a*tan(theta)
    r = ( ( ( U-.50-du ) / f1 ).^2 + ( ( V-.50-dv ) / f2 ).^2 ).^.5;
    
    theta = newrap1(r,alpha,1e-10);
    phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
% $$$     if ( max(abs(( V-.50-dv ) )) > 1e-12 | max(abs( U-.50-du )) > 1e-12 )
% $$$       
% $$$       phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
% $$$       
% $$$     else
% $$$       
% $$$       phi = (0);
% $$$       
% $$$     end
   case 4
    % U = f*theta^alpha -> theta = (U/f)^(1/alpha)
    theta = ( ( ( (U-.50-du ) / f1 ).^2 + ...
                ( ( V-.50-dv ) / f2 ).^2 ).^.5 ).^(1/alpha);
    phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
% $$$     if ( max(abs(( V-.50-dv ) )) > 1e-12 | max(abs( U-.50-du )) > 1e-12 )
% $$$       
% $$$       phi = atan2((U-.50-du)/(f1),(V-.50-dv)/(f2));
% $$$       
% $$$     else
% $$$       
% $$$       phi = (0);
% $$$       
% $$$     end
    
   case 5
    
    % ( u^2 + w^2 )^1/2 = f*tan(theta*alpha)
    % theta = 1/alpha*atan(1/f*( u^2 + w^2 )^1/2)
    r = ( ( ( U-.50-du ) / f1 ).^2 + ( ( V-.50-dv ) / f2 ).^2 ).^.5;
    theta = (atan( r )/alpha );
    phi = atan2((U-0.50-du)/(f1),(V-0.50-dv)/(f2));
% $$$     if ( max(abs(( 2.0*V-0.50-dv ) )) > 1e-12 | max(abs( 2.0*U-0.50-du )) > 1e-12 )
% $$$       
% $$$       phi = atan2((U-0.50-du)/(f1),(V-0.50-dv)/(f2));
% $$$       
% $$$     else
% $$$       
% $$$       phi = (0);
% $$$       
% $$$     end
   
   case 6
    % Optical transfer of the all sky camera in Kiruna.
    r0 = .25*(bx+by);
    xmp = bx/2;
    ymp = by/2;
    alpha = 180;
    beta = 4.35;
    rnmp = .002;
    a(5) = 89.997;
    a(1) = -74.956;
    a(2) = -21.581;
    a(3) = 34.321;
    a(4) = -27.562;
    
    xnmp = xmp +rnmp*r0*cos(3*pi/2-alpha*pi/180);
    ynmp = ymp +rnmp*r0*sin(3*pi/2-alpha*pi/180);
    rn = ((u-xnmp).^2+(v-ynmp).^2).^.5/r0;
    rn = min(rn,1);
    h = a(1)*rn+a(2)*rn.^2+a(3)*rn.^3+a(4)*rn.^4+a(5);
    h = max(h,5);
    h = h*pi/180;
    
    theta = pi/2-h;
    
    phi = atan2(u-xnmp,v-ynmp)-beta*pi/180;
   case 11
    % ASK camera model
    [phi,el] = ASK_camera_invmodel(u,v,optpar);
    theta = pi/2-el;
    
   otherwise
    
  end

end

function [theta] = m3roftheta(alpha, theta, r )

theta = ( alpha * theta + ( 1 - alpha ) * tan( theta ) - r );


function [dm3] = dm3roftheta( alpha, theta )

dm3 = ( alpha + ( 1 - alpha ) * ( 1 + (tan(theta)).*tan(theta) ) );


% Newton - Rapson solution for optical model 2 ( r = f*a*theta + f*(1-a)*tan(theta) )
% The method converges fast for 0<r<.81 to give errors less than 1e-17 within 5 
% itterations. ( B. G. 1996 04 20 )

function [theta] = newrap1( r, alpha, tol )

thetaout = atan(r);
diff = m3roftheta(alpha,thetaout,r);

while ( any(abs(diff) > tol) )
  
  thetaout = thetaout - diff./dm3roftheta(alpha,thetaout);
  diff = m3roftheta(alpha,thetaout,r);
  
end

theta = thetaout;
