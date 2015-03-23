function [I3D] = I3d_p_dI3D2(var_pars,indx_v_p,fix_par,X,Y,Z,ds,dt,tau,I3d,dI3d,convection_m,conv_pars)
% I3d_p_dI3D2 - Integration of continuity equation with sources
% loss-rates, drifts and diffusion, a pseudo-analytical scheme is
% used. This version models convection in a mode selected with the
% convection_model input parameter.
% 
% Calling: 
%   [I3D] = I3d_p_dI3D2(var_pars ,indx_v_p,fix_par,X,Y,Z,dt,tau,I3d,dI3d,convection_model)
% Input:
%  var_pars - free parameters for the convection, depending on the
%             convection model the parameterization is different
%  indx_v_p - the index for free parameters, 
%  fix_par - the fixed parameters for convection, fix_par(1) is a
%         diffusion coefficient, the other parameters depend on the
%         convection model, see below.
%  X - spatial position of 3-D blobbs in first dimension [NxMxn]
%  Y - spatial position of 3-D blobbs in second dimension [NxMxn]
%  Z - spatial position of 3-D blobbs in third dimension [NxMxn]
%  dt - time step to integrate the continuity equation over, (s)
%  tau - lifetime of the species, same sized as X, Y, Z, (s)
%  I3d - concentration of speices at the beginning of the
%        current integration interval, at time t, same size as tau
%  dI3d - production of species in the inteval [t, t+dt], same size
%         as tau.
%  convection_model - I3d_p_dI3D2 can calculate convection in three
%                     different modes:
%  1 - one constant convection in the entire volume, arbitrary wind
%      direction. fix_par(2:4) = [vx,vy,vz]
%  2 - 2 regions separated by plane (parallel with e_z) with one
%      constant drift in each region || to plane of
%      separation. fix_par(2:5) = [phi,l,v1,v2], where:
%      phi - azimuth angle of the normal to the separating plane,
%      l - the shortest distance from the origin to the separating
%      plane ([X,Y]*e_n(phi) == l)
%      v1 - magnitude of convection on side where e_n*[X Y] <= l
%      v2 - magnitude of convection on side where e_n*[X Y] > l
%  3 - 2 regions separated by plane (parallel with e_z) with one
%      drift in each region || to plane of separation whose
%      magnitude varies with the distance to the separation
%      boundary. fix_par(2:7) = [phi,l,v1,v2,dv1,dv2], where:
%      phi - azimuth angle of the normal to the separating plane,
%      l - the shortest distance from the origin to the separating
%      plane ([X,Y]*e_n(phi) == l)
%      the magnitude of convection on side where e_n*[X Y] <= l is
%      v1+(l-e_n*[X,Y])*dvdl1
%      the magnitude of convection on side where e_n*[X Y] >  l is
%      v2+(l-e_n*[X,Y])*dvdl2
%
% The (var_par, indx_v_p,fix_par,... pattern makes it
% straightforward to call the function with any number of
% varying/variable parameters (var_par) and a complementary set of
% fixed parameters. The paramater indx_v_p determines which
% elements in fix_par shall be replaced with the variable
% parameters from var_par: fix_par(indx_v_p) = var_par; It
% obviously require that the number of elements in var_par and
% indx_v_p be the same.



%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


Pars = fix_par; % Set Pars to the fixed parameter array.
Pars(indx_v_p) = var_pars; % Overwrite the variable parameters with
                           % var_pars.

Diff = Pars(1); % Diffusion coefficient
v_pars = Pars(2:end); % Convection parameters.


% accounting for drift:
switch convection_m
 case 1 % one constant drift in entire volume
  dx = v_pars(1)*dt;
  dy = v_pars(2)*dt;
  dz = v_pars(3)*dt;
  I3D = interp3(X,Y,Z,I3d,...
                 X-dx,Y-dy,Z-dz);
  %i1 = find(~isfinite(I3D(:)));
  I3D(~isfinite(I3D(:))) = 0;
  
 case 2 % 2 regions separated by plane with 2 drifts || to plane of
        % separation
  phi = v_pars(1);    % Rotation angle of the separating plane
  l_sep = v_pars(2);  % Shortest distance to plane from origin.
  v1 = v_pars(3);     % convection velocity on side <=
  v2 = v_pars(4);     % convection velocity on side >
  
  e_sep = [cos(phi),sin(phi)]; % unit vector for plane normal
  e_v   = [sin(phi),-cos(phi)];% unit vector of convection
  l = e_sep(1)*X + e_sep(2)*Y; % r dot e_n
  
  % I3D Convected with v1 on one side + I3D convected with v2 on
  % other side.
  %I3D = interp3(X,Y,Z,permute(I3d,[2 1 3]),...
  %              X-v1*dt*e_v(1),Y-v1*dt*(e_v(2)),Z) .* (l <= l_sep) ...
  %      + ...
  %      interp3(X,Y,Z,permute(I3d,[2 1 3]),...
  %              X-v2*dt*e_v(1),Y-v2*dt*(e_v(2)),Z) .* (l > l_sep);
  I3D = interp3q(I3d,...
                 v1*dt*e_v(1),v1*dt*(e_v(2))) .* (l <= l_sep) ...
        + ...
        interp3q(I3d,...
                 v2*dt*e_v(1),v2*dt*(e_v(2))) .* (l > l_sep);
  
 case 3 % 2 regions separated by plane with 2 drifts || to plane of
        % separation whose magnitude varies with the distance to
        % the separation boundary
  phi = v_pars(1);   % Rotation angle of the separating plane
  l_sep = v_pars(2); % Shortest distance to plane from origin.
  v1 = v_pars(3);    % convection velocity constant on side <=
  v2 = v_pars(4);    % convection velocity constant on side >
  dvdl1 = v_pars(5); % increment in convection velocity on side <=
  dvdl2 = v_pars(6); % increment in convection velocity on side >
  
  e_sep = [cos(phi),sin(phi)]; % unit vector for plane normal
  e_v   = [sin(phi),-cos(phi)];% unit vector of convection
  l = e_sep(1)*X + e_sep(2)*Y; % r dot e_n
  dl = l - l_sep;              % Distance from separating plane.
  disp([(v1+dl*dvdl1)*dt*e_v(1) (v1+dl*dvdl1)*dt*e_v(2)])
  disp([(v2+dl*dvdl2)*dt*e_v(1) (v2+dl*dvdl2)*dt*e_v(2)])
  
  % I3D Convected with v1+dl*dvdl1 on one side + I3D convected with
  % v2 + dl*dvdl2 on other side.
  I3D = interp3(X,Y,Z,I3d,...
                X-(v1+dl*dvdl1)*dt*e_v(1),Y-(v1+dl*dvdl1)*dt*e_v(2),Z) .* (l <= l_sep) ...
        + ...
        interp3(X,Y,Z,I3d,...
                X-(v2+dl*dvdl2)*dt*e_v(1),Y-(v2+dl*dvdl2)*dt*e_v(2),Z) .* (l > l_sep);

 case 4 % 2 regions separated by plane with 2 drifts || to plane of
        % separation and one drift perpendicular
  phi = v_pars(1);    % Rotation angle of the separating plane
  l_sep = v_pars(2);  % Shortest distance to plane from origin.
  v1 = v_pars(3);     % convection velocity on side <=
  v2 = v_pars(4);     % convection velocity on side >
  v_perp = v_pars(5); % convection velocity perpendicular to plane
  
  e_sep = [cos(phi),sin(phi)]; % unit vector for plane normal
  e_v   = [sin(phi),-cos(phi)];% unit vector of convection
  l = e_sep(1)*X*ds + e_sep(2)*Y*ds; % r dot e_n
  
  % I3D Convected with v1 on one side + I3D convected with v2 on
  % other side.
  %I3D = interp3(X,Y,Z,permute(I3d,[2 1 3]),...
  %              X-v1*dt*e_v(1),Y-v1*dt*(e_v(2)),Z) .* (l <= l_sep) ...
  %      + ...
  %      interp3(X,Y,Z,permute(I3d,[2 1 3]),...
  %              X-v2*dt*e_v(1),Y-v2*dt*(e_v(2)),Z) .* (l > l_sep);
  I3D = interp3q(I3d,...
                 v1*dt*e_v(1),v1*dt*(e_v(2))) .* (l <= l_sep) ...
        + ...
        interp3q(I3d,...
                 v2*dt*e_v(1),v2*dt*(e_v(2))) .* (l > l_sep);
  I3D = interp3q(I3D,...
                 v_perp*dt*e_sep(1),v_perp*dt*(e_sep(2)));
  
 case 5 % 2 regions separated by plane with 2 drifts || to plane of
        % separation whose magnitude varies with the distance to
        % the separation boundary
  phi = v_pars(1);   % Rotation angle of the separating plane
  l_sep = v_pars(2); % Shortest distance to plane from origin.
  v1 = v_pars(3);    % convection velocity constant on side <=
  v2 = v_pars(4);    % convection velocity constant on side >
  dvdl1 = v_pars(5); % increment in convection velocity on side <=
  dvdl2 = v_pars(6); % increment in convection velocity on side >
  v_perp = v_pars(7); % convection velocity perpendicular to plane
  
  e_sep = [cos(phi),sin(phi)]; % unit vector for plane normal
  e_v   = [sin(phi),-cos(phi)];% unit vector of convection
  l = e_sep(1)*X + e_sep(2)*Y; % r dot e_n
  dl = l - l_sep;              % Distance from separating plane.
  
  % I3D Convected with v1+dl*dvdl1 on one side + I3D convected with
  % v2 + dl*dvdl2 on other side.
  %disp([e_sep,l_sep,e_v,v1*dt,dvdl1*dt,v2*dt,dvdl2*dt,v_perp*dt])
  I3D = interp3(X,Y,Z,I3d,...
                X-(v1+dl*dvdl1)*dt*e_v(1),Y-(v1+dl*dvdl1)*dt*e_v(2),Z) .* (l <= l_sep) ...
        + ...
        interp3(X,Y,Z,I3d,...
                X-(v2+dl*dvdl2)*dt*e_v(1),Y-(v2+dl*dvdl2)*dt*e_v(2),Z) .* (l > l_sep);
  
  I3D = interp3q(I3D,...
                 v_perp*dt*e_sep(1),v_perp*dt*(e_sep(2)));
 otherwise
  %I3D = permute(I3d,[2 1 3]); % No convection at all.
end
%I3D = permute(I3D,[2 1 3]); % Unpermute

% If there is diffusion - account for diffusion
if Diff > 0
  
  V_tot = sum(I3D(:)); % total emission should be conserved during
                       % diffusion so calculate total I3D before

  [x,y,z] = meshgrid(-3:3,-3:3,-3:3);
  % Diffusion kernel, just a 3-D Gaussian...
  Ixyz_diff = ( 1/(pi*Diff(end)*dt)^1.5 ...
                *exp(-( (x).^2 + (y).^2 + (z).^2 ) ...
		   /(Diff(end)*dt) ) );
  % And then convolve with it
  I3D = convn(I3D,Ixyz_diff/sum(Ixyz_diff(:)),'same');
  
  %i1 = find(~isfinite(I3D(:)));
  I3D(~isfinite(I3D(:))) = 0;
  V_t_d = sum(I3D(:)); % and calculate total I3D after diffusion
  
  if ( V_t_d > 0 )
    
    I3D = I3D*V_tot/V_t_d; % then scale to conserve total I3D
    
  end
end

% accounting for decay with appropriate lifetime.
It = exp(-dt./tau);
I3D = It.*I3D;

% Add the production
I3D = I3D+dI3d;

if any(I3D(:)<0)
  keyboard
end

function I3D = interp3q(I_3D,dx,dy)%v1*dt*e_v(1),v1*dt*(e_v(2))
% INTERP3Q - 
%   

ix = 1:size(I_3D,2);            % get x-dimension
while dx < 0                    % on left side of separatrix
  ix = [1,ix(1:end-1)];         
  dx = dx+1;
end
while dx > 1                    % on right side of separatrix
  ix = [ix(2:end),ix(end)];
  dx = dx-1;
end
iy = 1:size(I_3D,1);            % get y-dimension
while dy < 0
  iy = [1,iy(1:end-1)];
  dy = dy+1;
end
while dy > 1
  iy = [iy(2:end),iy(end)];
  dy = dy-1;
end

I3D = ( I_3D(iy(1:end),ix(1:end),:)   *(1-dx) + ...
        I_3D(iy(1:end),ix([2:end,end]),:) * dx ) * (1-dy) + ...     % added comma here was I_3D(iy(1:end),ix([2:end end]),:) * dx ) * (1-dy) + ...
      ( I_3D(iy([2:end,end]),ix(1:end),:)    * (1-dx) + ...         
        I_3D(iy([2:end,end]),ix([2:end,end]),:)*dx    )   * dy;
end

end
