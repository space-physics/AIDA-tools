function optpar = acc2optpar(acc)
% ACC2OPTPAR - Convert ACC-formated optical parameters to standart optpar
%   
% Calling:
%  optpar = acc2optpar(acc)
% Input:
%  acc - acc-formated array: [stn,az,ze,date1,date2,optmod,optpar,0]
% Outut:
%  optpar - [focalU,focalV,rot1,rot2,rot3,dx,dy,alpha,optmod,0]

% Copyright Bjorn Gustavsson 20100715

optpar = [acc([7:14,6]),0];
