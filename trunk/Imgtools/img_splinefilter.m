function [varargout] = img_splinefilter(img_in,OPS)
% IMG_SPLINEFILTER - spline fitting optimum statistical filter
%  IMG_SPLINEFILTER is a filter based on 2-dimensional least square
%  fitting splines. A sequence of 2-D splines with increasing
%  number of node-points is fitted to the input matrix IMG_IN,
%  for which the statistical characteristics the noise is supposed
%  to be known; the known distribution of the noise is used to
%  calculate statistical measures of the fits (standard deviation
%  ofthe scaled residuals, Akaike Information Criterion,
%  sum-of-squares between the distribution of residuals and the
%  expected residual distribution), the 
%
%   [varargout] = img_splinefilter(img_in,OPS)
% Calling:
%   [Img,Imgs,Measures,BestIndxs] = img_splinefilter(img_in,OPS);
%   OPS = img_splinefilter
% Input:
%   img_in - double array with input image to filter
%   OPS    - optional struct with parameters to control filtering
% Output:
%   Img       - average of the images of the best values of the
%               different statistical measures
%   Imgs      - images 
%   Measures  - statistical measures [4 x (MaxKnots-MinKnots+1)]
%               with standar deviation of the scaled residuals on
%               the first row, sum-of-squares of the difference
%               between the scaled residual distribution and the
%               expected on row 2, sum-of-squares of the difference
%               between the scaled residual distribution and the
%               expected excluding the first and last bin  on row
%               3, and the Akaike Information Criteria on row 4.
%   BestIndxs - 
%   OPS       - Optional structure with parameters controling the
%               filtering, default options returned when function
%               called without input arguments. The fields are: 
%               Order [3], integer for spline order (3 - cubic splines)
%               MaxKnots [21], maximum number of node points in
%                        vertical and horizontal dimension 
%               MinKnots [2], minimum number of node points in
%                        vertical and horizontal dimension
%               NoisePdfF [@normcdf], cumulative distribution function of
%                        noise statistics, defaults to normal
%                        distributed noise.
%               NoisePdfExtraArgs [{}]; if there should be extra arguments to
%                        the NoisePdfF function, here is the
%                        cell array to put them into.
%               NoiseRange [-3 3] Range of noise to calculate the
%                        distribution of the pixel noise
%               nrNR [101], number of bins to calculate the
%                        residual histogram in
%               NoiseScaleFcn [@(I,Is) (I-Is)./Is.^.5], Function to scale
%                        the noise with, this example assumes that
%                        the noise in I is N(Is,sqrt(Is))
%               display [0|{1}|2], whether to display the filtering or not
%               pause [1], how long to pause during displaying, -1
%                        disables pausing 
%               medianFilter [3], reg-size to use for prefiltering image
%                        to fit the 2-D splines to, sometimes
%                        preferable (when there is spiky noise),
%                        statistics or residuals is calculated with
%                        input image
% 
% Example:
%  Img_in = (9+peaks(234))*100;             
%  Img_in = Img_in + Img_in.^.5.*randn(size(Img_in));
%  OPS = img_splinefilter;
%  OPS.pause = 0.25;  
%  OPS.MaxKnots = 41;                   
%  clf                             
%  [Img_out,Imgs_out,Measures,bestIdxs] = img_splinefilter(Img_in,OPS);

%   Copyright © 20110105 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%% 1 Make the default options:
dOPS.Order = 3;             % Spline order (3 - cubic splines)
dOPS.MaxKnots = 21;         % Maximum number of node points in
                            % vertical and horizontal dimension
dOPS.MinKnots = 2;          % Minimum number of node points in
                            % vertical and horizontal dimension
dOPS.NoisePdfF = @normcdf;  % Cumulative distribution function of
                            % noise statistics, defaults to normal
                            % distributed noise.
dOPS.NoisePdfExtraArgs = {};% If there should be extra arguments to
                            % the NoisePdfF function, here is the
                            % cell array to put it into.
dOPS.NoiseRange = [-3 3];   % Range of noise to calculate the
                            % distribution of the pixel noise
dOPS.nrNR = 101;            % Number of bins to calculate the
                            % histogram in
dOPS.NoiseScaleFcn = @(I,Is) (I-Is)./Is.^.5; % Function to scale
                                             % the noise with, this
                                             % example assumes that
                                             % the noise in I is N(Is,sqrt(Is))
dOPS.display = 1;  % Whether to display the filtering or not
dOPS.pause = 1;    % How long to pause during displaing, -1 disables
dOPS.medianFilter = 3;    % reg-size to use for prefiltering image
                          % to fit the 2-D splines to

%% 2 merge user-supplied options ontop of defaults:
if nargin == 0
  varargout{1} = dOPS;
  return
elseif nargin > 1
  dOPS = merge_structs(dOPS,OPS);
end

%% 3 Extract parameters
order = dOPS.Order;
max_knts = dOPS.MaxKnots;
min_knts = dOPS.MinKnots;
NoiseScaleFcn = dOPS.NoiseScaleFcn;
NoisePdfF = dOPS.NoisePdfF;

%% 4 Allocate big numbers to the statistical measures:
stdI = inf*ones(1,max_knts);
nfit = stdI;
nfit2 = stdI;
AIC = stdI;

%% 5 set-up of additional parameters for the statistical measures:
% coordinates for the scaled residuals (normal-distributed noise
% statistics are scaled to become N(0,1) so typical values of
% NoiseRange is something like +/-3)
x = linspace(dOPS.NoiseRange(1),dOPS.NoiseRange(2),dOPS.nrNR);
x = [-inf,x,inf];
hI = zeros(max_knts,length(x));
eDfit = hI(:,1:end-1);
%% 6 build the proper noise-distribution
if isempty(dOPS.NoisePdfExtraArgs)
  % In case it is simple
  nc01 = NoisePdfF(x);
else
  % or needs extra arguments:
  nc01 = NoisePdfF(x,dOPS.NoisePdfExtraArgs{:});
end
% Convert the cumulative distribution values to probability
% densities:
n01 = diff(nc01);

%% 7 In case pre-filtering with median-filter is requested
if dOPS.medianFilter > 0,
  img2fit = medfilt2(img_in,[1,1].*dOPS.medianFilter);
else
  img2fit = img_in;
end
sz = size(img_in);

%% 8 Setup for displaying:
if dOPS.display == 1
  phImgIn = subplot(2,3,1);
  imagesc(img_in)
  title('Img_{in}')
  cx = imgs_smart_caxis(0.003,img_in(:));
elseif dOPS.display == 2
  % This variant seems a bit iffy when it comes to not crashing
  % indx2plot = round(linspace(max(10,min_knts),max_knts-8,5));
  % while this might be more robust...
  indx2plot = round(linspace(min_knts,max_knts,5));
  spp_org = [2,1,1;4,5,11;4,5,12;4,5,13;4,5,14;4,5,15;5,1,4;5,1,5];
  for i1 = 1:(length(spp_org)-2),
    sph(i1) = subplot(spp_org(i1,1),spp_org(i1,2),spp_org(i1,3));
    axP{i1} = get(sph(i1),'position');
  end
  dx = axP{i1}(1) - (axP{i1-1}(1)+axP{i1-1}(3));
  for i1 = 2:length(spp_org)-2,
    set(sph(i1),'position',axP{i1}+[-(i1-2)/5*dx,axP{1}(2)-(axP{i1}(2)+axP{i1}(4)),4/5*dx,0])
    axP{i1} = get(sph(i1),'position');
  end
  axes(sph(1))
  imagesc(img_in),set(gca,'xticklabel','')
  cx = imgs_smart_caxis(0.003,img_in(:));
  cblh = colorbar_labeled('Counts','linear','fontsize',12);
  cblP = get(cblh,'position');
  %set(cblh,'position',[cblP(1)-0.01,axP{6}(2),cblP(3)+0.0,cblP(2)+cblP(4)-axP{6}(2)])
  set(cblh,'position',cblP+[-0.01,0,0,0])
  for i1 = (length(spp_org)-1):length(spp_org),
    sph(i1) = subplot(spp_org(i1,1),spp_org(i1,2),spp_org(i1,3));
    axP{i1} = get(sph(i1),'position');
  end
  dy = axP{end-2}(2) - (axP{end-1}(2)+axP{end-1}(4));
  set(sph(end-1),'position',axP{end-1}+[0,0,0,dy])
  dy = axP{end-1}(2) - (axP{end}(2)+axP{end}(4));
  set(sph(end),'position',axP{end}+[0,0,0,dy])
  
end

%% 9 actual filtering sequence
for i1 = min_knts:max_knts,
  % i1-length knot-point sequence
  knts = augknt(linspace(1,sz(1),i1),order);
  % Least square spline approximant:
  sI(i1) = spap2({knts,knts},[1,1]*order,{1:sz(1),1:sz(2)},img2fit);
  % with the corresponding least square spline approximation image
  Is = fnval(sI(i1),{1:sz(1),1:sz(2)});
  
  % Calculate histogram of the scaled residual:
  hI(i1,:) = histc(NoiseScaleFcn(img_in(:),max(1,Is(:))),x);
  % Calculate the sum-of-squares between the "residual histogram"
  % and a normal-distributed pdf:
  nfit(i1) = sum((hI(i1,1:end-1)/sum(hI(i1,:))-n01).^2);
  nfit2(i1) = sum((hI(i1,2:end-2)/sum(hI(i1,2:end-2))-n01(2:end-1)).^2);
  % Calculate the standard deviation of the scaled residual:
  stdI(i1) = std(NoiseScaleFcn(img_in(:),max(1,Is(:))));
  % Calculate the Akaike Information Criteria:
  AIC(i1) = (sum(NoiseScaleFcn(img_in(:),max(1,Is(:))).^2)) + ...
            (prod(sz)+length(knts)^2)/(prod(sz)-length(knts)^2-2);
  %  BIC(i1) = Do the same with the Bayesian information criteria
  BIC(i1) = (sum(NoiseScaleFcn(img_in(:),max(1,Is(:))).^2)) + ...
            (length(knts)^2)*log(prod(sz));
  
  % Save away the difference between the histogram and the
  % normal-pdf:
  eDfit(i1,:) = hI(i1,1:end-1)/sum(hI(i1,1:end-1))-n01;
  %Idiff(i1) = mean((I(:)-Is(:)).^2);
  
  
  % For displaying the current lsqfs-filtered image:
  if dOPS.display == 1
    subplot(2,3,3)
    imagesc(Is),caxis(cx)
    hold on
    % with the corresponding node points:
    if i1 < 20
      [Kntx,Knty] = meshgrid(knts,knts);
      plot(Kntx,Knty,'k+')
    end
    hold off
    title('Img_N')
    
    subplot(2,3,2)
    imagesc(img_in - Is),imgs_smart_caxis(0.005,img_in - Is)
    title('Scaled Img_{in}-Img_N')
    
    subplot(2,1,2)
    ph = stairs(x,hI(i1,:)/sum(hI(i1,:)),'r','linewidth',3);
    hold on,
    plot(x(2:end-1),n01(2:end),'b','linewidth',3),
    title(num2str([i1, stdI(i1), nfit(i1)]))
    axis([x([2,end-1]) 0 1.2*max(n01(2:end))])
    drawnow
    if dOPS.pause > 0 && i1 > min_knts
      pause(dOPS.pause)
    elseif dOPS.pause == 0 || i1 == min_knts
      disp('push any key')
      pause
    end
    set(ph,'color','k','linewidth',1),
  elseif dOPS.display == 2 && any(i1==indx2plot)
    i2p = 1+ find(i1==indx2plot);
    axes(sph(i2p))
    imagesc(Is),caxis(cx),
    if i2p > 2
      set(gca,'xticklabel','','yticklabel','')
    else
      set(gca,'xticklabel','')
    end
    text(10,30,num2str(i1),'fontweight','bold')
  end
end

if dOPS.display == 1
  subplot(2,2,4)
  imagesc(1:size(eDfit,1),x(2:end-1),eDfit'),caxis([-1 1]/200)
  ylabel('Residual','fontsize',14)
  xlabel('# knot-points per dimension','fontsize',14)
  title('Residual distribution error','fontsize',14)
  colorbar_labeled('','linear','fontsize',12)
  subplot(2,2,3)
  hold off
  
  
  ph = semilogy(min_knts:max_knts,0.0001+[abs(stdI(min_knts:end)-1);
                      400*(nfit(min_knts:end)-min(nfit(min_knts:end)));
                      (AIC(min_knts:end)-min(AIC(min_knts:end)));
                      (BIC(min_knts:end)-min(BIC(min_knts:end)));
                      400*(nfit2(min_knts:end)-min(nfit2(min_knts:end)))],'.-');
  axis tight
  title('Fit-measures','fontsize',14)
  xlabel('# knot-points per dimension','fontsize',14)
  set(gca,'ytick',[1e-4 1e-2 1e0])
  legend(ph,'abs(std-1)','pdf-diff','AIC','BIC','pdf-fit2')
  
elseif dOPS.display == 2
  
  
  axes(sph(end))
  ph = semilogy(min_knts:max_knts,0.0001+[abs(stdI(min_knts:end)-1);
                      400*(nfit(min_knts:end)-min(nfit(min_knts:end)));
                      (AIC(min_knts:end)-min(AIC(min_knts:end)));
                      400*(nfit2(min_knts:end)-min(nfit2(min_knts:end)))],'.-');
  axis tight
  ylabel('Fit-measures','fontsize',14)
  xlabel('# knot-points per dimension','fontsize',14)
  set(gca,'ytick',[1e-4 1e-2 1e0])
  legend(ph,'abs(std-1)','pdf-diff','AIC','pdf-fit2')
  
  axes(sph(end-1))
  imagesc(1:size(eDfit,1),x(2:end-1),eDfit'),caxis([-1 1]/200)
  ylabel('Residual','fontsize',14)
  %xlabel('# knot-points per dimension','fontsize',14)
  %title('Residual distribution error','fontsize',14)
  set(gca,'xticklabel','')
  colorbar_labeled('\Delta # pixels','linear','fontsize',12)
  
end
[sNfit,isNfit] = sort(nfit(min_knts:end));
[sNfit2,isNfit2] = sort(nfit2(min_knts:end));
[sStdI,isStdI] = sort(abs(stdI(min_knts:end)-1));
[sAIC,isAIC] = sort(AIC(min_knts:end));
[sBIC,isBIC] = sort(BIC(min_knts:end));
if nargout == 0
  disp([isNfit(1:5)+min_knts-1;sNfit(1:5);stdI(isNfit(1:5)+min_knts-1)])
  disp([isStdI(1:5)+min_knts-1;sNfit(isStdI(1:5)+min_knts-1);stdI(isStdI(1:5)+min_knts-1)])
  disp([isAIC(1:5)+min_knts-1;sAIC(1:5)])
else
  
  Measures = [stdI(min_knts:end);nfit(min_knts:end);nfit2(min_knts:end);AIC(min_knts:end)];
  
  BestIndxs = [isNfit(1),isNfit2(1),isStdI(1),isAIC(1),isBIC(1)];
  Img = 0;
  for i1 = 1:length(BestIndxs),
    Imgs{i1} = fnval(sI(BestIndxs(i1)+min_knts-1),{1:sz(1),1:sz(2)});
    Img = Img+Imgs{i1}/length(BestIndxs);
  end
  varargout{1} = Img;
  varargout{2} = Imgs;
  varargout{3} = Measures;
  varargout{4} = BestIndxs;
  if dOPS.display == 1
    subplot(2,3,3)
    imagesc(Img)
    caxis(cx)
  end
  
end
    
