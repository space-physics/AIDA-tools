function Ccam=camcalTS(camno,wl,bin,exptime)
%Ccam=camcalTS(camno,wl,bin,exptime)
%   
%Camera calibration factors calculated by Tima Sergienko
%camno=camera number [1:6] as in stns(stationno).obs.camnr
%wl 1=4278 2=5577 3=6300    
%bin 1=1x1, 4=2x2, 16=4x4
%exp=exposure (s) 
%
% CFE 20101028
    
    
%prepare array, 3 wavelengths, 3 binnings, 6 cameras
calib=zeros(3,3,6);
    
%TS calibration factors
%Cameras 1 and 2: preliminary calibration, same for all binninga
%Cameras 3-6: two sources at 5577 and 6300 (using mean for now),
%one source at 4278    


%4278, binnings 1,4,16
calib(1,1,:)=[50.01 36.81 27.97 31.21 38.08 21.60];
calib(1,2,:)=[50.01 36.81 27.84 31.25 38.08 21.58];
calib(1,3,:)=[50.01 36.81 27.67 31.12 38.18 21.78];

%5577, binnings 1,4,16
calib(2,1,:)=[24.46 23.13 mean([13.40 14.58]) mean([15.56 16.37]) mean([19.74 21.09]) mean([14.64 14.92])];
calib(2,2,:)=[24.46 23.13 mean([13.78 14.53]) mean([15.62 16.36]) mean([19.84 21.11]) mean([14.64 14.91])];
calib(2,3,:)=[24.46 23.13 mean([13.72 14.46]) mean([15.62 16.33]) mean([19.82 21.11]) mean([14.88 15.10])];

%6300, binnings 1,4,16
calib(3,1,:)=[26.98 21.29 mean([14.85 14.79]) mean([16.53 16.44]) mean([15.63 15.72]) mean([11.16 11.05])];
calib(3,2,:)=[26.98 21.29 mean([14.72 14.69]) mean([16.57 16.47]) mean([15.63 15.75]) mean([11.14 11.05])];
calib(3,3,:)=[26.98 21.29 mean([14.65 14.62]) mean([16.59 16.48]) mean([15.65 15.75]) mean([11.34 11.18])];

%Calibration factor (Rs/counts) for given binning
switch bin
  case 1,
    cft=calib(wl,1,camno);
    
  case 4,
    cft=calib(wl,2,camno)/4;
    
  case 16,
    cft=calib(wl,3,camno)/16;
    
  otherwise
    error('Wrong binning: use 1,4,16')
    
end

%Sensitivity factor (counts/R)
Ccam=exptime/cft;

%%% EOF