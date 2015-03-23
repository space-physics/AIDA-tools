function  [SkMp] = saveerrordata(SkMp)
% SAVEERRORDATA - saves error data
%
% SYNOPSIS:
% 		[SkMp] = saveerrordata(SkMp)
% 		saveerrordata(SkMp)
%
% DESCRIPTION
% 		saveerrordata saves error data to a file STNyymmdd_hhmmss_error.mat
% 		and to SkMp.error_data (if output parameter is given) for easier access
% 		saved data: horizontal, vertical, radial and angular error.
%
% 		does not override old error files, but renames them to STNyymmdd_hhmmss_error.mat.001
% 		and so on. it must be noted though, that there is no information as to which error file
% 		corresponds with a specific set of optical parameters and identified stars, the user
% 		must be careful and keep this in mind.
%

% Copyright M V

u  = SkMp.identstars(:, 3); % horizontal image coordinate
v  = SkMp.identstars(:, 4); % vertical image coordinate
r  = ((u-size(SkMp.img,2)/2).^2+(v-size(SkMp.img,1)/2).^2).^.5; % radial image coordinate
fi = atan2((u-size(SkMp.img,2)/2),(v-size(SkMp.img,1)/2))*180/pi; % angular image coordinate

[ua, va] = project_directions(SkMp.identstars(:,1), SkMp.identstars(:,2), SkMp.optpar, SkMp.optmod, size(SkMp.img));
ra       = ((ua-size(SkMp.img,2)/2).^2+(va-size(SkMp.img,1)/2).^2).^.5;
fia      = atan2((ua-size(SkMp.img,2)/2),(va-size(SkMp.img,1)/2))*180/pi;

error_horiz = u-ua;
error_verti = v-va;
error_radia = r-ra;
error_angul = fi-fia;

SkMp.error_data.horizontal = error_horiz;
SkMp.error_data.vertical   = error_verti;
SkMp.error_data.radial     = error_radia;
SkMp.error_data.angular    = error_angul;

%fn_length = size(SkMp.obs.filename);
%if fn_length(2) == 25
%	errorfile = SkMp.obs.filename(1:16);
%elseif fn_length(2) == 27
%	errorfile = SkMp.obs.filename(1:22);
%end
%errorfile = [errorfile, '_error.mat']
errorfile = genfilename(SkMp, 3);

Wmessg = sprintf('\nWriting error data to file %s...\n', errorfile);
disp(Wmessg)

try
  if exist(errorfile,'file')
    sprintf('\nBacking up the old file as...')
    counter = '001';
    while exist([errorfile, '.', counter],'file')
      counter = num2str(sprintf('%03d', str2num(counter)+1));
    end
    sprintf('%s', [errorfile, '.', counter])
    [status, message] = movefile(errorfile, [errorfile, '.', counter]);
  end
  save(errorfile, 'error_horiz', 'error_verti', 'error_radia', 'error_angul');
  disp('OK.')
catch
  Wmessg = sprintf('\nWriting %s failed:\n%d:%s\n', errorfile, status, message);
  disp(Wmessg)
end
