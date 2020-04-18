%%intrinsicsExtrinsicsToP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function creates a camera P matrix from a specified camera EO and
%  IO from beta and LCP respectively. 
  

%  Reference Slides:
%  

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsics = 1x6 Vector representing [ x y z yaw pitch roll] of the camera.
%  XYZ should be in the same units as xyz points to be converted and yaw,
%  pitch, and roll should be in radians. 


%  Output:
%  P= [4 x 4] transformation matrix to convert XYZ coordinates to distorted
%  UV coordinates. 


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function P = intrinsicsExtrinsics2P( intrinsics, extrinsics )


%% Section 1: Format IO into K matrix
fx=intrinsics(5);
fy=intrinsics(6);
c0U=intrinsics(3);
c0V=intrinsics(4);

K = [fx 0 c0U;
     0 -fy c0V;
     0  0 1];

 
 
 
 
%% Section 2: Format EO into Rotation Matrix R
yaw= extrinsics(4); 
pitch=extrinsics(5);  
roll=extrinsics(6);

R(1,1) = cos(yaw) * cos(roll) + sin(yaw) * cos(pitch) * sin(roll);
R(1,2) = -cos(roll) * sin(yaw) + sin(roll) * cos(pitch) * cos(yaw);
R(1,3) = sin(roll) * sin(pitch);
R(2,1) = -sin(roll) * cos(yaw) + cos(roll) * cos(pitch) * sin(yaw);
R(2,2) = sin(roll) * sin(yaw) + cos(roll) * cos(pitch) * cos(yaw);
R(2,3) = cos(roll) * sin(pitch);
R(3,1) = sin(pitch) * sin(yaw);
R(3,2) = sin(pitch) * cos(yaw);
R(3,3) = -cos(pitch);





%% Section 3: Format EO into Translation Matrix
x=extrinsics(1);
y=extrinsics(2);
z=extrinsics(3);

IC = [eye(3) [-x -y -z]'];





%% Section 4: Combine K, Rotation, and Translation Matrix into P 
P = K*R*IC;
P = P/P(3,4);   % unnecessary since we will also normalize UVs





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
