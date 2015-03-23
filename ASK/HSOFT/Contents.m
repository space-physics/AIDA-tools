% ASK-HSOFT toolbox HSOFT
% Version (0.98) (2011-08-04) Copyright B Gustavsson
% Tools for reading and analysing ASK-images and ASK-like image
% data.
%
% ASK-data analysis functions:
% 
%  ASK_READ_V        - read one image
%  ASK_KEOGRAMS      - make keograms from an ASK image sequence
%  ASK_FANOGRAMS     - make keograms of a fan-beam-cut from an ASK image sequence
%  ASK_OVERLAY       - overlay three images to RGB composite
%  ASK_ADD_INT_RADAR - get image intenisity inside radar beam.
%  ASK_LINE_INT      - make intensity line plots from an image sequence.
%  ASK_IMCALIBRATE   - scale the images to Rayleighs
%
%  ASK_OVERLAY     - procedure to combine 3 ASK images to RGB-image
%  ASK_BINNING     - post-bin data
%  ASK_ADD_MULTI   - addmultiple frames
%  ASK_ADD_UP      - alpha-trimmed temporal average of data block
%  ASK_AUTO_RANGE  - returns an array of automatic range 
%  ASK_BYTSCL      - clip-n-scale matrix into [0-MAXOUT] from min(max_IN,max(min_IN,M_in))
%  ASK_IMAGE_C     - reinterpolate image nearest neighbour style.
%  ASK_ROUNDMASK   - "circular" mask with ones in image sized [sy,sx]
%  ASK_SLICE2TRMTR - projection matrix from blobs in slice || B to ASK-image
%
% ASK-plotting functions:
%
%  ASK_KEOGRAM_OVERLAYED - to plot an overlayed keogram, ASK-style
%  ASK_IMAGE_SEQUENCE    - to display an ASK image sequence as movie
%  ASK_IMAGE_PLAY        - Convert image-stacks to matlab movie
%  ASK_PLOT_LINE         - make a line plot with time axis
% 
%  ASK_DRAW_FOV       - draw one cameras field-of-view in another cameras f-o-v
%  ASK_DRAW_NORTH     - draws the north direction on an image, from the centre.
%  ASK_DRAW_RADAR     - plot the radar beam onto an image. 
%  ASK_PLOT_FIELDLINE - plot magnetic field-line projection onto an image.
%  ASK_GET_RADAR      - get image coordinates of the radar beam.
%  ASK_GET_FIELDLINE  - get magnetic field-line projection onto an image.
%  ASK_tvin           - display an image
%  ASK_PLAY_KEOLINES  - 
%  ASK_SPH_DIST       -  Calculating angle between two points on a sphere. 
% 
% ASK_overviewmaker - Create mega-block overlayed-keogram for overviews
% ASK_megablockviewer - Utility callback function for zooming around
% 
% ASK-setup and meta-data handling functions:
%
%  ASK_READ_VS       - procedure to read event setup files
%  ASK_V_SELECT      - set current camera index for event
%  ASK_V_SUMMARY     - print summary of event setup
% 
%  ASK_GET_ASK_CAL   - get absolute intensity calibration factors 
%  ASK_FIND_CNV      - get cnv camera parameters for a specific time
%  ASK_GET_CNV       - get the cnv from the vs common block
%  ASK_CURRENT_IMCAL - get the dark and flat from the common block
%  ASK_BIAS          - returns the bias drift during a observation megablock
%  ASK_READ_ASKLUT   - reads ASKLUT meta-data
%  ASK_READ_CNVLUT   - reads camera parameter lookup table
%  ASK_GET_DARK_NAME - get the name of the dark megablock corresponding to the
%  ASK_GET_IMCAL     - routine filling the imcal common block with
% 
%  ASK_ENABLE_DATADIR - short routine to automatically enable 
%  ASK_MAKE_ASKDARK   - Script that creates darks or flats.
%
% ASK-time handling function:
%
%  ASK_MJS_TT     - convert modified Julian second to calender date
%  ASK_TT_MJS     - converts calendar date to modified Julian second
%  ASK_time2MJS   - converts calendar date to modified Julian second
%  ASK_DAT2STR    - convert modified Julian second (mjs) to date string
%  ASK_MJS_DY     - convert modified Julian second (mjs) to decimal years
%
%  ASK_TIME2INDX    - returns the image index for a time-vector
%  ASK_INDX2DATEVEC - Convert a frame index into a [yyyy,mm,dd,HH,MM,SS.FFF]
%  ASK_LOCATE_INT   - locate time intervals
%  ASK_NEAREST_INT  - finds the interval starting at t1 closest to mjs1
%  ASK_TIME_V       - returns time since the start of the sequence
%  ASK_READ_SST     - read start and stop times from a string 
%
%  ASK_PRINT_DAT  - prints the date corresponding to a modified
%  ASK_TIME_AXIS  - get suitable settings for time tick marks and labels.
%  ASK_TIME_TICK - suitable settings for time tick marks and labels.
