% Creates ALIS experiment set up for EISCAT Heating campaign
% 20041MDD

%%% Stations in operation
sn =            {'bus','kiruna','optlab','abisko','silkimuotka','tjautjas'};

%%% With the following cameras
mima_nr     =   [ 6        3       4        5      2       1];
% And their corresponding gain-tables
% Behoever fixas...
GTlittlenoise = {'2,1'    '2,1'    '2,1'    '2,0'  '2,0'  '1,2'};
GTlownoise =    {'3,2'    '3,2'    '3,2'    '3,1'  '3,1'  '2,3'};

%%% Start and stop times (Start just a default providing
%%% syncronisation) 
Startstop = {'17:30:00'    '17:30:00'    '17:30:00'   '17:30:00'    '17:30:00'    '17:30:00'
             '21:20:00'    '21:20:00'    '21:20:00'   '21:20:00'    '21:20:00'    '21:20:00'};

%%% Basic interval time (s)
interv = [6    6     6     6     6     6
          6    6     6     6     6     6];


%%% Filter sequences, Main focus is on 4278, and 4226 might just be
%%% usefull...
filter4 = {'6300'   '6300'   '5577'   '6300'   '6300'   '6300' 
           '5577'   '6300'   '5577'   '5577'   '5577'   '5577'};

%%% Length of the filter cycles
c_l4 = [2 2 2 2 2 2];

%%% Exposure times (ms)
exptimes = [3700   3700 3700  3700 3700 3700
            3700   3700 3700  3700 3700 3700];


%%% OPTIONS:
OPS4.binning = '4,4';%8x8...
OPS4.object= 'heatin-200503';
OPS4.observer= 'ALIS-standing-tall';

%%% Create the gopta-scripts
OK = to_gopta('Heating2005n-1700',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating','heating','heating'},...
              exptimes-2000,interv,...
              GTlownoise,OPS4);
OK = to_gopta('Heating2005n-2700',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating','heating','heating'},...
              exptimes-1000,interv,...
              GTlownoise,OPS4);
OK = to_gopta('Heating2005n',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating'},...
              exptimes,interv,...
              GTlownoise,OPS4);

OK = to_gopta('Heating2005l-1700',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating'},...
              exptimes-2000,interv,...
              GTlittlenoise,OPS4);
OK = to_gopta('Heating2005l-2700',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating'},...
              exptimes-1000,interv,...
              GTlittlenoise,OPS4);
OK = to_gopta('Heating2005l',...
              sn,Startstop,...
              c_l4,filter4,...
              {'','heating','heating','heating'},...
              exptimes,interv,...
              GTlittlenoise,OPS4);
