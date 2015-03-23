function dVem = backprojection(b,p,uv,l_cl,bfk,indx,tomoptions)
% BACKPROJECTION - Function that projects the localized ratios
% of B and P  in radial direction into DVEM. For iterative tomography
% B is the observed image and P is a current projection of the
% volume emission. UV is the projection matix from 3D space to
% the image space such that P(:) = UV*DVEM(:). L_CL is a cell-array
% holding indexes for 3D base functions in the corresponding
% size-class. BFK is the base-function-fotprint. 
% 
% Calling:
% dVem = backprojection(b,p,uv,l_cl,bfk)
% 
% See also FASTPROJECTION,  
% 
% Based on the algorithm of Peter Rydes√§ter


%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% Todo: get size of dVem into this function!
error(nargchk(6,7,nargin));

if nargin == 7;
  
  if isfield(tomoptions,'alpha')
    alpha_power = tomoptions(indx).alpha;
  else
    alpha_power = 1;
  end
  
  quiet_borderx1 = tomoptions(indx).qb(1);
  quiet_borderx2 = tomoptions(indx).qb(2);
  quiet_bordery1 = tomoptions(indx).qb(3);
  quiet_bordery2 = tomoptions(indx).qb(4);
  norm_regx1 = tomoptions(indx).renorm(1);
  norm_regx2 = tomoptions(indx).renorm(2);
  norm_regy1 = tomoptions(indx).renorm(3);
  norm_regy2 = tomoptions(indx).renorm(4);
  
  if ( alpha_power~=1 )
    
    q = (b./p).^alpha_power;
    
  else
    
    q = b./p;
    
  end
  %i1 = find(~isfinite(q));
  %q(i1) = 1;
  q(~isfinite(q)) = 1;
  if ~isnan(norm_regx1(1))
    
    q = q/mean(mean(q(norm_regy1:norm_regy2,norm_regx1:norm_regx2)));
    
  end
  
  %q([1:quiet_borderx1 quiet_borderx2:end],:) = 1;
  %q(:,[1:quiet_bordery1 quiet_bordery2:end]) = 1;
  for i1 = 1:quiet_borderx1,
    %q(:,i1) = max(0,q(:,quiet_borderx1+1)).^(alpha_power/2);
    q(:,i1) = max(1e-18,q(:,quiet_borderx1+1)).^(alpha_power/2);
  end
  for i1 = quiet_borderx2:size(q,2),
    %q(:,i1) = max(0,q(:,quiet_borderx1+1)).^(alpha_power/2);
    q(:,i1) = max(1e-18,q(:,quiet_borderx2-1)).^(alpha_power/2);
  end
  for i1 = 1:quiet_bordery1,
    %q(:,i1) = max(0,q(:,quiet_borderx1+1)).^(alpha_power/2);
    q(i1,:) = max(1e-18,q(quiet_bordery1+1,:)).^(alpha_power/2);
  end
  for i1 = quiet_bordery2:size(q,1),
    %q(:,i1) = max(0,q(:,quiet_borderx1+1)).^(alpha_power/2);
    q(i1,:) = max(1e-18,q(quiet_bordery2-1,:)).^(alpha_power/2);
  end
  
else
  
  q = b./p;
  
end

q(~isfinite(q)) = 1;

for i1 = 1:length(l_cl),
  
  if min(size(l_cl{i1}))
    
    dq = conv2(q([ones(1,floor(length(bfk{i1})/2))...
                  1:end...
                  end*ones(1,floor(length(bfk{i1})/2))],:),bfk{i1}','same');
    dq = conv2(dq(:,[ones(1,floor(length(bfk{i1})/2))...
                  1:end...
                  end*ones(1,floor(length(bfk{i1})/2))]),bfk{i1},'same');
    dq = dq(ceil(length(bfk{i1})/2):end-ceil(length(bfk{i1})/2-1),...
            ceil(length(bfk{i1})/2):end-ceil(length(bfk{i1})/2-1));
    
    dVem(l_cl{i1}) = uv(:,l_cl{i1})'*dq(:);
    
  end
  
end
