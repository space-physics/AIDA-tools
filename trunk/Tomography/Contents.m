% Tomography
% Version (1.0) (20100320)
% Path ->  AIDA_tools/Tomography
% 
% Tomographic example scripts
% 
%  TOMO20080305NewBeginnings - script for tomographing ALIS
%                              20080305 event with GACT-like start
%                              guess 
% these below are depreciated with less good start guesses:
%  TOMO_SKELETON - Template/example script for auroral tomography,
%  TOMO20061212ARIEL2 - script for tomographing ALIS 20061212 event
%  TOMO20061212ARIEL3 - script for tomographing ALIS 20061212 event
%  TOMO_EXMPL970216   - Template/example script for auroral tomography,
%  TOMO20080305FinalIR_082011 - script for tomographing ALIS 20080305 event, 18:40 UT
%  HH_TOMO1234_NEW01  - script for tomographing 2007 HIPAS-observations
%  BA_RT_ERROR        - Black aurora inversion error function
% 
% Tomographic ``user-level'' functions 
% 
%  TOMO_INP_IMAGES - Preprocessing of images for tomography plus
%  MAKE_TOMO_OPS   - User interface to set some parameters for the
%  TOMO_STEPS      - tomographic itterative step(s).
%  ADJUST_LEVEL    - Scale 3D intensities to give projections that have
% 
% Start guess functions:
% 
%  tomo_start_guessGACT - start guess for 3-D distribution of volume emission rates
%  tomo_setup4reduced2D - Set up coordinates and projection matrices
%  tomo_err4sliceGACT   - error function for estimating electron spectra
%  trmtr3Dto1D          - make projection matrix from 3-D to 1-D image cuts
%  tomo_arcpeakfinderinslice - Finds peaks of emission along [U,V]
%  GACT_snippet
%
% Old start guess functions
% 
%  TOMO_ALT_VAR4STARTGUESS - altitude variation for Maxwellian
%  TOMO_START_GUESS - One Grroooovy start guess for auroral tomography!
%  TOMO_START_GUESS1 - One Grroooovy start guess for auroral
%  TOMO_START_GUESSN - One Grroooovy start guess for auroral tomography!
%  TOMO_START_GUESSN2 - Fancy start guess for auroral tomography!
%  TOMO_START_GUESS_ALTVAR1 - 3D start guess with varying alt and width
%  TOMO_START_GUESS_ALTVAR1DC - 3D start guess with varying alt and width
%  tomo_start_guess1deconvAltvarQD - One Grroooovy start guess for auroral
%  TOMO_START_GUESS_EPITRI - build Vem0 from triangulations in the epipolar planes
%
% Tomographic engine/atomic functions
%
%  TOMO_STEPS     - tomographic itterative step(s).
%  BACKPROJECTION - Function that projects the localized ratios
%  FASTPROJECTION - project the volume emission VEM down to image IMG_OUT.
% 
% Tomographic set-up functions:
% 
%  SC_POSITIONING - position voxels/base-functions in SC grid. 
%  SC_SIZING - calculates the approximate size in the image plane
%  SC_GROUPING - divides base functions into NR_LAYER groups
%  CAMERA_SET_UP_SC - Calculates the projection matrix from 3-D simple cubic grid 
%  BASE_FCN_KERNEL - gives 1-D footprints of 3-D base functions
%  FIX_SUBPLOTS_TOMO - determine useful subplot orientation
%  tomo_CalSensMat - calibration factors for FASTPROJECTION
% 
% Subfunctions:
% 
%  TOMO_ALTMAXISCALING - tomographic itterative step(s).
%  TOMO_3DFILTERING    - wrapper for filtering of 3-D block of blobbs
%  TOMO_PROX_FILT      - Proximity filtering along 3rd dimension
%  TOMO_PROX_SHARPEN   - Proximity sharpening filter,
%  TOMO_RESCALING      - rescale volume emission rate to correct l-o-s intensity
%  TOMO_RESCALINGHYUGE - rescale volume emission rate to correct l-o-s intensity
%  TOMO_CAL            - estimate calibration factor for fastprojection of 3D b-o-b
%  TOMO_CAL0           - estimate calibration factor for fastprojection of 3D b-o-b
%  TOMO_CAL1           - estimate calibration factor for fastprojection of 3D b-o-b
%  TOMO_RENORM_CHECK   - check calibration factor for fastprojection of 3D b-o-b
%  TOMO_SET_BLOCKOFBLOBS - setup function for b-o-b geometry parameters
%  TOMO_SLICE_I - slice with arbitrary X, Y, and Z,
%
% Functions related to more specialised volume emission estimations
%
% BA_RT_ERROR - Black aurora inversion error function
% 
% When life feels jolly rotten:
% 
%  helloWorld - a function to be guaranteedly completely bug-free!
% 
% Copyright B Gustavsson 20100320, 20121207
