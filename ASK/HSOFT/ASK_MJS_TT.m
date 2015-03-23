function varargout = ASK_MJS_TT(MJS)
% ASK_MJS_TT - convert modified Julian second to calender date
%
% Calling:
%  [DateVec] = ASK_MJS_TT(MJS)
%  [year,month,day,hour,minute,sec] = ASK_MJS_TT(MJS)
% Input
%  MJS - modified Julian seconds (since 1950/1/1 00:00:00.00)
% Output:
%  DateVec - array with columns for year, month, day, hour, minute,
%            second
%

% Modified from MJS_TT.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

% Let the date-functions of matlab do the heavy lifting:
dateVec = datevec(MJS/24/3600+datenum([1950 1 1]));

% This should split up dateVec into one output array for the YYYY,
% MM, DD... (as per requested) even if function is called with
% multiple MJS-times.
if nargout > 1
  if size(dateVec,1) > 1
    for i1 = 1:nargout
      varargout{i1} = dateVec(:,i1);
    end
  else
    varargout = num2cell(dateVec(1:nargout));
  end
else
  varargout{1} = dateVec;
end
