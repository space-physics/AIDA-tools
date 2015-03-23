function [lam]=lambda(hi,Energy,pad)

logE_m=[1.69 1.8:0.1:3.7];
Param_m(1,:)=[1.43 1.51 1.58 1.62 1.51 1.54 1.18 1.02 0.85 0.69 0.52 0.35 0.21 0.104 0.065 0.05 0.04 0.03 0.03 0.025 0.021];
Param_m(2,:)=[0.83 0.77 0.72 0.67 0.63 0.59 0.56 0.525 0.495 0.465 0.44 0.42 0.40 0.386 0.37 0.36 0.35 0.34 0.335 0.325 0.32];
Param_m(3,:)=-[0.025 0.030 0.040 0.067 0.105 0.155 0.210 0.275 0.36 0.445 0.51 0.61 0.69 0.77 0.83 0.865 0.90 0.92 0.935 0.958 0.96];
Param_m(4,:)=[-1.67 -1.65 -1.62 -1.56 -1.46 -1.35 -1.20 -0.98 -0.70 -0.37 -0.063 0.39 0.62 0.92 1.11 1.25 1.36 1.44 1.50 1.55 1.56];

logE_i=[1.69 1.8:0.1:3.0];
Param_i(1,:)=[0.041 0.051 0.0615 0.071 0.081 0.09 0.099 0.1075 0.116 0.113 0.13 0.136 0.139 0.142];
Param_i(2,:)=[1.07 1.01 0.965 0.9 0.845 0.805 0.77 0.735 0.71 0.69 0.67 0.665 0.66 0.657];
Param_i(3,:)=-[0.064 0.1 0.132 0.171 0.2 0.221 0.238 0.252 0.261 0.267 0.271 0.274 0.276 0.277];
Param_i(4,:)=-[1.054 0.95 0.845 0.72 0.63 0.54 0.475 0.425 0.38 0.345 0.319 0.295 0.28 0.268];


if pad == 1,
  
  logE=log10(Energy);
  if Energy >= 5000,
    lam=(Param_m(1,end)*hi+Param_m(2,end)).*exp(Param_m(3,end).*hi.*hi+Param_m(4,end)*hi);
  else
    C1=interp1(logE_m,Param_m(1,:),logE);
    C2=interp1(logE_m,Param_m(2,:),logE);
    C3=interp1(logE_m,Param_m(3,:),logE);
    C4=interp1(logE_m,Param_m(4,:),logE);
    lam=(C1*hi+C2).*exp(C3.*hi.*hi+C4*hi);
  end
  
elseif pad == 2,
  
  logE=log10(Energy);
  if Energy >= 1000,
    lam=(Param_i(1,end)*hi+Param_i(2,end)).*exp(Param_i(3,end)*hi.*hi+Param_i(4,end)*hi);
  else
    C1=interp1(logE_i,Param_i(1,:),logE);
    C2=interp1(logE_i,Param_i(2,:),logE);
    C3=interp1(logE_i,Param_i(3,:),logE);
    C4=interp1(logE_i,Param_i(4,:),logE);
    lam=(C1*hi+C2).*exp(C3.*hi.*hi+C4*hi);
  end
  
end
