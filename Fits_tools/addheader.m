function out_header = addheader(in_header,add_str)
% ADDDHEADER - function to add header entry to fits header.
%
% Calling:
% function out_header = addheader(in_header,add_str)
% 
% Input:
%         IN_HEADER - string matrix with 80 characters
%         per line.
%         ADD_STR - string with at the most 80 characters,
%         the 10 first making up the new keyword.
% WARNING: Looks dubious!

%   Copyright � 19980525 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

out_header = in_header;

if ( length(add_str)<81)
  
  % out_header = str2mat(out_header(1:end-1,:),add_str);
  % out_header = str2mat(out_header,'END');
  out_header = char(out_header(1:end-1,:),add_str);
  out_header = char(out_header,'END');
  
else
  
  %err_msg = sprintf('\n   keyworld too long:\n   %s\n   Its length is %d and the limit is 80 characters',add_str,length(add_str));
  %error(err_msg);
  error('\n   keyworld too long:\n   %s\n   Its length is %d and the limit is 80 characters',add_str,length(add_str));
  
end
