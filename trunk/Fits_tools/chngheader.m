function out_header = chngheader(in_header,key,new)
% CHNGHEADER - function to change header entry in fits header.
%
% Calling:
% out_header = chngheader(in_header,key,new)
% 
%         IN_HEADER - string matrix with 80 characters
%         per line.
%         KEY - string with at the most 10 characters,
%         giving the keyword.
%         NEW the new value for the keyword.


%   Copyright � 19980525 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


out_header = in_header;

for i1 = size(in_header,1):-1:1,
  
  qw(i1) = strncmp(in_header(i1,1:8),key,length(key));
  
end

if ( sum(qw) == 0 )
  
  if ischar(new)
    addstr = sprintf('%8s= ''%s''',key,new);
  elseif ( fix(new) == new)
    addstr = sprintf('%8s=               %d',key,new);
  else
    addstr = sprintf('%8s=               %f',key,new);
  end
  out_header = addheader(in_header,addstr);
  
elseif ( sum(qw) > 1 )
  
  errmsg = sprintf('Ambiguos key: %s, at least %d matches',key,sum(qw));
  err_id = 'Fits:chngheader:Ambigous key ';
  error([err_id,errmsg])
  
else
  
  indx = find(qw);
  
  if ischar(new)
    addstr = sprintf('%8s= ''%s''',key,new);
  else
    addstr = sprintf('%8s=               %d',key,new);
  end
  if ( length(addstr)<80)
    
    % out_header = str2mat(in_header(1:indx-1,:),addstr);
    % out_header = str2mat(out_header,in_header(indx+1:end,:));
    out_header = char(in_header(1:indx-1,:),addstr);
    out_header = char(out_header,in_header(indx+1:end,:));
    
  else
    
    %err_msg = sprintf('\n   keyworld too long:\n %s\n   Its length is %d and the limit is 80 characters',add_str,length(add_str));
    %error(err_msg);
    error('\n   keyworld too long:\n %s\n   Its length is %d and the limit is 80 characters',add_str,length(add_str));
    
  end
  
end
