% Script used to make gopta experiment configuration file for
% ALIS-EISCAT-Heating campaign 200411
% EISCAT_ALIS200411 - example script showing how to make gopta experiment configuration files

% Copyright Bjorn Gustavsson

sn =            {'bus' 'kiruna' 'abisko'};
GTfast =        {'1,0'    '1,0'    '1,3'  '1,0'  '1,3'};
GTlittlenoise = {'2,1'    '2,1'    '2,0'  '2,1'  '2,0'};
GTlownoise =    {'3,2'    '3,2'    '3,1'  '3,2'  '3,1'};
mima_nr     =   [ 6        3        5       4      2];

Startstop = {'15:00:00'    '15:00:00'    '15:00:00'
             '21:05:00'    '21:05:00'    '21:05:00'};

exptimes = [3000        3000  3000        3000        3000
            3000        3000  3000        3000        3000
            3000        3000  3000        3000        3000
            3000        3000  3000        3000        3000];

interv = [ 5     5     5     5     5
           5     5     5     5     5
           5     5     5     5     5
           5     5     5     5     5];

OPS1.binning = '4,4';
OPS1.object =  'heating A:r-b-r-g B:r-b K:r-g';
OPS1.observer =  'ALIS heating team';

c_l1 =     [   2         2         4    2       2 ];
filter1 = {'6300'    '6300'    '6300'  '6300'   '8446'
           '4278'    '5577'    '4278'  '8446'   '6300'
           '6300'    '6300'    '6300'  '6300'   '8446'
           '4278'    '5577'    '5577'  '8446'   '6300'};

OK = to_gopta('rgb1_5_3ln',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes-700,interv,GTlownoise,OPS1);
OK = to_gopta('rgb1_5_3mn',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes-400,interv,GTlittlenoise,OPS1);
OK = to_gopta('rgb1_5_3fast',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes-300,interv,GTfast,OPS1);
OK = to_gopta('rgb1_10_7ln',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes+4000,interv*2,GTlownoise,OPS1);
OK = to_gopta('rgb1_10_7mn',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes+4000,interv*2,GTlittlenoise,OPS1);
OK = to_gopta('rgb1_10_7fast',sn,Startstop,c_l1,filter1,{'','heating','heating'},exptimes+4000,interv*2,GTfast,OPS1);


OPS4.binning = '4,4';
OPS4.object= 'heating All r-b-ir-g';
OPS4.observer= 'ALIS heating team';

c_l4 = [4 4 4 4 4];
filter4 = { '6300'    '6300'    '6300'    '6300'    '6300'
            '4278'    '4278'    '4278'    '4278'    '4278'
            '8446'    '8446'    '8446'    '8446'    '8446'
            '5577'    '5577'    '5577'    '5577'    '5577'};

OK = to_gopta('rgbir_5_3ln',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes-700,interv,GTlownoise,OPS4);
OK = to_gopta('rgbir_5_3mn',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes-400,interv,GTlittlenoise,OPS4);
OK = to_gopta('rgbir_5_3fast',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes-300,interv,GTfast,OPS4);
OK = to_gopta('rgbir_10_7ln',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes+4000,interv*2,GTlownoise,OPS4);
OK = to_gopta('rgbir_10_7mn',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes+4000,interv*2,GTlittlenoise,OPS4);
OK = to_gopta('rgbir_10_7fast',sn,Startstop,c_l4,filter4,{'','heating','heating'},exptimes+4000,interv*2,GTfast,OPS4);

OPS2.binning = '4,4';
OPS2.object= 'heating All r-g';
OPS2.observer= 'ALIS heating team';

c_l2 = [2 2 2];
filter2 = { '6300'    '6300'    '6300'
            '5577'    '5577'    '5577'};

OK = to_gopta('rg_5_3ln',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes-700,interv,GTlownoise,OPS2);
OK = to_gopta('rg_5_3mn',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes-400,interv,GTlittlenoise,OPS2);
OK = to_gopta('rg_5_3fast',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes-300,interv,GTfast,OPS2);
OK = to_gopta('rg_10_7ln',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes+4000,interv*2,GTlownoise,OPS2);
OK = to_gopta('rg_10_7mn',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes+4000,interv*2,GTlittlenoise,OPS2);
OK = to_gopta('rg_10_7fast',sn,Startstop,c_l2,filter2,{'','heating','heating'},exptimes+4000,interv*2,GTfast,OPS2);

OPSg.binning = '4,4';
OPSg.object= 'heating All g';
OPSg.observer= 'ALIS heating team';

c_lg = [1 1 1];
filterg = {'5577' '5577' '5577'};
exptimes(:) = 500;
interv = [ 2     2     2     2     2
           2     2     2     2     2
           2     2     2     2     2
           2     2     2     2     2];

OK = to_gopta('g_2_500ln',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes-700,interv,GTlownoise,OPSg);
OK = to_gopta('g_2_500mn',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes-400,interv,GTlittlenoise,OPSg);
OK = to_gopta('g_2_500fast',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes-300,interv,GTfast,OPSg);
OK = to_gopta('g_4_500ln',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes+4000,interv*2,GTlownoise,OPSg);
OK = to_gopta('g_4_500mn',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes+4000,interv*2,GTlittlenoise,OPSg);
OK = to_gopta('g_4_500fast',sn,Startstop,c_lg,filterg,{'','heating','heating'},exptimes+4000,interv*2,GTfast,OPSg);



OPS5.binning = '4,4';
OPS5.object = 'heating All g-b-g-b-r';
OPS5.observer = 'ALIS heating team';

c_l5 = [5 5 5];
filter5 = { '4278'    '4278'    '4278'    '4278'    '4278'
            '5577'    '5577'    '5577'    '5577'    '5577'
            '4278'    '4278'    '4278'    '4278'    '4278'
            '5577'    '5577'    '5577'    '5577'    '5577'
            '6300'    '6300'    '6300'    '6300'    '6300'
            };
exptimes = [3000        3000        3000        3000        3000
            3000        3000        3000        3000        3000
            3000        3000        3000        3000        3000
            3000        3000        3000        3000        3000
            3000        3000        3000        3000        3000];

interv = [ 5     5     5     5     5
           5     5     5     5     5
           5     5     5     5     5
           5     5     5     5     5
           5     5     5     5     5];


OK = to_gopta('bgbgr_5_3ln',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes-700,interv,GTlownoise,OPS5);
OK = to_gopta('bgbgr_5_3mn',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes-400,interv,GTlittlenoise,OPS5);
OK = to_gopta('bgbgr_5_3fast',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes-300,interv,GTfast,OPS5);
OK = to_gopta('bgbgr_10_7ln',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes+4000,interv*2,GTlownoise,OPS5);
OK = to_gopta('bgbgr_10_7mn',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes+4000,interv*2,GTlittlenoise,OPS5);
OK = to_gopta('bgbgr_10_7fast',sn,Startstop,c_l5,filter5,{'','heating','heating'},exptimes+4000,interv*2,GTfast,OPS5);
