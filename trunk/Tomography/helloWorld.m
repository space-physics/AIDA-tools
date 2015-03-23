function Txt = helloWorld(varargin)
% helloWorld - a function to be guaranteedly completely bug-free!
%  Displays a cheerful message if called with no input arguments
%  and a cheerful and soothing message if called with input
%  arguments 
% 
% Calling:
%   Txt = helloWorld(varagin)
% Input:
%   Anything in any numbe4r of arguments.
% Output:
%   Txt - cheerful or reassuring text string.

%   Copyright � 20120330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

txt = ('Hello world!');
if nargin > 0
  txt = char(txt,'Don''t panic');
end
disp(txt)
if nargout
  Txt = txt;
end
