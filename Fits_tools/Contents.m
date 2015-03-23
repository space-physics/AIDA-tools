% Fits_tools - functions for reading fits and other image formats
% Version (1.6) (20120711)
% Path -> AIDA_tools/Fits_tools
%
% FITS_TOOLS contains functions for reading fits, sbig and AFRL
% and other scientific format data/image files, and parsing for
% meta-data about the image from headers. Further some 
% pre-processing/correction functions is 
% included.
%   
% 
%Raw fits handling functions
% 
% FITS1                  - reads fits files stored in LE
% FITS2                  - reads fits files stored in BE
% FITS_FRAMES            - reads fits files, data frames 3-D data-blocks
% WFITS                  - function to write 2-D fits files.
% ISFITS - Determine if file in FILENAME is in fits format.
% FITS_HEADER            - reads the first fits-file header
% FITS_HEADER2INFOSTRUCT - parse fits header, make struct of meta-data
% FITSFINDINHEADER       - finds string S in fitsheader H
% FITSFINDKEY            - Searches a FITS header V for keyword S
% FITSFINDKEY_STRMHEAD   - Searches a FITS header H for keyword S
% ADDHEADER              - function to add header entry to fits header.
% CHNGHEADER             - function to change header entry in fits header.
%
%Readers for other file formats
%
% SBIG             - reads files in SBIG image format, 
% READ_ARL_KEO     - reads Airforce research labs (Todd Pedersen's) KEO image format
% READ_ARL_RAW     - reads Airforce research labs (Todd Pedersen's) raw image format
% READ_ASKIMGS     - AIDA_TOOLS' ASK-image-reading function wrapper
% READ_miracle     - reads MIRACLE ASC jpg or png images
% READ_MIRACLE_ASC - reads MIRACLE ASC jpg or png images
% READ_PGIASC      - read PGI All Sky Images.
% READ_PIKERAW     - read pike raw 2-byte images
% read_pric_jpg    - reads PRIC jpg images
% READ_TORSTEN_RAW - read Torsten Inge I Aslaksen's raw 2-byte images
% IMWRAPPER        - simple wrapping function for image reading 
% 
%Next level utilities
% 
% INIMG                - reads and pre-process an image.
% READ_IMG             - reads image data and process header info.
% IMWRAPPER            - simple wrapping function for image reading 
% PRE_PROC_IMG         - systematic image correction and preprocessing of
% TYPICAL_PRE_PROC_OPS - Typical ALIS-fits preprocessing options
% LANCS_PRE_PROC_OPS   - Typical ALIS-fits preprocessing options
%
% (ALIS) header parsing and meta-data retrieval:
%
% TRY_TO_BE_SMART        - parses an (ALIS) fits header for observation info
% FITS_HEADER2INFOSTRUCT - parse fits header, make struct of needed
% AIDAstationize         - calculate station lat-long, xyz positions and rotation matrices 
% AIDApositionize        - calculate station lat-long and xyz positions 
% STATION_READER         - collects station number, name, long, lat  
% TIME_FROM_HEADER       - parses a ALIS header for time
% FIND_OPTPAR            - search the optpar data-base for best OPTPAR
% FIND_OPTPAR2           - search the optpar data-base for best OPTPAR
% ACC2OPTPAR             - Convert ACC-formated optical parameters to standart optpar
% PARSE_PNG_TIME         - parse miracle png time
% 
%Atomic pre-processing functions
%   
% QUADFIX3          - quadrant balancing of from overscan-strips 
% QUAD_EXTRAFIX     - extra balancing of quadrants
% REMOVERSCANSTRIP  - removes overscan-strips from raw CCD data
% REPLACE_BORDER    - replaces the outermost border
% BIAS_CORRECTION   - Corrects zero level bias from ALIS ccd images
% BAD_PIXEL_FIX     - simple badpixel korrection function works on
% REMOVE_SOME_STARS - Remove bright stars from images,
% REM_VERT_INTERFERENCE - Notch filter to remove vertical
% VERT_INTERFERENCE_PATTERN - Isolates vertical interferens from images.
% FIX_CCDCAM6       - example of how to fix the "interesting" placement of
% INTERFERENCE_RED  - Interference reduction
% INTERFERENCE_REM  - manual interference identification (and reduction)
% INTERFERENCE_REM_AUTO - automatic high frequency interference reduction
% INTERFERENCE_REM_MAN - manual interference identification (and reduction)
%
% Misc. fcns
% 
% SIFREAD           - Support for Andor SIF multi-channel image file.
% KOSCH2FITS        - Transform Kosch's images to fits format.
% KOSCH_DOUBLE2FITS - Transform Kosch's double-format images to fits format.
% KOSCH_FLOAT2FITS  - Transform Kosch's float-format images to fits format.
% 
% Copyright 20120711 B Gustavsson, P Rydesater, GNU Copyleft applies
