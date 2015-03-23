% Template/example of how to fix the "interesting" placement of
% overscan strips in ALIS CCD-cam 6

% Copyright Bjorn Gustavsson 20050110

% This is only tested on the images from 980325 that I have
% available on my PC. All images are 256x256 after processing.
% The size of the overscan strip is half the differens of the image
% size and this should work for all image sizes. Regarding the
% columns in the middle I cant do better than this at the
% moment. Their general possition is something you will have to
% decide. Further I have found that columns close to the "black"
% lines in the image have signal as if they where half
% illuminated - valid for binning 4x4 - like if 2x4 of each super
% pixel were covered...
% The quadrant 1:128,1:128 is approximatelly 1.088 times more
% sensitive at least 980325 and it seems to work for images in
% 4278, 5577, 6300 and 8446 in the intensity range I've tested.

% This is the processing steps that seems to balance the quadrants
[h,d] = fits2('23P01035.RAF');
d = d(:,[1 133 134 2 3 4:132 137:end 135 136]);
d = quadfix3(d,2,diff(size(d))/2);
d(:,[134 135]) = d(:,[134 135])*2;
d = d(:,7:end-6);
d(1:128,1:128) = d(1:128,1:128)/1.08;

% this is a step by step instructive (not much) argumentation
[h,d] = fits2('23P01035.RAF');
disp('[h,d] = fits2(''23P01035.RAF'');')
imagesc(replace_border(d)),caxis([-31836 -31836+2400])
disp('imagesc(replace_border(d)),caxis([-31836 -31836+2400])')
disp('press any key')
pause
axis([125 140 110 180])
disp('axis([125 140 110 180])')
disp('press any key')
pause
tmpfig = figure;

subplot(2,1,1)
plot((d(2:end-1,[1 2 3])))        
title('col 1, 2, 3')
subplot(2,1,2)
plot((d(2:end-1,[133 134])))      
title('col 133 134')
disp('subplot(2,1,1)')
disp('plot((d(2:end-1,[1 2 3])))')
disp('subplot(2,1,2)')
disp('plot((d(2:end-1,[133 134])))')
disp('Columns 133 & 134 belongs to left overscan strip')
disp('press any key')
pause
clf
disp('clf')

subplot(2,1,1)
plot((d(2:end-1,[end-2 end-1 end])))
title('col end-2 end-1 end')
subplot(2,1,2)
plot((d(2:end-1,[135 136])))      
title('col 135 136')
disp('subplot(2,1,1)')
disp('plot((d(2:end-1,[end-2 end-1 end])))')
disp('subplot(2,1,2)')
disp('plot((d(2:end-1,[135 136])))')

disp('Columns 135 & 136 belongs to right overscan strip')
disp('rearange these columns')
d1 = d(:,[1 133 134 2 3 4:132 137:end 135 136]);
disp('d1 = d(:,[1 133 134 2 3 4:132 137:end 135 136]);')

disp('press any key')
pause
d2 = quadfix3(d1,2,diff(size(d1))/2);
disp('d2 = quadfix3(d1,2,diff(size(d1))/2);')
clf
disp('clf')
plot(d2(2:end-1,133:136))
disp('plot(d2(2:end-1,133:136))')

disp('columns 134 & 135 too small...')
disp('press any key')
pause

plot(d2(2:end-1,134:135)./d2(2:end-1,[133 136]))
disp('plot(d2(2:end-1,134:135)./d2(2:end-1,[133 136]))')
disp('...by a factor of 2.')
disp('press any key')
pause

d3 = d2;                            
d3(:,[134 135]) = d3(:,[134 135])*2;
d3 = d3(:,7:end-6);
disp('d3 = d2;')
disp('d3(:,[134 135]) = d3(:,[134 135])*2;')
disp('d3 = d3(:,7:end-6);')

imagesc(d3),caxis([0 2400])
disp('imagesc(d3),caxis([0 2400])')
disp('one quadrant is more sensitive?')
disp('press any key')
pause

subplot(2,1,1)
plot(d3(2:end-1,128)./d3(2:end-1,129),'r')
grid
subplot(2,1,2)
plot(d3(128,:)./d3(129,:))
grid

disp('subplot(2,1,1)')
disp('plot(d3(2:end-1,128)./d3(2:end-1,129),''r''')
disp('grid')
disp('subplot(2,1,2)')
disp('plot(d3(128,:)./d3(129,:))')
disp('grid')
disp('mean(medfilt1(d3(128,1:end/2)./d3(129,1:end/2),3)) = ')
disp(mean(medfilt1(d3(128,1:end/2)./d3(129,1:end/2),3)))
disp('mean(medfilt1(d3(128,end/2+1:end-1)./d3(129,end/2+1:end-1),3)) = ')
disp(mean(medfilt1(d3(128,end/2+1:end-1)./d3(129,end/2+1:end-1),3)))
disp('mean(medfilt1(d3(2:end/2,128)./d3(2:end/2,129),3)) = ')
disp(mean(medfilt1(d3(2:end/2,128)./d3(2:end/2,129),3)))
disp('mean(medfilt1(d3(end/2+1:end-1,128)./d3(end/2+1:end-1,129),3)) = ')
disp(mean(medfilt1(d3(end/2+1:end-1,128)./d3(end/2+1:end-1,129),3)))

disp('press any key')
pause

d4 = d3;                               
d4(1:128,1:128) = d4(1:128,1:128)/1.08;

disp('d4 = d3;')
disp('try with correction factor 1/1.08')
disp('d4(1:128,1:128) = d4(1:128,1:128)/1.08;')
close(tmpfig)
imagesc(d4),caxis([0 2400])
title('Maybe not so bad for this image...')
