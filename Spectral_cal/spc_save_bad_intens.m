function err = spc_save_bad_intens(gI1,gI2,gI3,gT,gX,gY,gfilter, filename)
% SPC_SAVE_BAD_INTENS - saves bad times for spectral calibration
%

% Copyright M V

% path = '.data/spc/';
path = './';

err = 0;
status = -12;
message = '';

disp(sprintf('\nWriting data to file %s...\n', filename))

try
  if exist(fullfile(path,filename),'file')
    [status, message] = backup1000filesversions(fullfile(path,filename));
  end
  save(fullfile(path,filename), 'gI1', 'gI2', 'gI3', 'gT', 'gX', 'gY', 'gfilter');
  disp(sprintf('OK.'))
catch
  disp(sprintf('\nWriting %s failed:\n%d:%s\n', [path filename], status, message))
  err = 1;
end

