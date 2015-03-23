function fp = ASK_v_summary(fp)
% ASK_V_SUMMARY - print summary of event setup
% 
% Calling:
%   ASK_v_summary(vs,fp)
% Input:
%   vs - vs struct, or something TBD
%   fp - file identifier. Optional, if function is called with only
%        vs output is directed to standard output (1)

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs

if nargin == 0 | fp < 1 
  fp = 1;
end

str = ASK_dat2str( vs.vmjs(vs.vsel) );

len = (vs.vnl(vs.vsel) - vs.vnf(vs.vsel)) * vs.vres(vs.vsel);

az    = vs.vcnv(vs.vsel,6)*180/pi;
el    = vs.vcnv(vs.vsel,7)*180/pi;
scale = vs.vcnv(vs.vsel,2)*1d-3*180/pi;


fprintf(fp, 'Summary of the event setup for event #%d\n',vs.vsel);
fprintf(fp, 'Directory name: %s\n', vs.vdir{vs.vsel})
fprintf(fp, '------------------------------------------------\n')
fprintf(fp, 'Camera name:        %s\n',vs.vcam{vs.vsel})
fprintf(fp, 'Location:           %f6.2, %f6.2\n',vs.vlat(vs.vsel),vs.vlon(vs.vsel))
fprintf(fp, 'Filter:             %s\n',vs.vftr{vs.vsel})
fprintf(fp, 'Image rate:         %f5.2 fps\n',(1/vs.vres(vs.vsel)))
fprintf(fp, 'Start time:         %s\n',str)
fprintf(fp, 'Length, s:          %f8.1\n',len)
fprintf(fp, 'First image number: %d\n', vs.vnf(vs.vsel))
fprintf(fp, 'Last image number:  %d\n', vs.vnl(vs.vsel))
fprintf(fp, 'Step in the sequence: %d\n', vs.vnstep(vs.vsel))
fprintf(fp, 'Image dimensions:  (%4d x %4d)\n',vs.dimx(vs.vsel),vs.dimy(vs.vsel))
fprintf(fp, '------------------------------------------------\n')
fprintf(fp, 'Image to celestial mapping\n')
fprintf(fp, 'Look direction:  azimuth %f6.1 east of north, elevation %f5.1\n',az,el)
fprintf(fp, 'Pixel scale:        %f7.5 deg/pixel\n',scale)
fprintf(fp, 'Rotation angle:     %f7.1 degrees\n',vs.vcnv(vs.vsel,5)*180/pi)
fprintf(fp, 'F.O.V.              (%f4.1 x %f4.1) degrees\n',scale*vs.dimx(vs.vsel),scale*vs.dimy(vs.vsel))
fprintf(fp, '------------------------------------------------\n')
fprintf(fp, 'Dark field used: %s\n',vs.vdrk{vs.vsel})
fprintf(fp, 'Flat field used: %s\n',vs.vflt{vs.vsel})
