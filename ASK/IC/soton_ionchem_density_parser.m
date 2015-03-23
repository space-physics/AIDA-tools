function [densities] = soton_ionchem_density_parser(filename)
% soton_ionchem_density_parser - Parses the SOTON IC *out*.dat
%  output file from the Southampton ion-chemistry-electron
%  transport model. The function returns a structure with the
%  densities saved from a model run, together with some auxiliary
%  information. 
% 
% Calling:
%   dens = soton_ionchem_density_parser(filename)
% Input;
%   filename - filename, with relative or full path to a
%              file with the emissions.dat output, long header
%              format assumed currently.
% Output
%   density - a structure with fields:
%          SourceFile: Char array with file name of input script
%         nr_profiles: Integer with number of profiles saved for
%                      each timestep 
%        profile_vars: [NR_profiles x 1] - identifier-index into
%                      reactions_vec identifying the modeled profiles
%           alt_range: [2x1 double] with the upper and lower limit for
%                      altitude range
%            nr_p_alt: Number of altitude ranges
%           nr_p_chem: number of chemical reactions 
%       reactions_vec: {[nr_p_chem x 1 ]  {nr_p_chem x 1 cell} [nr_p_chem x 1 int32]}
%                      Cell array with first cell containing the
%                      reaction ID, second cell containing the
%                      reaction-name, and third cell containing
%                      something else.
%               t_out: [1 x NR_time_steps double] array with
%                      simulation time
%                data: [nr_p_alt x nr_profiles x NR_time_steps double]
%                      3-D array with model output.

% Copyright Bjorn Gustavsson 20110128,
% % GPL version 3 or later applies.

fp = fopen(filename,'r');

if fp < 0 
  
  error(['Could not open file: ',filename])
  
end

FileType = fgets(fp);% Line with: 'IONCHEM output file'
tmp_line = fgets(fp);% Line with: 'Based on the scriptfile'
densities.SourceFile = fgets(fp);% Line with source file
densities.SourceFile = deblank(densities.SourceFile);

tmp_line = fgets(fp);% Line with number of profiles saved
nr_profiles = sscanf(tmp_line,'%f %f');
densities.nr_profiles = nr_profiles(1)+1;
profile_vars = [];
tmp_line = fgets(fp);% Line with variables per index
profile_vars = sscanf(tmp_line,'%d');
densities.profile_vars = profile_vars;

[svars,sv_indx] = sort(profile_vars);
unsrt_indx = 1:length(profile_vars);
unsrt_indx(sv_indx) = unsrt_indx;

tmp_line = fgets(fp);             % Should be number of additional
                                  % profiles?
tmpI =  sscanf(tmp_line,'%d');
if tmpI(1) > 0
  tmp_line = fgets(fp);% Line with variables per index
  profile_vars = sscanf(tmp_line,'%d');
  densities.profile_vars2 = profile_vars;
else
  densities.profile_vars2 = [];
end
tmp_line = fgets(fp);             % Should be: Altitude range, km
tmp_line = fgets(fp);             % Line with altitude range
densities.alt_range = sscanf(tmp_line,'%f');

tmp_line = fgets(fp);             % Bla-bla line
tmp_line = fgets(fp);             % Line with number of points in altitude
nr_p_alt = sscanf(tmp_line,'%f');
densities.nr_p_alt = nr_p_alt;

tmp_line = fgets(fp);% Should be: ###############
%disp('###############')
tmp_line = fgets(fp);% Should be: Species
tmp_line = fgets(fp);% Line with number of species
nr_p_spec = sscanf(tmp_line,'%f');
densities.nr_p_spec = nr_p_spec;

densities.species_vec = textscan(fp,'%d%s\n',nr_p_spec); % Cell-array with chemical reactions

tmp_line = fgets(fp); % Should be: ###############
%disp('###############')
tmp_line = fgets(fp);% Should be: Reactions
tmp_line = fgets(fp);% Line with number of reactions
nr_reactions = sscanf(tmp_line,'%d');

for i1 = 1:nr_reactions,
  tmp_line = fgets(fp);
end
tmp_line = fgets(fp);% Should be:  ###############
tmp_line = fgets(fp);% Should be:  Production/loss balance

for i1 = 1:densities.nr_p_spec,
  tmp_line = fgets(fp);% Should be: Species name
  tmp_line = fgets(fp);% Should be: sources #NR
  [qwe,nr_sources] = strtok(tmp_line);
  nr_sources = str2num(nr_sources);
  tmp_line = fgets(fp);% Should be: losses  #NR
  [qwe,nr_losses] = strtok(tmp_line);
  nr_losses = str2num(nr_losses);
  for i2 = 1:(nr_sources+nr_losses)
    tmp_line = fgets(fp);
  end
end
tmp_line = fgets(fp); % Should be ###############

i0 = 0;
indx_t = 1;
tmp_line = fgets(fp); % Should be first time step.
densities.t_out(indx_t) = str2num(tmp_line);
while ~feof(fp)
  
  densities.t_out(indx_t) = str2num(tmp_line);
  tmp_line = fgets(fp);  % should be profile-lable-line
  %profiles = fscanf(fp,'%f ',[nr_p_alt,nr_profiles])
  densities.data(:,:,indx_t) = fscanf(fp,'%f ',[densities.nr_profiles,nr_p_alt])';
  tmp_line = fgets(fp);  % should be something like the
                         % profile-lable-line for the profile-2-lable-line
  densities.data2(:,:,indx_t) = fscanf(fp,'%f ',[length(densities.profile_vars2)+1,nr_p_alt])';
  %plot(densities.data(:,2,indx_t),densities.data(:,1,indx_t),'color',rand(1,3))
  %hold on
  %drawnow
  tmp_line = fgets(fp);% Should be: next time step
  i0 = i0+1;
  indx_t = indx_t + 1;
  %disp(['i0 = ',sprintf('%d',i0)])
  
end
fclose(fp);

%keyboard
