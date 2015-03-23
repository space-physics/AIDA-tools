function theAxis = mysubplot(nrows, ncols, thisPlot)
%MYSUBPLOT Create axes in tiled positions.
%   MYSUBPLOT(m,n,p), or MySUBPLOT(mnp), breaks the Figure window into
%   an m-by-n matrix of small axes, selects the p-th axes for 
%   for the current plot, and returns the axis handle.  The axes 
%   are counted along the top row of the Figure window, then the
%   second row, etc.  For example,
% 
%       MYSUBPLOT(2,1,1), PLOT(income)
%       MYSUBPLOT(2,1,2), PLOT(outgo)
% 
%   plots income on the top half of the window and outgo on the
%   bottom half.
% 
%   MYSUBPLOT(m,n,p), if the axis already exists, makes it current.
%   MYSUBPLOT(H), where H is an axis handle, is another way of making
%   an axis current for subsequent plotting commands.
%
%   MYSUBPLOT('position',[left bottom width height]) creates an
%   axis at the specified position in normalized coordinates (in 
%   in the range from 0.0 to 1.0).
%
%   If a MYSUBPLOT specification causes a new axis to overlap an
%   existing axis, the existing axis is deleted.  For example,
%   the statement MySUBPLOT(1,1,1) deletes all existing smaller
%   axes in the Figure window and creates a new full-figure axis.
%
%   MYSUBPLOT makes the subplots thighter with smaller gap inbetween.

% we will kill all overlapping siblings if we encounter the mnp
% specifier, else we won't bother to check:
narg = nargin;
kill_siblings = 0;
create_axis = 1;
delay_destroy = 0;
tol = sqrt(eps);
if narg ~= 3 % make compatible with 3.5, i.e. subplot == subplot(111)
  error('Wrong number of arguments')
end

%check for encoded format
handle = '';
position = '';

kill_siblings = 1;

% if we recovered an identifier earlier, use it:
if(~isempty(handle))
  
  set(get(0,'CurrentFigure'),'CurrentAxes',handle);
  
elseif(isempty(position))
  % if we haven't recovered position yet, generate it from mnp info:
  if (min(thisPlot) < 1)
    error('Illegal plot number.')
  else
    % This is the percent offset from the subplot grid of the plotbox.
    PERC_OFFSET_L = 0.07;
    PERC_OFFSET_R = 0.085;
    PERC_OFFSET_B = PERC_OFFSET_L;
    PERC_OFFSET_T = PERC_OFFSET_R;
    if nrows > 2
      PERC_OFFSET_T = 0.9*PERC_OFFSET_T;
      PERC_OFFSET_B = 0.9*PERC_OFFSET_B;
    end
    if ncols > 2
      PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
      PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
    end
    
    row = (nrows-1) -fix((thisPlot-1)/ncols);
    col = rem (thisPlot-1, ncols);

    % For this to work the default axes position must be in normalized coordinates
    if ~strcmp(get(gcf,'defaultaxesunits'),'normalized')
      warning('DefaultAxesUnits not normalized.')
      tmp = axes;
      set(axes,'units','normalized')
      def_pos = get(tmp,'position');
      delete(tmp)
    else
      def_pos = get(gcf,'DefaultAxesPosition')+[-.05 -.05 +.1 +.05];
    end
    col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...
	(ncols-PERC_OFFSET_L-PERC_OFFSET_R);
    row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...
	(nrows-PERC_OFFSET_B-PERC_OFFSET_T);
    totalwidth = def_pos(3) + col_offset;
    totalheight = def_pos(4) + row_offset;
    width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;
    height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;
    position = [def_pos(1)+min(col)*totalwidth/ncols ...
		def_pos(2)+min(row)*totalheight/nrows ...
		width height];
    if width <= 0.5*totalwidth/ncols
      position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);
      position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);
    end
    if height <= 0.5*totalheight/nrows
      position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);
      position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);
    end
  end
end

% kill overlapping siblings if mnp specifier was used:
nextstate = get(gcf,'nextplot');
if strncmp(nextstate,'replace',7), nextstate = 'add'; end
if(kill_siblings)
  if delay_destroy
    if nargout
      error('Function called with too many output arguments')
    else
      set(gcf,'NextPlot','replace'); return,
    end
  end
  sibs = get(gcf, 'Children');
  got_one = 0;
  for i = 1:length(sibs)
    if(strcmp(get(sibs(i),'Type'),'axes'))
      units = get(sibs(i),'Units');
      set(sibs(i),'Units','normalized')
      sibpos = get(sibs(i),'Position');
      set(sibs(i),'Units',units);
      intersect = 1;
      if(     (position(1) >= sibpos(1) + sibpos(3)-tol) || ...
	      (sibpos(1) >= position(1) + position(3)-tol) || ...
	      (position(2) >= sibpos(2) + sibpos(4)-tol) || ...
	      (sibpos(2) >= position(2) + position(4)-tol))
	intersect = 0;
      end
      if intersect
	if got_one || any(abs(sibpos - position) > tol)
	  delete(sibs(i));
	else
	  got_one = 1;
	  set(gcf,'CurrentAxes',sibs(i));
	  if strcmp(nextstate,'new')
	    create_axis = 1;
	  else
	    create_axis = 0;
	  end
	end
      end
    end
  end
  set(gcf,'NextPlot',nextstate);
end

% create the axis:
if create_axis
  if strcmp(nextstate,'new'), figure, end
  ax = axes('units','normal','Position', position);
  set(ax,'units',get(gcf,'defaultaxesunits'))
else 
  ax = gca; 
end


% return identifier, if requested:
if(nargout > 0)
  theAxis = ax;
end
