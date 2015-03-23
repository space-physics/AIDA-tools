function [gI1,gI2,gI3,gT,gX,gY,gFilter] = spc_cal_bad_intens(inI1,inI2,inI3,inT,inX,inY,inFilter,checkfilters,OPTS)
% SPC_CAL_BAD_INTENS - Select intensity limits for each star, and
% sort out the outliers. This is done manually, which is slightly
% time-consuming (== becommes tedious and boring)
% 
% Calling:
%  [GI1,GI2,GI3,GT,GX,GY,Gfilter] = spc_cal_bad_intens(inI1,inI2,inI3,inT,inX,inY,inFilter,checkfilters)
% Inputs:
%   inI1 - stellar intensity (counts) as produced by
%   inI2 - stellar intensity (counts) as produced by
%   inI3 - stellar intensity (counts) as produced by
%   inT  - Times for the corresponding INI[1-3]
%   inX  - Horisontal image coordinate of stars
%   inY  - Vertical image coordinate of stars
%   inFilter - Filter index for images
%   checkfilters - Filter to select for output
%
% Outputs:
%   GI1  - Cleaned up stellar intensity
%   GI2  - Cleaned up stellar intensity
%   GI3  - Cleaned up stellar intensity
%   GT   - Times for the corresponding GIn
%   GX   - Corresponding horisontal image coordinates
%   GY   - Corresponding vertical image coordinates
%   Gfilter - Corresponding filter indexes

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

clrs = ['g','r','m','c','k','b','c','m','c','c']';
if nargin>=9 & isfield(OPTS,'clrs')
  clrs = OPTS.clrs;
end
% Adapt for colours defined as char-array or rgb-array.
if ischar(clrs(1))
  clrsIDX = 1;
else
  clrsIDX = 1:3;
end

for si = 1:size(inI1,1),
  
  for iF = 1:length(checkfilters),
    
    if numel(inI1{si,iF})
      % If there are intensities for star with index "si" in filter
      % "iF" start with assigning:
      gI1{si,iF} = inI1{si,iF};
      gI2{si,iF} = inI2{si,iF};
      gI3{si,iF} = inI3{si,iF};
      gT{si,iF} =  inT{si,iF};
      gX{si,iF} =  inX{si,iF};
      gY{si,iF} =  inY{si,iF};
      gfilter{si,iF} = inFilter{si,iF};
      % Then plot the identied stars:
      ints_plot(inT{si,iF},inI1{si,iF},inI2{si,iF},inI3{si,iF},clrs(iF,clrsIDX));
      title([num2str(si),' ',num2str(si/size(inI1,1))])
      
      %xlabel('press any button...')
      % pause % Just cut this one out?
      
      title('If there is intensity outliers select the min and max intensity in','fontsize',14,'fontweight','bold')
      xlabel('...panel 1 with left mouse button, skip with middle or right.','fontsize',14,'fontweight','bold')
      ylabel(sprintf('Star nr %d out of %d, %4.2f',si,size(inI1,1),si/size(inI1,1)))
      subplot(2,1,1)
      [qwt,Ilim1,ButtonSelected] = ginput(1);
      
      if all(ButtonSelected==[1])
        [qwt,Ilim2] = ginput(1);
        % sort out point lying outside any of the limits.
        ii = find( min([Ilim1,Ilim2]) < inI1{si,iF} & inI1{si,iF} < max([Ilim1,Ilim2]) );
        gI1{si,iF} = inI1{si,iF}(ii);
        gI2{si,iF} = inI2{si,iF}(ii);
        gI3{si,iF} = inI3{si,iF}(ii);
        gT{si,iF} =  inT{si,iF}(ii);
        gX{si,iF} =  inX{si,iF}(ii);
        gY{si,iF} =  inY{si,iF}(ii);
        gFilter{si,iF} = inFilter{si,iF}(ii);
      end
      
    end
    
  end
  
end

%i = find(gX(:)==0);
%Gfilter(i) = -2;
% TODO: Figure out what this is supposed to achieve, and then fix it!
% Gfilter(gX(:)==0) = -2;


function ok = ints_plot(T,I1,I2,I3,clr)
% INTS_PLOT - 
%   

clf

if ~isempty (I1)
  subplot(2,1,2)
  plot(T,I2,'h','color',clr )
  grid on
  try
    timetick
  catch
  end
% $$$   subplot(3,1,3)
% $$$   plot(T,I3,'h','color',clr )
% $$$   grid on
% $$$     try
% $$$     timetick
% $$$   catch
% $$$   end

  subplot(2,1,1)
  plot(T,I1,'h','color',clr )
  grid on
  try
    timetick
  catch
  end
end
ok = 1;
