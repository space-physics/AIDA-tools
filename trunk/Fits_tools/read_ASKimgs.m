function [header,img_out] = read_ASKimgs(DummyFilename,PO)
% READ_ASKIMGS - AIDA_TOOLS' ASK-image-reading function wrapper
%   

if isfield(PO,'frame')
  frame = PO.frame;
else
  frame = 1;
end
header = [];
img_out = ASK_read_v(frame,[],[],[]);
