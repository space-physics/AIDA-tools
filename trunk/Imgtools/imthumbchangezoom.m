function imthumbchangezoom()
% IMTHUMBCHANGEZOOM - 
%   

seltype = get(gcf,'SelectionType');
point1 = get(gca,'CurrentPoint'); % button down detection

axZoom = axis;
% axC = [mean(axZoom(1:2)),mean(axZoom(3:4))];
axD = [diff(axZoom(1:2)),diff(axZoom(3:4))]/2;

switch seltype
 case 'normal'
  % axis([axC(1)+1.2*[-1 1]*axD(1),axC(2)+1.2*[-1 1]*axD(2)])
  axis([point1(1,1)+1.2*[-1 1]*axD(1),point1(1,2)+1.2*[-1 1]*axD(2)])
 case 'alt'
  %  axis([axC(1)+0.8*[-1 1]*axD(1),axC(2)+0.8*[-1 1]*axD(2)])
  axis([point1(1,1)+1/1.2*[-1 1]*axD(1),point1(1,2)+1/1.2*[-1 1]*axD(2)])
 otherwise
end
