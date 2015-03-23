%tools - assorted tools that fits nowhere, or are from others.
% ver (1.7) (20121206)
%   
%   
% Plotting/graphics functions:
%  
%  IMAGEVIEWER          - Interactively preview, pan and zoom images on the computer.
%  TCOLOR               - truecolor version of pcolor
%  MPLAYER              - movie player (avi or matlab movie)
%  DRAW3D_VEM           - Use of the routine vol3d to plot ALIS formatted outputs in 3D
%  VOL3D                - Volume render 3-D data
%  VOL3DTOOL            - Tool to edit color/alpha channels when
%  CLINE                - plots a 3D curve (x,y,z) encoded with scalar color data (c)
%  ARROW                -  Draw a line with an arrowhead
%  ARROW3               - draw vector lines (2D/3D) from P1 to P2 with arrowhead,
%  COLORBAR_LABELED     - colorbar with label for range linear or log
%  HEATERONOFF          - plottin heater on periods 
%  freezeColors         -  Lock colors of an image to current colors
%  MYSUBPLOT            - Create axes in tiled positions
%  PLOTCUBE             - plot a cube/cuboid
%  UNPLOT               - Delete the most recently created graphics object(s)
%  ERRORBARXY           - graph y against x, with both x and y errorbars. 
%  PROGMETER            - displays the progress of completion of a task in the MATLAB
%  MTIT                 - creates a major title in a figure with many axes
%  TIMETICK             - change axis-labels to time/date format. Clever choice
%  SUBPLOT_DX_SQUEEZER  - Squeeze out space between subplot-axes
%  magnifyOnFigure      - interactive zooming in inset subaxes
%  
% Physcs related stuff
%  
%  ATM_ATTENUATION - Atmospheric attenuation
%  CHAPMAN         - gives the Chapman profile.
%  GET_B_EISCAT    - get geomagnteic fields for the EISACT sites.
%  IRIFILELOADER   - load and parse IRI data files
%  LunarAzEl       - get lunar Azimuth and Elevation angle at position and time
%  sun_posiiton    - get solar zenith and azimuth at local time and position. 
%  
% Data filtering and fixing
%  
%  BLACKMAN      - blackman window (of length L)
%  CORR_COEF_CMT - raw correlation between multidim V1 and V2
%  DETREND       - Remove a linear trend from a vector, usually for FFT processing
%  IMRESIZE      - binning/resizing of image.
%  INPAINT_NANS  - in-paints over nans in an array
%  GRIDFIT       - estimates a surface on a 2d grid, based on scattered data
%  TVDENOISE     - Total variation image denoising
%  MEDFILT2      - 2-dimensional sliding median filter
%  MAXFILT1      - one dimensional sliding max-filter
%  MAX2D         - maximum element and its indices in a 2-D array
%  FMINSEARCHBND - FMINSEARCH, but with bound constraints by transformation
%  
% Vector related functions
%  
%  ANGLE_ARRAYS - angle between arrays
%  RAND_DIRECTION - unit vectors pointing in random directions

% String tools
% 
%  IN_DEF2  - input, with default value
%  ISCHAR   - return true if STR is a char-array
%  MTIT     - creates a major title in a figure with many axes
%  NUM8STR  - numerical to string converter
%  STRIM    - strip the trailing and leading blanks of a string
%  TEXTABLE - writes a TeX formatted table to file
%  TIMETICK - change axis-labels to time/date format. Clever choice
%  
% File handling utilities
%  
%  BACKUP1000FILESVERSIONS - Backup files to prevent overwriting them
%  FIND_FP                 - is a function that locates a named file
%  GENFILENAME             - generates starcal formated filenames
%  
% Other functions
%
%  CATSTRUCT              - concatenate structures
%  FIND_IN_CELLSTR        - search for string in cellstrings
%  IN_RANGES              - True if T is in any of the T_RANGES intervalls
%  MAKE_DEPEND_FROM_INMEM - Extracts currently used functions with
%  MERGE_STRUCTS          - Merge all fields of S2 into S1
%  ISLEAP True for leap year.
%  unixtime2mat           - Converts unix time stamps (seconds since Jan 1, 1970) to
%  SUBDIR                 - Performs a recursive file search
%
