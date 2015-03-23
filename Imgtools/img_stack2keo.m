function [Keo] = img_stack2keo(Imstack,locnrs,line_not_columns,optp,PO)
% imgs_stack2keo - make keograms from stack of images
%   relative path) LOCNRS should be an Nx1 or 1xN array with line
%   numbers for the lines or columns to take from an
%   image. LINE_NOT_COLUMNS binary array with same size as LOCNRS
%   (1 for taking a line 0 for column at the corresponging
%   position) OPTP should be an array with OPTPAR, PO should be a
%   struct with PRE_PROC_OPS
% 
% Example
%   lines_or_column_nr = [21, 12, 123, ...,32];
%   lines_not_columns =  [ 1,  1,   0, ..., 1]; 
%   Keo = img_stack2keo(Imstack,locnrs,line_not_columns,optp,PO)
%  
% See also: INIMG, STARCAL, TYPICAL_PRE_PROC_OPS


%   Copyright © 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if numel(line_not_columns)==1
  line_not_columns = line_not_columns*ones(size(locnrs));
end

for i1 = size(files,1):-1:1,
  %disp(i1)
  [data1,head1,o] = inimg(files(i1,:),PO);
  if isempty(data1)
    % In case inimg returns an empty image just skip the rest and
    % try with the next image.
    continue
  end
  exptimes(i1) =  o.exptime;
  try
    optps(i1,:) = o.optpar;
  catch
    optps(i1,:) = nan;
  end
  %%%  Exposures shorter than 100 is assumed to be in s and
  %%%  converted to ms.
  if exptimes(i1)<100
    exptimes(i1) = 1000*exptimes(i1);
  end
  if ~isempty(o.time)
    Tstrs(i1,:) = o.time;
  else
    Tstrs(i1,:) = time_from_header(head1);
  end
  if ~isempty(o.filter)
    filters(i1) = o.filter;
  else
    hindx = fitsfindinheader(head1,'ALISEMI');
    if ~isempty(hindx)
      %filters(i1) = str2num(head1(hindx,12:30));
      filters(i1) = str2double(head1(hindx,12:30));
    else
      filters(i1) = 0;
    end
  end
  data1 = 1000*data1./ff/exptimes(i1);
  for j2 = 1:length(locnrs)
    
    if line_not_columns(j2) > 0
      
      utargs(i1,j2,:) = data1(locnrs(j2),:);
      
    else
      
      utargs(i1,j2,:) = data1(:,locnrs(j2));
      
    end
    
  end
  
end

for i1 = length(locnrs):-1:1,
  
  varargout(i1) = {squeeze(utargs(:,i1,:))};
  
end

if nargout>length(locnrs)
  
  varargout(length(locnrs)+1) = {exptimes};
  
end
if nargout>length(locnrs)+1
  
  varargout(length(locnrs)+2) = {Tstrs};
  
end
if nargout>length(locnrs)+2
  
  varargout(length(locnrs)+3) = {filters};
  
end
if nargout>length(locnrs)+3
  
  varargout(length(locnrs)+4) = {optps};
  
end
