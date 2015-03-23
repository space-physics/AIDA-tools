function [img_E0,img_fO] = imgs_spec_ratio2E0fO(img4278,img6300,img8446,img4278b)
% imgs_spec_ratio2E0fO - estimate characteristic e^- energy and depletion of O
% By the method of Strickland, Hecht, Christensen and Meyer [] from
% images at 4278, 6300 and 8446 A.
%
% Calling:
% [img_E0,img_fO] = imgs_spec_ratio2E0fO(img4278,img6300,img8446,img4278b)
%
% Output parameters:
%   IMG_E0 - image of characteristic electron energy
%   IMG_FO - image of scaling factor of atomic Oxygen (an O not 2-1-1)
% 
% Input parameters:
% IMG4278 - image at 4278 A, corrected and calibrated in Rayleighs
% IMG6300 - image at 6300 A, corrected and calibrated in Rayleighs
% IMG8446 - image at 8446 A, corrected and calibrated in Rayleighs
% optional:
% IMG4278b - second image at 4278 A, corrected and calibrated in
%            Rayleighs for interpolation in time sequence
%
% See also:  Strickland, D. J., R. R. Meier, J. H. Hecht, and
%            A. B. Christensen, Deducing composition and incident
%            electron spectra from ground-based auroral optical
%            measurements: theory and model results,
%            J. Geophys. Res.,  94, 13527-13539, 1989. or 
% @Article{hecht1999jgr,
%  author =	 "Hecht, J. H. and Christensen, A. B. and Strickland,
%                  D. J. and Majeed, T. and Gattinger, R. L. and
%                  Vallance Jones, A.",
%  title =	 "A comparison between auroral particle
%                  characteristics and atmospheric composition inferred
%                  from analysing optical emission measurements alone
%                  and in combination with incoherent scatter radar
%                  measurements",
%  journal =	 jgr,
%  year =	 1999,
%  volume =	 104,
%  number =	 "A1",
%  pages =	 "33-44",
%  month =	 "January"
%}

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


fO = [.1 .25 .5 1];
E0 = [.1 .3 .6 1 3 6];

E0_2d = E0'*ones(1,4);
fO_2d = fO'*ones(1,6);

Y6300 = [1200 1950 3100 5200;...
         500   800 1400 2400;...
	 260   400  700 1100;...
	 150   220  350  600;...
	  32    50   80  150;...
	  13    20   32  58];

Y4278 = [230 198 170 120;...
         243 230 205 170;...
	 250 240 220 193;...
	 250 245 230 208;...
	 250 248 245 235;...
	 250 250 248 245];

Y8446 = [245 570 1000 1600;...
         150 350  600 1100;...
	 100 240  430  780;...
	  80 170  310  580;...
	  48  87  150  270;...
	  40  62  100  170];

irb = Y8446./Y4278;
rb = Y6300./Y4278;

if nargin == 4
  r_b = img6300./(.5*img4278+.5*img4278b);
  ir_b = img8446./(.75*img4278+.25*img4278b);
else
  r_b = img6300./(img4278);
  ir_b = img8446./(img4278);
end

img_E0 = exp(griddata(log(rb),log(irb),log(E0_2d),log(r_b),log(ir_b)));
if nargout > 1
  img_fO = exp(griddata(log(rb),log(irb),log(fO_2d'),log(r_b),log(ir_b)));
end
