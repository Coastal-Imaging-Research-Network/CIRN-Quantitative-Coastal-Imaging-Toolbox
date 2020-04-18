%% localTransformPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function tranforms between Local World Coordinates and Geographical
%  World Coordinates. Local refers to the rotated coordinate system where X
%  is positive offshore and y is oriented alongshore. The function can go
%  from Local to Geographical and in reverse. Input can be vectors or
%  matrices. Note, for rotation to equidistant grids, localTransformEquiGrid 
%  should be used. Note, this only performs horizontal rotations/
%  transformations.
  

%  Reference Slides:
%  

%  Input:

%  localAngle = The local.angle should be the relative angle 
%  between the new (local) X axis  and old (Geo) X axis, positive counter-
%  clockwise from the old (Geo) X.  Units are degrees.

%  localOrigin = Location of Local (0,0) in Geographical Coordinates.
%  Typically first entry is E and second is N coordinate.

%  Note: Regardless of transformation direction, local Angle and
%  localOrigin should stay the same.

%  Xin = Local (X) or Geo (E) coord depending on transformation direction
%  Yin = Local (Y) or Geo (N) coord depending on transformation direction

%  directionFlag = 1 or zero to indicate whether you are going from
%  Geo-->Local (1) OR
%  Local-->Geo (0)


%  Output:
%  Xout = Local (X) or Geo (E) coord depending on transformation direction
%  Yout = Local (Y) or Geo (N) coord depending on transformation direction


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ Xout Yout]= localTransformPoints(localOrigin,localAngle,directionFlag,Xin,Yin)

%% Section 1: Transformation from Geo (EN) -->  Local  (XY)
if directionFlag ==1 
% Translate from origin
ep=Xin-localOrigin(1);
np=Yin-localOrigin(2);

% Rotation    
Xout=ep.*cosd(localAngle)+np.*sind(localAngle);
Yout=np.*cosd(localAngle)-ep.*sind(localAngle);

end

%% Section 2: Transformation from Local  (XY) -->  Geo (EN) 

if directionFlag==0 
  % Rotation
  Yout=Yin.*cosd(localAngle)+Xin.*sind(localAngle);
  Xout=Xin.*cosd(localAngle)-Yin.*sind(localAngle);
  
  % Translation to Origin
  Xout=Xout+localOrigin(1);
  Yout=Yout+localOrigin(2);
end





%% Copyright Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (C) 2017  Coastal Imaging Research Network
%                       and Oregon State University

%    This program is free software: you can redistribute it and/or  
%    modify it under the terms of the GNU General Public License as 
%    published by the Free Software Foundation, version 3 of the 
%    License.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see
%                                <http://www.gnu.org/licenses/>.

% CIRN: https://coastal-imaging-research-network.github.io/
% CIL:  http://cil-www.coas.oregonstate.edu
%
%key UAVProcessingToolbox
