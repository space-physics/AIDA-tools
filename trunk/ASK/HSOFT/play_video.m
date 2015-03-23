PRO play_video, num=num, start=start,stop=stop,step=step,range=range,$
                pause=pause,speed=speed,fast=fast, quiet=quiet, raw=raw,$
		north=north, zenith=zenith,$
		circle_tromso=circle_tromso,circle_esr=circle_esr,$
		ct=ct, invert=invert, pngkalk=pngkalk,pnglora=pnglora, $
		true=true,rot=rot, background=background, timestamp=timestamp, add=add
;
; Plays through the video sequence currently read in using read_vs.
; Keywords (all optional):
; num     - Set this to a number to read that video event with read_vs
;           before starting.
; start   - The first frame number to show. If not set then it starts at
;           the begining.
; stop    - The last frame number to show. If not set then it runs until
;           the end.
; step    - The step between frames. If not set, step is 1.
; range   - This is a 2 element vector with the image contrast scaling
;           values ([min,max]), as used in bytscl. Defaults are 0.9 times the
;           min value of the first image and 1.1 times the max.
; pause   - If this is set then the video will start paused.
; speed   - Set this to a value to play the video at that fps. (e.g. if
;           you set speed=10 it will play at 10 frames per second).
;           The default is the video real time.
; fast    - If set then the speed keyword is ignored, and the video will
;           play at the maximum speed possible.
; quiet   - If NOT set then the frame number and time are printed.
; raw     - If set then no flat fielding is done (this keyword is passed
;           on to read_v).
; north   - If set then a north pointing arrow is drawn on the video.
; zenith  - Set this to an array of altitudes at which to calculate and
;           plot the magnetic zenith, as found from the IGRF field model.
;           The points are colour coded, so that the lowest altitude has
;           the highest colour index and the highest altitude has the
;           lowest colour index. The colour table used is 1 (blue-white).
; ct      - Set to a number for the colour table to use for displaying the
;           video. If not set the default is 0 (black-white).
; invert  - Set this to show a negative of the image
; pnglora - Writes the images as png files in /stp/raid2/ask/png/ on
;           lora
; pngkalk - Writes the images as png files in /ask/data1/png on kalk
; circle_tromso - Set to plot the Tromso UHF beam.
; circle_esr - Set to plot the ESR 42m beam.
;   Note that only one of circle_tromso and circle_esr can be set.
; true    - Display colour images. Is passed to read_v, and tv.
; rot     - Rotates the image
; timestamp - sets a timestamp on the image
; background - removes a background value
; add     - if set then images are added to give a better S/N. The
;           number of images to be added is the same as set in step
;
; NOTE that the maximum fps (i.e. when fast-forwarding) will be severly
; limited by the speed of the conection to the data and the speed of your
; X-server. Ideally this should be run on a linux computer in the same
; building as the data!
;
; Video controls
; --------------
;
; If you click and hold down the left mouse button then the video is
; played in fast-forward.
;
; If you click and hold down the right mouse button then the video is
; played backwards quickly. After that the video will coninue to play in
; reverse, until you click the left mouse button.
;
; Clicking on the video with the middle mouse button (or both left and
; right together) pauses or unpauses the video.
;
; Scrolling with the mouse wheel causes the video to move 1 frame forward
; or backwards while paused.
;
; If you click with the left mouse button in the left most 10 pixels of
; the image, then you can type in a frame number to jump to.
;
; If you click in the right most 10 pixels then the routine ends.
;
; --------------
;  
; Dan added true keyword, 01/05/08, for colour images.
;
; Dan modified this following Hanna's recommendations and changes
; 19/05/2010, to have new radar beam radii.
;
common hities
common vs
if keyword_set(quiet) then quiet=1 else quiet=0
if KEYWORD_SET(num) then read_vs,num=num,/quiet
if not(keyword_set(start)) then start=long(vnf[vsel])
if not(keyword_set(stop)) then stop=long(vnl[vsel])
if not(keyword_set(step)) then step=1L
if keyword_set(pause) then pause=1 else pause=0
if not(keyword_set(range)) then begin
 read_v,start,im
 range=[fix(min(im)-abs(0.1*min(im))),fix(max(im)+abs(0.1*max(im)))]
endif
if keyword_set(north) then north=1 else north=0
if keyword_set(speed) then spf=speed^(-1.0) else spf=vres[vsel]
if keyword_set(fast) then spf=0
if not(keyword_set(ct)) then ct=0
if keyword_set(invert) then invert=1 else invert=0
if keyword_set(circle_tromso) then begin
 circle=1
 get_cnv, cnv, scale
 rad_r=0.3/scale
 rad_az=185.02*!dtor
 rad_el=77.5*!dtor
endif else if keyword_set(circle_esr) then begin
 circle=1
 get_cnv, cnv, scale
 rad_r=0.45/scale
 rad_az=181.0*!dtor
 rad_el=81.6*!dtor
endif else circle=0
if circle then begin
 conv_xy_ae, rad_x0,rad_y0,rad_az,rad_el,cnv,/back
 rad_xx=rad_r*sin(findgen(100)/49.*!pi)+rad_x0
 rad_yy=rad_r*cos(findgen(100)/49.*!pi)+rad_y0
endif
if not(quiet) then begin
 print, string(range[0],range[1],form='("Image scaling: min = ",i0,", max = ",i0)')
 if spf gt 0.0 then print, string(spf^(-1.0),vres[vsel]/spf, form='("Play speed: ",f5.2,"fps (",f0.1,"x realtime)")')
 print,string(start,form='("First frame: ",i0)')
 print,string(stop,form='("Last frame:  ",i0)')
endif
if keyword_set(zenith) then begin
 if not(quiet) then print, "Calculating magnetic zenith position..."
 xzen=intarr(n_elements(zenith))
 yzen=intarr(n_elements(zenith))
 czen=intarr(n_elements(zenith))
 mjs_dy,time_v(start,/full),dy
 for i=0,n_elements(zenith)-1 do begin
  igrf_zenith,dy,vlat[vsel],vlon[vsel],0.0d,zenith[i],zaz,zel
  if not(quiet) then print, string(zenith[i],zaz*!radeg,zel*!radeg,form='(f6.1,"km: ",f7.2," az, ",f7.2," el")')
  conv_xy_ae,x,y,zaz,zel,vcnv[vsel,*],/back
  xzen[i]=x
  yzen[i]=y
  czen[i]=250-fix(((zenith[i]-min(zenith))/(max(zenith)-min(zenith)))*75.0)
 endfor
 zenith=1
endif else zenith=0
!mouse.button=0
window,xsi=dimx[vsel],ysi=dimy[vsel],retain=2,/free
skip=long(vnstep[vsel])
spf*=skip ; convert spf
; Dan changed the way 'step' keyword works - moved here 21/01/08:
skip*=long(step)
skip2=skip
i=long(start)
inx=20
if not(keyword_set(rot)) then rot=0 
while ((i le stop) and (i ge start)) do begin
  if !mouse.button eq 0 then oldtime=systime(1) else oldtime=systime(1)-spf
;  if !mouse.button eq 0 then oldtime=systime(1) else begin
;   oldtime=systime(1)-spf
;   basetime=systime(1)
;   baseframe=i
;  endelse
  ; show the image, print the status, etc
  if keyword_set(true) then read_v,i,image,/true else if keyword_set(raw) then read_v,i,image,/raw else if keyword_set(add) then begin 
   read_mv,i,step,data
   add_multi,data,image
  endif else read_v,i,image
  if KEYWORD_SET(background) then image=image-background
  image=bytscl(image,min=range[0],max=range[1])
 
  mjs_tt, time_v(i,/full), yr,mo,da,hr,mi,se,ms
  if not(quiet) then print,string(i, hr,mi,se,ms,form='("Frame #:",(i6),"  (",(i02),":",(i02),":",(i02),".",(i03),")")')
  loadct,ct,/silent
  ; plot the radar beam
  if circle then for a=0,n_elements(rad_xx)-1 do image(rad_xx(a),rad_yy(a))=1000
  if invert then image=255-image
  if rot gt 0 then image=rotate(image,rot)
  if keyword_set(true) then tv, image,/true else tv,image
  !p.position=[0,0,1,1]
  loadct,1,/silent
  if north then draw_north,length=0.5,/arrow,colour=255-(invert*254)
  if zenith then plots,xzen,yzen,psym=1,/dev,color=czen-(invert*((2*czen)-255))
  if keyword_set(timestamp) then begin
   str=string(yr, form='(i4.2)')+'/'+string(mo, form='(i2.2)')+'/'+string(da,form='(i2.2)')+' '+string(hr, form='(i2.2)')+':'+string(mi, form='(i2.2)')+':'+string(se, form='(i2.2)')+'.'+string(ms, form='(i4.2)')
   xyouts,0.1,0.1,str,charsize=1.5,charthick=2,/dev
  endif
  ; read input and delay if not running at max speed
  repeat begin
   if pause then cursor,inx,iny,/dev else cursor,inx,iny,/nowait,/dev
   if !mouse.button eq 2 then begin ; middle button
    pause=not(pause)
    cursor,inx,iny,/dev,/up
    !mouse.button=0
    oldtime=systime(1)
;    basetime=systime(1)+spf
;    baseframe=i
    continue
   endif else if !mouse.button eq 1 then begin ; left button
    if (inx le 10) then begin
     aaa=' '
     read,aaa,prompt="Enter frame number to jump to: "
     i=long(aaa)-skip2
     !mouse.button=0
    endif else if (inx gt dimx[vsel]-10) then i=vnf[vsel]-(skip+1) else skip2=skip
    break
   endif else if !mouse.button eq 4 then begin ; right button
    skip2=-skip
    break
   endif else if !mouse.button eq 8 then begin ; wheel up
    if pause then skip2=-skip
   endif else if !mouse.button eq 16 then begin ; wheel down
    if pause then skip2=skip
   endif
  endrep until (systime(1) ge (oldtime+spf))
  
;  frameloss=fix(((systime(1)-basetime)/spf)-abs((i-baseframe)*skip))
;  if frameloss gt 0 then begin
;   if not(quiet) then print, "Frame #: dropped to match desired framerate!"
;   i+=(skip2*frameloss)
;  endif
  i+=skip2
  
  if keyword_set(pnglora) then begin
    filelora='/stp/raid2/ask/png/'+string(i, form='(i5.5)')+'.png'
    write_png, filelora, image
  endif else if keyword_set(pngkalk) then begin
    filekalk='/ask/data1/png/'+string(i, form='(i5.5)')+'.png'
    image=tvrd()
    write_png, filekalk, image
  endif
endwhile
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
