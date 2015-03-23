function AvOk = avok_update_movie_menue(AvOk)
% AVOK_UPDATE_MOVIE_MENUE - update the view-movie-menue
%   

data_out_dir = './';
movie_extension = 'mpg'; % or avi, or mat

movies = dir([fullfile(data_out_dir,'*',datestr([AvOk.date(1:3) 0 0 0],29),'*.'),movie_extension]);

delete(AvOk.movie_menue(2:end))
AvOk.movie_menue(2:end) = [];

for i = 1:length(movies),
  
  moviename = fullfile(data_out_dir,movies(i).name);
  exec_str = ['avok_watching_movies(AvOk,',moviename,')'];
  if isreal(str2num(movies(i).name(end-7:end-4)))
    
    clrs = alis_emi2clrs(str2num(movies(i).name(end-7:end-4)));
    
  else
    
    clrs = [0 0 0];
    
  end
  AvOk.movie_menue(end+1) = uimenu(AvOk.movie_menue(1),...
                                   'Label',movies(i).name,...
                                   'ForegroundColor',clrs,...
                                   'callback',exec_str);
  
end
