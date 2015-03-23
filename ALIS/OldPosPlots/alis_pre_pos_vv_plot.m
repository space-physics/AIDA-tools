% Script that plots ALIS predefined observation rotations
% BG 20050111

subplot(4,2,1)
alis_visiblevol(1,225,20,110,60,0);
alis_visiblevol(2,100 ,14,110,60,0);
alis_visiblevol(3,45 ,12,110,60,0); 
alis_visiblevol(4,115 ,15,110,60,0);
alis_visiblevol(5,30 ,14,110,60,0); 
alis_visiblevol(6,270 ,20,110,60,0);

xlabel('surveilance')
ylabel('')           
title('')

subplot(4,2,2)                                 
alis_visiblevol(1,180 ,12,110,60,0);
alis_visiblevol(2,180 ,12,110,60,0);
alis_visiblevol(3,180 ,12,110,60,0);
alis_visiblevol(4,180 ,12,110,60,0);
alis_visiblevol(5,180 ,12,110,60,0);
alis_visiblevol(6,180 ,12,110,60,0);

xlabel('mag\_zen')    
ylabel('')
title('')

subplot(4,2,3)
alis_visiblevol(1,180 ,30,110,60,0);
alis_visiblevol(2,250 ,23,110,60,0);
alis_visiblevol(3,215 ,28,110,60,0);
alis_visiblevol(4,260 ,7,110,60,0);
alis_visiblevol(5,148 ,31,110,60,0);
alis_visiblevol(6,135 ,23,110,60,0);

xlabel('south')
ylabel('')
title('')

subplot(4,2,4)
alis_visiblevol(1,0   , 0,110,60,0);
alis_visiblevol(2,298 ,24,110,60,0);
alis_visiblevol(3,249 ,28,110,60,0);
alis_visiblevol(4,346 ,20,110,60,0);
alis_visiblevol(5,130 ,24,110,60,0);
alis_visiblevol(6,90  ,20,110,60,0);

xlabel('core')
ylabel('')
title('')

subplot(4,2,5)
alis_visiblevol(1,0, 39,110,60,0);
alis_visiblevol(2,0, 15,110,60,0);
alis_visiblevol(3,0, 32,110,60,0);
alis_visiblevol(4,0, 42,110,60,0);
alis_visiblevol(5,0, 35,110,60,0);
alis_visiblevol(6,0, 15,110,60,0);

xlabel('east-west')
ylabel('')
title('')

subplot(4,2,6)
alis_visiblevol(1,0,   30,110,60,0);
alis_visiblevol(2,330, 33,110,60,0);
alis_visiblevol(3,311, 25,110,60,0);
alis_visiblevol(4,355, 33,110,60,0);
alis_visiblevol(5,85,  22,110,60,0);
alis_visiblevol(6,44,  26,110,60,0);

xlabel('north')
ylabel('')
title('')

subplot(4,2,7),axis([-300 300 -56.3654 400])
h1 = alis_visiblevol(1,0,   39,110,60,0);axis([-300 300 -56.3654 400]);
%h2 = alis_visiblevol(2,348, 42,110,60,0);axis([-300 300 -56.3654 400]);
h3 = alis_visiblevol(3,350, 32,110,60,0);axis([-300 300 -56.3654 400]);
h4 = alis_visiblevol(4,0,   42,110,60,0);axis([-300 300 -56.3654 400]);
h5 = alis_visiblevol(5,20,  35,110,60,0);axis([-300 300 -56.3654 400]);
%h6 = alis_visiblevol(6,15,  42,110,60,0);axis([-300 300 -56.3654 400]);

xlabel('eiscat')
ylabel('')
title('')

subplot(4,2,8),axis([-300 300 -56.3654 400])
alis_visiblevol(1,346, 37,110,60,0);axis([-300 300 -56.3654 400])
alis_visiblevol(2,340, 40,110,60,0);axis([-300 300 -56.3654 400])
alis_visiblevol(3,330, 37,110,60,0);axis([-300 300 -56.3654 400])
alis_visiblevol(4,345, 44,110,60,0);axis([-300 300 -56.3654 400])
alis_visiblevol(5,5, 25,110,60,0);axis([-300 300 -56.3654 400])
alis_visiblevol(6,5, 40,110,60,0);axis([-300 300 -56.3654 400])

xlabel('heating')
ylabel('')
title('')

suptitle('Approximate field of view at 110 km')
