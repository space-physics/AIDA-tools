function [varargout] = img_svdfilter(img_in,OPS)
% IMG_SVDFILTER - SVD fitting filter optimum statistical filter
% IMG_SVDFILTER - does a singular value decomposition of the input
%   image, and then tests a sequence of SVD-approximation, with
%   varying number of singular values (and corresponding
%   base-vectors) included in the approximations. Four/three
%   statistics of each approximation if calculated (Chi-2, Akaike
%   information criterion, and square-of-residual-between-expected-
%   and-approximate-distribution-of-residuals)
%   
% Calling:
%   [Img,Imgs,Measures,BestIndxs] = img_svdfilter(img_in,OPS)
%   OPS = img_splinefilter
% Input:
%   img_in - image to filter, double [N x M].
%   OPS    - options struct (optional), without this input
%            default values is used. Fields that are used is:
%             NoisePdfF (@normcdf) Cumulative distribution function
%                       of noise statistics, defaults to normal
%                       distributed noise.
%             NoisePdfExtraArgs ({}) If there should be extra
%                       arguments to the NoisePdfF function, here
%                       is the cell array to put it into.
%             NoiseRange ([-3 3]) Range of noise to calculate the 
%                       distribution of the pixel noise
%             nrBins (101) Number of bins to calculate the
%                       histogram in 
%             NoiseScaleFcn (@(I,Is) (I-Is)./Is.^.5) Function to
%                       scale the noise with, this example assumes
%                       that the noise in I is N(Is,sqrt(Is))
%             min_nSval (1) Lowest number of singular values to
%                       test for filtered image
%             max_nSval (256) Lowest number of singular values to
%                       test for filtered image
%             medianFilter (3) reg-size to use for prefiltering
%                       image before the singular value
%                       decomposition
%             display (0) Whether to display (1) the filtering or not,
%                       2 shows filtered images at 5 number of
%                       singular values between min and max number,
%                       0 disables.
%             pause (1) How long to pause during displaing, -1
%                       disables 
% Output:
%   Img       - Output image [N x M], average of the SVD-approximated
%               images with the lowest measures (abs(chi^2-1), AIC,
%               and sum of the square of the difference between the
%               theoretical and empirical noise distribution
%               functions) 
%   Imgs      - Cell array with the 4 images with the best
%               measures. 
%   Measures  - Array with measures of the fit [4 x number-of-svds-tested]
%   BestIndxs - Array [4 x 1] with number of SVD-components with
%               the best measures.
% Example:
%   d = (peaks(256)+10)*100;
%   d = d + 30.*randn(size(d));
%   OPS4svdf = img_svdfilter
%   OPS4svdf.NoiseScaleFcn = @(I,Is)(I-Is)/30;
%   OPS4svdf.display = 2;
%   [D,d_Imgs,Measures,BestIndxs] = img_svdfilter(d,oSVDF);
%   
% The premise of this filter is that the image is made from an
% ideal signal plus a stochastical noise with a known distribution
% that can be transformed to a normal distribution; then the
% image we search for with the filtering should "work" as an image
% from which the observed image is a plausible stochastical draw. 

%   Copyright � 20110105 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%function [Imgs,Measures] = lsqfs_filter(img_in,Order,MaxKnots,noise_pdfF)

% 1 Make the default options:
dOPS.NoisePdfF = @normcdf;  % Cumulative distribution function of
                            % noise statistics, defaults to normal
                            % distributed noise.
dOPS.NoisePdfExtraArgs = {};% If there should be extra arguments to
                            % the NoisePdfF function, here is the
                            % cell array to put it into.
dOPS.NoiseRange = [-3 3];   % Range of noise to calculate the
                            % distribution of the pixel noise
dOPS.nrBins = 101;          % Number of bins to calculate the
                            % histogram in
dOPS.NoiseScaleFcn = @(I,Is) (I-Is)./Is.^.5; % Function to scale
                                             % the noise with, this
                                             % example assumes that
                                             % the noise in I is N(Is,sqrt(Is))
dOPS.min_nSval = 1;  % Lowest number of singular values to test for
                    % filtered image
dOPS.max_nSval = 256;  % Lowest number of singular values to test for
                       % filtered image
dOPS.display = 0;  % Whether to display the filtering or not
dOPS.pause = 1;    % How long to pause during displaing, -1 disables
dOPS.medianFilter = 3;    % reg-size to use for prefiltering image
                          % to fit the 2-D splines to

% If no input arguments...
if nargin == 0
  % ...simply retrurn the default options:
  varargout{1} = dOPS;
  return
elseif nargin > 1
  % If opstions struct in input arguments merge those ontop of the
  % default ones
  dOPS = merge_structs(dOPS,OPS);
end

if dOPS.medianFilter > 0,
  img2fit = medfilt2(img_in,[1,1].*dOPS.medianFilter);
else
  img2fit = img_in;
end
% Do the singular value decomposition of the image:
[U,S,V] = svd(img2fit);
% Make sure that the maximum number of singular values is not
% larger than the number of singular values.
max_nSval = min(min(size(S)),dOPS.max_nSval);
min_nSval = dOPS.min_nSval;

% Get the functions describing the statistical characteristics of
% the image noise:
NoiseScaleFcn = dOPS.NoiseScaleFcn;
NoisePdfF = dOPS.NoisePdfF;

% Pre-allocate space for the fitting measures:
stdI = inf*ones(1,max_nSval);
nfit = stdI;
nfit2 = stdI;
AIC = stdI;

sz = size(img_in);

% Set-up for plotting of the itterations:
if dOPS.display == 1
  phImgIn = subplot(2,3,1);
  imagesc(img_in)
  cx = imgs_smart_caxis(0.003,img_in(:));
elseif dOPS.display == 2
  indx2plot = round(linspace(max(1,min_nSval),max_nSval,5));
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
% Spacing of the bins for making the histograms of the scaled
% residuals:
x = linspace(dOPS.NoiseRange(1),dOPS.NoiseRange(2),dOPS.nrBins);
x = [-inf,x,inf];
hI = zeros(max_nSval,length(x));
eDfit = hI(:,1:end-1); % Error of the Distribution FIT (eDfit)
                       % Should rather have been residual 

if isempty(dOPS.NoisePdfExtraArgs)
  nc01 = NoisePdfF(x);
else
  nc01 = NoisePdfF(x,dOPS.NoisePdfExtraArgs{:});
end
n01 = diff(nc01);

for i1 = min_nSval:max_nSval,
  % The SVD-approximation of the input image with i1 number of
  % singular values used:
  Is = U(:,1:i1)*S(1:i1,1:i1)*V(:,1:i1)';
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
            (prod(sz)+i1)/(prod(sz)-i1-2);
  %  BIC(i1) = Do the same with the Bayesian information criteria
  
  % Save away the difference between the histogram and the
  % expected distribution (default: normal-pdf):
  eDfit(i1,:) = hI(i1,1:end-1)/sum(hI(i1,1:end-1))-n01;
  
  % For displaying the current lsqfs-filtered image:
  if dOPS.display == 1
    subplot(2,3,3)
    imagesc(Is),caxis(cx)
    hold on
    % with the corresponding node points:
% $$$     if i1 < 20
% $$$       [Kntx,Knty] = meshgrid(knts,knts);
% $$$       plot(Kntx,Knty,'k+')
% $$$     end
    hold off
    subplot(2,3,2)
    imagesc(img_in - Is),imgs_smart_caxis(0.005,img_in - Is)
    subplot(2,1,2)
    ph = stairs(x,hI(i1,:)/sum(hI(i1,:)),'r','linewidth',3);
    hold on,
    plot(x(2:end-1),n01(2:end),'b','linewidth',3),
    title(num2str([i1, stdI(i1), nfit(i1)]))
    axis([x([2,end-1]) 0 1.2*max(n01(2:end))])
    if dOPS.pause > 0 && i1 > min_nSval
      pause(dOPS.pause)
    elseif dOPS.pause == 0 || i1 == min_nSval
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
  
  
  ph = semilogy(min_nSval:max_nSval,0.0001+[abs(stdI(min_nSval:end)-1);
                      400*(nfit(min_nSval:end)-min(nfit(min_nSval:end)));
                      (AIC(min_nSval:end)-min(AIC(min_nSval:end)));
                      400*(nfit2(min_nSval:end)-min(nfit2(min_nSval:end)))],'.-');
  axis tight
  title('Fit-measures','fontsize',14)
  xlabel('# knot-points per dimension','fontsize',14)
  set(gca,'ytick',[1e-4 1e-2 1e0])
  legend(ph,'abs(std-1)','pdf-diff','AIC','pdf-fit2')
  
elseif dOPS.display == 2
  
  
  axes(sph(end))
  ph = semilogy(min_nSval:max_nSval,0.0001+[abs(stdI(min_nSval:end)-1);
                      400*(nfit(min_nSval:end)-min(nfit(min_nSval:end)));
                      (AIC(min_nSval:end)-min(AIC(min_nSval:end)));
                      400*(nfit2(min_nSval:end)-min(nfit2(min_nSval:end)))],'.-');
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
[sNfit,isNfit] = sort(nfit(min_nSval:end));
[sNfit2,isNfit2] = sort(nfit2(min_nSval:end));
[sStdI,isStdI] = sort(abs(stdI(min_nSval:end)-1));
[sAIC,isAIC] = sort(AIC(min_nSval:end));
if nargout == 0
  disp([isNfit(1:5)+min_nSval-1;sNfit(1:5);stdI(isNfit(1:5)+min_nSval-1)])
  disp([isStdI(1:5)+min_nSval-1;sNfit(isStdI(1:5)+min_nSval-1);stdI(isStdI(1:5)+min_nSval-1)])
  disp([isAIC(1:5)+min_nSval-1;sAIC(1:5)])
else
  
  Measures = [stdI(min_nSval:end);nfit(min_nSval:end);nfit2(min_nSval:end);AIC(min_nSval:end)];
  
  BestIndxs = [isNfit(1),isNfit2(1),isStdI(1),isAIC(1)];
  Img = 0;
  for i1 = 1:length(BestIndxs),
    bestN_S = (BestIndxs(i1)+min_nSval-1);
    Imgs{i1} = U(:,1:bestN_S)*S(1:bestN_S,1:bestN_S)*V(:,1:bestN_S)';
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
    
