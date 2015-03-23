function [J,res] = genqt_statfilt2(I,alpha,fK,OPS)
% genqt_statfilt - Filtering until regional residues are statisticaly acceptable
%   I_GQT_SF make a generalized quad-tree decomposition filtering
%   with arbitrary 2-D polynomial fits to the input image until the
%   statistical criteria is met, composed-from-decomposed image are
%   filtered with filter kernel FK.
%
% Calling:
%  [J,res] = genqt_statfilt(I,alpha,fK,OPS)
%
% Input:
%  I - Intensity/grayscalle image to filter
%  ALPHA - signifficance level for statistic of noise distribution
%          (the difference between input image I and filtered image J,
%          assumed to be normal distributed N(0,J.^0.5)). Default
%          is 0.1
%  FK - filter kernel to filter image regions, defaults to 9x9
%       Gaussian window with 4 pixels FWHM. If an empty matrix, [],
%       is given filtering is not performed.
%  OPS - options structure. The default is returned when
%        GENQT_STATFILT is called without input parameters. Fields
%        are: OPS.minregsize - minimum size of the quad-tree size,
%        partitioning stops at the given size, defaults to 4
%        pixels. OPS.model_depmat is a 2-D matrix describing the
%        2-D polynomial to fit the intensities in the partitioned
%        image region to. Default is [0 0], which corresponds to
%        one constant intensity inside the image region. Any 2-D
%        polynomial can be used, for example C+Ax+By+Dxy^2 is
%        [0 0;1 0;0 1;1 2]. OPS.demo, [ {0} | 1 ], if one the
%        proceedings of the computations is shown with intermediate
%        plots. OPS.tests_for_OK number of statistical test
%        required for accepting the filtered fit to be
%        statistically good [{3} | 2 | 1 ]
% 
% The function uses ESTIMATE_MODEL, and EVALUATE_MODEL to
% respectively determine a least square fitting polynomial to the
% raw image in each partitioned region. The fit is deemed
% statistically good if 3 (or 2, or 1 of) chi2test_normpdf,gtest
% mtest does not reject the hypothesis that the difference, D,
% between the raw image I and the filtered J is N(0,J.^0.5).
% 
% See also ESTIMATE_MODEL, EVALUATE_MODEL, CHI2TEST_NORMPDF, GTEST, MTEST


%   Copyright � 20050225 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Check in-parameters

if nargin == 0 % Then produce the default OPS-struct
  
  J.minregsize = 4; % any power of 2, should be kept at reasonable
                    % size with respect to MODEL_DEPMAT
  J.model_depmat = [0 0]; % 2-D polynonmial to fit intensities in
                          % regions, C+Ax+By+Dxy^2 <-> [0 0;1 0;0 1;1 2]
  J.demo = 0; % [{0}| 1] show proceding of computation.
  J.test_fcn = [];
  J.tests_for_OK = 3;
  return
  
end
if nargin < 3
  
  fK = conv2(conv2(conv2(ones(3)/9,ones(3)/9,'full'),ones(3)/9,'full'),ones(3)/9,'full');
  
end
minregsize = 4;
model_depmat = [0 0];
do_demo = 0;
tests_for_OK = 3;
if nargin == 4
  if isfield(OPS,'minregsize')
    minregsize = OPS.minregsize;
  end
  if isfield(OPS,'model_depmat')
    model_depmat = OPS.model_depmat;
  end
  if isfield(OPS,'demo')
    do_demo = OPS.demo;
  end
  if isfield(OPS,'tests_for_OK')
    tests_for_OK = OPS.tests_for_OK;
  end
end

reg = size(fK);
if nargin < 2 || isempty(alpha)
  
  alpha = 0.1;
  
end

regpos = [1;1];
regsiz = size(I)';
regok = 0;

J = zeros(size(I));
while 1
  
  regs_notok = find(regok==0);
  for i = regs_notok,%1:size(regpos,2),
    
    if all(model_depmat==0)
      
      J(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
        regpos(2,i):(regpos(2,i)+regsiz(2,i)-1)) = mean( mean( I(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
                                                        regpos(2,i):(regpos(2,i)+regsiz(2,i)-1))));
    else
      
      d = I(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
            regpos(2,i):(regpos(2,i)+regsiz(2,i)-1));
      x = 1:size(d,2);
      y = 1:size(d,1);
      [x,y] = meshgrid(x,y);
      m = estimate_model([x(:)-mean(x(:)) y(:)-mean(y(:))],d(:),model_depmat);
      
      d(:) = evaluate_model([x(:)-mean(x(:)) y(:)-mean(y(:))],m);
      J(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
        regpos(2,i):(regpos(2,i)+regsiz(2,i)-1)) = d;
      
    end
    
  end
  
  if ~isempty(fK)
    Jtmp = filter2(fK,...
                   J([ones(1,ceil((reg(1)-1)/2)) 1:end size(I,1)*ones(1,(reg(1)-1)/2)],...
                     [ones(1,ceil((reg(2)-1)/2)) 1:end size(I,1)*ones(1,(reg(2)-1)/2)]),'same');
    Jtmp = Jtmp(ceil((reg(1)-1)/2)+1:ceil((reg(1)-1)/2)+size(I,1),...
                ceil((reg(2)-1)/2)+1:ceil((reg(2)-1)/2)+size(I,2));
  else
    Jtmp = J;
  end
  lregpos = size(regpos,2);
  for i = regs_notok,
    
    Jr = Jtmp(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
              regpos(2,i):(regpos(2,i)+regsiz(2,i)-1));
    Ir = I(regpos(1,i):(regpos(1,i)+regsiz(1,i)-1),...
           regpos(2,i):(regpos(2,i)+regsiz(2,i)-1));
    D = (Ir(:)-Jr(:))./(max(Jr(:),1)).^.5;
    if ( ( sum([chi2test_normpdf(D',alpha),gtest(D',alpha),mtest(D',max(0.001,min(0.1,alpha)))]) < tests_for_OK ) && ...
         ( regsiz(1,i) > minregsize ) )
      
      regok(end+1:end+4) = 0;
      regsiz(1,end+1:end+4) = regsiz(1,i)/2; 
      regsiz(2,end-3:end)   = regsiz(2,i)/2; 
      regpos(:,end+1) = regpos(:,i);
      regpos(:,end+1) = regpos(:,i)+regsiz(:,end).*[0;1];
      regpos(:,end+1) = regpos(:,i)+regsiz(:,end).*[1;1];
      regpos(:,end+1) = regpos(:,i)+regsiz(:,end).*[1;0];
      regpos(:,i) = [];
      regsiz(:,i) = [];
      regok(i) = [];
      
    elseif regsiz(1,i) == minregsize
      
      regok(i) = 2;
      
    else
      
      regok(i) = 1;
      
    end
    
  end
  if  size(regpos,2) == lregpos
    
    J = Jtmp;
    if nargout == 2
      res.regpos = regpos;
      res.regsiz = regsiz;
      res.regok = regok;
      
    end
    return
    
  end
  if do_demo
    mysubplot(2,2,1)
    imagesc(I),colorbar
    mysubplot(2,2,2)
    imagesc(Jtmp),colorbar
    regs_ok = find(regok==1);
    hold on
    for i = regs_ok
      plotsquare(regpos(:,i),regsiz(:,i))
    end
    hold off
    mysubplot(2,2,3)
    imagesc(I-Jtmp),colorbar
    hold on
    for i = regs_ok
      plotsquare(regpos(:,i),regsiz(:,i))
    end
    hold off
    mysubplot(4,2,6)
    plot(regok,'.')
    mysubplot(4,2,8)
    ok_indx = find(regok==1);
    if ~isempty(ok_indx)
      plot(ok_indx,regsiz(1,ok_indx),'b.')
      hold on
    end
    ok_indx = find(regok==0);
    if ~isempty(ok_indx)
      plot(ok_indx,regsiz(1,ok_indx),'r.')
    end
    hold off
    drawnow
  end
  
end


function plotsquare(r_llc,dxy,clr)
% PLOTSQUARE - plot a black square
%   

if nargin == 2
  clr = rand([1 3]);
end
h = plot(r_llc(2)+[0 dxy(2) dxy(2) 0 0],...
         r_llc(1)+[0 0 dxy(1) dxy(1) 0]);
set(h,'color',clr)
