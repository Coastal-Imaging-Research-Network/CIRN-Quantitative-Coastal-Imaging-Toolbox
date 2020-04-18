%% distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function distorts undistorted UV coordinates using distortion
%  models from from the Caltech lens distortion manuals.
  

%  Reference Slides:
%  

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  U = Nx1 vector of undistorted U coordinates for N points.
%  V = Nx1 vector of undistorted V coordinates for N points.


%  Output:
%  Ud= Nx1 vector of distorted U coordinates for N points.
%  Vd= Nx1 vector of distorted V coordinates for N points.


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Ud,Vd] = distortUV(U,V,intrinsics)


%% Section 1: Assign Coefficients out of Intrinsic Matrix
c0U=intrinsics(3);
c0V=intrinsics(4);
fx=intrinsics(5);
fy=intrinsics(6);
d1=intrinsics(7);
d2=intrinsics(8);
d3=intrinsics(9);
t1=intrinsics(10);
t2=intrinsics(11);



%% Section 2: Calculate Distorted Coordinates

% Normalize Distances
x = (U(:)-c0U)/fx; 
y = (V(:)-c0V)/fy;

% Radial Distortion
r2 = x.*x + y.*y;   % distortion found based on Large format units
fr = 1 + d1*r2 + d2*r2.*r2 + d3*r2.*r2.*r2;

% Tangential Distortion
dx=2*t1*x.*y + t2*(r2+2*x.*x);
dy=t1*(r2+2*y.*y) + 2*t2*x.*y;

%  Apply Correction, answer in chip pixel units
xd = x.*fr + dx;
yd = y.*fr + dy;
Ud = xd*fx+c0U;       
Vd = yd*fy+c0V;




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
