function [Keos,Uout,Vout] = img_stack2fanogram(Imstacks,varargin)
% img_stack2fanogram - make fan-keograms from  image stack.


%   Copyright © 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



v1 = varargin{1};
v2 = varargin{2};

if all(size(v1)==size(v2))
  % Function called with U and V:
  % [Keo] = img_stack2fanogram(Imstacks,U,V)
  U = v1;
  V = v2;
  for cam = length(Imstacks):-1:1,
    Keos{cam} = zeros(length(U{cam}),size(Imstacks{cam},3));
  end
  for cam = 1:length(Imstacks),
    
    if ~isempty(Imstacks{cam})
      for num = 1:size(Imstacks{cam},3),
        
        %keyboard
        % Extract and average the intensities in the fan
        if exist('nanmean','file')
          Keos{cam}(:,num) = nanmean(interp2(Imstacks{cam}(:,:,num),U{cam},V{cam},'linear'),2);
        else
          Keos{cam}(:,num) = mean(interp2(Imstacks{cam}(:,:,num),U{cam},V{cam},'linear',0),2);
        end
      end
      
    end
    
  end
  
else
  % Function called with e_Fan and optpars:
  % [Keo] = img_stack2fanogram(Imstacks,e_Fan,optpars)
  e_Fan = v1;
  optpars = v2;
  width = varargin{3};
  for cam = length(Imstacks):-1:1,
    Keos{cam} = zeros(length(e_Fan),size(Imstacks{cam},3));
  end
  for cam = 1:length(Imstacks),
    
    imsiz = size(Imstacks{cam}(:,:,1));
    if ~isempty(Imstacks{cam})
      [u{cam},v{cam}] = project_point([0,0,0],optpars{cam},e_Fan',eye(3),imsiz);
      % 2-D unit vector of fan's image coordinates
      E_pix  = [u{cam}(125)-u{cam}(124);v{cam}(125)-v{cam}(124)];
      % Rotate it 90 degrees to get a perpendicular vector
      E_perp = [0 1;-1,0]*E_pix;
      % Build a 2-D grid for the fan with the requested width:
      U = repmat(u{cam}',1,width) + repmat(linspace(-width/2,width/2,width),length(e_Fan),1)*E_perp(1);
      V = repmat(v{cam}',1,width) + repmat(linspace(-width/2,width/2,width),length(e_Fan),1)*E_perp(2);
      U = inpaint_nans(U);
      V = inpaint_nans(V);
      if nargout > 1
        
        Uout{cam} = U;
        Vout{cam} = V;
        
      end
      %keyboard
      for num = 1:size(Imstacks{cam},3),
        
        % Extract and average the intensities in the fan
        if exist('nanmean','file')
          Keos{cam}(:,num) = nanmean(interp2(Imstacks{cam}(:,:,num),U,V,'linear'),2);
        else
          Keos{cam}(:,num) = mean(interp2(Imstacks{cam}(:,:,num),U,V,'linear',0),2);
        end
        
      end
      
    end
    
  end
  
end
