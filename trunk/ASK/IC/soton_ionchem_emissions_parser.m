function [emissions] = soton_ionchem_emissions_parser(filename)
% soton_ionchem_emissions_parser - Parses the emission.dat output
%  file from the Southampton ion-chemistry-electron transport
%  model. The function returns a structure with the emissions saved
%  from a model run, together with some auxiliary information.
% 
% Calling:
%   emissions = soton_ionchem_emissions_parser(filename)
% Input;
%   filename - filename, with relative or full path to a
%              file with the emissions.dat output, long header
%              format assumed currently.
% Output
%   emissions - a structure with fields:
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

FileType = fgets(fp);% Line with information on what is in file.
tmp_line = fgets(fp);% 
emissions.SourceFile = fgets(fp);% Line with source file

tmp_line = fgets(fp);% Line with number of profiles saved
nr_profiles = sscanf(tmp_line,'%f')+1;
emissions.nr_profiles = nr_profiles;
profile_vars = [];
for i1 = 1:length(nr_profiles)
  tmp_line = fgets(fp);% Line with variables per index
  tmpprofile_vars = sscanf(tmp_line,'%d');
  profile_vars = [profile_vars,tmpprofile_vars];
end
emissions.profile_vars = profile_vars;

[svars,sv_indx] = sort(profile_vars);
unsrt_indx = 1:length(profile_vars);
unsrt_indx(sv_indx) = unsrt_indx;

tmp_line = fgets(fp);             % Should be: Altitude range, km
tmp_line = fgets(fp);             % Line with altitude range
emissions.alt_range = sscanf(tmp_line,'%f');

tmp_line = fgets(fp);             % Bla-bla line
tmp_line = fgets(fp);             % Line with number of points in altitude
nr_p_alt = sscanf(tmp_line,'%f');
emissions.nr_p_alt = nr_p_alt;

tmp_line = fgets(fp);% Should be: ###############
%disp('###############')
tmp_line = fgets(fp);% Should be: Reactions
tmp_line = fgets(fp);% Line with number of reactions
nr_p_chem = sscanf(tmp_line,'%f');
emissions.nr_p_chem = nr_p_chem;

emissions.reactions_vec = textscan(fp,'%d%s%d\n',nr_p_chem); % Cell-array with chemical reactions

tmp_line = fgets(fp); % Should be: ###############
%disp('###############')

tmp_line = fgets(fp);% Should be: first time step


i0 = 0;
indx_t = 1;
while ~feof(fp)
  
  emissions.t_out(indx_t) = str2num(tmp_line);
  %disp(emissions.t_out(indx_t))
  %profiles = fscanf(fp,'%f ',[nr_p_alt,nr_profiles])
  emissions.data(:,:,indx_t) = fscanf(fp,'%f ',[nr_profiles,nr_p_alt])';
  %plot(emissions.data(:,2,indx_t),emissions.data(:,1,indx_t),'color',rand(1,3))
  %hold on
  %drawnow
  tmp_line = fgets(fp);% Should be: next time step
  i0 = i0+1;
  indx_t = indx_t + 1;
  %disp(['i0 = ',sprintf('%d',i0)])
  
end
fclose(fp);

%keyboard
