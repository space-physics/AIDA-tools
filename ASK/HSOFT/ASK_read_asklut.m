function asklut = ASK_read_asklut(filename)
% ASK_READ_ASKLUT - reads ASK meta-datafrom look up tables
%   
% Calling:
%   asklut = ASK_read_asklut(filename)
% Input:
%   Filename - name of file with ASK_LUT-formated meta-data
% Output:
%   asklut - ask-meta-data struct, also declared as global to mimic
%            the working of HSOFT in IDL. The ASKLUT struct
%            contains fields:
%            ask_t1 - start time of intervall for the field (1xN)
%            ask_t2 - stopt time of intervall for the field (1xN)
%            ask_lat - latitude of ASK position (degrees)   (1xN)
%            ask_long - longitude of ASK position (degrees) (1xN)
%            ask_ncam - number of cameras taking data during 
%                       intervall (1xN)
%            ask_uon  - ID number of camera mounted upside down
%                       (Upp Och Ner) (1xN)
%            ask_cam  - Cell array with filter names '(5620)'
%                       {ask_ncam x N}
%            ask_cnv  - Cell array of filenames to the camera
%                       parameter lookup table.
%            ask_cal  - ASK calibration factors (R/c/s?) [3 x N]
%            ask_flat - Cell array with filenames of flat-field
%                       data {3 x N}
%            ask_fps  - array with framerates [3 x N]
%            ask_bin  - array with binning factors [3 x N] only
%                       square binnings apparently.
%
% Written to mimic read_asklut.pro,
% TODO: here it start to becomme dodgy. IDL apparently has a
% "common block" construct that work pretty much like a namespace
% with globals that can be accessed from other functions. The
% question is how to do this with the best possible
% matlab-design-wise...

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


global asklut % This is the ASK-way, apparently works slightly
              % differently in IDL.


fid = fopen(filename,'r');
if fid == -1
  error(['could not open file: ',filename])
end
% Else just go ahead and start read the meta-data...

% ASK-lut starts with a five-line comment.
for i1 = 1:5,
  cline = fgets(fid);
end

formatStrDateline = '%f/%f/%f %f:%f:%f %f/%f/%f %f:%f:%f %f %f %f %f';
%keyboard
indx = 1; % First element in arrays...
while ~feof(fid)
  
  CNV = textscan(fid,formatStrDateline,1);
  a = fgets(fid);
  
  t1 = [CNV{3},CNV{2},CNV{1},CNV{4},CNV{5},CNV{6}];
  %checkdate(indx,:) = t1;
  t2 = [CNV{9},CNV{8},CNV{7},CNV{10},CNV{11},CNV{12}];
  ask_t1(indx) = ASK_TT_MJS(t1); % Start time (modified Julian seconds)
  ask_t2(indx) = ASK_TT_MJS(t2); % Stop time (modified Julian seconds)
  ask_lat(indx) = CNV{13};       % ASK latitude
  ask_long(indx) = CNV{14};      % ASK longitude
  ask_ncam(indx) = CNV{15};      % number of ASK cameras
  ask_uon(indx) =  CNV{15};      % number of ASK camera mounted
                             % "upp-och-ner" == upside down
  for j1 = 1:ask_ncam(indx), % Read stuff for each camera that's running
    a = fgets(fid);
    if ~isempty(strfind(a,' ')) % We have both filter and
                                % calibration factor
      filter_n_cal = sscanf(a,'%f %f');
      ask_cam{j1,indx} = sprintf('%d',filter_n_cal(1)); % The filter
      ask_cal(j1,indx) = filter_n_cal(2);    % The intensity calibration number
    else
      ask_cam{j1,indx} = a; % The filter
    end 
    a = fgets(fid);
    if  ~isempty(strfind(a,' ')) % We have both cnv parameters and
                                 % flat-file
      [s1,s2] = strtok(a,' ');
      ask_cnv{j1,indx} = s1;  % The lookup table with cnv parameters
      ask_flat{j1,indx} = s2; % The default flat file
    else
      ask_cnv{j1,indx} = a;     % The lookup table with cnv parameters
      ask_flat{j1,indx} = '';    % The fall-back flat file
    end
    a = fgets(fid);
    if  ~isempty(strfind(a,' ')) % If there's a binning number...
      nfps_n_nbin = sscanf(a,'%f %f');
      ask_fps(j1,indx) = nfps_n_nbin(1);
      ask_bin(j1,indx) = nfps_n_nbin(2);
    else                        % Or if there's just a fps number...
      nfps = sscanf(a,'%f');
      ask_fps(j1,indx)=nfps;
      ask_bin(j1,indx)=1;
    end
  end
  indx = indx+1; % increment index.
  
end

asklut.ask_t1 = ask_t1;
asklut.ask_t2 = ask_t2;
asklut.ask_lat = ask_lat;
asklut.ask_long = ask_long;
asklut.ask_ncam = ask_ncam;
asklut.ask_uon = ask_uon;
asklut.ask_cam = ask_cam;
asklut.ask_cal = ask_cal;
asklut.ask_cnv = ask_cnv;
asklut.ask_flat = ask_flat;
asklut.ask_fps = ask_fps;
asklut.ask_bin = ask_bin;

fclose(fid);
