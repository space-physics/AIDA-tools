function [ok] = starhelp(val)
% STARHELP Main help function
%
% Calling:
%  [ok] = starhelp(val)

%   Copyright � 20011105 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


ok = 1;
if ( val == 3 || val == 2 )
  % staridentification image window  
  starhelp =['FILE                                                                    ';
      'OPEN - give the name ( full path to ) of the fits image You want to load';
      'CLOSE ends the starcalibration par of the work.                         ';
      'SAVE - give the name of the variable You want to save ( idstars/optpar )';
      '                                                                        ';
      'COLOURSCALES - Different colourscales to choose from to stress certain  ';
      'levels in the image as well as changing its appearance.                 ';
      'BRIGTHEN - Enhance and make the darker parts of the image brighter.     ';
      '                                                                        ';
      'UPPERLIMIT                                                              ';
      'Select a cut of in intensity to reduce cosmic rays from the image.      ';
      'To avoid wasting the colorscale on somethign that''s just junk.          ';
      '                                                                        ';
      'CENTER/ZOOM                                                             ';
      'CENTER - Move the center of the image by ''click and point''.             ';
      'ZOOM - Select a region in the large image to display magnified in the   ';
      'smaller image.                                                          '];

elseif ( val == 4 )
  % staridentification zoom window  
  starhelp =['CENTER - Move the center of the image by ''click and point''.             ';
      '                                                                        ';
      'STAR - Determine the size, orientation and brightness of a star by      ';
      'point and click. Auto - makes a fit of a general 2-D Gaussian to the    ';
      'image-intensity above the average in the frame. Man.pick sets the       ';
      'parameters of the gaussian to fixed widths and maximum intensity as the ';
      'intensity above the average in the central point.                       ';
      'Current experience favour use of Man.pick - faster and sufficiently     ';
      'accurate.                                                               '];
  
elseif ( val == 5 )
  % staridentification skyview - window
  starhelp =['FILE                                                                             ';
      'OPEN - give the name ( full path to ) of the fits image You want to load         ';
      'CLOSE ends the starcalibration par of the work.                                  ';
      'SAVE - give the name of the variable You want to save ( idstars/optpar )         ';
      '                                                                                 ';
      'POS/TIME                                                                         ';
      'POS/TIME - Change the position and time of the obseration to update the starplot ';
      '                                                                                 ';
      'STAR                                                                             ';
      'IDENTIFY - identify the star picked in the zoomwindow by point and click.        ';
      'INFORMATION gives information about the star closest to where You point and click';
      'DELETE LAST - To remove an erroneously identified star does not work at the      ';
      'moment.                                                                          ';
      'AUTOIDENTIFY - suggests where in the image the stars from the skyview window     ';
      'shuld appear and allows you to semiautomatically change missidentification of the';
      'the star picked in the zoomwindow by point and click.                            ';
      '                                                                                 ';
      'The popup menu in the window allows you to set maximum magnitude of the stars to ';
      'be displayed.                                                                    ';
      '                                                                                 ';
      'The lower horizontal scrollbar is the azimuth angle of the central point of the  ';
      'feild of view, south is in the centre of the scrollbar.                          ';
      'The upper horizontal scrollbar is the field of view.                             ';
      'The left vertical scrollbar is the zenith angle of the central point of the      ';
      'feild of view, zenith is all down and 90 deg is all the way upp                  ';
      'The right vertical scrollbar is the rotation angle of the                        ';
      'feild of view.                                                                   '];
  
elseif ( val == 6 )
  % staridentification optparfit window  
  % NEED some work
  starhelp =['FILE                                                                             ';
      'OPEN - give the name ( full path to ) of the fits image You want to load         ';
      'CLOSE ends the starcalibration par of the work.                                  ';
      'SAVE - give the name of the variable You want to save ( idstars/optpar )         ';
      '                                                                                 ';
      'The PLOT - In the plot the the possitions of the stars in the picture is plotted ';
      'as red + and the modelled positions are plotted as green x.                      '];
  
elseif ( val == 7 )
  % staridentification optpar window  
  starhelp =['APLY - Applies the current setting of the optical parameters in the optpar     ';
      'window to the current list of identified stars - the plot gives the actual     ';
      'possition in the image and the modeled position of the star from the optical   ';
      'parameters.                                                                    ';
      '                                                                               ';
      'To set some parameters to a fixed and known value just press the corresponding ';
      'checkbox.                                                                      ';
      '                                                                               ';
      'SEARCH - Finds the optimal values of the optical parameters.                   '];
  
elseif ( val == 8 )
  % intercalibration input window  
  starhelp =['OPEN - give the name ( full path to ) of the .ids file You want to load ';
             'You should load two ids-files with approximately the same stars to do   ';
             'the sensitivity intercalibration.                                       ';
             'SAVE - give the name of the variable You want to save ( idstars/optpar )';
             'AS - give the name of the file You want to save the parameter in.       ';
             'Nothing is saved until You have given both a variable and a name.       ';
             'QUIT ends the intercalibration part of the work.                        '];
  
elseif ( val == 9 )
  % intercalibration surface ratio window  
  starhelp =['PRINT (C) prints the panel in colour output to the colour printer     ';
      'PRINT (B/W) prints the panel in black/white output to the printer lwO ';
      'QUIT ends the intercalibration part of the work.                      ';
      'The horizontal slider changes the azimuth of the viewing direction    ';
      'The vertical slider changes the elevation of the viewing direction    '];
  
elseif ( val == 10 )
  % intercalibration ratio histogram window    
  starhelp =['PRINT (C) prints the panel in colour output to the colour printer     ';
      'PRINT (B/W) prints the panel in black/white output to the printer lwO ';
      'QUIT ends the intercalibration part of the work.                      ';
      'HELP - well try it once more and compare the output with this...      '];
  
end

if exist('starhelp','var')
  
  if ( exist('helpdlg','file') )
    
    helpdlg(starhelp,'starhelp 1')
    
  else
    
    disp(starhelp)
    
  end

end
clear starhelp
