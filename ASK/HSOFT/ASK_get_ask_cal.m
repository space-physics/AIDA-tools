function retval = ASK_get_ask_cal(mjs,cam)
% ASK_GET_ASK_CAL - get  absolute intensity calibration factors 
% for the ASK cameras. They come from the ask.lut lookup table.
% 
% Calling:
%   CalFactor = ASK_get_ask_cal(mjs,cam)
% Inputs:
%   mjs - The time in mjs
%   cam - The camera(s) wanted. This can be a single value (e.g. 2 for ASK2)
%         or an array, e.g. [1,2,3] for all cameras. In this case an array
%         to match cam is returned.
% Output:
%   CalFactor - calibration factor(s)

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global asklut

% [start_indx,stop_indx] = ASK_locate_int(asklut.ask_t1,asklut.ask_t2,mjs,mjs);
[start_indx] = ASK_locate_int(asklut.ask_t1,asklut.ask_t2,mjs,mjs);

retval = asklut.ask_cal(cam,start_indx);

for i1 = 1:length(cam),
  
  if retval(i1) == 0
    disp(['WARNING!! Data is not intensity calibrated for ASK',sprintf('%d',cam),': ' num2str(asklut.ask_t1(start_indx)),' - ',num2str(asklut.ask_t2(start_indx))])
    retval(i1) = 1;
  end
  
end
