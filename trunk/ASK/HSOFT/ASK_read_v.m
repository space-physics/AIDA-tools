function img_out = ASK_read_v(i1,noImCal,RGBout,nocnv,OPS)
% ASK_READ_V - Read ASK image #i1 from current camera in current "mega-block" 
%
% Calling:
%   img_out = ASK_read_v(i1,noImCal,RGBout,nocnv,OPS)
% Input:
%   i1      - index of the image to read in the image
%             sequence. Scalar integer.
%   noImCal - Optional flag to set to avoid background subtraction
%             and flatfield correction.
%   RGBout  - Optional flag to set if the image is an RGB image -
%             will avoid calibration.
%   nocnv   - Optional flag for avoiding 
%   OPS     - options struct for controlling image filtering,
%             fields are: filtertype and filterArgs. The available
%             filters are  [ {'none'} | 'conv2' | 'sigma' | 'median'
%             | 'susan' | 'medfilt2' | 'wiener2'] (sigma and wiener2;
%             and median and medfilt2 are "same-thing-different
%             name) SUSAN is bilateral filter, conv2 linear
%             filter. Then the filterArgs should be a cell array
%             with cell arrays, where the inner cell-array should
%             be the extra arguments to the respective
%             filter. Several filtertypes can be run sequentially.
% 
% Translated from read_v.pro
%
% Original help/header comments:
%
% Modified by Dan 01/05/08 - added true keyword, to keep an image in colour. Note that this also
% stops image calibration, as the imcalibrate routine will not work on colour images.
%
% Keyword added nocnv to stop the routine trying to read the conversion coefficients to locate the image with reference to the sky
% This broke TLC data.
% Dan changed it 07/12/09, so that png doesn't do the cnv thing.
% Will do a better fix later.
%
%


global vs

dOPS.filtertype = {'none'};
dOPS.filterArgs = {};
dOPS.videodir = '';
if nargin == 0
  img_out = dOPS;
  return
end
if nargin >= 5
  dOPS = merge_structs(dOPS,OPS);
end
j1 = floor(i1);


if ( ( vs.vnf(vs.vsel) <= j1 ) & ...
     ( j1 <= vs.vnl(vs.vsel) ) & ...
     ( mod( (j1 - vs.vnf(vs.vsel)), vs.vnstep(vs.vsel) ) == 0 ) )
% Were on a number that should be between the first and the last in
% the sequence and j1 should be in the sequence:
% vs.vnf(vs.vsel):vs.vnstep(vs.vsel):vs.vnl(vs.vsel),
% Maybe faster/neater/CLEANER with ismember?
% Like so: if ismember(j1,vs.vnf(vs.vsel):vs.vnstep(vs.vsel):vs.vnl(vs.vsel))
else
  disp(['Image number ', num2str(j1), ' does not exist in this sequence!'])
  keyboard
  % TODO: determine what to do with "stop" -> dbstop/keyboard
end

if isempty(dOPS.videodir)
  videodir = vs.videodir;
else
  videodir = dOPS.videodir;
end

switch vs.vtyp{vs.vsel}
 case 'raw'
  %
  % RAW two byte data - Andor detector, winter 2004
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%d',j1)],'dat');
  % d = uintarr(vs.dimy(vs.vsel),vs.dimx(vs.vsel));
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  img_out = 1.0*rotate(d,6);
  
 case 'ask'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',j1),'.dat']);
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d)); % FLIPUD?
  
 case 'ask3'
  %
  % RAW two byte data - Andor detector #3 (upside down), winter 05/06
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',j1),'.dat']);
  % d = uintarr(dimx(vsel),dimy(vsel))
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d,3)); % FLIPUD?
  
 case 'askv8'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  
  % This is for calculating the file name-number (the mega-block
  % sequence number of the first frame in the file)
  % This should be 1, 41, 81 for 20 fps and 1 33 65 for 32 fps.
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  % File-name
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'.dat']);
  fID = fopen(file,'r');
  % the number of frames to skip to get to the desired frame:
  frames2skip = j1-fnum;
  % Skip ahead that number of frames:
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  % ...and read the desired frame:
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d)); % FLIPUD?
  
 case 'ask3v8'
  %
  % RAW two byte data - Andor detector #3 (upside down), winter 05/06
  %
  
  % Same procedure as ASKV8 above
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'.dat']);
  % d = uintarr(dimx(vsel),dimy(vsel))
  fID = fopen(file,'r');
  frames2skip = j1-fnum;
  
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d,3)); % FLIPUD?
  
 case 'askd'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',j1),'d.dat']);
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d)); % FLIPUD?
 case 'ask3d'
  %
  % RAW two byte data - Andor detector #3 (upside down), winter 05/06
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',j1),'d.dat']);
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d,3)); % FLIPUD?

 case 'askv8d'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  
  % This is for calculating the file name-number (the mega-block
  % sequence number of the first frame in the file)
  % This should be 1, 41, 81 for 20 fps and 1 33 65 for 32 fps.
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  % File-name
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'d.dat']);
  fID = fopen(file,'r');
  % the number of frames to skip to get to the desired frame:
  frames2skip = j1-fnum;
  % Skip ahead that number of frames:
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  % ...and read the desired frame:
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d)); % FLIPUD?
  
 case 'askdv8'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  
  % This is for calculating the file name-number (the mega-block
  % sequence number of the first frame in the file)
  % This should be 1, 41, 81 for 20 fps and 1 33 65 for 32 fps.
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  % File-name
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'d.dat']);
  fID = fopen(file,'r');
  % the number of frames to skip to get to the desired frame:
  frames2skip = j1-fnum;
  % Skip ahead that number of frames:
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  % ...and read the desired frame:
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d)); % FLIPUD?
  
 case 'ask3v8d'
  %
  % RAW two byte data - Andor detector #3 (upside down), winter 05/06
  %
  
  % Same procedure as ASKV8 above
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'d.dat']);
  % d = uintarr(dimx(vsel),dimy(vsel))
  fID = fopen(file,'r');
  frames2skip = j1-fnum;
  
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d,3)); % FLIPUD?
  
 case 'ask3dv8' % fucking hell...
  %
  % RAW two byte data - Andor detector #3 (upside down), winter 05/06
  %
  
  % Same procedure as ASKV8 above
  fnum = floor((j1-1)/(2./vs.vres(vs.vsel)))*(2./vs.vres(vs.vsel)) + 1;
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',fnum),'d.dat']);
  % d = uintarr(dimx(vsel),dimy(vsel))
  fID = fopen(file,'r');
  frames2skip = j1-fnum;
  
  status = fseek(fID,2*frames2skip*vs.dimx(vs.vsel)*vs.dimy(vs.vsel),'bof');
  
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = flipud(rot90(d,3)); % FLIPUD?
  
 case 'alvis'
  %
  % RAW two byte data - Andor detectors, winter 05/06
  %
  file = fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},sprintf('%05d',j1),'.dat']);
  fID = fopen(file,'r');
  d = double(fread(fID,[vs.dimx(vs.vsel),vs.dimy(vs.vsel)],'uint16'));
  fclose(fID);
  d = double(d);
  d(d(:) > 60000) = d(d(:) > 60000) - 65536.0;
  img_out = rot90(d,3)';
  
  %
  % PNG files
  %
 case 'pngkak' 
  si = sprintf('%8.8d',i1);%,form = '(i8.8)') 
  img_out = double(255.-1.0*imread(fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},si,'.png'])));
  %%%%vname(vsel) before +si
  %if not (keyword_set(nocnv)) then begin
  %  mjs = time_v(j,/full)
  %  find_cnv,mjs,conv
  %  vcnv[vsel,*] = conv
  %  endif
  %end
  
 case   'png'
  
  si = sprintf('%5.5d',i1); % ,form = '(i5.5)')
  img_out = double(255.-1.0*imread(fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},si,'.png'])));
  
  %if not (keyword_set(nocnv)) then begin
  %    mjs = time_v(j,/full)
  %    find_cnv,mjs,conv
  %    vcnv[vsel,*] = conv
  %endif
  %%%%%%%%%%%%%%%

 case 'pngRobDon'
  
  si = sprintf('%5.5d',i1); % ,form = '(i5.5)')
  img_out = 255.-1.0*imread(fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},si,'.png']));
  img_out = double(rot90(img_out,2))';
  %if not (keyword_set(nocnv)) then begin
  %  mjs = time_v(j,/full)
  %  find_cnv,mjs,conv
  %  vcnv[vsel,*] = conv
  %  endif
  %  %%%%%%%%%%%%%%%
  %end
 case 'clvis'
  
  %si = string(i,form = '(i5.5)')
  si = sprintf('%5.5d',i1); % ,form = '(i5.5)')
  img_out = -double(255.-1.0*imread(fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},si,'.png'])));
  img_out = rot90(img_out,2)';
  %if not (keyword_set(nocnv)) then begin
  %  mjs = time_v(j,/full)
  %  find_cnv,mjs,conv
  %  vcnv[vsel,*] = conv
  %  endif
  %  %%%%%%%%%%%%%%%
  %end
  %Guppy mirrored data
 case 'guppy2mirror'
  %
  %   si = string(i,form = '(i5.5)')
  si = sprintf('%5.5d',i1); % ,form = '(i5.5)')
  %   read_ppm,videodir+vdir(vsel)+'/'+si+'.pgm',img_out
  img_out = double(imread(fullfile(videodir,vs.vdir{vs.vsel},[vs.vname{vs.vsel},si,'.pgm'])));
  %
  img_out = rot90(img_out,2)';
  % mjs = time_v(j,/full)
  % find_cnv, mjs, conv
  % vcnv[vsel,*] = conv
 otherwise
end




ndim = size(img_out);
if length(ndim) == 3 
  if nargin > 2 & RGBout % Then dont add up the colour channels
    % Nothing
  else
    img_out = sum(img_out,3);
    %correct for the fact that a negative image is produced
    % Do we need to do this? img_out = 255-img_out;
  end
end

if nargin > 1  & ~isempty(noImCal) & noImCal
else
  if nargin > 2 & ~isempty(RGBout) & RGBout
  else
    img_out = ASK_imcalibrate(img_out);
  end
end

% Do image filtering here,
% a sequence of filtering can be done. This allows for systematic
% use of image filtering in all functions that reads or plots
% ASK-images, as long as an options struct is passed to
% ASK_read_v.
for i1 = 1:length(dOPS.filtertype),
  filtertype = dOPS.filtertype{i1};
  switch filtertype
   case 'none'
   case 'conv2'
    filterArgs = dOPS.filterArgs{i1};
    img_out = conv2(img_out,filterArgs{:});
   case 'sigma'
    filterArgs = dOPS.filterArgs{i1};
    img_out = wiener2(img_out,filterArgs{:});
   case 'wiener2'
    filterArgs = dOPS.filterArgs{i1};
    img_out = wiener2(img_out,filterArgs{:});
   case 'medfilt2'
    filterArgs = dOPS.filterArgs{i1};
    img_out = medfilt2(img_out,filterArgs{:});
   case 'median'
    filterArgs = dOPS.filterArgs{i1};
    img_out = medfilt2(img_out,filterArgs{:});
   case 'susan'
    filterArgs = dOPS.filterArgs{i1};
    img_out = gen_susan(img_out,filterArgs{:});
   otherwise
    try
      ffcn = str2func(dOPS.filtertype{i1});
      filterArgs = dOPS.filterArgs{i1};
      img_out = ffcn(img_out,filterArgs{:});
    catch
      disp(['Failed to run the filtering function: ',dOPS.filtertype{i1}])
    end
  end
end
