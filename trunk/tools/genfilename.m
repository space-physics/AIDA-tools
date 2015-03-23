function filename = genfilename(SkMp, n)
% GENFILENAME - generates starcal formated filenames
%  either according to ALIS or Miracle standards. This function
%  generates a filename with full path with a station identifier at
%  the beginning. For ALIS that is the single character station
%  identifier [ABKNOST], for Miracle the three character
%  identifier. If the filename belongs to an ALIS or a Miracle
%  station is determined from the SkMp.obs.station
%  number. Filenames for saving optical parameters (.acc),
%  temporary parameters - identified stars, optpar (_param.mat) or
%  error parameters (_error.mat) can be generated.
%  
% SYNOPSIS
%   filename = genfilename(SkMp, n)
%
% DESCRIPTION
% input:
%   SkMp = skymap
%   n = mode number
% 	valid values:
% 	1 - acc
% 	2 - preliminary optical parameters & identified stars
% 	3 - error file
%
% output:
%   filename - generated filename
%

% Copyright � M V

% Separate the filename:
[fdir,fname,fextenstion] = fileparts(SkMp.obs.filename);

% Determine the station identifier, and set it first in the
% filename:
FilenameWithStationFirst = fname;
if isfield(SkMp,'obs')
  if ( isfield(SkMp.obs,'station') && ...
       0 < SkMp.obs.station && SkMp.obs.station < 20 )
    % ... for ALIS version the station identifier is found as the
    % last character in the filename (excluding the extensions)
    FilenameWithStationFirst = [fname(end), fname(1:end-1)];
    FilenameWithStationFirst = SkMp.obs.filename;
  elseif ( isfield(SkMp.obs,'station') && ...
       700 < SkMp.obs.station && SkMp.obs.station < 800 )
    % For Miracle version the station identifier is found as the
    % First 3 character in the filename
    stn = fname(1:3);
    FilenameWithStationFirst = [stn, '_', fname(4:end)];
  else
    % Here the function can be extended for other naming conventions:
  end
end

% Attach the selected ending+extension:
switch(n)
 case 1
  % Filename for saving optical parameters in .acc format:
  fstr = [FilenameWithStationFirst, '.acc'];
 case 2
  % Filename for saving identified stars and optical parameters in
  % .mat format:
  fstr = [FilenameWithStationFirst, '_param.mat'];
 case 3
  % Filename for saving error parameters in .mat format:
  fstr = [FilenameWithStationFirst, '_error.mat'];
 otherwise
  % Here to things can be extended if needed:
  fstr = FilenameWithStationFirst;
end

% Set the path of the file to the desired out-put directory:
if isfield(SkMp,'StarCalResDir')
  filename = fullfile(SkMp.StarCalResDir,fstr);
else
  filename = fullfile(fstr);
end
