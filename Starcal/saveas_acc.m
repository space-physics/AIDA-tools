function saveok = saveas_acc(optpar,tvec,name,stnnr,az,ze,om)
% SAVEAS_ACC - function to save optical parameters
% in an improved format. 
%   
% Calling:
% saveok = saveas_acc(optpar,tvec,name,stnnr,az,ze,om)


%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if om < 0
  name = [name,'.mat'];
  disp(['Non-parametric optical parameters for ',num2str(tvec,'%4d%02d%02d-%02d:%02d:%02d')])
  disp(optpar)
  disp(['Is beeing saved in: ',name])
  save(name,'optpar')
else
  accvec = [stnnr, az, ze, date2juldate(tvec(1:3)-[0 4 0]) ...
            date2juldate(tvec(1:3)+[0 6 0]) om optpar 0];
  
  disp(accvec)
  disp(['Is beeing saved in: ',name])
  save(name,'accvec','-ascii')
  
end
saveok = 1;
