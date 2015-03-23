% STARCAL - functions to do geometric camera calibration
% ver (1.4) (20071129)
% Path ->  AIDA_tools/Starcal
% 
% STARCAL - functions to do geometric camera calibration
% by fitting imaged stars to catalog positions.
% 
% Main interface:
%
%  STARCAL - functions to do geometric camera calibration
% 
% Utilities:
%  STARCAL_CHECKER  - verify geometric calibration quality.
%  STARCAL_COMPARER - compare quality of geometric calibrations.
%  
% GUIs:
%
%  STARGUI  - sets up the GUI for starcal
%  ERRORGUI - Create the figure and GUI for the errorplots
% 
% GUI callbacks:
% 
%  AUTOMAT2             - total square of deviation between image and catalog position stars
%  AUTOMAT4             - give sum tanh(dr)^2 between the image and catalog position of star
%  DEF_S_PREFERENCES    - default preferences for starcal
%  REMOVE_MISIDENTIFIED - Removes misidentified stars from SkMp
%  REMOVE_NEARESTSTARXY - remove the star among PSTARS closest to X0, Y0
%  REVERT_OPTPAR        - revert optical parameters to initial guess
%  S_PREFERENCES        - set preferences for starcal and skymap
%  SAVEACC              - save optical parameters as ACC-file
%  SAVEAS_ACC           - function to save optical parameters
%  SKMP_CLOSE           - ending of the skymap session
%  STARERRORPLOT        - Plots the error of the starprojection.
%  STARHELP             - Main help function
%
% Subfunctions:
% 
%  BQUIVER            - temporary interface to the function ARROW() that is 
%  FIND_LOC_MAX_2D    - find a set of local maximas i a matrix
%  FIND_THE_STARS     - finds stars in images. 
%  FITAETA_2_ALFABETA - converts AZIMUTH & ZENITH rotations
%  GUESS_ALIS_OPTPAR  - sets up initial guess for the optics
%  SORT_BCKGR         - sorts the local image maxima in I(i,j)
%  SORT_OUT           - finds the possible stars among the local maxima. 
%  STAR_ENHANCER      - average background-removed images to enhance stars
%  STAR_MINUS_BG      - background reduction from star
%  STARDIFF           - total error of starfield fit.
%  STARDIFF2          - total error of starfield fit.
%  STARDIFF3          - total error of starfield fit.
%  STARDIFF4          - total error of starfield fit.
%  STARDIFF_AS        - total error of starfield fit.
%  STARDIFFG          - total error of starfield fit.
%  STARINT            - Star modeled as a 2D gaussian.
%  STARINT3           - Star modeled as a 2D gaussian.
%  STARPLOT2          - plots the skymap.
%  STARSINIMG         - finds stars inside the image field-of-view.
%  
% Other function:
%  
%  OPTPAROLD2OPTARPNEW - scale f_u and f_v between optical transfer functions
%  SAVEOPTIDENT  - saves preliminary optical parameters and identified stars
%  SAVEERRORDATA - saves error data
%  LOADERRORDATA - loads error data
%  LOADPARAM     - loads parameters for lens model tests and 
% 
% Very obsolete functions, will be removed in next release!
%  make_r_o_theta      - Function that determines the image coordinates of light from a
%
% Copyright B Gustavsson 20100320, GNU Copyleft applies


%  FINDNEARESTSTARXY      - find the star among PSTARS closest to X0, Y0
