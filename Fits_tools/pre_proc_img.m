function img_out = pre_proc_img(img_in,obs,PREPRO_OPS)
% PRE_PROC_IMG - systematic image correction and preprocessing of
% images 
% 
% Calling: 
%   img_out = pre_proc_img(img_in,obs,PREPRO_OPS)
%   def_pre_proc_ops = pre_proc_img
% Input:
%   IMG_IN - input image, double [nY x nX]
%   PREPRO_OPS - struct with preprocessing instructions.
% Output:
%   IMG_OUT - preprocessed image. 
% or if function is called without input options it outputs
%   def_pre_proc_ops - the default pre-processing options.
% 
% The fields of PREPRO_OPS that is used are: 
%   quadfix:       - for imagers that have multiple read-out
%                    electronics quadrants of halves migh have
%                    zero-levels that drift relative to each
%                    other. If overscan-strips (O-S) are available,
%                    this can be corrected for. Value here is
%                    [0,1,2] for 0, 1 or 2 O-Ss. The O-S are
%                    supposed to be in the first and last columns
%                    of the image
%   quadfixsize: - Size of the O-S, if set to Zero, the size will
%                  be calculated as abs(diff(size(img_in)))/quadfix
%   replaceborder: First and last row of the ALIS images are often
%                  way off compared to the second and second last
%                  row. With this set to 1 the first and last row
%                  will be replaced with the 2nd and second last
%                  rows.
%   badpixfix: -  Set to 1 if there is a bad-pixel map that can be
%                 used to find the dead, white, hot and cold pixels
%                 to make it possible to correct.
%   outimgsize: - Set to something to allow for post-binning, for
%                 resize-ratios of 2, 4 8 and 16 this should be
%                 relatively fast.
%   medianfilter: - for image filtering, array of filtersizes for
%                   cascading filtering ( medianfilter > 0,
%                   wienerfilter < 0, complex numbers will lead to
%                   filtering with gen_susan), example
%                   PO.medianfilter = [3 -5] -> 
%                   I = wiener2(medfilt2(I,[3 3]),[5 5]),
%                   PO.medianfilter = 2 + 1.5i ->
%                   I = gen_susan(I, fK, gsOPS); 
%                   where fK is a Gaussian filter with 1/e-width of
%                   4, and scaling of the intensity weights as
%                   exp(-|I-I0|^2/(1.5*I)) - straight Poissonian
%                   should be exp(-|I-I0|^2/(I)). With
%                   real(PO.medianfilter)>0 the center pixels are not
%                   included in the bilateral filtering step
%                   leading to a more median-filter characteristic,
%                   with real(PO.medianfilter) < 0 the center
%                   pixels are included leading to a filter
%                   characteristics more similar to the Lee-sigma
%                   filter. 
%   defaultccd6:    Only ALIS-signifficant: ALIS CCD-6 has a bug in
%                   the AstroCam software, with this set to 1
%                   corrections are made.
%   bias_correction: Set to one if there is bias images to use for bias-removal
%   bzero_sign:      Sign of BZERO if that is found in image header/obs-struct.
%   imreg:           Set to sub-array if not entire image is wanted
%                    [iu1,iu2,iv1,iv2] with u and v as horizontal
%                    and vertical image coordinates respectively,
%                    I = I(iv1:iv2,iu1:iu2);
%   C_cam: - matrix for image intensity scaling, such as correcting
%            for Pixel Response Non Uniformity, or vignetting. I = I/C_cam;
%   remove_these_stars: List of stars to mask out from the
%                       image. Should be an array [2 x N] with
%                       right ascension and declination in degrees.
%   optpar:          parameters for optical characteristics. Used
%                    for masking of stars and calculation of
%                    flat-field correction.
%   size_r_t_s: Size of the mask, in pixels. size_r_t_s = 2
%               corresponds to a square mask of -2:2 centred on the
%               ideal image position from the catalogued star
%               position.
%   v_interf_notches: Some ALIS-images has severe vertical
%                     interference. This should be set to an array
%                     of vertical spatial requencies to filter
%                     out. Automatically accounts for wrapping and
%                     mirroring.
%   psf: Point spread function for deblurring/sharpening.
%
% The following three fields are used for automatic removal of
% interference noise. The method use the ratio between the
% unfiltered image and the sigma-filtered image and identifies
% interference frequencies as the 2-D frequencies that are above
% INTERFERENCE_LEVEL. The Sigma-filter (wiener2 in matlab parlance)
% is done with a region of INTERFERENCE_SWF.*[1,1]. The
% interference pattern can be tweaked somewhat with the
% INTERFERENCE_METHODs 
%   interference_level: Inf (off because only ratios larger than
%                       Inf will be identified as interference
%                       signal), smaller values leads to masking of
%                       increasing number of requencies. 
%   interference_method: [{'flat'} | 'interp' | 'weighted'] 
%   interference_swf: 3  size of region for wiener2
%
%   img_histeq: - do histogram equalisation, give the equalized
%                 image a flat histogram with IMG_HISTEQ number of bins.
%   hist_crop:  - set to percentage of histogram to crop in top and
%                 bottom.
%   find_optpar: - search for optical parameters, if set to 1,
%   fairly outdated so keep this at its default value at 0.
% 
% See also INIMG, TYPICAL_PRE_PROC_OPS


%   Copyright � 20050804 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

persistent ff  optp

if nargin == 0
  
  % If no input arguments give the default PO-struct
  img_out = typical_pre_proc_ops;
  return
  
end

if isempty(ff)
  ff{1} = [];
  optp{1} = [];
end

img_out = img_in;

manual_ccd6 = 1;

if obs.camnr == 6
  
  if PREPRO_OPS.defaultccd6
    
    manual_ccd6 = 0;
    switch min(size(img_out))
     case 1024
      img_out = img_out(:,[529:538 1:528 549:end 539:548]);
     case 512
      img_out = img_out(:,[265:269 1:264 275:end 270:274]);
     case 256
      img_out = img_out(:,[133:134 1:132 137:end 135:136]);
     case 128
      img_out = img_out(:,[67 1:66 69:end 68]);
     case 64
      img_out = img_out(:,[33 1:32 35:end 34]);
     otherwise
      manual_ccd6 = 1;
    end % switch min(size(img_out))
    
  end % if isfield(PREPRO_OPS,
  
end % if obs.camnr

if  obs.camnr == 6 && manual_ccd6
    
    disp('Current image are taken with ccd-cam 6 which is a little bit')
    disp('tricky to preprocess. So you have to untangle the central')
    disp('columns manually. Below follows a scheme that is a')
    disp('suggestion of what type of steps is suitable for')
    disp('256x256 images. Try and test step by step which modifications')
    disp('that are needed. to continue type: return at the prompt')
    disp('  d = img_out;')
    disp('  d = d(:,[1 133 134 2 3 4:132 137:end 135 136]);')
% $$$     disp(exstr)
% $$$     exstr = '  d = img_out;';
% $$$     exstr = str2mat(exstr,'  d = d(:,[1 133 134 2 3 4:132 137:end 135 136]);');
% $$$     disp(exstr)
    
end % if  obs.camnr == 6 && manual_ccd6

if ~isempty(PREPRO_OPS.remove_these_stars)
  if PREPRO_OPS.quadfixsize
    stripsize = PREPRO_OPS.quadfixsize;
  else
    stripsize = .5*abs(diff(size(img_out)));
  end
  bxy = size(img_out);
  bx = bxy(1);
  by = bxy(2);
  [az,ze] = starpos2(PREPRO_OPS.remove_these_stars(:,1),...
                     PREPRO_OPS.remove_these_stars(:,2),...
                     obs.time(1:3),...
                     obs.time(4:6),...
                     obs.longlat(2),... % Changed from obs.pos(2)
                     obs.longlat(1));   % Changed from obs.pos(1)
  if isfield(PREPRO_OPS,'optpar')
    optpar = PREPRO_OPS.optpar;
  end
  
  if isstruct(optpar)
    [ua,wa] = project_directions(az',ze',optpar,optpar.mod,bxy);
  else
    [ua,wa] = project_directions(az',ze',optpar,optpar(9),bxy);
  end
  ua = round(ua)+stripsize;
  wa = round(wa);
  iu = find(inimage(ua-4,wa-4,bx-7,by-7));
  
  if isfield(PREPRO_OPS,'size_r_t_s')
    dl = PREPRO_OPS.size_r_t_s;
  elseif mean(size(img_out))>256
    dl = 2;
  else
    dl = 1;
  end
  
  for i = 1:length(iu),
    wreg1 = max( min( wa(iu(i))-dl:wa(iu(i))+dl, bx), 1);
    ureg1 = max( min( ua(iu(i))-dl:ua(iu(i))+dl ,by) ,1);
    wreg2 = max( min( wa(iu(i))-(dl+1):wa(iu(i))+(dl+1), bx), 1);
    ureg2 = max( min( ua(iu(i))-(dl+1):ua(iu(i))+(dl+1) ,by) ,1);
    A_diff = length(ureg2)*length(wreg2) - length(ureg1)*length(wreg1);
    
    img_out(wreg1,ureg1) = (sum(sum(img_out(wreg2,ureg2)))-...
                              sum(sum(img_out(wreg1,ureg1))))/A_diff;
    
  end
  
end

if isfield(PREPRO_OPS,'bzero_sign') && ~isempty(PREPRO_OPS.bzero_sign)
  
  try
    img_out = img_out + sign(PREPRO_OPS.bzero_sign)*obs.BZERO;
  catch
    warning('Could not correct image intensities with BZERO')
  end
  
end


if ~isempty(PREPRO_OPS.v_interf_notches)
  
  img_out = rem_vert_interference(img_out([2 2:end-1 end-1],:),PREPRO_OPS.v_interf_notches,2);
  
end

if ( PREPRO_OPS.quadfix )
  
  if PREPRO_OPS.quadfixsize
    stripsize = PREPRO_OPS.quadfixsize;
  else
    stripsize = .5*abs(diff(size(img_out)));
    if stripsize == 2
      stripsize = 1;
    end
  end
  
  if ( stripsize )
    
    img_out = quadfix3(img_out,2,stripsize);
    img_out = removerscanstrip(img_out,2,.5*abs(diff(size(img_out))));
    
  end
  
end

if PREPRO_OPS.bias_correction
  
  img_out = bias_correction(img_out,obs);
  
end

if PREPRO_OPS.replaceborder
  
  img_out = replace_border(img_out);
  
  if ( PREPRO_OPS.quadfix )
    
    img_out = quad_extrafix(img_out);
    
  end
  
end

if ( ~isempty(PREPRO_OPS.C_cam') && ...
     ( all( size(PREPRO_OPS.C_cam) == size(img_out) ) || ...
       all( size(PREPRO_OPS.C_cam) == 1 ) ) )
  
  img_out = img_out./PREPRO_OPS.C_cam;
  
end

if PREPRO_OPS.badpixfix
  
  badpix_file = fullfile(['ccd',num2str(obs.camnr)],'badpix.dat');
  % Haer skulle man kunna testa med inpaint_nans
  if exist(badpix_file,'file')
    
    load(badpix_file)
    bp_tbl = badpix;
    bpm = sparse(ceil(bp_tbl(:,2)/(1024/size(img_out,1))), ... 
                 ceil(bp_tbl(:,1)/(1024/size(img_out,2))), ...
                 ones(size(bp_tbl(:,1))), ...
                 size(img_out,1),size(img_out,2));
    bpm = spones(bpm);
    img_out = bad_pixel_fix(img_out,bpm);
    
    % here everything after clear is interpreted as a string and thus
    % cam*badpix is a regexp...
    clear bpm badpix bp_tbl
  end
end

if ~isempty(PREPRO_OPS.imreg)
  
  imregion = PREPRO_OPS.imreg;
  img_out = img_out(imregion(3):imregion(4),imregion(1):imregion(2));
  
end


if PREPRO_OPS.interference_level < inf

  if PREPRO_OPS.quadfix
    img_out(1:end/2,1:end/2) = interference_rem_auto(img_out(1:end/2,1:end/2),...
                                                      PREPRO_OPS.interference_level,...
                                                      PREPRO_OPS.interference_method,...
                                                      PREPRO_OPS.interference_swf);
    img_out(1:end/2,end/2+1:end) = interference_rem_auto(img_out(1:end/2,end/2+1:end),...
                                                      PREPRO_OPS.interference_level,...
                                                      PREPRO_OPS.interference_method,...
                                                      PREPRO_OPS.interference_swf);
    img_out(end/2+1:end,1:end/2) = interference_rem_auto(img_out(end/2+1:end,1:end/2),...
                                                      PREPRO_OPS.interference_level,...
                                                      PREPRO_OPS.interference_method,...
                                                      PREPRO_OPS.interference_swf);
    img_out(end/2+1:end,end/2+1:end) = interference_rem_auto(img_out(end/2+1:end,end/2+1:end),...
                                                      PREPRO_OPS.interference_level,...
                                                      PREPRO_OPS.interference_method,...
                                                      PREPRO_OPS.interference_swf);
  else
    img_out = interference_rem_auto(img_out,...
                                      PREPRO_OPS.interference_level,...
                                      PREPRO_OPS.interference_method,...
                                      PREPRO_OPS.interference_swf);
  end
end

if ~isreal(PREPRO_OPS.medianfilter)
  gsOPS = gen_susan;
end
for ii = 1:length(PREPRO_OPS.medianfilter(:))
  
  if ~isreal(PREPRO_OPS.medianfilter(ii)) % If complex use gen_susan filter
    
    gW = real(PREPRO_OPS.medianfilter(ii));
    gsOPS.tau = abs(imag(PREPRO_OPS.medianfilter(ii)));
    if gW < 0
      gsOPS.include_center = 1;
    else
      gsOPS.include_center = 0;
    end
    x = -(ceil(min(abs(gW)+1,3))):(ceil(min(abs(gW)+1,3)));
    [x,y] = meshgrid(x,x);
    fK = exp(-(x.^2+y.^2)/gW^2);
    fK = fK/sum(fK(:));
    img_out = gen_susan(img_out,fK,gsOPS);
    
  elseif ( PREPRO_OPS.medianfilter(ii) > 0 ) % Else if > 0 use medfilt2
    
    mfk = PREPRO_OPS.medianfilter(ii);
    
    %2-D median filtering
    if exist('medfilt2','file')
      %Use symmetric edge processing if available
      try
        img_out = medfilt2(img_out,[mfk mfk],'symmetric');
      catch
        img_out = medfilt2(img_out,[mfk mfk]);
      end
    else
      %Fall back on repeated 1-D filtering
      img_out = medfilt1(medfilt1(img_out',mfk)',mfk);
      
    end
    % sloppy fix to bug in matlab 5.1
    for i = 1:floor(mfk/2),
      for j = 1:floor(mfk/2),
        img_out(i,j) = img_out(ceil(mfk/2),ceil(mfk/2));
        img_out(end+1-i,j) = img_out(end+1-ceil(mfk/2),ceil(mfk/2));
        img_out(i,end+1-j) = img_out(ceil(mfk/2),end+1-ceil(mfk/2));
        img_out(end+1-i,end+1-j) = img_out(end+1-ceil(mfk/2),end+1-ceil(mfk/2));
      end
    end
  elseif ( PREPRO_OPS.medianfilter(ii) < 0 ) % Otherwise use wiener2
    mfk = PREPRO_OPS.medianfilter(ii);
    if exist ('wiener2','file')
      img_out = wiener2(img_out,[-mfk -mfk]);
    end
  end
end

if ~isempty(PREPRO_OPS.psf)
  
  img_out = invfilter_reg2(img_out,PREPRO_OPS.psf/sum(PREPRO_OPS.psf(:)));
  
end % 


if obs.camnr == 6
  
  if isfield(PREPRO_OPS,'defaultccd6') && PREPRO_OPS.defaultccd6
    imgsize = size(img_out);
    
    img_out(1:imgsize(1)/2,1:imgsize(2)/2) = img_out(1:imgsize(1)/2,1:imgsize(2)/2)/1.08;
    if ( imgsize(1) == 256 )
      img_out(:,128:129) = img_out(:,128:129)*2;
    elseif ( imgsize(1) == 128 )
      img_out(:,64:65) = img_out(:,64:65)*4/3;
    end
    if ( PREPRO_OPS.quadfix )
      
      img_out = quad_extrafix(img_out);
      
    end
    
  end % if isfield(PREPRO_OPS,'defaultccd6'
  
end % if obs.camnr == 6

if ( isfield(PREPRO_OPS,'ffc') && ...
     ~isempty(PREPRO_OPS.ffc) && ...
     ~all(PREPRO_OPS.ffc(:)==0) )
  
  if all( size(PREPRO_OPS.ffc) == size(img_out) )
    
    img_out = img_out./PREPRO_OPS.ffc;
    
  elseif ( isfield(obs,'optpar') || isfield(PREPRO_OPS,'optpar') )
    
    if isfield(PREPRO_OPS,'optpar') && ~isempty(PREPRO_OPS.optpar)
      optpar = PREPRO_OPS.optpar;
    else
      optpar = obs.optpar;
    end
    if ~isempty(optpar)
      if ( obs.camnr>0 && ...
           ( ( length(ff) < obs.camnr || isempty(ff{obs.camnr}) ) || ...
             (~all(size(ff{obs.camnr})==size(img_out)) ) || ...
             ( length(optp) < obs.camnr || isempty(optp{obs.camnr}) ) || ...
             ( ~isempty(optp{obs.camnr}) && ~isequal(optp{obs.camnr},optpar) ) ) )
        if isstruct(optpar)
          ff{obs.camnr} = ffs_correction2(size(img_out),optpar,optpar.mod);
        else
          ff{obs.camnr} = ffs_correction2(size(img_out),optpar,optpar(9));
        end
        optp{obs.camnr} = optpar;
      end
      img_out = img_out./ff{obs.camnr};
    end
  end
end

if ( ~isempty(PREPRO_OPS.outimgsize) && ...
     ~ all(PREPRO_OPS.outimgsize) == 0 && ...
     ~ all(PREPRO_OPS.outimgsize==size(img_out)) )
  
  fix_it_slowly = 1;
  outimgsize = [1 1].*PREPRO_OPS.outimgsize; % make sure outimgsize
                                             % is 1x2
% $$$   if ( size(img_out,1) == size(img_out,2) && ...
% $$$        outimgsize(1) == outimgsize(2) )
    
  fix_it_slowly = 0;
  resize_ratio = size(img_out) ./ outimgsize;
  if abs(diff(resize_ratio))/mean(resize_ratio) > 0.1
    disp('WARNING, theresizing will change the aspect ratio of')
    WarnStr = sprintf('the image from [%d %d], %f to [%d %d], %f',...
                      size(img_out),size(img_out,1)/size(img_out,2),...
                      outimgsize,outimgsize(1)/outimgsize(2));
    disp(WarnStr)
  end
  switch resize_ratio(1)
   case 1
    % do nothing already right size
   case 2
    img_out = img_out(1:2:end,:) + img_out(2:2:end,:);
   case 4
    img_out = ( img_out(1:4:end,:) + img_out(2:4:end,:) + ...
                img_out(3:4:end,:) + img_out(4:4:end,:) );
   case 8
    img_out = ( img_out(1:8:end,:) + img_out(2:8:end,:) + ...
                img_out(3:8:end,:) + img_out(4:8:end,:) + ...
                img_out(5:8:end,:) + img_out(6:8:end,:) + ...
                img_out(7:8:end,:) + img_out(8:8:end,:) );
   case 16
    img_out = ( img_out(1:8:end,:) + img_out(2:8:end,:) + ...
                img_out(3:8:end,:) + img_out(4:8:end,:) + ...
                img_out(5:8:end,:) + img_out(6:8:end,:) + ...
                img_out(7:8:end,:) + img_out(8:8:end,:) );
    img_out = img_out(1:2:end,:) + img_out(2:2:end,:);
   otherwise
    fix_it_slowly = 1;
  end
  switch resize_ratio(2)
   case 1
    % do nothing already right size
   case 2
    img_out = img_out(:,1:2:end) + img_out(:,2:2:end);
   case 4
    img_out = ( img_out(:,1:4:end) + img_out(:,2:4:end) + ...
                img_out(:,3:4:end) + img_out(:,4:4:end) );
   case 8
    img_out = ( img_out(:,1:8:end) + img_out(:,2:8:end) + ...
                img_out(:,3:8:end) + img_out(:,4:8:end) + ...
                img_out(:,5:8:end) + img_out(:,6:8:end) + ...
                img_out(:,7:8:end) + img_out(:,8:8:end) );
   case 16
    img_out = ( img_out(:,1:8:end) + img_out(:,2:8:end) + ...
                img_out(:,3:8:end) + img_out(:,4:8:end) + ...
                img_out(:,5:8:end) + img_out(:,6:8:end) + ...
                img_out(:,7:8:end) + img_out(:,8:8:end) );
    img_out = img_out(:,1:2:end) + img_out(:,2:2:end);
   otherwise
    fix_it_slowly = 1;
  end
  % end
  if fix_it_slowly
    if ( all(size(img_out)./PREPRO_OPS.outimgsize >= 1 ) && ...
         all(rem(size(img_out)./PREPRO_OPS.outimgsize,1)==0) ) 
      fun = @(x) sum(x(:)); % fun = inline('sum(x(:))');
      img_out = blkproc(img_out,size(img_out)./PREPRO_OPS.outimgsize, ...
                        fun);
    elseif ~all(rem(size(img_out)./PREPRO_OPS.outimgsize,1)==0)
      out_size = PREPRO_OPS.outimgsize.*[1 1];
      img_out = interp2(img_out,...
                        linspace(1,size(img_out,2),out_size(2)),...
                        linspace(1,size(img_out,1),out_size(1))','linear')*...
                prod(size(img_out)./PREPRO_OPS.outimgsize);
    else
      out_size = PREPRO_OPS.outimgsize.*[1 1];
      img_out = interp2(img_out,...
                        linspace(1,size(img_out,2),out_size(2)),...
                        linspace(1,size(img_out,1),out_size(1))','nearest')*...
                prod(size(img_out)./PREPRO_OPS.outimgsize);
    end
  end
end
if ( PREPRO_OPS.hist_crop )
  
  [b,x] = hist(img_out(:),100);
  pc = cumsum(b)/numel(img_out);
  I = find( ( PREPRO_OPS.hist_crop < pc ) & ( pc < ( 1 - PREPRO_OPS.hist_crop )) );
  if ~isempty(I)
    img_out = max(img_out,x(max(1,I(1)-1)));
    img_out = min(img_out,x(min(I(end)+1,length(x))));
  else
    try
      qu = (unique(img_out));
      int_lim = qu(round(length(qu)*(PREPRO_OPS.hist_crop*[1 -1] + [0 1])));
      img_out = max(min(img_out,int_lim(2)),int_lim(1));
    catch
      
      img_out = img_out;
      
    end
  end
end

if ( PREPRO_OPS.img_histeq )
  
  try
    img_out = img_histeq(img_out,PREPRO_OPS.img_histeq);
  catch
    cmax = max(img_out(:));
    cmin = min(img_out(:));
    img_out = max(img_out,cmin+.01*(cmax-cmin));
    img_out = min(img_out,cmax-.01*(cmax-cmin));
  end
end

