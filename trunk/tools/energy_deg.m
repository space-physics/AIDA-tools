function [Am] = energy_deg(Energy,pad,atm)
% ENERGY_DEG - energy degradation of electrons
% Calling:
%  [Am,alt] = energy_deg(Energy,pad);
% Input:
%   Enrergy - electron energies
%   pad     - pitch angle distribution: 1 field aligned, 2
%             isotropic
%   atm     - atmospheric model [alt,N2,O2,O,density] {km /m^3 kg/m^3}

if nargin<3 || isempty(atm)
  % Make atmp_m an input variable!
  load atmp_m.dat
  atmp = atmp_m;
else
  atmp = atm;
  atmp(:,2:4) = atmp(:,2:4)/1e6;
  atmp(:,5) = atmp(:,5)/1e3;
end
N_alt0 = length(atmp(:,1));%find(atmp(:,1) == 700);
zetm = atmp(:,1)*0;
zetm(N_alt0) = 0;
dH = gradient(atmp(:,1));
for ih = (N_alt0-1):-1:1,
  %disp(ih)
  %dzetm = (atmp(ih+1,5)+atmp(ih,5))*(atmp(ih+1,1)-atmp(ih,1))*1e5/2;
  dzetm = (atmp(min(length(atmp(:,5)),ih+1),5)+atmp(ih,5))*dH(ih)*1e5/2;
  zetm(ih) = zetm(ih+1)+dzetm;
  
end

N_Energy = length(Energy);
Am = zeros(N_Energy,N_alt0);
D_en = Energy(2:end)-Energy(1:end-1);

for ih = 1:N_alt0,
  
  for ie = 1:N_Energy,
    
    r = Pat_range(Energy(ie),pad);
    %r = Rees_P_range(Energy(ie));
    hi = zetm(ih)/r;
    Am(ie,ih) = atmp(ih,5)*lambda(hi,Energy(ie),pad)*Energy(ie)*(1-albedo(Energy(ie),pad))/r;
    %Am(ie,ih) = atmp(ih,5)*Rees_lambda(hi)*Energy(ie)*(1-albedo(Energy(ie),pad))/r; 
    
    if N_Energy ~= 1,
      
      if ie == 1,
        
        Am(1,ih) = Am(1,ih)*D_en(1)/2.0;
        
      elseif (ie == N_Energy),
        
        Am(N_Energy,ih) = Am(N_Energy,ih)*D_en(N_Energy-1)/2.0;
        
      else
        
        Am(ie,ih) = Am(ie,ih)*(D_en(ie)+D_en(ie-1))/2.0;
        
      end
      
    end
    
  end
  
end
