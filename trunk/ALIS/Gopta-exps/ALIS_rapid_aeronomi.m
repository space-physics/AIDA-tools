%%% Stations in operation
sn =            {'bus','kiruna','optlab','abisko'};

%%% With the following cameras
mima_nr     =   [ 6        3       4        5      2       1];
% And their corresponding gain-tables
% Behoever fixas...
GTlittlenoise = {'2,1'    '2,1'    '2,1'    '2,0'  '2,0'  '1,2'};
GTlownoise =    {'3,2'    '3,2'    '3,2'    '3,1'  '3,1'  '2,3'};

%%% Start and stop times (Start just a default providing
%%% syncronisation) 
Startstop = {'17:30:00'    '17:30:00'    '17:30:00'    '17:30:00'
             '21:20:00'    '21:20:00'    '21:20:00'    '21:20:00'};

%%% Basic interval time (s)
interv = [3    5     3     3
          3    4     5     5
          5    5     3     3
          4    3     5     5
          5    3     4     4];


%%% Filter sequences, Main focus is on 4278, and 4226 might just be
%%% usefull...
filter4 = {'5577'   '4278'   '6300'     '5577' 
           '6300'   '8446'   '4278'     '4278'
           '4278'   '4278'   '5577'     '5577'
           '8446'   '5577'   '4278'     '4278'
           '4278'   '6300'   '8446'     '5577'};

%%% Length of the filter cycles
c_l4 = [5 5 5 5];

%%% Exposure times (ms)
exptimes = [500   2700   500  500
            500   1800  2700  500
            2700  2700   500  500
            1800   500  2700  500
            2700   500  1800  500];


%%% OPTIONS:
OPS4.binning = '8,8';
OPS4.object= 'rapid-aeronomi';
OPS4.observer= 'ALIS-standing-tall';

%%% Create the gopta-scripts
OK = to_gopta('sync-rapid-aeronomi',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','0,0','0,0','core'},...
              exptimes,interv,...
              GTlownoise,OPS4);
