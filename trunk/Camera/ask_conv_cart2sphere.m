function [Out1,Out2] = ask_conv_cart2sphere(a,d,aref,dref,f,g,sphere2cart)
% ASK_CONV_CART2SPHERE - conversion used in ASK_camera_[inv]model
%  Conversion between cartesian coordinates on a plane tangential
%  to the sphere with the camera at the centre, in radians. The
%  centre of the field of view is aref, dref. 
%
% Calling:
%  [Out1,Out2] = ask_conv_cart2sphere(a,d,aref,dref,f,g,sphere2cart)
% Input:
%   a    - Azimuth (radians), double array [n x m]
%   d    - Elevation (radians), double array [n x m]
%   aref - Azimuth of centre of field-of-view (radians)
%   dref - Elevation of centre of field-of-view (radians)
%   f    - Cartesian coordinates on the tangential plance (radians)
%          [n x m]
%   g    - Cartesian coordinates on the tangential plance (radians)
%          [n x m]
%   sphere2cart - flag for selecting conversion from spherical to
%                 cartesian coordinates
% Output:
%   EITHER [a,d] or [f,g]
% Usage:
%  [a,d] = ask_conv_cart2sphere([],[],aref,dref,f,g,1);
%  [f,g] = ask_conv_cart2sphere(a,d,aref,dref);
%  
% Adapted by B Gustavsson on  20101104 from conv_sc.pro (Ivchenko,
% Whiter, Dahlgren)


%   Copyright � 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin == 4 || sphere2cart == 0  % not(keyword_Set(cs)) then begin
  % Then convert from spherical to Cartesian
  ctgq = cos(d)./sin(d).*cos(a-aref);
  f =           tan(a-aref).*ctgq./(sin(dref)+cos(dref).*ctgq);
  g = (cos(dref)-sin(dref).*ctgq)./(sin(dref)+cos(dref).*ctgq);
  Out1 = f;
  Out2 = g;
else
  % else convert from Cartesian to spherical
  ctgq=(cos(dref)-sin(dref)*g)./(sin(dref)+cos(dref)*g);
  a=aref + atan(  f.*(sin(dref)./ctgq + cos(dref)) );
  d=atan( cos(a-aref)./ctgq );
  Out1 = a;
  Out2 = d;
end

%% Original comments from conv_sc.pro
%
%pro conv_sc, a,d,aref,dref,f,g,cs=cs
%;
%; A procedure to convert the spherical coordinates (a,d) - AZ/ELE
%; to cartesian coordinates on a plane tangential to the sphere 
%; with the camera at the centre, in radians.
%; The centre of the field of view is aref, dref.
%;
%; Inputs:
%;  a,d - Azimuth and elevation, in radians
%;  aref,dref - Centre of the FOV (pointing direction), in AZ/EL coordinates
%; Outputs:
%;  f,g - Cartesian coordinates on the tangential plane, in radians.
%; Keyword cs switches inputs and outputs (except aref and dref).
%;
%; keyword cs - for conversion of the detector coordinates into the
%; sperical angles 
%;
%; Used in conv_xy_ae.
%;
