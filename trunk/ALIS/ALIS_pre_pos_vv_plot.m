function hndl = ALIS_pre_pos_vv_plot(configNR)
% ALIS_pre_pos_vv_plot - plot the visible volume of ALIS
%  pre-defined camera rotations. 
%
% Calling:
%   hndl = ALIS_pre_pos_vv_plot(configNR)
% Input:
%   configNR - ALIS configuration number for pre-defined:
%               1 - Surveilance
%               2 - Magnetic zenith
%               3 - South
%               4 - Core
%               5 - EAST-West
%               6 - North
%               7 - EISCAT
%               8 - Heating
%               9 - EISCAT-2
% Output:
%   hndl - handle to the lines of the plotted visible-volume
%   borders 


%   Copyright © 20121203 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


ops = ALISstdpos_visvol;
ops.clrs = {[0 0 1],...
            [0,1,0],...
            [1,0,0],...
            0.7*[1 1 0],...
            0.7*[1 0 1],...
            1*[1 1 0],...
            0.5*[1,0.5,0],...
            0.5*[0.5,0,1],...
            0.5*[0,1,0.5],...
            0.5*[0.5,1,0],...
            0.5*[1,0,0.5],...
            0.5*[0,0.5,1]};

stnNrs = 1:6;
alt = 110*ones(size(stnNrs));
fov = 60*ones(size(stnNrs));

switch configNR
 case 1
  az = [225,100, 45,115, 30,270];
  ze = [ 20, 14, 12, 15, 14, 20];
 case 2
  az = 180*ones(size(stnNrs));
  ze =  12*ones(size(stnNrs));
 case 3
  az = [180,250,215,260,148,135];
  ze = [ 30, 23, 28,  7, 31, 23];
 case 4
  az = [ 0,298,249,346,130,90];
  ze = [ 0, 24, 28, 20, 24,20];
 case 5
  az = [ 0, 0, 0, 0, 0, 0];
  ze = [39,15,32,42,35,15];
 case 6
  % STN 1    2   3   4   5   6
  %     K    M   S   T   A   N
  az = [0, 330,311,355, 85, 44];
  ze = [30, 33, 25, 33, 22, 26];
  % K: set s north 0,30
  % S: set s north 311,25
  % T: set s north 355,33
  % A: set s north 85,22
 case 7
  stnNrs = [  7,  2,  3,  4,  5, 6,   11];
  az     = [  0,348,350,  0, 20, 15, 183];
  ze     = [ 39, 42, 32, 42, 35, 42,  12];
  fov    = [ 60, 60, 60, 60, 60  60   ,1];
  alt = 110*ones(size(stnNrs));
 case 8
  stnNrs = [  7,  2,  3,  4,  5,  6,   11];
  az     = [346,340,330,345,  5,  5,  183];
  ze     = [ 37, 40, 37, 44, 25, 40,   12];
  fov    = [ 60, 60, 60, 60, 60  60   ,1];
  alt = 200*ones(size(stnNrs));
 case 9
  stnNrs = [ 7,   3,  4,  5, 10, 11];
  az     = [ 0, 340,  0, 20,180,183];
  ze     = [39,  40, 45, 35,  0, 12];
  fov    = [60,  60, 60, 60, 60,  1];
  alt = 110*ones(size(stnNrs));
 case 10
  stnNrs = [ 7,   3,  4,  5,  10,  11,  11,  11,  11, 11];
  az     = [-10, 330, -5, 20, 180, 183, 183, 183, 183,   0]; 
  ze     = [ 35,  40, 42, 30,   0,  12,  20,  28,  36,   0];
  fov    = [ 60,  60, 60, 60, 150,   2,   2,   2,   2, 160];
  alt = 110*ones(size(stnNrs));
  % K: set s EISCATsouth 350,35
  % S: set s EISCATsouth 330,40
  % T: set s EISCATsouth 355,42
  % A: set s EISCATsouth  20,30
 case 11
  stnNrs = [ 7,   3,  4,  5,  10,  11,  11,  11,  11, 11];
  az     = [-10, 330, -5, 20, 180, 183, 183, 183, 183,   0]; 
  ze     = [ 35,  40, 42, 30,   0,  12,  20,  28,  36,   0];
  fov    = [ 60,  60, 60, 60, 150,   2,   2,   2,   2, 160];
  alt = 240*ones(size(stnNrs));

 otherwise
end

hndl = ALISstdpos_visvol(stnNrs,az,ze,alt,fov,ops);

switch configNR
 case 1
  axis([-230 250 -150 375 -10 120])
  title('surveilance')
 case 2
  axis([-230 250 -150 275 -10 120])
  title('mag\_zen')    
 case 3
  axis([-230 250 -150 275 -10 120])
  title('south')
 case 4
  title('core')
  %axis([-200 200 -125 275 -10 120])
  axis( [-230 250 -150 275 -10 120])
 case 5
  axis([-230 250 -150 375 -10 120])
  title('east-west')
 case 6
  axis([-230 250 -125 275 -10 120])
  title('north')
 case 7
  axis([-230 250 -125 375 -10 120])
  title('eiscat')
 case 8
  axis([-230 250 -125 375 -10 220])
  title('Heating')
 case 9
  axis([-230 250 -125 375 -10 120])
  title('eiscat-2')
 case 10
  axis([-250 350 -100 450])
  title('eiscat-south 110 km')
 case 11
  axis([-250 350 -100 450])
  title('eiscat-south 240 km')
 otherwise
end
