% Imgtools - image plotting and analysis functions
% Version (1.7) (20121206)
% Path -> AIDA_tools/Imgtools
%
% Imgtools
% 
% 
% General image data analysis functions:
% 
% imgs_keograms        - make keograms from sequence of image files.
% imgs_keogram_r3      - make keogram of R3's projection in the image.
% imgs_movie_r         - produce a matlab movie M from a series of image files.
% imgs_regs_mmmm       - max, mean, median and min from regions in an image-serie
% imgstack_regs_mmmm   - max, mean, median and min from regions in an image-stack
% imgs_spec_ratio2E0fO - estimate characteristic e^- energy and depletion of O
% imgs_stereo          - Triangulate from 2 series of images
% img_optflow          - optical-flow displacements with intensity-scaling adjustment
% img_morphing         - Intensity and spatial morphing of image
% img_stack2fanogram   - make fan-keograms from  image stack.
% imgs_stack2keo       - make keograms from stack of images
% imgs2timeserieses    - make time-series for selected pixels
% 
% Special plots
% 
% IMG_OVERPLOT_LLH       - longitude-latitude-height points projected
% IMGS_PLOT              - Plot a row of images
% IMGS_PLOT_BG_RED       - Plot a row of images with background reduction
% IMGS_PLOT_BG_RED1L     - Plot a row of  background reduced images, one colorlabel
% IMGS_PLOT_BG_RED_CLALL - Plot a row of background reduced images with colorbars
% IMGS_SMART_CAXIS       - alpha-percentile setting of color-axis,
% 
% 2-D filtering functions
% 
% GEN_SUSAN         - Generalized SUSAN/bilateral filtering
% SYMNIN_FILTER     - Symmetric nearest intensity neighbour filter
% GENQT_STATFILT    - Filtering until regional residues are statisticaly acceptable
% IMG_WIENER2       - 2-D adaptive noise-removal filtering.
% IMG_SPLINEFILTER  - spline fitting filter optimum statistical filter
% IMG_SVDFILTER     - SVD fitting filter optimum statistical filter
% IMGS_DECONV_CRUDE - Deconvolution, amplitude cut-off method
% 
% Assorted other functions:
% 
% IMG_HISTEQ               - histogram equalisation. 
% IMG_REG_BG_RED           - removal of estimated background in image region
% IMG_ROT                  - rotate image around arbitrary point.
% IMGS_DEINTERLACE         - Deinterlace 2-field video-frames
% IMGS_EDGE_TAP            - Edge tapering, "extrapolating" version
% IMGS_INTERP_DATA_WRPT    - estimate image intensities at t0 from image-sequence
% IMGS_INTERP_WEIGHTS_WRPT - linear interpolation weights at T0
% MK_IMGKEOS_DB            - Make keogram data-base from images.
% errFcnAuroralFlow        - error function for auroral motion estimate
%
% Copyright © B Gustavsson 20120711, GNU copyleft applies
