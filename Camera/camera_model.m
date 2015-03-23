function [u,w] = camera_model(az,ze,e1,e2,e3,optpar,optmod,imsiz)
% CAMERA_MODEL - determine the image coordinates of light from [az,ze]
% The point source is in the direction described by the azimuth and
% zenith angles AZ, ZE. E1, E2 and E3 are the rotated camera coordinate
% system. OPTPAR is the optical parameters, OPTMOD is the camera
% model, and IMSIZ is the image size.
%
% Calling:
%  [u,w] = camera_model(az,ze,e1,e2,e3,optpar,optmod,imsiz)
%
% Input:
%  az - azimuthal angle (radians) of lines of sight
%  ze - zenith angle (radians) of lines of sight, should have same
%       size as az.
%  e1 - unit vector for horizontal image coordinates
%  e2 - unit vector for vertical image coordinates
%  e3 - unit vector for optical axis of camera
%  OPTPAR - is a vector caracterising the optical
%           transfer function, or an OPTPAR struct, with fields:
%           sinzecosaz, sinzesinaz, u, v that define the horizontal
%           components of a pixel l-o-s, and the pixel coordinates
%           for the corresponding horizontal l-o-s components,
%           respectively, and optionally a field rot (when used a
%           vector with 3 Tait-Bryant rotaion angles)
%  For OPTMOD 1-5 OPTPAR is an array where the fields have following
%  meaning: 
%  OPTPAR(1) is the horizontal focal widht (percent of the image size )
%  OPTPAR(2) is the vertical focal width (percent of the image size )
%  OPTPAR(6) is the horizontal displacement of the optical axis
%  OPTPAR(7) is the vertical displacement of the optical axis
%  OPTPAR(8) is a correction factor for deviations from a pin-hole
% camera-model. All parameters are relative to the image size.
%  OPTMOD - is the optical model/transfer function to use:
%           1 - f*tan(theta),
%           2 - f*sin(alfa*theta),
%           3 - f(alfa*theta + (1-alfa)*tan(theta))
%           4 - f*theta
%           5 - f*tan(alfa*theta)
%          -1 - non-parametric, unrotated from zenith, with look-up
%               tables,
%          -2 - non-parametric, rotated from zenith, with look-up
%               tables,
%          11 - ASK camera model.
%  OPTMOD is the camera-model-number.
%  IMSIZ  - image size in pixels. 
%
% See also CAMERA_INV_MODEL

%   Copyright � 2001-03-30 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



if nargin >= 8
  % Todo: Check if this should be swapped:
  bx = imsiz(2);%%% Possible bug! BG 20060919
  by = imsiz(1);%%% Possible bug!
else
  
  disp('Calling: camera_model without ''imsiz'' argument this is _OBSOLETE_ and will no longer be supported')
  disp('Here is where it happened:')
  dbstack
  
end


if ( optmod == 7 || optmod == -1 || optmod == 8 || optmod ==-2 )

  es1 = sin(ze).*sin(az);
  es2 = sin(ze).*cos(az);
  es3 = cos(ze);
  % Projection of l-o-s vector in direction [az,ze] onto e1
  dot_e_e1 = es1*e1(1) + es2*e1(2) + es3*e1(3);
  % Projection of l-o-s vector in direction [az,ze] onto e2
  dot_e_e2 = es1*e2(1) + es2*e2(2) + es3*e2(3);
  % ��� Projection of l-o-s vector in direction [az,ze] onto e3
  % ��� dot_e_e3 = es1*e3(1) + es2*e3(2) + es3*e3(3);
  cosazsinze_i = linspace(-1,1,50); % cos*sin aer begraensade till
  sinazsinze_i = linspace(-1,1,50); % intervallet [-1 1]
  u = interp2(sinazsinze_i,cosazsinze_i,optpar.u,dot_e_e1,dot_e_e2);
  w = interp2(sinazsinze_i,cosazsinze_i,optpar.v,dot_e_e1,dot_e_e2);
  
elseif 0 && (optmod == 7 || optmod == -1)
  
  % Non-parametric surfaces approximations applied. Full
  % interpolation-lookup table implementation. Used for asymmetric
  % (off-centered) mirror imaging and other assymetric
  % imaging set ups.
   cosazsinze_i = linspace(-1,1,50); % cos*sin aer begraensade till
   sinazsinze_i = linspace(-1,1,50); % intervallet [-1 1]
   sinzecosaz = sin(ze).*cos(az);
   sinzesinaz = sin(ze).*sin(az);
   u = interp2(cosazsinze_i,sinazsinze_i,optpar.u,sinzecosaz,sinzesinaz);
   w = interp2(cosazsinze_i,sinazsinze_i,optpar.v,sinzecosaz,sinzesinaz);
   
elseif 0 && ( optmod == 8 || optmod == -2)
  
  % Non-parametric surfaces approximations applied. Full
  % interpolation-lookup table implementation. Used for asymmetric
  % (off-centered) mirror imaging and other assymetric
  % imaging set ups. This variant differs in that it uses the rotations.
  
  sinze = sin(ze);
  es1 = sinze.*sin(az);
  es2 = sinze.*cos(az);
  es3 = cos(ze);
  
  % Projection of unit vector in direction [az,ze] onto e1
  sese1 = es1*e1(1) + es2*e1(2) + es3*e1(3);
  
  % Projection of unit vector in direction [az,ze] onto e2
  sese2 = es1*e2(1) + es2*e2(2) + es3*e2(3);
  
  cosazsinze_i = linspace(-1,1,50); % cos*sin aer begraensade till
  sinazsinze_i = linspace(-1,1,50); % intervallet [-1 1]
  u = interp2(cosazsinze_i,sinazsinze_i,optpar.u,sese1,sese2);
  w = interp2(cosazsinze_i,sinazsinze_i,optpar.v,sese1,sese2);

elseif optmod == -3
  
  es1 = sin(ze).*sin(az);
  es2 = sin(ze).*cos(az);
  es3 = cos(ze);
  % Projection of l-o-s vector in direction [az,ze] onto e1
  dot_e_e1 = es1*e1(1) + es2*e1(2) + es3*e1(3);
  % Projection of l-o-s vector in direction [az,ze] onto e2
  dot_e_e2 = es1*e2(1) + es2*e2(2) + es3*e2(3);
  % ��� Projection of l-o-s vector in direction [az,ze] onto e3
  % ��� dot_e_e3 = es1*e3(1) + es2*e3(2) + es3*e3(3);
  
  
  % ��� cosazsinze_i = linspace(-1,1,50); % cos*sin aer begraensade till
  % ��� sinazsinze_i = linspace(-1,1,50); % intervallet [-1 1]
  u = griddata(sin(optpar.az(:)).*sin(optpar.ze(:)),...
               cos(optpar.az(:)).*sin(optpar.ze(:)),...
               optpar.u(:),...
               dot_e_e1,dot_e_e2);
  w = griddata(sin(optpar.az(:)).*sin(optpar.ze(:)),...
               cos(optpar.az(:)).*sin(optpar.ze(:)),...
               optpar.v(:),...
               dot_e_e1,dot_e_e2);
  
else
  
  f1 = optpar(1);
  f2 = optpar(2);
  dx = optpar(6);
  dy = optpar(7);
  alfa = optpar(8);
  
  sinze = sin(ze);
  es1 = sinze.*sin(az);
  es2 = sinze.*cos(az);
  es3 = cos(ze);
  
  % Projection of unit vector in direction [az,ze] onto e1
  sese1 = es1*e1(1) + es2*e1(2) + es3*e1(3);
  
  % Projection of unit vector in direction [az,ze] onto e2
  sese2 = es1*e2(1) + es2*e2(2) + es3*e2(3);
  
  % Projection of unit vector in direction [az,ze] onto e3
  sese3 = es1*e3(1) + es2*e3(2) + es3*e3(3);
  
  switch optmod
   case 4
    % ( u^2 + w^2 )^1/2 = f*taeta^alfa
    %## For pixel field-of-view to be finite alfa has to be 1.
    
    % thetas
    atan_sese1sese2 = abs( atan(((sese1).^2+(sese2).^2).^.5./(sese3)) );
    % For check-for-divide-by-zero
    sese1_p_sese2 = ((sese1).^2+(sese2).^2).^.5;
    u2 = f1*(sese1)./sese1_p_sese2.*atan_sese1sese2.^alfa;
    w2 = f2*(sese2)./sese1_p_sese2.*atan_sese1sese2.^alfa;
    % Check for divide-by-zero
    u2(sese1_p_sese2 == 0 ) = 0;
    w2(sese1_p_sese2 == 0 ) = 0;
    % Shift to center of image frame
    u = u2 + .5 +dx;
    w = w2 + .5 +dy;
    
   case 3
    % ( u^2 + w^2 )^1/2 = f(a*taeta + (1-a)*tan(taeta))
    % Second term
    u1 = f1*(1-alfa)*(sese1)./(sese3);
    w1 = f2*(1-alfa)*(sese2)./(sese3);
    % thetas
    atan_sese1sese2 = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
    % For check-for-divide-by-zero
    sese1_p_sese2 = ((sese1).^2+(sese2).^2).^.5;
    % First term
    u2 = f1*alfa*(sese1)./sese1_p_sese2.*atan_sese1sese2;
    w2 = f2*alfa*(sese2)./sese1_p_sese2.*atan_sese1sese2;
    % Check for divide-by-zero
    u2(sese1_p_sese2 == 0 ) = 0;
    w2(sese1_p_sese2 == 0 ) = 0;
    % Shift to center of image frame
    u = u1 + u2 + .5 +dx;
    w = w1 + w2 + .5 +dy;
    
   case 2
    % ( u^2 + w^2 )^1/2 = f*sin(alfa*taeta)
    
    % thetas
    taeta = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
    % For check-for-divide-by-zero
    sese1_p_sese2 = ((sese1).^2+(sese2).^2).^.5;
    
    u2 = f1*(sese1)./((sese1).^2+(sese2).^2).^.5.*sin(taeta*alfa);
    w2 = f2*(sese2)./((sese1).^2+(sese2).^2).^.5.*sin(taeta*alfa);
    % Check for divide-by-zero
    u2(sese1_p_sese2 == 0 ) = 0;
    w2(sese1_p_sese2 == 0 ) = 0;
    
    % Shift to center of image frame
    u = u2 + .5 +dx;
    w = w2 + .5 +dy;
    
   case 5
    % ( u^2 + w^2 )^1/2 = f*tan(alfa*taeta)
    
    % thetas
    taeta = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
    % For check-for-divide-by-zero
    sese1_p_sese2 = ((sese1).^2+(sese2).^2).^.5;
    
    u2 = f1*(sese1)./((sese1).^2+(sese2).^2).^.5.*tan(taeta*alfa);
    w2 = f2*(sese2)./((sese1).^2+(sese2).^2).^.5.*tan(taeta*alfa);
    % Check for divide-by-zero
    u2(sese1_p_sese2 == 0 ) = 0;
    w2(sese1_p_sese2 == 0 ) = 0;
    
    % Shift to center of image frame
    u = u2 + .5 +dx;
    w = w2 + .5 +dy;
    
    
   case 1
    
    % ( u^2 + w^2 )^1/2 = f*tan(taeta)
    u1 = f1*(sese1)./(sese3);
    w1 = f2*(sese2)./(sese3);
    % Check for divide-by-zero
    u1(sese3 == 0 ) = 0;  % Changed on 20110109, was:  u2(sese3 == 0 ) = 0;
    w1(sese3 == 0 ) = 0;  % Changed on 20110109, was:  w2(sese3 == 0 ) = 0;
    % Shift to center of image frame
    u = u1 + .5 +dx;
    w = w1 + .5 +dy;
    
   case 6
    % New Kiruna allsky-camera
    % within +-1 pixel for zenit < 65-70 degrees
    taeta = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
    coefs = [1053.5 -1.0125 15.28 -109.4 58.874];
    r_of_th = ( coefs(1)*taeta + ...
                coefs(2)*taeta.^2 + ...
                coefs(3)*taeta.^3 + ...
                coefs(4)*taeta.^4 + ...
                coefs(5)*taeta.^5 );
    u2 = f1*(sese1)./((sese1).^2+(sese2).^2).^.5.*r_of_th/bx;
    w2 = f2*(sese2)./((sese1).^2+(sese2).^2).^.5.*r_of_th/by;
    u2((sese1).^2+(sese2).^2 == 0 ) = 0;
    w2((sese1).^2+(sese2).^2 == 0 ) = 0;
    
    u = u2 + .5 +dx;
    w = w2 + .5 +dy;
    
   case 9
    % Koschs kamera, no rotations
    zep = -0.111218+1.178282*(ze*180/pi)-0.017945*(ze*180/pi).^2 + 0.00043*(ze*180/pi).^3;
    u = 10.174/2*zep.*cos(az)+369;
    w = 9.569/2*zep.*sin(az)+250;
   case 11
    % ASK camera model
    [x,y] = ASK_camera_model(az,pi/2-ze,optpar);
    u = x/bx;
    w = y/by;
    
   otherwise
    
    u = zeros(size(az));
    w = zeros(size(az));
    warning(['Trying to use unknown camera model: ',num2str(optmod)])
    
  end
  
end

if optmod ~= 6
  
  u = u*bx;
  w = w*by;
  
end
