This document describes the use of available software in the /sif/idl folder which are not
currently compiled within hsoft. (Software agreed to be useful by all should be added
to the main hsoft library)

Note: there is far more software in the idl folder currently than there is documented here
Software here should be documented for all to use! If it's personal software hardcoded for one
specific event, keep it in your own idl folder, not here! - JMS


###################################

Additions proposed for hsoft

1] Modification to sat_overview

Print to psfile option added to sat_overview routine 
Call to sat_closest_approach added at end of sat_overview

2] sat_closest approach routine

This routine should be called from sat_overview, displaying information
about a read in satellite trace in image frames. Sat_closest_approach
 calculates the distance of closest approach of the satellite trace to 
the centre of the radar beam in pixel coordinates. The conversion 
coefficients for the image sequence are then used to convert this
 distance into degrees.

Syntax: sat_closest_approach, s_x, s_y, x0, y0

;s_x, s_y  - pixel coordinates describing satellite trace in ODIN fov
;xo, yo    - pixel coordinate of magnetic zenith in ODIN fov

(these coordinates are all previously calculated in sat_overview, hence why
it should be called from within this)

**********************************************************************

Other routines available, should be added to hsoft at some point

1]  autotrace_stars.pro  (NB. currently hardcoded for ODIN)

This routine automatically takes a number of frames from an ODIN image
 sequence, locates visible stars, and matches them to the positions of
 known stars from the sao star catalogue to locate the imagers field of view.

Syntax: autotrace_stars, event, toadd, step, start=start, stop=stop

event - event number of image sequence
toadd  -  number of frames to add together for each fitting
step  -  number of frames to skip before doing another fitting
start  - first frame number to use
stop   - last frame number to use

ie. autotrace_stars, 1, 50, 50, start=1, stop=160
will use frames 1-50, and then 100-150.
Be careful to avoid infinite loops! ie.autotrace_stars,1,50,0,start=1,stop=100

This creates an all_stars.dat file in the aux folder for the current image sequence


2] autotrace_fit.pro   (NB.routine currently located in autotrace_stars.pro file)

This routine calculates the conversion coefficients obtained by fitting automatically
traced stars, and saves them into a variable a. This routine works iteratively, 
ie. homing in on the best set of coefficients, so run it a few times until it
 settles on a final fit. This can be seen by the value of RMS deviation of the
 fit printed on screen, as it decreases and stabilises.
Once the best fit is obtained, passing the /write keyword will overwrite the
 conv.txt file in the aux directory for the current image sequence with the
 new values. (A rough conv.txt file is needed to start things off)

Syntax: autotrace_fit, a, write=write


2] sif_to_odin

This routine takes a satellite trace in SIF camera and calculates what the 
trace would be as seen from the ODIN imager (for example if ODIN was
 obscured by localised cloud, while SIF is clear)

Syntax: sif_to_odin, vsel_sif,s_sif,range, vsel_odin,s_odin

;vsel_sif  - event number for SIF image sequence
s_sif      - satellite number in SIF sequence
range      - range of satellite used for transfering frame
vsel_odin  - event number in ODIN to create this manufactured trace in
s_odin     - satellite number to name it

#########################################################################

Other software made available independently for sif data


plot_hp_multi,time,file,readhours,plotsec

script that creates a ps-file with 4 HITIES panels. It does what plot_hp does, but creates 4 panels.
 time is the wanted starting time (e.g. '23/01/2006 09:45:00', file is the name of the ps outputfile 
(e.g. '/home/hanna/test.ps'), readmin is the amount of hours to be read from the data (e.g. 1.0) and
 plotsec is the amount of seconds from the starting time to be plotted (e.g. 3600)
##########

createoverview

lists all events and sends them to plot_hp_multi, which then creates ps.plots for them.

#################

plot_panel_bigfont

Identical to the hsoft compiled routine plot_panel, except with bigger size text used for
the axis labels. Good to use for posters and presetntations
