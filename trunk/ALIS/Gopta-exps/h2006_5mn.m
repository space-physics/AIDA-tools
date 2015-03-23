%% to_gopta - how to
% The process of producing working experiment configuration files
% for ALIS would be difficult for simple experiment - if one were
% to use one and the same filter sequence for all stations. With
% different filter sequences at different stations this would soon
% turn into a typing nightmare. 
%
% Foortunatelly there is help nearby when needed. The ALIS toolbox
% includes a function to_gopta that rapidly produces experiment
% files for each station - at the same time it even produces
% documentation of the filter sequences for each station.
% 
% This example script used to make gopta experiment configuration
% file for the ALIS-EISCAT-Heating campaign 200411

% Copyright Bjorn Gustavsson
%% Camera set-up
% In addition to the problem keeping the filter sequences in order
% and at the right place is the more serious problem with giving
% the cameras the right gain-tables. Therefore this table is vital
% to keep up to date:
sn =            {'botn' 'kiruna' 'silki' 'tjautjas' 'abisko' 'optics lab'};
mima_nr     =   [ 6      4        2         3        5         1];
GTfast =        {'1,0'  '1,0'    '1,3'     '1,0'    '1,3'      '1,2'};
GTlittlenoise = {'2,1'  '2,1'    '2,0'     '2,1'    '2,0'      '1,2'};
GTlownoise =    {'3,2'  '3,2'    '3,1'     '3,2'    '3,1'      '2,3'};
%% 
% |sn| is a cell-array with the station names. The first letter
% is used as identifier and one experiment file will be produced
% and put into a directory with capitalized first letter (A/, B/,
% ...). 
% The GTxxx is the gain table entries for the cameras 1-6,
% GTlownoise is the slowest with the lowest read-out noise,
% typically 6-10 electrons, GTlittlenoise give a slightly larger
% read noise (10-12 e^-) and a faster read-out. While GTfast gives
% about 50 per cent faster read-out but a read noise of around
% 15-25 e^-. Also the camera sensitivity is decreasing for the
% faster read-outs.

%% Start and stop times
% The start time should in most cases rather be seen as a
% syncronization time.
Startstop = {'03:00:00'    '03:00:00'    '03:00:00'
             '06:30:00'    '06:30:00'    '06:30:00'};

%% Filter sequence
% The real benefit of this procedure of producing experiment
% scripts is that it is easy to bend and permute any filter
% sequences. For this experiment all filter sequences are 8 items
% long. 
c_l1 =     [  9         9         9         9        9         9 ];
%%
% And here are the individual filter sequences. One column for each
% station. This cell-array with filter names can of course be
% produced in any way, but for this relatively short one it is
% still doable to put it down explicitly.
filter1 = {'6300'    '6300'    '6300'    '6300'    '6300'    '5577'
           '5577'    '6300'    '5577'    '5577'    '5577'    '5577'
           '4278'    '6300'    '4278'    '8446'    '4278'    '5577'          
           '6300'    '6300'    '6300'    '6300'    '6300'    '5577'
           '8446'    '6300'    '4278'    '8446'    '8446'    '5577'
           '5577'    '6300'    '5577'    '4278'    '5577'    '5577'
           '6300'    '6300'    '6300'    '6300'    '6300'    '5577'
           '4278'    '6300'    '4278'    '4278'    '4278'    '5577'
           '8446'    '6300'    '5577'    '5577'    '8446'    '5577'
          };

%% Exposure times
% Here the base exposure times are set to 1000 ms, uniformly, which
% might not be ideal under all circumstances, but for this
% experiment intended for HF-pump experiments intended for quiet
% ionospheric conditions this will of course give the best
% syncronisation. As any matlab variable these matrices might be
% modified at will.
exptimes = [3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000
            3000        3000  3000        3000        3000      3000];
%% Interval times
% Again uniform all over - at 5 s.
interv = [ 5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5
           5     5     5     5    5     5];

%% Position
% When only one position if given that will be set asap, and then
% kept during the entire run.
POS = {'' 'heating' 'heating' 'heating' 'heating' 'heating'};

%% Binning
% Here we set the camera binning factor to 4 by 4. Since camera
% reconfiguration takes some time, we regularly try to reduce the
% number of reconfigurations to keep the observational dead-time
% down.
OPS1.binning = '4,4';
OPS1.observer =  'ALIS team 2006/7';
%%
% Here we change all exposures to 2000ms
exptimes(:) = 2000;
%%
% In addition to the fields |binning| and |observer| the option
% struct keep |object|. Here we put a campaign subject relevant to
% the experiment file as well as a name for the filter cycle:
OPS1.object =  'Heating-200411: filter cycle tge_4_16';
OK = to_gopta('hKrOg2006_2p6x5mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-400,interv,GTlittlenoise,OPS1);
OK = to_gopta('hKrOg2006_3p6x6mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-400+1000,interv+1,GTlittlenoise,OPS1);
OK = to_gopta('hKrOg2006_2p8x5mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-200,interv,GTlittlenoise,OPS1);
OK = to_gopta('hKrOg2006_3p8x6mn',sn,Startstop,c_l1,filter1   ,POS,exptimes-200+1000,interv+1,GTlittlenoise,OPS1);
% In addition to the experiment set-up files to_gopta will produce
% one .eps and one .png figure of the filter sequence with the same
% name as the experiment - makes it easier to check out what
% different experiments do at run-time.
