%% localTransformEquiGrid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function tranforms between Local World Coordinates and Geographical
%  World Coordinates for equidistant grids. However, we cannot just rotate
%  our local grid. The resolution would no longer be constant.So we find
%  the local limits, rotate them in to world coordinates, and then make an
%  equidistant grid. Local refers to the rotated coordinate system where X
%  is positive offshore and y is oriented alongshore. The function can go
%  from Local to Geographical and in reverse. Note, this only performs
%  horizontal rotations/transformations. Function assumes transformed grid
%  will have same square resolution as input grid.



%  Input:

%  localAngle = The local.angle should be the relative angle
%  between the new (local) X axis  and old (Geo) X axis, positive counter-
%  clockwise from the old (Geo) X.  Units are degrees.

%  localOrigin = Location of Local (0,0) in Geographical Coordinates.
%  Typically first entry is E and second is N coordinate.

%  Note: Regardless of transformation direction, local Angle and
%  localOrigin should stay the same.

%  XIn = Local (XY) or Geo (EN) Grid depending on transformation
%        direction. Should be equidistant in both X and Y and a valid
%        meshgrid.

%  YIn = Local (XY) or Geo (EN) Grid depending on transformation
%        direction. Should be equidistant in both X and Y and a valid
%        meshgrid.

%  directionFlag = 1 or zero to indicate whether you are going from
%  Geo-->Local (1) OR
%  Local-->Geo (0)


%  Output:
%  XOut= Local (XY) or Geo (EN) Grid depending on transformation
%        direction. Should be equidistant in both X and Y and a valid
%        meshgrid.

%  YOut = Local (XY) or Geo (EN) Grid depending on transformation
%        direction. Should be equidistant in both X and Y and a valid
%        meshgrid.


%  Required CIRN Functions:
%  localTransformPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Xout Yout]= localTransformExtrinsics(localOrigin,localAngle,directionFlag,Xin,Yin)




%% Section 1: Find Input Grid Extents + Resolution
% Find Corners of XY Local Grid to Find Extents of AOI
iCorners(1,:)= [min(min(Xin)), min(min(Yin))]; % [x,y]
iCorners(2,:)= [min(min(Xin)), max(max(Yin))];
iCorners(3,:)= [max(max(Xin)), max(max(Yin))];
iCorners(4,:)= [max(max(Xin)), min(min(Yin))];

% Find Resolution, assuming dx and dy are equal.
idxdy=nanmean(nanmean(diff(Xin)));
% Difference dimension depends on how meshgrid created.
if idxdy ==0
    idxdy=nanmean(nanmean(diff(Xin')));
end

%% Section 2: Transform Input Grid Extents and Find Limits
% Transform the Corners, depending on direction

%World to Local
if directionFlag==1
    [ oCorners(:,1) oCorners(:,2)]= localTransformPoints(localOrigin,localAngle,1,iCorners(:,1),iCorners(:,2));
end

%Local to World
if directionFlag==0
    [ oCorners(:,1) oCorners(:,2)]= localTransformPoints(localOrigin,localAngle,0,iCorners(:,1),iCorners(:,2));
    
end

% Find the limits of the AOI in Transformed Coordinates
oxlim=[min(oCorners(:,1))  max(oCorners(:,1)) ];
oylim=[min(oCorners(:,2))  max(oCorners(:,2)) ];


%% Section 3: Create Equidistant Rotated Grid

%  Make Horizontal input Grid with same input resolution
[Xout Yout]=meshgrid([oxlim(1):idxdy:oxlim(2)],[oylim(1):idxdy:oylim(2)]);




