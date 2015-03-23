%% Set up script for producing the excitation profile matrices
% 
% The production profiles are fairly simple to get from
% ion-chemistry output files. 
% ## identify the setup-files on lora.
% ## make a function extracting the relevant production profile
%    matrices 
% A1 & A2 - ganska enkelt, bara en fraaga om skalning.
% E enkelt!
% Laes ihop fraan /stp/raid2/ion_chem/20110808001547 eller
% Modeling4Excitation-profiles-2006121502
% Now saved in Excitation-profiles-20061215.mat E z_trans A_O2p1stNeg A_O7774

% load Excitation-profiles-20061215.mat E z_trans A_O2p1stNeg A_O7774
load Excitation-profiles-20120124.mat E z_trans a_N26730 a_O7774
C_filter7774 = 0.7;
C_filter6370 = 0.76;
C_filter5620 = 0.0633;
A1Z = interp1(z_trans(2:end)/1e5, C_filter6370*a_N26730, squeeze(ZfI(1,1,:)));
A2Z = interp1(z_trans(2:end)/1e5, C_filter7774*a_O7774,  squeeze(ZfI(1,1,:)));
A1Z(~isfinite(A1Z)) = 0;
A2Z(~isfinite(A2Z)) = 0;
