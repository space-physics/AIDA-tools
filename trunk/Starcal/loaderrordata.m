function [SkMp] = loaderrordata(SkMp)
% LOADERRORDATA - loads error data
%
% SYNOPSIS
% 		[SkMp] = loaderrordata(SkMp)
%
% DESCRIPTION
% 		loads error data from file STNyymmdd_hhmmss_error.mat and
% 		saves them to SkMp.error_data
%
%			SkMp.error_data	.horizontal
%											.vertical
%											.radial
%											.angular
%

% Copyright © M V 2010

% $$$ fn_length = size(SkMp.obs.filename);
% $$$ if fn_length(2) == 25
% $$$   errorfile = SkMp.obs.filename(1:16);
% $$$ elseif fn_length(2) == 27
% $$$   errorfile = SkMp.obs.filename(1:22);
% $$$ end
% $$$ errorfile = [errorfile, '_error.mat']
errorfile = genfilename(SkMp, 3);
if ~exist(errorfile,'file')
  disp(sprintf('The file %s with error-data does not exist.\n', errorfile))
else
  load(errorfile);
  SkMp.error_data.horizontal 	= error_horiz;
  SkMp.error_data.vertical		= error_verti;
  SkMp.error_data.radial			= error_radia;
  SkMp.error_data.angular			= error_angul;
  sprintf('Error data loaded.\n');
end
