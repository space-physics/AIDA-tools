function varargout = irifileloader(filename,ops)
% IRIFILELOADER - load and parse IRI data files
% 
% Calling:
%   [alt,Op,NOp,O2p,Te,Ti,Hep,Hp,Np,Clustp] = irifileloader(filename,ops)    Outargflag = 0
%   altOpNOpO2pTeTiHepHpNpClustp = irifileloader(filename,ops)   Outargflag = 1
%   AtmStruct = irifileloader(filename,ops)          Outargflag = -1 
%   ops = msisfileloader;
% Input:
%   filename - string with full or relative path to MSIS data file
%              to be loaded.
%   ops      - Options struct (slightly optional) containing fields
%              OutargFlag, [-1, 0, 1] selecting output format
%              according to above, defaults to 0. And named field
%              for column index of the species to extract, these
%              are built as OPS.indz (1) OPS.indTe (6) OPS.indTi
%              (5) OPS.indOp (7) OPS.indNp (8) OPS.indHp (9)
%              OPS.indHep (10) OPS.indO2p (11) OPS.indNOp  = 12;
% Outputs:
%
% He, O, N2, O2, Ar, H and N are the number densities (per m^3) of
% these species at the requested altitude. Mass is the total mass
% density (kg/m^3) at this altitude. Tex is the "exospheric
% temperature" and T is the temperature at the altitude.
% 

% Copyright © Bjorn Gustavsson 20120131
% This is free software GNU copyleft version 3 or later applies.

% Default options
dOPS.OutargFlag = 0; % Output format selection flag
dOPS.indz    = 1;    % Column index for altitudes
dOPS.indTe   = 6;    % Column index for electron temperature
dOPS.indTi   = 5;    % Column index for ion temperature
dOPS.indOp   = 7;    % Column index for atomic oxygen ions
dOPS.indNp   = 8;    % Column index for N+
dOPS.indHp   = 9;    % Column index for H+
dOPS.indHep  = 10;   % Column index for He+
dOPS.indO2p  = 11;   % Column index for O2+
dOPS.indNOp  = 12;   % Column index for NO+

% If no input argument is given
if nargin == 0
  % then return the default options struct
  varargout{1} = dOPS;
  return
elseif nargin > 1
  % if there are a user supplied options struct merge that one with
  % the default:
  dOPS = mergestruct(dOPS,ops);
end

try % to load the iri data file
  iri_data = load(filename);
catch
  % If that fails just give up
  error(sprintf('Could not load file %s',filename))
end

% If outputflag is
if dOPS.OutargFlag < 0
  % Then build a struct with named fields for the desired ion-species.
  atm.alt  = iri_data(:,dOPS.indz);
  atm.Te   = iri_data(:,dOPS.indTe);
  atm.Ti   = iri_data(:,dOPS.indTi);
  atm.Op   = iri_data(:,dOPS.indOp);
  atm.NOp  = iri_data(:,dOPS.indNOp);
  atm.O2p  = iri_data(:,dOPS.indO2p);
  
  if isfield(dOIPS,'indHep')
    atm.Hep   = iri_data(:,dOIPS.indHep);
  end
  if isfield(dOIPS,'indHp')
    atm.Hp    = iri_data(:,dOIPS.indHp);
  end
  if isfield(dOIPS,'indClustp')
    atm.Clustp  = iri_data(:,dOIPS.indClustp);
  end
  if isfield(dOIPS,'indNp')
    atm.Np    = iri_data(:,dOIPS.indNp);
  end
  varargout{1} = atm;
  
elseif     dOPS.OutargFlag > 0
  % just put everything together in one sorted array
  altOpNOpO2pTeTiHepHpNpClustp(:,1) = iri_data(:,dOPS.indz);
  altOpNOpO2pTeTiHepHpNpClustp(:,2) = iri_data(:,dOPS.indO);
  altOpNOpO2pTeTiHepHpNpClustp(:,3) = iri_data(:,dOPS.indN2);
  altOpNOpO2pTeTiHepHpNpClustp(:,4) = iri_data(:,dOPS.indO2);
  altOpNOpO2pTeTiHepHpNpClustp(:,5) = iri_data(:,dOPS.indMass);
  altOpNOpO2pTeTiHepHpNpClustp(:,6) = iri_data(:,dOPS.indTn);
  if isfield(dOIPS,'indTex')
    altOpNOpO2pTeTiHepHpNpClustp(:,7) = iri_data(:,dOIPS.indTex);
  end
  if isfield(dOIPS,'indHe')
    altOpNOpO2pTeTiHepHpNpClustp(:,8) = iri_data(:,dOIPS.indHe);
  end
  if isfield(dOIPS,'indH')
    altOpNOpO2pTeTiHepHpNpClustp(:,9) = iri_data(:,dOIPS.indH);
  end
  varargout{1} = altOpNOpO2pTeTiHepHpNpClustp;
  
else
  % Transfer outputs to meaningful names
  alt  = iri_data(:,dOPS.indz);
  Op   = iri_data(:,dOPS.indOp);
  NOp  = iri_data(:,dOPS.indNOp);
  O2p  = iri_data(:,dOPS.indO2p);
  Te   = iri_data(:,dOPS.indTe);
  Ti   = iri_data(:,dOPS.indTi);
  if isfield(dOIPS,'indNp')
    Np    = iri_data(:,dOIPS.indNp);
  end
  if isfield(dOIPS,'indHp')
    Hp    = iri_data(:,dOIPS.indHp);
  end
  if isfield(dOIPS,'indHep')
    Hep   = iri_data(:,dOIPS.indHep);
  end
  if isfield(dOIPS,'indClustp')
    Clustp  = iri_data(:,dOIPS.indClustp);
  end
  varargout{1} = alt*1e3;
  varargout{2} = Op;
  varargout{3} = NOp;
  varargout{4} = O2p;
  varargout{5} = Te;
  varargout{6} = Ti;
  varargout{7} = Np;
  varargout{8} = Hp;
  varargout{9} = Hep;
  varargout{5} = Ar;
  
end
