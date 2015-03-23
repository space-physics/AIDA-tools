% Scaffolding/pattern for plotting density outputs from the
% Southampton ion chemistry model.

for i1 = 1:9,
  subplot(3,3,i1)
  pcolor(densities.t_out,squeeze(densities.data(:,1,1))/1e5,squeeze(densities.data(:,i1+1,:))),shading flat
  title(densities.species_vec{2}{densities.profile_vars(i1)},'fontsize',16)
  colorbar_labeled('/m^3')
end
