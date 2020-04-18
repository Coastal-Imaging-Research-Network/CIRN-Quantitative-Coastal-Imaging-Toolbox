%% plotRectification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function plots a rectified image in Matlab given a corresponding X 
%  and Y  meshgrid on the current axes. The user can plot it as an RGB
%  image using imagesc or a grayscale image using pcolor depending on the
%  flag. Take note of how the matrices align for each, and how Matlab plots
%  images versus matrices. When loading an image, and then using this
%  function be sure to use the XYZ grid output by G_imageProducts. If using
%  this from imageRectifier directly with no flipping, Ir, use the grid 
%  used as input to imageRectifier.
  
%  Reference Slides:
%  

%  Input:
%  I= NxMx3 rectified image with rgb values or NxM Matrix with grayscale
%  values (will be gray for both options of imageFlag).

%  X = MeshGrid of X coordinates of NxM size.
%  Y = MEshGrid of Y coordinates of NxM size. 


%  imageFlag= Flag of whether to plot as an rgb image (=1) or grayscale
%             pcolor (=0).


%  Output:
%  Plotted rectified frame on current axes. 

%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function rectificationPlotter(I,X,Y,imageFlag)


%% Section 1: If RBG Image Is desired
if imageFlag==1
imagesc(X(1,:),Y(:,1),I) %imagesc assumes grid is valid meshgrid and 
                              %only allows vector input

end





%% Section 2: If Pcolor Gray Image Is desired
if imageFlag==0
    
    
    
try    
pcolor(X,Y,rgb2gray(I))
catch
pcolor(X,Y,(I)) % If a grayscale Image already
end

shading flat
colormap(gray)
end





%% Section 3: Add Axes Limits
axis equal
set(gca,'ydir','normal')        % Imagesc plots as imshow, with V increasing 
                                % from top to bottom, we need to reset to 
                                % normal axis direction, increasing from
                                % bottom to top. 
xlim([min(min(X)) max(max(X))])
ylim([min(min(Y)) max(max(Y))]) 
xlabel('X')
ylabel('Y')







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










