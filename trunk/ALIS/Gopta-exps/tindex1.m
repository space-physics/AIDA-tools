% Script used to make gopta experiment configuration file for
% ALIS-EISCAT-Heating campaign 200411
% EISCAT_ALIS200411 - example script showing how to make gopta experiment configuration files

% Copyright Bjorn Gustavsson

sn =            {'botn' 'kiruna' 'silki' 'tjautjas' 'abisko'};
GTfast =        {'1,0'  '1,0'    '1,3'     '1,0'    '1,3'   };
GTlittlenoise = {'2,1'  '2,1'    '2,0'     '2,1'    '2,0'   };
GTlownoise =    {'3,2'  '3,2'    '3,1'     '3,2'    '3,1'   };
mima_nr     =   [ 6      4        2         3        5      ];

Startstop = {'16:00:00'    '16:00:00'    '16:00:00'
             '27:00:00'    '27:00:00'    '27:00:00'};

exptimes = [1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000
            1000        1000  1000        1000        1000];

interv = [ 3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3
           3     3     3     3     3];

OPS1.binning = '4,4';
OPS1.observer =  'ALIS team 2005/6';

c_l1 =     [  9         9         9       9         9 ];
filter1 = {'4278'   '4278'    '4278'  '4278'    '4278'
           '5577'   '4278'    '5577'  '5577'    '5577'
           '6300'   '4278'    '6300'  '8446'    '6300'           
           '4278'   '4278'    '4278'  '4278'    '4278'
           '8446'   '4278'    '6300'  '8446'    '8446'
           '5577'   '4278'    '5577'  '6300'    '5577'
           '4278'   '4278'    '4278'  '4278'    '4278'
           '6300'   '4278'    '6300'  '6300'    '6300'
           '8446'   '4278'    '5577'  '5577'    '8446'};

POS = {'' 'eiscat' 'eiscat' 'eiscat' 'eiscat'};


OPS1.object =  'Index: filter cycle tindex1_fast.eps';
OK = to_gopta('tindex1_fast',sn,Startstop,c_l1,filter1 ,POS,exptimes-300,interv,GTfast,OPS1);
OPS1.object =  'Index: filter cycle tindex1_3_06.eps';
OK = to_gopta('tindex1_3_06mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-400,interv,GTlittlenoise,OPS1);

interv(:) = 4;
exptimes(:) = 2000;

OPS1.object =  'Index: filter cycle tindex1_4_13.eps';
OK = to_gopta('tindex1_4_13ln',sn,Startstop,c_l1,filter1   ,POS,exptimes-700,interv,GTlownoise,OPS1);
OPS1.object =  'Index: filter cycle tindex1_4_16.eps';
OK = to_gopta('tindex1_4_16mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-400,interv,GTlittlenoise,OPS1);
