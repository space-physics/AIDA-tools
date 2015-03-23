function [I_red,W] = imgs_TimeSeries_bg_red(I_ts,I_bg,idx4bg)
% IMGS_TIMESERIES_BG_RED - linear combination timeseries background reduction
%  from back-ground time-series. A typical application is
%  Heating-experiments during twighlight where region of interest
%  is spatially well confined and background intensities can be
%  taken from that region between HF-on periods and in surrounding
%  regions at all times, this makes it possible to take into
%  account the non-trivial variation in sky background intensities
%  by making a lsq weighted linear combination of the background
%  intensities.
%   
%  Consider a sequence of images like this (ASCII-art, _everybody_
%  loves ASCII-art!):
%
%  -------------------------
%  |     -----------       |
%  |     | bg-reg A|       |
%  | -------------------   |
%  | |bg |         |bg |   |
%  | |reg| region  |reg|   |
%  | |B  |   of    |C  |   |
%  | |   | interest|   |   |
%  | -------------------   |
%  |     | bg-reg D|       |
%  |     -----------       |
%  |                       |
%  -------------------------
% 
%  Intensities in a pixel in the region of interest I_i can be
%  approximated with a linear combination of the average
%  intensities in regions A-D:
%
%    I_iapprox = W_A*I_A + W_B*I_B + W_C*I_C + W_D*I_D
%
%  which we can put on matrix form:
%
%    I_iapprox = [I_A,I_B,I_C,I_D]*W_ABCD
%
%  for which we can use the powers of matlab to easily estimate the
%  weight array:
%
%    W_ABCD = [I_A(t_bg),I_B(t_bg),I_C(t_bg),I_D(t_bg)]\I_i(t_bg)
%
%  Where we have taken intensities (I_i, I_A,...) at times suitable
%  for background conditions (for example exposures close to the
%  end of HF-off periods). For other instances in time the
%  background contribution is then estimated as:
%
%   I_bg(t) = [I_A(t),I_B(t),I_C(t),I_D(t)]*W_ABCD
%
% Calling:
%   [I_red,W] = imgs_TimeSeries_bg_red(I_ts,I_bg,idx4bg)
% Input:
%   I_ts   - time-series with data of interest, double array [n_timesteps x N]
%   I_bg   - time-series with background data, double array
%            [n_timesteps x N_bgregs] or cell-array [1 x N_bgregs]
%            or  [N_bgregs x 1] with arrays  [n_timesteps x 1] in
%            each cell
%   idx4bg - 
% Output:
%   I_red - Intensities after background reduction double array
%           [n_timesteps x N] 
%   W     - least-square fitted weight vectors.
%   
% Example:
%   regs = {[xRegmin,xRegmax,yRegmin,yRegmax],...
%           [xbg1min,xbg1max,ybg1min,ybg1max],...
%           [xbg2min,xbg2max,ybg2min,ybg2max],...
%           [xbg3min,xbg3max,ybg3min,ybg3max],...
%           [xbg4min,xbg4max,ybg4min,ybg4max]};
%   files = dir('*.*');
%   PO = typical_pre_proc_ops;
%   [~,I_mean] = imgs_regs_mmmm(files,regs,[],PO);
%   idx4Bg = [12:48:523,11:48:523];
%   [I_red,W] = imgs_TimeSeries_bg_red(I_ts(I_mean(:,1)),I_mean(:,2:end),idx4Bg);

if iscell(I_bg)
  I_M = cell2mat(I_bg(:)');
end

W = I_M(idx4bg,:)\I_ts(idx4bg,:);

I_red = I_ts - I_M*W;
