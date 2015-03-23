function alis_avok_exportvars(AvOk)
% ALIS_AVOK_EXPORTVARS - export overview variables to matlab workspace
%   


AvOk.exp_var_indx = [get(AvOk.exportvars,'value')];AvOk.exp_var_indx = find([AvOk.exp_var_indx{:}]);
for jj = 1:length(unique(AvOk.Stns));
  
  AvOk.ass_str{1} = ['filenames_',AvOk.STNN2NAME{AvOk.Stns(jj)},' = ','AvOk.Files{AvOk.Stns(',num2str(jj),')};'];
  AvOk.ass_str{2} = [   'wl_emi_',AvOk.STNN2NAME{AvOk.Stns(jj)},' = ','AvOk.Wl_emi{AvOk.Stns(',num2str(jj),')};'];
  AvOk.ass_str{3} = [    't_obs_',AvOk.STNN2NAME{AvOk.Stns(jj)},' = ','AvOk.T_obs{AvOk.Stns(',num2str(jj),')};'];
  AvOk.ass_str{4} = [     'optp_',AvOk.STNN2NAME{AvOk.Stns(jj)},' = ','AvOk.Optps{AvOk.Stns(',num2str(jj),')};'];
  AvOk.ass_str{5} = [      'keo_',AvOk.STNN2NAME{AvOk.Stns(jj)},' = ','AvOk.Keo{AvOk.Stns(',num2str(jj),')};'];
  
  for ii = AvOk.exp_var_indx,
    
    evalin('base',deblank(AvOk.ass_str{ii}))
    disp(deblank(AvOk.ass_str{ii}))
    
  end
  
end
