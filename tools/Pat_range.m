function [pr]=Pat_range(Energy,pad)

E1=Energy/1000;
if pad == 1,
  pr=2.16e-06*E1.^1.67.*(1.+9.48e-02*E1.^(-1.57));
else
  pr=1.64e-06*E1.^1.67.*(1.+9.48e-02*E1.^(-1.57));
end
