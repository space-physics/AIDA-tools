function [dark_name,dark_short] = ASK_get_dark_name(dpath,BeforeOrAfter)
% ASK_GET_DARK_NAME - get the name of the dark megablock corresponding to the
% 'light' megablock.
%
% Calling:
%   [dark_name,dark_short] = ASK_get_dark_name(dpath,BeforeOrAfter)
% Inputs: 
%   dpath - the full path to the data megablock
% Outputs:
%   dark_name - the full path to the dark megablock
%   dark_short - the dark megablock name (without full path)
%
%
% Written to mimic behaviour of get_dark_name.pro

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


% Dan fixed a bug, so that this works even when enabling the last megablock
% in the data directory (it didn't work before). 23/07/2009
%


slsh = filesep; % General file separator, with usage of fullfile
                % and fileparts this should make function OS
                % independent....
% Strip trailing "/" if necessary.
if isequal(dpath(end),slsh) 
  Dpath = dpath(1:end-1);
else
  Dpath = dpath;
end

% Directory with all ASK-data is in the directory one level above "dpath"
% iSlsh = findstr(Dpath,slsh);
iSlsh = strfind(Dpath,slsh);
DataDirName = Dpath(iSlsh(end)+1:end);
DataDirPath = Dpath(1:iSlsh(end));

% Get the date-n-time of data directory
DataDNyyyyDDmmHHmmSS = sscanf(DataDirName,'%4d%02d%02d%02d%02d%02d')';
% Keep track of data type: 'd'(-ark), 'r'(-eal), r#w real-awerage
% Not used: type = DataDirName(15);
% Camera number
nums = DataDirName(16);

% modified Julian seconds of data
mjsData = ASK_TT_MJS(DataDNyyyyDDmmHHmmSS);

% Get all darks for camera #NUMS
darksDirsN = dir([DataDirPath,slsh,'*d',nums]);

i1 = length(darksDirsN);
% make modified Julian seconds of most recent dark
darkDNyyyyDDmmHHmmSS = sscanf(darksDirsN(i1).name,'%4d%02d%02d%02d%02d%02d')';
mjsDark = ASK_TT_MJS(darkDNyyyyDDmmHHmmSS);

% Loop from more recent darks towards earlier days, stop when darks
% dir older - return with the darks just before data-dir.
while i1 > 1 & mjsDark > mjsData
  
  i1 = i1-1;
  darkDNyyyyDDmmHHmmSS = sscanf(darksDirsN(i1).name,'%4d%02d%02d%02d%02d%02d')';
  mjsDark = ASK_TT_MJS(darkDNyyyyDDmmHHmmSS);
  % Seems unused: Dmjs(i1) = mjsDark - mjsData;
  
end

if nargin == 2 & strcmp(BeforeOrAfter,'later')
  i1 = min(i1+1,length(darksDirsN));
end
dark_short = darksDirsN(i1).name;
dark_name = fullfile(DataDirPath,dark_short);
