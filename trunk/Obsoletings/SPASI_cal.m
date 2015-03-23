% SPASI_cal - Example script - calibration of South-Pole ASI

%%% Make a structure of what typical image pre-processing options
%%% to use
PO = typical_pre_proc_ops;
PO.imreg = [90.262 422.22 101.11 428.83];
PO.quadfix = 0;
PO.quadfixsize = 0;
PO.replaceborder = 0;
PO.badpixfix = 0;
PO.outimgsize = 0;
PO.medianfilter = 0;
PO.defaultccd6 = 1;
PO.bias_correction = 0;

data_path = '/home/DATA/SP_ASI';


% Load optical parameters describing the optics
load S017_20030710000310.acc % This file is used for images that
                             % are croped to the above IMREG and is
                             % not useful for full images.
optpar = S017_20030710000310([7:14 6 15]);

load f5577_spasi.dat
load f6300_spasi.dat
load f4278_spasi.dat

%%% Make a structure of options for the star search
OPTS = spc_typical_ops;
% Reduce the brightness limit to speed up the processing
OPTS.Mag_limit = 3.5;%2.5;%4.5;


[C_spasi,N,Pars,Chi2s] = spec_ccd_cal(data_path,optpar,PO,longlat,OPTS);
