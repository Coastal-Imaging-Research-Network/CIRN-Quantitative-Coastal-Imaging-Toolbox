%% thresholdCenter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function finds the center of area of pixels above a specified
%  threshold in a region of interest (ROI) in a given image. This function is
%  useful for finding the center of a bright area of pixels.
  
%  Reference Slides:
%  

%  Input:
%  I= NxMx3 image where points of interest (SCPs, etc) reside.

%  Udo= Initial Ud center coordinate of Region of interest of shape. [1x1] 
%       Value must be withing size(2) of I.

%  Vdo= Initial Vd center coordinate of Region of interest of shape. [1x1]
%       Value must be withing size(1) of I.

%  R = Radius for area of interest. Does not define circle, but rather 1/2
%  the length of a square. [1x1] Value should be in pixels and greater than
%  1.

%  T= Threshold Lower Limit for selected bright pixel intensities. Is a [1x1]
%  value that can be 0-255.


%  Output:
%  Udn = Ud coordinate of New Center of Region of Interest considering only 
%        pixels above threshold

%  Vdn = Vd coordinate of New Center of Region of Interest considering only 
%        pixels above threshold

%  i   = single intensity subset of Image I, only convering Region of
%        Interest

%  udi=  ud axes of subset image i

%  vdi = vd axes of subset image i


%  Required CIRN Functions:
%  none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Udn, Vdn, i, udi,vdi] = thresholdCenter(I,Udo,Vdo,R,T)


%% Section 1: Limit Area to ROI

% Round so you can use as indices in image matrix
Udo=round(Udo);
Vdo=round(Vdo);
                
ulim=[(Udo-R) (Udo+R)];
vlim=[(Vdo-R) (Vdo+R)];

% Check Image Size, set to image limits if radius too big
s=size(I);
if ulim(1)<=0
    ulim(1)=0;
end
if vlim(1)<=0
    vlim(1)=0;
end
if vlim(2)>s(1)
    vlim(2)=s(1);
end
if ulim(2)>s(2)
    ulim(2)=s(2);
end
                
% Retrieve ROI from image
udi=ulim(1):ulim(2);
vdi=vlim(1):vlim(2);
i = I(vdi,udi,:);

% Set as single Intensity Image
i=rgb2gray(i);
                


%% Section 2: Calculate New Center of Region using Threshold

% Calculate Center of Area of Thresholded Value
[U V]=meshgrid(udi,vdi);
Udn = mean(U(i>T)); 
Vdn = mean(V(i>T));




