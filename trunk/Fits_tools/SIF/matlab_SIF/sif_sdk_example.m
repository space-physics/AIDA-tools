% Set file access mode to read all
access_mode = 0;
rc=AndorSifSetAccessMode(access_mode);

% read the file from specific location ** cHANGE THIS **

rc=AndorSifReadFromFile('C:\last_test.sif');

% check it is loaded
[rc,loaded]=AndorSifIsLoaded;

signal=0;
% check that signal is present
[rc,present]=AndorSifIsDataSourcePresent(signal);

% Get the number of signal frames in the sif
[rc,no_frames]=AndorSifGetNumberFrames(signal);

% Determine how many sub images make up 1 frame
[rc,no_subImgs]=AndorSifGetNumberSubImages(signal);

% get the sub image info (zero based index);
[rc,left,bottom,right,top,vBin,hBin]=AndorSifGetSubImageInfo(signal,0);

%  Determine the size of 1 frame
[rc,frameSize]=AndorSifGetFrameSize(signal);

% Retrieve a frame (zero based index);
[rc,data]=AndorSifGetFrame(signal,0,frameSize);

% remap the data
width=(right-left)+1;
disp(width);
height=(top-bottom)+1;
disp(height);

colormap(gray);
newdata=reshape(data,width,height);
imagesc(newdata);

% retrieve all frames
[rc,data]=AndorSifGetAllFrames(signal,frameSize*no_frames);

colormap(hot);
newdata=reshape(data,width,height);
imagesc(newdata);

% Demonstrate retrieving properties

disp('Head Model');
[rc,propValue]=AndorSifGetProperty(signal,'HeadModel');
disp(propValue);
disp('Formatted Time :');
[rc,propValue]=AndorSifGetProperty(signal,'FormattedTime');
disp(propValue);

% Close the file
rc=AndorSifCloseFile;
disp('!!DONE!!');


