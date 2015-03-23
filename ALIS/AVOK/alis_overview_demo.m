% Example showing the use of ALIS_OVERVIEW

[q,w] = my_unix('ls -1 --color=never /home/DATA/ALIS/19980325/s01/*.raf');
files{1} = w(1:end-1,:);
[q,w] = my_unix('ls -1 --color=never /home/DATA/ALIS/19980325/s02/*.raf');
files{2} = w(1:end-1,:);

PO = typical_pre_proc_ops;
PO.fix_missalign = 0;
POs{1} = PO;
POs{2} = PO;


OPS = alis_overview;
OPS.times_until_restart = 4;
OPS.overview_sppos = 1;
OPS.subplots = [4 3];
OPS.subplot_pos = [2 3];   
OPS.make_pause = 1;

files1{1} = files{1}(1:12,:);
files1{2} = files{2}(1:14,:);


[M,filters,Times,I_minmax] = alis_overview(files,POs,OPS);


[q,w] = my_unix('ls -1 --color=never /home/DATA/ALIS/19990216/s03/*.raf');
files{1} = w(1:end-1,:);
POr = PO;
POr.imreg = [60 110 30 100];


OPS = alis_overview;
OPS.times_until_restart = 1;
OPS.overview_sppos = -1;
OPS.subplots = [1 1];
OPS.subplot_pos = [1 3];   
OPS.make_pause = 0;
OPS.rgb_or_pseudo = 'pseudo';
OPS.caxis = [5000 13500];    

[M,filters,Times,I_minmax] = alis_overview(files{1}(77:(77+45)),{POr},OPS);

cd /home/DATA/ALIS/19980302
if 1
  
  [q,w] = my_unix('ls -1 --color=never s01/*.raf');
  f1 = w(1:end-1,:);                              
  [q,w] = my_unix('ls -1 --color=never s03/*.raf');
  f3 = w(1:end-1,:);                              
  [q,w] = my_unix('ls -1 --color=never s04/*.raf');
  f4 = w(1:end-1,:);                              
  [q,w] = my_unix('ls -1 --color=never s05/*.raf');
  f5 = w(1:end-1,:);                              
  [q,w] = my_unix('ls -1 --color=never s06/*.raf');
  f6 = w(1:end-1,:);                              
end

files = {f1,f3,f4,f5,f6};

PO = typical_pre_proc_ops
PO.fix_missalign = 0;
PO.verb = -2;

POs = {PO,PO,PO,PO,PO};

POs{2}.medianfilter = [5 -3];
POs{4}.interference_level = 1.5;
POs{1}.ffc = 1;
POs{2}.ffc = 1;
POs{4}.img_histeq = 100;
POs{5}.hist_crop = .001; 

OPS = alis_overview
OPS.subplots = [4 6];
OPS.subplot_pos = [2 3 4 5 6];
OPS.make_pause = 1;
OPS.times_until_restart = 8;
OPS.overview_sppos = 1;

[M,filters,Times,I_minmax] = alis_overview(files,POs,OPS);

OPS1 = 
              clear_fig: 0
               subplots: [4 6]
            subplot_pos: [2 3 4 5 6]
          rgb_or_pseudo: 'rgb'
    times_until_restart: 8
         overview_sppos: 1
                out_arg: 0
             make_pause: 1
      out_base_filename: ''
               printcmd: ''
                  caxis: 'auto'
             plot_style: 'map_proj'
             map_limits: [-100 2 100 -100 2 100]
                map_alt: 110
OPS2 = 
              clear_fig: 1
               subplots: [1 1]
            subplot_pos: [1 1 1 1 1 1]
          rgb_or_pseudo: 'rgb'
    times_until_restart: 1
         overview_sppos: 0
                out_arg: 0
             make_pause: 0
      out_base_filename: ''
               printcmd: ''
                  caxis: 'auto'
             plot_style: 'map_proj'
             map_limits: [-50 1 50 -50 1 50]
                map_alt: 110
OPS3 = 
              clear_fig: 0
               subplots: [4 6]
            subplot_pos: [2 3 4 5 6]
          rgb_or_pseudo: 'rgb'
    times_until_restart: 4
         overview_sppos: 1
                out_arg: 0
             make_pause: 0
      out_base_filename: ''
               printcmd: ''
                  caxis: 'auto'
             plot_style: 'map_proj'
             map_limits: [-50 1 50 -50 1 50]
                map_alt: 110
