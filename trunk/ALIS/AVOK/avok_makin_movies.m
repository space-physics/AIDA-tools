function AvOk = avok_makin_movies(AvOk)
% AVOK_MAKIN_MOVIES - Makes movies of images from a night
%   

movie_type = get(AvOk.ana(2),'value'); % 1 mono, 2 r,g,b, 3 ir,g,b
movie_extn = ['mpg';
              'avi';
              'mat'];
movie_extension = movie_extn(get(AvOk.ana(3),'value'),:); % 1 mpg, 2 avi, 3 mat

figure(AvOk.fig_keo)
tax = axis;
tax = tax(1:2);

if ~isfield(AvOk,'movie_fig')
  AvOk.movie_fig = figure('name','On the "Silver screen" tonight...');
else
  set(AvOk.movie_fig,'visible','on')
  figure(AvOk.movie_fig)
end

PO % <- maaste faa en klyftigare loesning.

nrstns = unique(AvOk.Stns);
ufnr = unique([Wl_emi{:}]);

for j = 1:length(nrstns),
  
  optps = Optps{AvOk.Stns(j)};
  filenames = Filenames{AvOk.Stns(j)};% anvaend bara tider som
                                      % visas i nuvarande keo-figuren...
  
  [d,h,o(j)] = inimg(filenames(1),PO);
  imagesc(1:size(d,2),1:size(d,1),imgs_smart_caxis(.005,d)),axis xy
  title(AvOk.STNN2NAME{AvOk.Stns(j)},'fontsize',16),
  xlstr = sprintf('%s\n%s',...
                  'zoom in to select close up region in images',...
                  'within ~4 s')
  xlabel(xlstr)
  zoom on
  pause(4)
  img_regs(j,:) = axis;
  end
end
title('Adjust figure size, reasonable should be [400x400]')
xlabel('Then push any button')
pause

set(AvOk.movie_fig,'visible','off') % To free the computer screen
                                    % from being locked by getframe.
for j = 1:length(nrstns),
  
  t_obs = T_obs{AvOk.Stns(j)};
  wl_emi = Wl_emi{AvOk.Stns(j)}(min(tax)<=t_obs&t_obs<=max(tax));
  filenames = Filenames{AvOk.Stns(j)}(min(tax)<=t_obs&t_obs<=max(tax),:);
  
  switch movie_type
   case 1 % mono
    for i = 1:length(ufnr),
      if sum(wl_emi==ufnr(i))>10 % At least 10 images in at one
                                 % wavelength to bother making a
                                 % movie.
        [M] = imgs_movie_r(filenames(wl_emi==ufnr(i),:),reg_img(j,:),.001,o(j).optpar,PO);
        out_name = [AvOk.STNN2NAME{AvOk.Stns(j)},'-',...
                    datestr([AvOk.date(1:3) 0 0 0],29),'-', ...
                    num2str(ufnr(i))];
        data_out_dir = './';
        moviename = fullfile(data_out_dir,out_name,movie_extension);
        avok_savinn_movie(M,moviename,movie_extension);
      end
    end
   case 2 % r,g,b
    [M] = alis_imgs_movie_rgb(filenames,reg_img(j,:),.001,o(j).optpar,PO);
    out_name = [AvOk.STNN2NAME{AvOk.Stns(j)},'-',...
                datestr([AvOk.date(1:3) 0 0 0],29)];
    data_out_dir = './';
    moviename = fullfile(data_out_dir,out_name,movie_extension);
    avok_savinn_movie(M,moviename,movie_extension);
   case 3 % ir,g,b
    [M] = alis_imgs_movie_rgb(filenames,reg_img(j,:),.001,o(j).optpar,PO,...
                              [8446 5577 4278]);
    out_name = [AvOk.STNN2NAME{AvOk.Stns(j)},'-',...
                datestr([AvOk.date(1:3) 0 0 0],29)];
    data_out_dir = './';
    moviename = fullfile(data_out_dir,out_name,movie_extension);
    avok_savinn_movie(M,moviename,movie_extension);
   case 4 % characteristic energy according to Strickland, Hecht,
          % Meyer Christensen
    [M] = alis_imgs_movie_rgb(filenames,reg_img(j,:),.001,o(j).optpar,PO,...
                              'E0');
    out_name = [AvOk.STNN2NAME{AvOk.Stns(j)},'-',...
                datestr([AvOk.date(1:3) 0 0 0],29),'-E0'];
    data_out_dir = './';
    moviename = fullfile(data_out_dir,out_name,movie_extension);
    avok_savinn_movie(M,moviename,movie_extension);
    
   otherwise
    disp('Strange choise of image to produce.')
    disp('I''m more of a three trick pony. I can produce:')
    disp('1: narrow movies focused on a limited band')
    disp('2: Bright, Colourful Rich action movies')
    disp('3: Technicoulour giving light and vision to previously invisible')
  end
  
end

end
AvOk = avok_update_movie_menu(AvOk);


function OK = avok_savin_movie(M,moviename,movie_format)
% AVOK_SAVINN_MOVIE - saving the movie
%   

switch movie_format
 case 'mpg'
  try
    mpgwrite(M,M.colormap,moviename)
  catch
    disp(['Could not write file: ',moviename])
    disp('Write permissions?')
  end
 case 'avi'
  try
    movie2avi(M,moviename)
  catch
    disp(['Could not write file: ',moviename])
    disp('Write permissions? Enough disk space?')
  end
 case 'mat'
  try
    save(moviename,'M')
  catch
    disp(['Could not save file: ',moviename])
    disp('Write permissions? Enough disk space?')
      end
 otherwise
  disp(['Unknown file format: ',movie_extension])
end
