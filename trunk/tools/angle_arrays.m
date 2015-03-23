function angle = angle_arrays(a,b)
% ANGLE_ARRAYS - angle between arrays
%   
% Calling:
% angle = angle_arrays(a,b)

angle = atan2(norm(cross(a,b)),dot(a,b));
