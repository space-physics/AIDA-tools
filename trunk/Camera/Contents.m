% Camera - triangulation, projection and mapping functions
% Version (1.6) (20120711) Copyright B Gustavsson
% Path -> AIDA_tools/Camera
% 
% Camera contains projection, mapping, corrections, and
% triangulation functions - all rerlated to or based on the optical
% characteristics of the camera.
% 
% Basic camera functions:
%   
% CAMERA_MODEL    - determine the image coordinates of light from [az,ze]
% CAMERA_INVMODEL - line-of-sight azimuthal and polar angles FI TAETA
% CAMERA_ROT      - determines the coordinate system of the camera 
% CAMERA_BASE     - determine the coordinate system of the camera 
% CAMERA_MIM_TEST - test that camera_model and camera_invmodel inverse-pair
% 
% Next level camera related functions.
% 
% PROJECT_DIRECTIONS - calculates the image positions [UA,WA] from (AZ,ZE) 
% PROJECT_POINT      - project a point in space R down onto an image
% PROJECT_LLH2IMG    - project a point in space LONGLATALT down onto an image
%
% Multi-view-point and similiar image functions
%
% INV_PROJECT_IMG        - maps an image IMG_IN to a plane.
% INV_PROJ_IMG_LATLONG   - calculate pixel-by-pixel Long-Lat coordinate for IMG_IN 
% INV_PROJ_IMG_LL2       - calculate pixel-by-pixel Long-Lat coordinate for IMG_IN 
% INV_PROJECT_IMG_SURF   - map IMG_IN - onto an arbitrary surface
% INV_PROJ_IMG_LL        - map IMG_IN to a latitude-longitude grid LAT, LONG
% INV_PROJECT_POINTS     - maps points (PX,PY) in image IMG_IN to a plane
% INV_PROJECT_DIRECTIONS - pixels line-of-sight azimuth and zenith angles
% INV_PROJECT_LineOfSightVectors - pixels coordinates to line-of-sight vectors
% TRIANGULATE            - stereoscopic triangulation from a pair of images
% AUTO_P_TRIANG          - triangulation of 3D positions of imaged objects
% AUTO_QUICKTRIANG       - Automatic triangulation of structured surfaces
% AUTO_TRIANGULATE       - Automatic stareoscopic triangulation
%
% Camera related image correction functions
%
% FFS_CORRECTION     - flat-field variation for optical transfer
% FFS_CORRECTION2    - flat-field variation for optical transfer
% FFS_CORRECTION_RAW - flat-field variation for optical transfer
% DOHMEGA            - calculate the solid angle spanned by a pixel.
% DOHMEGA1           - calculate the solid angle spanned by a pixel.
% DOHMEGA2           - calculate the solid angle spanned by a pixel.
% 
% ASK related functions in this directory
%
% ASK_camera_model     - the camera model for the ASK instrument.
% ASK_camera_invmodel  - the inverse camera model for the ASK instrument.
% ASK_CONV_CART2SPHERE - conversion used in ASK_camera_[inv]model
%
% Assorted functions:
% 
% DETERMINE_FOV     - determine field-of-view of optics
% INTERF_FILT_SHAPE - calculate pass-band of interference filter
% OLDROTS2NEWERROTS - Transformation between 2 set of rotation angles 
% STEREOSCOPIC      - calculate the shortest intersection between 2 lines.
