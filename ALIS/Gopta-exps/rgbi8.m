% Script used to make gopta experiment configuration file for
% ALIS-EISCAT-Heating campaign 200411
% EISCAT_ALIS200411 - example script showing how to make gopta experiment configuration files

% Copyright Bjorn Gustavsson
%                  X       Y       Y        X
sn =            {'botn' 'kiruna' 'silki' 'tjautjas' 'abisko' 'optics lab'};
GTfast =        {'1,0'  '1,0'    '1,3'     '1,0'    '1,3'      '1,2'};
GTlittlenoise = {'2,1'  '2,1'    '2,0'     '2,1'    '2,0'      '1,2'};
GTlownoise =    {'3,2'  '3,2'    '3,1'     '3,2'    '3,1'      '2,3'};
mima_nr     =   [ 6      4        2         3        5         1];


Startstop = {'03:00:00'    '03:00:00'    '03:00:00'
             '06:30:00'    '06:30:00'    '06:30:00'};

exptimes = [1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000
            1000        1000  1000        1000        1000      1000];

interv = [ 4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4
           4     4     4     4    4     4];

OPS1.binning = '4,4';
OPS1.observer =  'ALIS team 2005/6';

c_l1 =     [  8        8         8       8         8          8];
filter1 = {'4278'    '4278'    '4278'    '4278'    '4278'   '5577'
           '5577'    '5577'    '5577'    '5577'    '5577'   '4278'
           '4278'    '4278'    '4278'    '4278'    '4278'   '5577'
           '5577'    '5577'    '5577'    '5577'    '5577'   '4278'
           '6300'    '6300'    '6300'    '6300'    '6300'   '6300'
           '4278'    '4278'    '4278'    '5577'    '4278'   '5577'
           '5577'    '5577'    '5577'    '4278'    '5577'   '4278'
           '8446'    '8446'    '4278'    '8446'    '4278'   '8446'
          };

POS = {'' 'eiscat' 'eiscat' 'eiscat' 'eiscat' 'eiscat'};

interv(:) = 4;
exptimes(:) = 2000;

OPS1.object =  'Index: filter cycle rgbi8_4_16';
OK = to_gopta('rgbi8_4_16mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-400,interv,GTlittlenoise,OPS1);
OPS1.object =  'Index: filter cycle rgbi8_4_20';
OK = to_gopta('rgbi8_4_20mn',sn,Startstop,c_l1,filter1   ,POS,exptimes,interv,GTlittlenoise,OPS1);
interv(:) = 5;
OPS1.object =  'Index: filter cycle rgbi8_5_20';
OK = to_gopta('rgbi8_5_20mn',sn,Startstop,c_l1,filter1   ,POS,exptimes,interv,GTlittlenoise,OPS1);
