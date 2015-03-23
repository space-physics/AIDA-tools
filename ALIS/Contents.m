% ALIS - ALIS/multi-station imaging related tools
% Version (ALIS beta-1) (20100420)
% Path ->  AIDA_tools/ALIS
%   
% ALIS_AUTO_OVERVIEW - automated fits data to png image conversion 
% ALIS_IMAGE_SEQUENCE - to display an ALIS image sequence as movie
% ALISSTDPOS_VISVOL - Display ALIS f-o-v ontop of topographic map 
% AIDA_CALIBRATED_VISIBLEVOL - Calculates the field of view from an ALIS   \  |  /
% AIDA_VISIBLEVOL - Calculates the field of view from an ALIS   \  |  /
% ALIScalTS - ALIS Camera calibration factors 
% ALIS_EVENT_READER - parse event-list for automatic data-processing
% ALIS_FILTER_FIX - convert ALIS filter to emission wavelength (A)
%
%  ALIS_FIND_DATA - search for ALIS data from station STN at DATE
%  ALIS_FIND_DATA2 - search for ALIS data from station STN at DATE
%  ALIS_FIND_DATA2b - search for ALIS data from station STN at DATE
%  SSI_FE_FROM_4278N6300 - Single Station Inversion Fe(E) from 4278 and 6300
% 
% Alis overview-data-base functions
% 
%  ALIS_OVERVIEW_DEMO - Example showing the use of ALIS_OVERVIEW
%  ALIS_OVERVIEW - Overviews of alis data, movie or image-mosaics
%  ALIS_OVERVIEW_KEOS4WEB - image ALIS overview keograms
%  ALIS_OVERVIEWMOVIE - Makes movies of images in files
%  ALIS_OVERVIEWPLOT - graphics of the visible volumes and collour
%  ALIS_AUTO_OVERVIEW - function for displaying overview data
%  ALIS_AVOK_EXPORTVARS - export overview variables to matlab workspace
%  ALIS_IMG_OVERVIEW - make ALIS data overview-plots by scanning OVERVIEW-files and INDEX-files
%  ALIS_VIEW_OVERVIEW_KEOS - view ALIS overview keograms
%  ALIS_IMGS2KEOS - make overview-keograms
%  ALIS_MK_DB_KEOS - Update ALIS Keogram-database
%  ALIS_MK_DB_KEOS - Update ALIS Keogram-database
%  ALIS_UPDATE_OVERVIEW_WEB - update the ALIS overview web-keograms
%  ALIS_VIEW_OVERVIEW_KEOS - view ALIS overview keograms
%  ALIS_ZOOM_OR_AUTO_OVERVIEW - GUI-fcn for ALIS keogram overviewing
%  AVOK_CREATE - create alis-view-overview-keograms user interface
%  AVOK_MAKIN_MOVIES - Makes movies of images from a night
%  AVOK_UPDATE_MOVIE_MENUE - update the view-movie-menue
% 
% Alis data handling functions 
% 
%  ALIS_EVENT_READER - parse event-list for automatic data-processing
%  ALIS_FIND_DATA - search for ALIS data from station STN at DATE
%  ALIS_FIND_DATA2 - search for ALIS data from station STN at DATE
%  ALIS_FIND_DATA2b - search for ALIS data from station STN at DATE
%  SSI_FE_FROM_4278N6300 - Single Station Inversion Fe(E) from 4278 and 6300
%  ALIS_IMGS_MOVIE_R     - make matlab movie M from a series of image files.
%  ALIS_IMGS_MOVIE_RGB   - make matlab movie M from a series of image files.
%  ALIS_EMI2CLRS         - convert ALIS emission  to rgb colour
%  ALIS_FILTER_FIX       - convert ALIS filter to emission wavelength (A)
%  ALIS_IMG2RGB          - convert intensity image to rgb image
%
% Alis field of view functions
% 
%  AIDA_VISIBLEVOL - Calculates and plot a field of view from one station
%  ALIS_PRE_POS_VV_PLOT - plots ALIS predefined observation rotations
%  POS4INDEX20051024_NORTH - ALIS fields-of-view for position: INDEX-rocket
%  POS4INDEX20051029 - ALIS fields-of-view for position: INDEX-rocket
%  stdposCORE_200506 - ALIS fields-of-view for position: CORE
% These below here are most likely not working
%  stdposEISCAT_200506 - ALIS fields-of-view for position: EISCAT
%  stdposEISCAT2_200506 - ALIS fields-of-view for position: EISCAT2
%  stdposEISCAT_comparison - Compare ALIS-positions EISCAT and EISCAT2
%  stdposEW_2006 - ALIS fields-of-view for position: EW
%  stdposMZ_2006 - ALIS fields-of-view for position: MZ
%  stdposNORTH_2006 - ALIS fields-of-view for position: NORTH
%  stdposSOUTH_2006 - ALIS fields-of-view for position: SOUTH
%  stdposSURV_2006 - ALIS fields-of-view for position: SURV
%
% ALIS gopta program producer
% 
%  TO_GOPTA - Produce ALIS gopta files (experiment control files)
% 
% Copyright B Gustavsson 20100320, GNU copyleft applies
