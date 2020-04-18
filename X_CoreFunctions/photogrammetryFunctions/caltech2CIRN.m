%% caltech2CIRN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function converts the intrinsics calcuated from the caltech toolbox
%  to nomenclature congruent with the CRIN architecture. 

%  Slide References:
%  Presentation: X ; Slides X-10

%  Input:
%  caltechpath = filepath of saved calibration results from Caltech Toolbox

%  Output:
%  intrinsics = 11x1 Vector of intrinsics

%  Required CIRN Functions:
%  None

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [intrinsics] =caltech2CIRN(caltechpath)

%% Load Function
load(caltechpath)

%% Conversion
intrinsics(1) = nx;            % Number of pixel columns
intrinsics(2) = ny;            % Number of pixel rows
intrinsics(3) = cc(1);         % U component of principal point  
intrinsics(4)= cc(2);          % V component of principal point
intrinsics(5) = fc(1);         % U components of focal lengths (in pixels)
intrinsics(6) = fc(2);         % V components of focal lengths (in pixels)
intrinsics(7) = kc(1);         % Radial distortion coefficient
intrinsics(8) = kc(2);         % Radial distortion coefficient
intrinsics(9) = kc(5);         % Radial distortion coefficient
intrinsics(10) = kc(3);        % Tangential distortion coefficients
intrinsics(11) = kc(4);        % Tangential distortion coefficients




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

