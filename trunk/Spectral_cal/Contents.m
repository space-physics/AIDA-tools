% SpectralCal - functions for absolute camera intensity calibration
% Version (1.2) (20121206)
% Path ->  AIDA_tools/Spectral_cal
% 
% The main programs
%  Spec_cal_jobb_2007  - Example of spectral camera sensitivity calibration
%  Spec_cal_jobb_exmpl - Example of spectral camera sensitivity calibration
%  Spec_cal_jobb_HAARP_RnG2007 - spectral camera sensitivity calibration for HAARP
%  Spec_cal_jobb_spasi - calibration of South-Pole ASI
%  SPASI_cal           - Example of calibration of South-Pole ASI
%  PIXEL2PIXEL         - p-2-p variation in photo responce non uniformity 
%   
% For setting the options
%  SPC_TYPICAL_OPS - Provides a struct with typical options
%
% The functions
%  SPC_SCAN_FOR_STARS        - Scan image files for stars with known spectras
%  SPC_SAVE_STARS            - save scanned star data for spec cal scripts
%  CHECK_SCAN_FOR_STARS      - Check the result of spc_scan_for_stars.
%  SPC_CHK_IF_BAD_TIMES      - Screen out bad time periods for each star
%  SPC_CAL_BAD_TIMES         - Screen out bad time periods for each star
%  SPC_SAVE_BAD_TIMES        - saves bad times for spectral calibration
%  SPC_SORT_OUT_THE_BAD_ONES - Remove stars that are "bad"
%  SPC_CAL_BAD_INTENS        - Select intensity limits for each star
%  SPC_SAVE_BAD_INTENS       - saves bad times for spectral calibration
%  SPC_MAKE_THETA            - Calculate the angle from the optical axis,
%  SPC_SENS_DISTR            - scatter plot camera sensitivity estimates.
%  SPC_SENS_HIST             - make histogram with parametrisation and uncertainty
%  SPC_SENS_PDF              - Estimate PDF of the sensitivity, from
%  SPC_SPECTRAL_INT_CONV     - convert Pulkovo intensity to #/cm^2/s/fw
%  SPC_SPECTRAL_INT_CONV2    - convert Pulkovo intensity to #/cm^2/s/fw
%  SPC_SPECTRAL_FILTER_INT_CONV - convert Pulkovo intensity to #/cm^2/s/fw
%
% Subfunctions
%   
%  ATM_ATT_EST - Estimate of the atmospheric absorption 
%  SPC_GOOD_XY - Get index to points in X,Y that are not scattered
%  STAR_INT_SEARCH identifies points in image with stars, make a parametrisation
%  STAR_INT_MODEL - Model and plot of star
%  CIRC_ERR - 
%
% Remains from too long ago.
% 
%  PLOT_ITF - plot the intensities of a star INTENS from a series of
%  PLOT_ITF - INTENSITY vs TIMES in colours CLRS
%
% Copyright © B Gustavsson 20100320
