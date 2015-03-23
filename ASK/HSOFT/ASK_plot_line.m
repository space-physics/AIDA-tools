function ph = ASK_plot_line(mjs,time,data,mjsStart,time2end,titleStr,varargin)
% ASK_PLOT_LINE - make a line plot with time axis
% 
% Calling:
%  ph = ASK_plot_line(mjs,time,data,mjsStart,time2end,titleStr,varargin)
% inputs: 
%   mjs  - start time of the data sequence
%   time - time in seconds relative to the start time
%   data - 1D array of the data to plot
% optional (keywords):
%   mjsStart - start time of the plot
%   time2end - length of the plot in seconds
%   titleStr - title of the plot
%
% VARARGIN is passed to the plot function, and should consist of a
% cell array with matlab's property-value pairs, suitable for
% setting stuff by plot, such as 'linewidth', 'linestyle', 'color',
%
% SEE PLOT for details.

% Modified from plot_line.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


% TODO make use of time_axis function

ftSz = 14;

if nargin < 4 || isempty(mjsStart)
  mjsStart = mjs;
end
if nargin < 5 || isempty(time2end)
  time2end = max(time);
end

indx2plot = find(mjsStart-mjs<=time&time<=mjsStart+time2end);

ph = plot(time+mjs-mjsStart,data,varargin{:});
if nargin > 5 & ~isempty(titleStr)
  title(titleStr,'fontsize',ftSz)
end
ax1 = axis;
axis([0 time2end,ax1(3:4)])
timetick
