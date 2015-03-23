function err = spc_save_bad_times(sis, BT, filename)
% SPC_SAVE_BAD_TIMES - saves bad times for spectral calibration
%

% Copyright M V

% path = '.data/spc/';
path = './';
sis_saved = sis;
BT_saved = BT;

err = 0;
status = -12;
message = '';


sprintf('\nWriting data to file %s...\n', fullfile(path,filename) )
try
  if exist(fullfile(path,filename),'file')
    [status, message] = backup1000filesversions(fullfile(path,filename));
    % sprintf('\nBacking up the old file as...')
    %counter = '001';
    %while exist([path filename, '.', counter])
    %  counter = num2str(sprintf('%03d', str2num(counter)+1));
    %end
    %sprintf('%s', [path filename, '.', counter]);
    %[status, message] = movefile([path filename], [filename, '.', counter]);
  end
  save(fullfile(path,filename), 'sis_saved', 'BT_saved');
  sprintf('\nOK.\n')
catch
  sprintf('\nWriting %s failed:\n%d:%s\n', fullfile(path,filename), status, message)
  err = 1;
end


