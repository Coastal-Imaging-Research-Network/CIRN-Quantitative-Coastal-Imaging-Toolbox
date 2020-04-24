%% xyzToDistUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function computes the distorted UV coordinates that correspond to a 
%  set of real world xyz points for a given camera EO and IO specified by 
%  extrinsics and intrinsics respectively. 
  

%  Reference Slides:
%  

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsics = 1x6 Vector representing [ x y z azimuth tilt swing] of the camera.
%  XYZ should be in the same units as xyz points to be converted and azimuth,
%  tilt, and swing should be in radians. 

%  xyz = Nx3 list of world coordinates of N points to be transformed to UV
%  coordinates. Columns represent X,Y, and Z coordinates. 

%  Output:
%  UVd= 2Nx1 list of distorted UV coordinates for specified xyz world 
%  coordinates with 1:N being U and (N+1):2N being V coordinates. It is 
%  formatted as a 2Nx1 vector so it can be used in an nlinfit solver in 
%  extrinsicsSolver.

%  Required CIRN Functions:
%  intrinsicsExtrinsics2P
%  distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function  [UVd] = xyz2DistUV(intrinsics,extrinsics,xyz)

% Take Calibration Information, combine it into a sigular P matrix
% containing both intrinsics and extrinsic information. Requires function
% intrinsicsExtrinsicsToP.
P = intrinsicsExtrinsics2P( intrinsics, extrinsics );

% Find the Undistorted UV Coordinates atributed to each xyz point.
UV = P*[xyz'; ones(1,size(xyz,1))];
UV = UV./repmat(UV(3,:),3,1);  % Make Homogenenous

% So the camera image we are going to pull pixel values from is distorted. 
% Our P matrix transformation assumes no distortion. We have to correct for 
% this. So we distort our undistorted UV coordinates to pull the correct 
% pixel values from the distorted image.
[Ud,Vd] = distortUV(UV(1,:),UV(2,:),intrinsics); 

% Make into a singular matrix for use in the non-linear solver
UVd = [Ud; Vd];





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