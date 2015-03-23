
longlatalt = [ 19.15863 69.38518 104.695
               20.9     68.4     105];
UrlNames = {'http://polaris.nipr.ac.jp/~acaurora/aurora/Tromso/latest.jpg',...
            'http://www.irf.se/allsky/LASTv2.JPG'};
titleStrs = {'Ramfjord',...
             'Kiruna'};
longlataltCams = {[19+13/60+38/3600 69+35/60+11/3600 0.086],...
                  [20.4112          67.8407,         0.2]};
optpars = {[-0.73644  -0.72566  -1.0699  0.469    0.85278  0.0052725 -0.00043956 0.47421 2 0],...
           [-0.7062   -0.7055    0.0781  0.0215   9.5699  -0.0051    -0.0000     0.4751  2 0]};
ImRegS = {[132,590,15,480],...
          [1 479,122 600]};
lblStrs = {'EISCAT-MZ 105','Spider/ESRANGE'};


starter4PointsOverImg(longlatalt,UrlNames,titleStrs,longlataltCams,optpars,ImRegS,lblStrs);
