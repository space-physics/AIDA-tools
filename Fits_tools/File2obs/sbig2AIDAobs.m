function [obs] = sbig2AIDAobs(sbigOBS,varargin)
% sbig2AIDAops - extracts and converts information from SBIG header
% struct, that contain much in string format.
% 
% Calling:
%    [obs] = sbig2AIDAobs(sbigOBS,varagin)
% 
% INPUT: 
%   sbigOBS  - an SBIG header structure as returned from sbig.
%   varargin - cell array with name-value pairs to complete the
%              necessary fields of an AIDA-obs-struct:
%              latlong, xyz, az, ze, trmtr, that might not be
%              possible to get from the BIG-header-struct.
% OUTPUT:
%    OBS the output is a struct with some relevant key parameters
%    such as camera rotation, exposure time, time and date of
%    exposure filter camera number, camera position.
% SBIG2AIDAOBS is typically used as the log2obs function in the
% preprocessing options struct. Normally the SBIG header contains
% insufficient information for AIDA-tools, then additional
% information can be passed as name-value pairs. For example with
% this setting:
% PO = typical_pre_proc_ops('sbig');
% PO.log2obs = @(S) sbig2AIDAobs(S,'xyz',[0 0 0],'longlat',[-145.1500 62.3930],'station',401);
%
% The fields of the obs-struct for 'xyz', 'longlat' and 'station'
% will be set to xyz: [0 0 0], longlat and station to values for
% HIPAS, Alaska,. So this function can be used to ammend incomplete
% SBIG headers, with relevant and correct meta-data. This function
% uses dynamical field naming, this requires matlab versions >= XX.



%   Copyright © 2008 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

FITS_HOME = which('inimg');
FITS_HOME = fileparts(FITS_HOME);


delimiters = [9:13 32];
delimiters = [delimiters,'~=+*/^()[]{}<>,;:'''];

obs.time = [];
obs.pos = [];
obs.station = [];
obs.xyz = [];
obs.longlat = [];
obs.alpha = [];
obs.beta = [];
obs.az = [];
obs.ze = [];
obs.camnr = [];
obs.exptime = [];
obs.filter = [];
obs.trmtr = eye(3);

date = datevec(sbigOBS.date);
time = datevec(sbigOBS.time,'HH:MM:SS');

obs.time = [date(1:3),time(end-2:end)];

obs.exptime = str2double(sbigOBS.exposure);
obs.filter = str2double(sbigOBS.filter);
obs.size = [str2double(sbigOBS.height), str2double(sbigOBS.width)];
 
% time: [2011 3 29 5 46 12]
% filter: 5577
% size: [269 268]
% exptime: 90
%pos: [-145.1500 62.3930]
%longlat: [-145.1500 62.3930]
%camnr: 0
%beta: []
%alfa: []
%az: 0
%ze: 0
%station: 401
%xyz: [0 0 0]
%trmtr: [3x3 double]

for i1 = 1:2:length(varargin)
  obs.(varargin{i1}) =  varargin{i1+1};
end

