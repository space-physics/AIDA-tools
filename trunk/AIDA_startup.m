% This is the only customization needed.
% Set this path to where the AIDA_tools reside:
AIDA_root = fullfile('/home','bgu001');
% For those that work under non-unix OSes I think that you would
% have to modify the '/home' part above - but I have no such
% experience, so I cant help out.


%%% These are just to set the display format to something more
%%% compact, remove the comment to apply. 
% format short g
%format compact

%%% Just make matlab stop complaining about everything and the rest
%%% that can go wrong. Before the next release this should be
%%% possible to remove.
warning off

% This global variable is most likely obsolete - but since global
% variables are a bad programming practice just because they spread
% like weeds I havent dared to completely weed it out.
global stardir


% Determine which matlab version that is running
M_v = ver('matlab');
M_ver = floor(str2num(M_v.Version));

AIDA_matlabdir = fullfile(AIDA_root,'AIDA_tools');
path(path,AIDA_matlabdir)

% Local functions and overrides go in MyAIDA
path(path,fullfile(AIDA_matlabdir,'MyAIDA'))

% hide away some data files that you still want to have on your
% search path
% Directories for station locations:
path(path,fullfile(AIDA_matlabdir,'.data','Stations'))
% Directory for storing optical calibrations in:
path(path,fullfile(AIDA_matlabdir,'.data','OpticalParameters'))
% Directory for storing geographic and topographic data:
path(path,fullfile(AIDA_matlabdir,'.data','Geography'))
% And one directory for each ALIS camera, containing bad-pixel-maps
% bias images, and prnu-correction matrices
path(path,fullfile(AIDA_matlabdir,'.data','ccd1'))
path(path,fullfile(AIDA_matlabdir,'.data','ccd2'))
path(path,fullfile(AIDA_matlabdir,'.data','ccd3'))
path(path,fullfile(AIDA_matlabdir,'.data','ccd4'))
path(path,fullfile(AIDA_matlabdir,'.data','ccd5'))
path(path,fullfile(AIDA_matlabdir,'.data','ccd6'))
path(path,fullfile(AIDA_matlabdir,'.data'))

%% Auroral Image Data Analysis tools.
%
% 1 Camera related tools
path(path,fullfile(AIDA_matlabdir,'Camera'))
% 2 Funcitons related to Fits images, and image correction functions 
path(path,fullfile(AIDA_matlabdir,'Fits_tools'))
path(path,fullfile(AIDA_matlabdir,'Fits_tools','File2obs'))
% 3, WGS-84 Geoid
path(path,fullfile(AIDA_matlabdir,'EARTH'))
% 4, some trivial geometric functions
path(path,fullfile(AIDA_matlabdir,'Geometry'))
% 5, Functions related to some 3-D distributions
path(path,fullfile(AIDA_matlabdir,'I3D'))
% 6, Star calibration program
path(path,fullfile(AIDA_matlabdir,'Starcal'))
path(path,fullfile(AIDA_matlabdir,'Starcal','update'))
path(path,fullfile(AIDA_matlabdir,'Starcal','IOfcns'))
% Its version dependent functions, currently M 6.xx and M 7.xx
path(path,fullfile(AIDA_matlabdir,'Starcal',['M',num2str(M_ver)]))
% 7, The Skymap star ephemeris
path(path,fullfile(AIDA_matlabdir,'Skymap'))
% 8, ALIS related functions
path(path,fullfile(AIDA_matlabdir,'ALIS'))
% 9, some SVD-based invers problem solving functions
path(path,fullfile(AIDA_matlabdir,'Inversion'))
% 10, Some image processing functions
path(path,fullfile(AIDA_matlabdir,'Imgtools'))
% 11, The tomography toolbox
path(path,fullfile(AIDA_matlabdir,'Tomography'))
% 12, assorted other tools - not necessary by B. Gustavsson
path(path,fullfile(AIDA_matlabdir,'tools'))
% 14, Absolute Spectral Star calibration program
path(path,fullfile(AIDA_matlabdir,'Spectral_cal'))
% Its version dependent functions, currently M 6.xx and M 7.xx
path(path,fullfile(AIDA_matlabdir,'Spectral_cal',['M',num2str(M_ver)]))
% 8, Auroral-specific functions
path(path,fullfile(AIDA_matlabdir,'Aurora'))

% Add the ASK-related functions. These are straightly translated
% from the ASK related hsoft idl procedures/functions/programs, but
% should be included here as well:
path(path,fullfile(AIDA_matlabdir,'ASK','HSOFT'))
path(path,fullfile(AIDA_matlabdir,'ASK','IC'))





% clean upp some stuff
clear AIDA_matlabdir MY_matlabdir
