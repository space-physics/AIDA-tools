function [I_cuts,iPeaks] = tomo_arcpeakfinderinslice(stns,U,V,OPS)
% tomo_arcpeakfinderinslice - Finds peaks of emission along [U,V]
%  TOMO_ARCPEAKFINDERINSLICE extracts image intensities along curve
%  of image projection of plane between stations and parallell to
%  B, and finds signifficantly intensive local maxima in those.
% 
% Calling:
%   [I_cuts,iPeaks] = tomo_arcpeakfinderinslice(stns,U,V,OPS)
%   OPS = tomo_arcpeakfinderinslice
% Input:
%   stns - AIDA_tools tomo-station-struct. The two first elements
%          is used
%   U    - cell array with horizontal image coordinates of image
%          points of plane between STNS(1).r and STNS(2).r
%          (STNS(1).obs.xyz?) 
%   V    - cell array with vertical image coordinates, as above.
%   OPS  - options structure, default options is returned when
%          function is called without input arguments. Fields are:
%          OPS.iplot - [ 0 | {1} ] to plot the intensity cuts and
%                      the located maxima
%          OPS.ipng - [ {0} | 1 ] to save that plot as a png or not
%                     (default)
%          OPS.analys_dir - path to directory where png-files will
%                           be saved.
%          OPS.filterKernel - 1-D low-pass filter-kernel. Defaults
%                             to [0.25 0.72 1 1 1 0.75 0.25]/5
%          OPS.histlim      - 0.65 lower limit of intensity of
%          accepeted maxima, worked for one set of images...
%
% This is a work in process...

% Copyright Cyril Simon-Wedlund 2012

dOPS.iplot = 1;  % plots or not
dOPS.ipng = 0;   %saves png files in folder
dOPS.analys_dir = pwd;
dOPS.filterKernel = [.25 .75 1 1 1 .75 .25]/5;
dOPS.histlim = 0.65;

if nargin == 0
  I_cuts = dOPS;
  return
elseif nargin == 4
  dOPS = merge_structs(dOPS,OPS);
end


for i3 = 1:length(stns),
  % Cuts out curve in image that is in the plane between the
  % stations and is || B
  I_cuts{i3} = interp2(stns(i3).img,U{i3},V{i3});
  % Filters the cuts curve and smooths it out
  filtIntCut_stn{i3} = filtfilt(dOPS.filterKernel,1,[I_cuts{i3}]);
end

result.filtIntCut_stns = {filtIntCut_stn{1} filtIntCut_stn{2}};

for ist = 1:2,
  % find all peaks and their corresponding indices
  fc1 = result.filtIntCut_stns{ist}(1:end-2);
  fc2 = result.filtIntCut_stns{ist}(2:end-1);
  fc3 = result.filtIntCut_stns{ist}(3:end);
  % Indices to realy strict local maxima!
  result.iMax{ist} = find(fc1 < fc2 & fc2 > fc3) + 1;
  % Makes histogram of distribution of points in a certain interval
  fc = result.filtIntCut_stns{ist};
  [result.hist{ist},result.index{ist}] = hist(fc,linspace(min(fc),max(fc),101));
  
end

%percentofcdffic = interp1(hH2,cumsum(hH1)/sum(hH1),fIC1(iMax));

% Filters out the remaining minor non-significant peaks.
% here, threshold put at 62% in the normalised ratio, so that
% everything that is right off the blue peak in the middle panel
% disappears. The cumulative distribution cumsum serves as the 
% criterion. Filter is [1 1 1]/3.
% The 'unique' function to prevent that some unpopulated pixel bins
% might end up making the CDF flat making the cut-off tricky.
for ist = 1:2,
  
  cs = cumsum(result.hist{ist}); % Cumulative histogram of pixel
                                 % intensity distribution/intensity CDF
  sm = sum(result.hist{ist});    % total number of pixels?
  [Ucs,uindx] = unique(cs);      
  ind = result.index{ist};
  Uind = ind(uindx);
  % This should be a good value for intensity threshold for image
  % intensity to be considered "arc"-y in the start-guess sense.
  result.IntThresh(ist) = interp1(filtfilt([1,1,1]/3,1,Ucs/sm),Uind,dOPS.histlim);
  
end
fc = result.filtIntCut_stns{1};
ic = result.iMax{1};        
in1 = find(fc(ic) > result.IntThresh(1));
fc = result.filtIntCut_stns{2};
ic = result.iMax{2};
in2 = find(fc(ic) > result.IntThresh(2));

%% Here we have it!
result.IndexPeaks = {in1 in2};
iPeaks = {result.iMax{1}(in1),result.iMax{2}(in2)};

% Plots of the slice and the singling out of the main auroral peaks
if dOPS.iplot ==1,
  figure(2);
  
  for ist=1:2,
    subplot(3,2,ist);
    plot(I_cuts{ist},'b'); hold on;
    fc = result.filtIntCut_stns{ist};
    ic = result.iMax{ist};
    ind = result.index{ist};
    pks = result.hist{ist};
    plot(fc,'r.');
    plot(ic,fc(ic),'g*');
    ii = result.IndexPeaks{ist};  % find all peaks above threshold
    plot(ic(ii),fc(ic(ii)),'bo','MarkerFaceColor','b','MarkerSize',9); hold off;
    %plot(fIC1(iMax),percentofcdffic*256,'g*');
    subplot(3,2,ist+2);
    %            bar(peaks{ist}/max(peaks{ist})); hold on;
    stairs(ind,pks/max(pks)); hold on;
    %plot([1,257],[1.1,1.1]*min(filtIntCut_stns{ist}),'k');
    stairs(ind,cumsum(pks)/max(cumsum(pks)),'r'); hold off;
    axis([0 max(ind) 0 1 ]);
    
    subplot(3,2,ist+4);
    imagesc(stns(ist).img); hold on;
    plot(U{ist},V{ist},'k');
    plot(U{ist},V{ist},'w--'); hold off;
  end
  ha = axes('Position',[0 0 1 1],'Xlim',[0,1],'Ylim',[0 1],...
            'Box','off','Visible','off','Units','normalized',...
            'clipping','off');
  text(0.5,1,sprintf('ALIS image cuts %dA %dh%dm%ds',...
                     stns(1).obs.filter,stns(1).obs.time(4:end)),...
       'HorizontalAlignment','center',...
       'VerticalAlignment','top','FontWeight','bold');
  if dOPS.ipng == 1,
    cd(dOPS.analys_dir);
    print('-dpng',['Cuts_peaks_',sprintf('%dA_%dh%dm%ds',...
                                         stns(1).obs.filter,stns(1).obs.time(4:end)),'.png']);
  end
end

