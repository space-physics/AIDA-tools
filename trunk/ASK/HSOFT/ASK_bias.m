function delta = ASK_bias(file)
% ASK_BIAS - returns the bias drift of of megablock, by measuring the
% difference between the average of the darks after the megablock
% and the darks before the megablock. 
% 
% Calling:
%  delta = ASK_bias(file)
% Input:
%  file - directory name of megablock of interest, for example
%         '20061022204134r1' 
% Output:
%  delta - difference, bias_after - bias_before
% 
% Written to mimmick bias.pro made by Hanna Dahlgren on 3 Feb 2011. 

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


% global hities
% global vs

% dir = vs.videodir; % TODO - find out from where to get this!

[dark1_path,dark1_name] = ASK_get_dark_name(dpath);
[dark2_path,dark2_name] = ASK_get_dark_name(dpath,'later');


ASK_read_vs([dark1_name,'.txt'],'quiet')

dark1 = zeros(256,256,640);
dd1 = zeros(640,1);
dd2 = zeros(640,1);

for i1 = 1:640,
  
  im = ASK_read_v(i1);
  dark1(:,:,i1-1) = im;
  dd1(i1-1) = mean(im(:));
  
end

ASK_read_vs([dark2_name,'.txt'],'quiet')

dark2 = zeros(256,256,640);

for i1 = 1:640,

  im = ASK_read_v(i1);
  dark2(:,:,i1) = im;
  dd2(i1) = mean(im(:));
  
end

% Discard the highest and lowest values

sorted_dark1 = sort(dd1);
sorted_dark2 = sort(dd2);

mean1 = mean(dd1(sorted_dark1(5:635)));
mean2 = mean(dd2(sorted_dark2(5:635)));

delta = mean2 - mean1;
