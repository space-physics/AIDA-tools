function [D,o] = read_PGIASC(filename,frames,precision)
% READ_PGIASC - read PGI All Sky Images.
%   (nxn uint16 block).
%
% Calling:
%   [d,o] = read_PGIASC(filename,frames,precision)
% Input:
%  filename - filename either a string with name of file (either
%             relative of full path to file) or a struct from the
%             'dir' command (then care have to be taken that the
%             filename.name points to the file)
%  frames - array with the frames to be read [1,2,...], if empty
%           all frames are read, if first frame is negative the
%           frames will be added together [-1,2,54] will read frame
%           1, 2 and 54 and att them up. frames needs to be in
%           increasing order.
%  precision - the format of the data to read, 'uint8', 'uint16',
%              etc. read_PGIASC uses fread to read binary data
% Output:
%   d - data, [NxN] sized double array
%   o - observation struct holding available information of
%       observation.


%   Copyright � 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

N = 240;

% Open file
if ischar(filename)
  
  fp = fopen(filename,'r');
  
else
  filename = filename.name;
  fp = fopen(filename.name,'r');
  
end
% Return, as gracefully as possible...
if fp < 0
  disp(['read_PGIASC: Could not open file: ',filename])
  D = [];
  o = [];
  return
end
i1 = 1;
i2 = 1;

% If we have something in FRAMES then
if ~isempty(frames)
  
  % get the number of frames to read
  nr_frames = length(frames);
  if frames(1) < 0
    % and if the first is smaller than 0 we should just add them up.
    add_em_up = 1;
    frames = abs(frames);
  else
    % otherwise just return them all
    add_em_up = 0;
  end
  while ~feof(fp) && i2 <= nr_frames
    % Then read all frames
    d = fread(fp,[N N],precision);
    if i1 == frames(i2)
      % Keep the wanted ones
      if ~isempty(d)
        D(:,:,i2) = d';
      end
      i2 = i2+1;
    end
    i1 = i1+1;
  end
else
  % If frames is empty just plunge ahead and read them all
  nr_frames = inf;
  while ~feof(fp) && i2 <= nr_frames
    d = fread(fp,[N N],precision);
    %if i1 == frames(i2)
    if ~isempty(d)
      D(:,:,i2) = d';
    end
    i2 = i2+1;
    %end
    %i1 = i1+1;
  end
  add_em_up = 0;
end
% If they should be added up, do it
if add_em_up
  D = sum(double(D),3);
end

fclose(fp);
% Meta-data, hard-coded. Bad practise!
% Longitude-latitude of Polar Geophysical Institute observatory in
% Barentsburg on Svalbard is PGI_pos = [78.093� N, 14.208� E]
PGI_pos = [78.093, 14.208];


o.time = [2005 12 03 15 0 40];

o.filter = 5577;

o.longlat = fliplr(PGI_pos);
o.pos = o.longlat;

o.size = [N,N];
o.exptime = 1/25;
o.camnr = 0;
o.beta = [];
o.alfa = [];
o.az = 0;
o.ze = 0;
o.station = 15;
