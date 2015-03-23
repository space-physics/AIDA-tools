function [data_frames] = fits_frames(fid,info,out_frames)
% FITS_FRAMES - reads fits data frames from fits file
%
% Calling:
%  [data_frames] = fits_frames(fid,info,out_frames)
%
% Input:
%  FID - file pointer/file handle/file identifier as returned from
%        FOPEN 
%  INFO - fits info struct as returned from FITS_HEADER
%  OUT_FRAMES - array [1 x n] with indexes of frames to be read out
%               first frame is frame #1.
% Output:
%  DATA_FRAMES - array [n2 x n1 x n3] with data/image frames.
%  
% Comment: Only tested for fits files with 1 single header and
%          NAXIS either 2 or 3.
%
% See also: FOPEN, FITS_HEADER

%   Copyright © 20100705 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

f_position = ftell(fid);

% The info struct should have a field nx where the dimensions of
% the image-fields/images-field should be:
% sx = info.nx(1);info.PrimaryData.Size
% sy = info.nx(2);
sx = info.PrimaryData.Size(1);
sy = info.PrimaryData.Size(2);
% Allocate size for the output-array:
data_frames = zeros([sy,sx,length(out_frames)]);

BP = [8 16 16 ];
if ( nargout > 0 )
  
  for i1 = length(out_frames):-1:1,
    
    %disp([i1 f_position, abs(info.bitpix/8),(out_frames(i1)-1),sx,sy,f_position+abs(info.bitpix/8)*(out_frames(i1)-1)*sx*sy])
    % if the current frame is within the number of frames ofthe
    % fits-file this should work...
    FullFrameExist = fseek(fid,f_position+abs(info.bitpix/8)*(out_frames(i1))*sx*sy,'bof');
    if FullFrameExist == 0
      % ...then this should put the FID at the beginning of that
      % image field:
      status = fseek(fid,f_position+abs(info.bitpix/8)*(out_frames(i1)-1)*sx*sy,'bof');
      % So we can read the corresponding image-frame data:
      switch info.bitpix
       case 8
        data=fread(fid,[sx,sy],'char');
       case 16
        data=fread(fid,[sx,sy],'int16');
       case 32
        data=fread(fid,[sx,sy],'int32');
       case -32
        data=fread(fid,[sx,sy],'float32');
       case -64
        data=fread(fid,[sx,sy],'float64');
       otherwise
        warning(['unknown data format: bitpix = ',num2str(info.bitpix)]);
      end
      data_frames(:,:,i1) = data';
      fseek(fid,f_position,'bof');
    else
      disp(['Frame: ',sprintf('%d',out_frames(i1)),' does not exist!'])
    end
  end
  
end
