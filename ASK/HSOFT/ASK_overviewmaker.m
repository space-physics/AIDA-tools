function MegaBlocksDone = ASK_overviewmaker(MegaBlocksDone,data_dir)
% ASK_overviewmaker - Create mega-block overlayed-keogram for overview
%   This function creates overview-plots in keogram-overlayed style
%   for megablocks in the ask-data directory that have data from
%   all three cameras. The overviews created will consist of 1
%   figure spanning the entire time period of the mega-block and 20
%   figures covering 1-minute periods. The directory will work
%   through all directories, but if a cell-array of directory names
%   of directories with camera #1 is given those will be skipped.
% 
% Calling:
%   MegaBlocksDone = ASK_overviewmaker(MegaBlocksDone,data_dir)
% Input:
%  MegaBlocksDone - cell-array with directory names for camera #1
%                   for megablocks allready done. Defaults to {''}
%                   if none is given.
%  data_dir       - path to data directory, optional, defaults to:
%                   /stp/raid2/ask/data 
%

% Copyright B Gustavsson 20101119 <bjorn@irf.se>
% This is free software, licensed under GNU GPL version 2 or later


%% Script to make overlaye-keograms of all mega-blocks in /stp/raid2/ask/data 
% 
% For which there are setup-files.

% Make sure that the global VS structure is visible in the workspace:
global vs

if nargin == 0 | isempty(MegaBlocksDone)
  MegaBlocksDone{1} = '';
end
iMegaBlocksDone = length(MegaBlocksDone);

if nargin < 2 | isempty(data_dir)
  % Data directory:
  % data_directory = '/stp/raid2/ask/data/'; % at lora.phys.soton.ac.uk
  ASK_site_setup
  % data_directory = '/data/ask/data/';
end
% Go there
cd(data_directory)
% List all mega-block directories:
q3 = dir('*r3');
q1 = dir('*r1');
q2 = dir('*r2');

% Collect the mega-blocks where we have data from all three
% cameras, and store away those directories:
iAllThree = 1;
for i3 = 1:length(q3),
  % Should not matter whichever one we choose here #1, #2 or #3:
  Q3DateObs = (q3(i3).name(1:end-2)); % This should be datetime of
                                      % mega-block start
  Q2DateObs = [Q3DateObs,'r2'];       % name of mega-block #1
  Q1DateObs = [Q3DateObs,'r1'];       % and #2
  i2exist = strcmp(Q2DateObs,{q2(:).name}); % search for them among
  i1exist = strcmp(Q1DateObs,{q1(:).name}); % the data-directories.
  if any(i2exist) & any(i1exist)
    % If there are directories from all three cameras then we store
    % them for later processing:
    ThreeDirs{iAllThree} = {q1(i1exist).name, q2(i2exist).name, q3(i3).name};       
    iAllThree = 1 + iAllThree;
    % Yeah, yeah, successive memmory allocation and blablabla. 
    % This works and the time it might wast is _nothing_ compared to
    % the hours it takes to work through all data.
  end
  
end

clf
% This sets the figure size for printing to tall which is necessary
% for decent-looking figures when printed to file:
orient tall
% Setting of the default options:
ops4keoO = ASK_keogram_overlayed;
% Use 9 images in the row of images:
ops4keoO.subplot4imgs = [5,9,10];
% Image filtering:
ops4keoO.filtertype = {'sigma','median'};
ops4keoO.filterArgs = {{[3,3]},{[3,3],'symmetric'}};
% Only show the RGB-composite:
ops4keoO.oneImg = 4;
% Make the time-label a bit smaller to avoid overlapping:
ops4keoO.imrowFontsize = 10;
ops4keoO.quiet = 1;

iFiles = 1;

% Check all mega-blocks
while iFiles <= length(ThreeDirs)
  
  try
    % Combine the names of the mega-block directories from the
    % three cameras:
    filenames = str2mat([ThreeDirs{iFiles}{1},'.txt'],[ThreeDirs{iFiles}{2},'.txt'],[ThreeDirs{iFiles}{3},'.txt']);
    % If overview-plots of mega-block haven't been done
    if sum(strcmp(MegaBlocksDone,filenames(1,:))) == 0
      % then do it now!
      % Read the set-up files for the mega-block:
      ASK_read_vs(1,filenames)
      % if we have unequal number of frames in the megablock
      % directories from the 3 cameras just skip it for
      % simplicity. 
      % TODO - fix this so that we can get the partial
      % overlayedkeograms done as well. Left for cleaning up
      % stage... 
      if max(abs(diff(vs.vnl)))
        iFiles = iFiles + 1; 
        continue
      end
      % Get the start time of mega-block:
      startTime = ASK_indx2datevec(1);
      % Make name of directory to save plots in:
      Cdir = [data_directory,'MegablockOverviews/',sprintf('%d/%02d/%02d',startTime(1:3))];
      % Make that directory:
      mkdirstring = ['mkdir -p ',Cdir]
      [qOK,qKO] = system(mkdirstring);
      % Go there:
      cd(Cdir)
      % Make keogram of full megablock:
      % This will crash for megablocks with less than 1000 images,
      % this would correspond to exposure-times larger than 1.2 s
      clf
      %Was: [keo,imstack,timeV] = ASK_keogram_overlayed(1,vs.vnl(vs.vsel),round(vs.vnl(vs.vsel)/1000),[0 0 0],9,128,128,90,ops4keoO);
      ASK_keogram_overlayed(1,vs.vnl(vs.vsel),round(vs.vnl(vs.vsel)/1000),[0 0 0],9,128,128,90,ops4keoO);
      % Print the figure:
      ASK_keo_autoprint(ops4keoO.subplot4ASK3keo)
      % Number of frames in megablock:
      lastframe = vs.vnl(vs.vsel);
      % Frames in a minute:
      framesPerminute = round(lastframe/20);
      for i1 = 1:framesPerminute:lastframe,
        % Make an overlayed-keogram covering a minute:
        clf
        %Was: [keo,imstack,timeV] = ASK_keogram_overlayed(i1,min(vs.vnl(vs.vsel),i1+framesPerminute),1,...
        %                                                [0 0 0],9,128,128,90,ops4keoO);
        ASK_keogram_overlayed(i1,min(vs.vnl(vs.vsel),i1+framesPerminute),1,...
                              [0 0 0],9,128,128,90,ops4keoO);
        % and print them out:
        ASK_keo_autoprint(ops4keoO.subplot4ASK3keo)
      end
      % Store away the mega-block name for camera #1:
      MegaBlocksDone{iMegaBlocksDone} = filenames(1,:);
      iMegaBlocksDone = iMegaBlocksDone + 1; % increase the index.
      save([data_directory,'OverViewMegaBlocksDone.mat'], 'MegaBlocksDone')
    end
    iFiles = iFiles + 1; % increase the index.
  catch
    iFiles = iFiles + 1; % increase the index.
  end
  
end
