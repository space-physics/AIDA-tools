function [stnXYZ,stnLongLat,trmtr] = mk_alis_pos_xyz(ALISstnNr)
% MK_ALIS_POS_XYZ - get ALIS station coordinates and transformation
% matrices. 
% 
% Calling:
%   [stnXYZ,stnLongLat,trmtr] = mk_alis_pos_xyz(ALISstnNr)
% Input:
%   ALISstnsNr - ALIS station identification number [1-7,10,11],
%                optional - defaults to [1:7,10]
% Output:
%   stnXYZ     - local horizontal ALIS station coordinates (local
%                at IRF-Kiruna)
%   stnLongLat - longitude and latitude for ALIS stations
%   trmtr      - tranformation matrices between local ALIS-station
%                coordinates to IRF-Kiruna coordinates.
% 
% SEE also: AIDApositionize, AIDAstationize

%   Copyright © 20121203 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% If we have no input argument with station number...
if nargin == 0
  % ...then use the default ALIS stations:
  ALISstnNr = [1 2 3 4 5 6 7 10];
end

% Delegate the work to the AIDApositionize function:
[stnXYZ,stnLongLat,trmtr] = AIDApositionize(ALISstnNr,1);
