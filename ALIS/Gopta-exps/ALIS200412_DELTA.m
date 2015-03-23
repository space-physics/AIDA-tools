%%% Set up creation program for supporting observations of the
%%% DELTA rocket campaign at Andoeya 20041205-15
%%% Top secret, no gnu, high proprietary copyright Bjorn Gustavsson
%%% 2004-12-08



%%% Stations in operation
sn =            {'bus' 'kiruna' 'abisko'};

%%% With the following cameras
mima_nr     =   [ 6        3        5       4      2];
% And their corresponding gain-tables
GTfast =        {'1,0'    '1,0'    '1,3'  '1,0'  '1,3'};
GTlittlenoise = {'2,1'    '2,1'    '2,0'  '2,1'  '2,0'};
GTlownoise =    {'3,2'    '3,2'    '3,1'  '3,2'  '3,1'};

%%% Start and stop times (Start just a default providing
%%% syncronisation) 
Startstop = {'18:00:00'    '18:00:00'    '18:00:00'
             '22:20:00'    '22:20:00'    '22:20:00'};
%#### CAUTION!!! Different launch windows on some days and
%slightly later towards the end of the campaign.

%%% Basic interval time (s)
interv = [ 10     10     10     10     10
           10     10     10     10     10
           10     10     10     10     10
           10     10     10     10     10];


%%% Filter sequences, Main focus is on 4278, and 4226 might just be
%%% usefull...
filter4 = { '4226'    '4278'     '4278' 
            '4278'    '5577'     '5577'
            '4226'    '4278'     '4278'
            '4278'    '8446'     '8446'};

%%% Exposure times (ms)
exptimes = [2000        3000  3000
            3000        1000  1000
            2000        3000  3000
            3000        2000  2000];


%%% OPTIONS:
OPS4.binning = '4,4';
OPS4.object= 'Delta B:B-b K,A: b-g-b-ir';
OPS4.observer= 'delta force ALIS';

%%% Length of the filter cycles
c_l4 = [4 4 4 4 4];


%%% Create the gopta-scripts
OK = to_gopta('delta1_5ln',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes-700,interv/2,GTlownoise,OPS4);
OK = to_gopta('delta1_5mn',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes-400,interv/2,GTlittlenoise,OPS4);
OK = to_gopta('delta1_5fast',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes-300,interv/2,GTfast,OPS4);
OK = to_gopta('delta1_10ln',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes,interv,GTlownoise,OPS4);
OK = to_gopta('delta1_10mn',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes,interv,GTlittlenoise,OPS4);
OK = to_gopta('delta1_10fast',sn,Startstop,c_l4,filter4,{'','332,38','335,36'},exptimes,interv,GTfast,OPS4);
