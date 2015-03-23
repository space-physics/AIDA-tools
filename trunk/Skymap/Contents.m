% Skymap - a good accuracy star-chart/ephemeris program 
% Version (1.6) (20121206)
% Path ->  AIDA_tools/Skymap
%   
% Skymap
% Skymap - a good accuracy star-chart/ephemeris program 
% with Pulkovo spectrophotometric catalog interface. 
% 
% Main Interface:
% SKYMAP  - An easy to astronomical starchart.
% 
% User-usable functions:
% 
% GETSPEC       - high resolution stellar spectras at 350-1150 nm
% ABOVE_HORIZON - finds stars above the horizon at place and time,
% REFRCORR      - From true zenith angle to apparent zenith correcting
% DATE2JULDATE  - calculates the julian date at 0h UT
% UTC2LOSIDT    - calculates the local sidereal time.
% UTC2SIDT      - calculates the sidereal time.
% 
% SOLAR_POS - Get the sky position of the sun
% MOONPOS   - calculates lunar azimuth, zenith and apparent zenith angles
%
% STAROVERPLOT - plots the stars over an image.
% 
% Functions called from GUI:
%
% SKYHELP - Main GUI help function
% S_PREFERENCES - set preferences for starcal and skymap
% STARPLOT plots the skymap.
% FINDNEARESTSTARXY - is a function that find the star closes to sky-point (X0,Y0)
% FINDNEARESTSTAR   - is a function that find the star among PSTARS that
% DEF_S_PREFERENCES - default preferences for starcal
% GETSPEC - high resolution stellar spectras at 350-1150 nm
% SKMP_CLOSE - end the skymap session
% SKMP_DISP_POS_TIME - extracts position and time from SkMp
% 
% 
% Assorted functions of little user use:
% 
% ABROTA2 calculates the rotation matrix.
% CHECKOK - displays time and observation site GUI for user choise.
% FIX_RA_DECL - Extract rect ascension and declination from star
% INFOV2 finds stars inside a specified field of view
% LOADSTARS2 load stars from the: Bright Star Catalogue, 5th Revised
% NUTATION calculates the nutation 
% PLOTGRID - plots Azimuth-Zenith or Rect acsention-Declination grid. 
% PLOTTABLESTARS2 - Selects stars in INFOVSTARS brighter than MAGN
% POSCHOICE - short function that updates the GUI windows
% STARBESTAEMFT2 determines the possition of stars relative to axis
% STARPOS2 gives the azimuth, zenith and apparent zenith angles
% STARBAS calculates untit vectors of a rotated coordinate system.
%
% Copyright © B Gustavsson 20100320, GNU Copyleft applies
