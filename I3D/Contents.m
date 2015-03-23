% I3D - functions for distributions of volume emission
% ver (1.5) (20100320)
% Path ->  AIDA_tools/I3D
%   
% I3D - functions for distributions of volume emission
% parametrized with multiple generalised Gaussians, and some
% functions for analyzing cuts, slices and moments of such
% distributions 
%   
% I3D
%
% 3-D intensity and excitation functions:
%
% I3d_p_dI3D          - Integration of continuity equation with sources
% I3d_p_dI3D2         - Integration of continuity equation with sources
% dI3D_multiple       - multiple 3-D generalized Gaussians
% dI3D_multiple_ARIEL - multiple 3-D generalized Gaussians
% V_em_3d             - calculate volume emission rates by C-EQ integration
%
% Statistics, slices, cuts, and moments
%
% V_em_ex_alt     - altitude, time variation of emission and excitation,
% V_em_ex_alt2    - time variation of altitude distribution of emission and excitation
% V_em_ex_alt_mag - altitude distribution of emission and
% V_em_ex_horavg - horisontal averages of altitude-time variation
% V_em_ex_intrp - total emission, excitation, widths of excitation
% V_em_save_intrp - save volume distribution emission and
%
% Unfinished: img_moments
%
% Saving functions
% 
% V_em_save_intrp - save volume distribution emission and
% THREE_D_SAVE    - save 3-D arrays as ascii file
% TREDSAVE        - function to save 3D matlab arrays in ascii files.
%
% Copyright B Gustavsson 20100320, GNU copyleft applies
