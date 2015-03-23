function [GI1,GI2,GI3,GT,GX,GY,GFilter,BSC_NR,sortindx,uniqueFilters] = spc_sort_out_the_bad_ones(I_allt,all_t,all_filter,bad_times,sis,OPTS)
% SPC_SORT_OUT_THE_BAD_ONES  Remove stars that are "bad"
% that is either displaced in the image or from times marked as
% bad. Resort the identified image intensities, image filters and
% star positions, as well as the Bright Star Catalog number
% (BSC_NR) for each star
% 
% See also SPEC_CAL_BAD_TIMES, SPEC_CAL_BAD_INTENS
%
% Calling:
%  [GI1,GI2,GI3,...
%   GT, GX, GY,...
%   GFilter,BSC_NR,sortindx] = spc_sort_out_the_bad_ones(I_allt,all_t,all_filter,bad_times,sis)
% Input:
%  I_allt     - Array with star-intensities [N x 11], see
%               SPC_SCAN_FOR_STARS for details
%  all_t      - Array with times of observations
%  all_filter - array with filter identifiers
%  bad_times  - Array with time intervals to sort out, as returned
%               from SPC_CAL_BAD_TIMES
%  sis        - Array with star indices, as returned
%               from SPC_CAL_BAD_TIMES
% Output:
%  GI1      - Max intensity of star
%  GI2      - Total intensity of star
%  GI3      - Total intensity of fitting 2-D Gaussian
%  GT       - Time of observation
%  GX       - Horizontal image coorinate of 2D Gaussian centroid
%  GY       - Vertical image coorinate of 2D Gaussian centroid
%  GFilter  - Filter wavelength/number/identifier
%  BSC_NR   - Bright star catalog number of star.
%  sortindx - intensity sorted index of total star intensities
%             integrated over all filters 

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Brigth star catalog numbers for stars identified
BSC_NR = unique(I_allt(:,9));
% And the unique filter identifiers we have
%uniqueFilters = unique(I_allt(:,9));
uniqueFilters = unique(all_filter);
%for ii = 1:length(BSC_NR),

Imedian(max(sis)) = 0;

for ii = sis,
  % work with one star at a time
  I_this_star = I_allt(I_allt(:,9)==BSC_NR(ii),:);
  % the corresponding times
  times_t_star = all_t(I_this_star(:,1));
  
  % sort out the bad time periods for this star.
  good_t_i = [];
  for jj = 1:length(times_t_star),
    if isempty(bad_times{ii}) | ~( in_ranges(times_t_star(jj),bad_times{ii}) )
      good_t_i = [good_t_i jj];
    end
  end
  stats(ii,:) = [isempty(bad_times{ii}) size(good_t_i)];
  I_this_star = I_this_star(good_t_i,:);
  times_t_star = times_t_star(good_t_i);
  
  % search for star-fits that are far from the overal trajectory
  if isfield(OPTS,'starscatter')
    dx = OPTS.starscatter(1);
    dy = OPTS.starscatter(end);
  else
    dx = 4;
    dy = 4;
  end
  % Here we sort out the stars that are close enough [+/-dx,+/-dy]
  % of expected trajectory, this removes mis-identifications of the
  % current star
  jj = spec_cal_good_xy(times_t_star,I_this_star(:,2),I_this_star(:,3),dx,dy);
  I_this_star = I_this_star(jj,:);
  times_t_star = times_t_star(jj);
  %% Separate different filters here into cell array - 
  %  all components no longer need to have the same number of
  %  elements:
  %  GI1{ii,filterindx} =  I_this_star(filter==filterindx,5)';
  %
  StarFilters = all_filter(I_this_star(:,1));
  for iF = 1:length(uniqueFilters),
    
    indxCurrFilter = find(StarFilters == uniqueFilters(iF));
    GI1{ii,iF} = I_this_star(indxCurrFilter,5)';
    GI2{ii,iF} = I_this_star(indxCurrFilter,6)';
    GI3{ii,iF} = I_this_star(indxCurrFilter,7)';
    GX{ii,iF} = I_this_star(indxCurrFilter,2)';
    GY{ii,iF} = I_this_star(indxCurrFilter,3)';
    GT{ii,iF} = times_t_star(indxCurrFilter)';
    GFilter{ii,iF} = all_filter(I_this_star(indxCurrFilter,1));
    % calculate average star brightness.
    %Imedian(ii) = Imedian(ii) + median(GI1(ii,f0));
    Imedian(ii) = Imedian(ii) + median(GI1{ii,iF});
    
  end
  
end

% Sort the stars with brightest first...
[sorted_Im,sortindx] = sort(-Imedian);

GI1 = GI1(sortindx,:);
GI2 = GI2(sortindx,:);
GI3 = GI3(sortindx,:);
GT = GT(sortindx,:);
GX = GX(sortindx,:);
GY = GY(sortindx,:);
GFilter = GFilter(sortindx,:);
BSC_NR = BSC_NR(sortindx);
