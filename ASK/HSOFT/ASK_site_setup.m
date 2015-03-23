
% at lora.phys.soton.ac.uk: videodir = '/stp/raid2/ask/data'; % Here it is OK to have!

% ASKLUTfile = '/stp/raid2/ask/data/setup/ask.lut'; % at at lora.phys.soton.ac.uk
% videodir = '/stp/raid2/ask/data';                 % at lora.phys.soton.ac.uk
% HDIR       = '/export/bjg1c10/ASK/';              % at lora.phys.soton.ac.uk

% data_directory = '/data/ask/data/';
% videodir       = '/data/ask/data';
% HDIR           = '/data/bjg1c10/ASK/';
data_directory = '/media/ALIS_USB_2012-2/ASK';
videodir       = '/media/ALIS_USB_2012-2/ASK';
HDIR           = '/data/bjg1c10/ASK/';

% ASKLUTfile     = '/data/ask/data/setup/ask.lut';
ASKLUTfile     = '/media/ALIS_USB_2012-2/ASK/setup/ask.lut';


% TODO: move this one out of here, this is an initialization call,
% not a set-up, shouldn't be here!
% * step 1: find out where it the script is called and change that
%   to ASK_site_setup, ASK_site_init or some such
% * step 2: then put this line into the ASK_site_init.m
% ASK_read_asklut(ASKLUTfile);
% * step 3 move the other hard-coded set-ups into this and this
%   script into these places.