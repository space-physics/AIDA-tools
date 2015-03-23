% EARTH - WGS-84 teoid model and conversion functions
% Version (1.6) (20121111)
% Path -> AIDA_tools/EARTH
% 
% EARTH contains the WGS 84 teoid model and transformation
% functions between some coordinate systems.
%
% User utility functions, interface to wgs84
% 
% Coordinate system and rotation matrices:
%  E_LOCAL       - base vectors for local Cartesian coordinate in the GEO system
%  MAKETRANSFMTR - transformation/rotation matrix between (lat,long) and (lat0,long0)
% 
% Global (GEO) coordinate transformations between lat-long-alt and X-Y-Z:
%  LATLONGH_2_R - transforms the point ( LONG, LAT, H ) to (X,Y,Z) Earth centered GEO
%  R_2_LLH      - transforms R to lat,long,alt in earth centred horizontal system (GEO)
% 
% Geographic <-> Geomagnetic coordinate transformations
%  GEO2MAG95 - Convert from geographic to geomagnetic coordinates
%  MAG2GEO   - Convert from geomagnetic to geographic coordinates
% 
% Local coordinate transformation between lat-logn-alt and x-y-z
%  MAKENLCPOS         - transforms the point (LAT, LONG, ALT) to local (X,Y,Z)
%  LATLONGH_2_xyz     - transforms the point (LAT, LONG, ALT) to local (X,Y,Z)
%  LLH_TO_LOCAL_COORD - transforms the positions (LAT, LONG, ALT) to local (X,Y,Z)
%  XYZ_2_LLH          - transforms X,Y,Z in an lat0,long0 centred horizontal system to long,lat,alt
% 
% Topography handling functions:
%  TRACE_LINE_TO_EARTHSURF - from point [x0,y0,z0] in direction [dx,dy,dz]
%  GTOPO2MAPS              - Parse gtopo digital elevation models
%  NSCAND_MAP              - plot topographic mat over northern Scandinavia
% 
% WGS-84 Geoid
%
% n = NN( fi, alt )
% x = xx( fi, lambda , alt )
% y = yy( fi, lambda, alt)
% z = zz( fi, lambda, alt )
% dndf = dNdfi( fi, lambda )
% dndl = dNdlambda( fi, lambda )
% dxdf =  dxdfi( fi, lambda )
% dxdl = dxdlambda( fi,  lambda )
% dydf = dydfi( fi, lambda )
% dydl = dydlambda( double fi, double lambda )
% dzdf = dzdfi( fi, lambda )
% dzdl = dzdlambda( fi, lambda )


% Copyright Bjorn Gustavsson 20060210-20121111
