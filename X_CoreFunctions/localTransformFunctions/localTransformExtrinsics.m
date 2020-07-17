%% localTransformExtrinsics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function tranforms between Local World Coordinates and Geographical
%  World Coordinates for the extrinsics vector. Local refers to the rotated
%  coordinate system where X is positive offshore and y is oriented
%  alongshore. The function can go from Local to Geographical and in
%  reverse. Note, this only performs horizontal rotations/transformations.


%  Input:

%  localAngle = The local.angle should be the relative angle
%  between the new (local) X axis  and old (Geo) X axis, positive counter-
%  clockwise from the old (Geo) X.  Units are degrees.

%  localOrigin = Location of Local (0,0) in Geographical Coordinates.
%  Typically first entry is E and second is N coordinate.

%  Note: Regardless of transformation direction, local Angle and
%  localOrigin should stay the same.

%  extrinsicsIn = Local (XY) or Geo (EN) coord depending on transformation
%                 direction. Should be Nx6 Matrix, N number of positions.

%  directionFlag = 1 or zero to indicate whether you are going from
%  Geo-->Local (1) OR
%  Local-->Geo (0)


%  Output:
%  extrinsicsOut = Local (XY) or Geo (EN) coord depending on transformation
%                  direction. Should be Nx6 Matrix, N number of positions.


%  Required CIRN Functions:
%  localTransformPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [extrinsicsOut]= localTransformExtrinsics(localOrigin,localAngle,directionFlag,extrinsicsIn)


%% Section 1: World to Local
if directionFlag==1
    
    % Initiate Vector
    extrinsicsOut=nan(length(extrinsicsIn(:,1)),6);
    
    % Transform X and Y coordinate of extrinsics
    [ extrinsicsOut(:,1) extrinsicsOut(:,2)]= localTransformPoints(localOrigin,localAngle,1,extrinsicsIn(:,1),extrinsicsIn(:,2));
    
    % Z, Tilt and Swing are the Same Since Just Horizontal Rot. and Tran
    extrinsicsOut(:,[ 3 5 6])= extrinsicsIn(:,[3 5 6]);
    
    % Rotate Azimuth
    extrinsicsOut(:,4)= extrinsicsIn(:,4)+[deg2rad(localAngle)];
    
end





%% Section 2: Local to World
if directionFlag==0
    
    % Initiate Vector
    extrinsicsOut=nan(length(extrinsicsIn(:,1)),6);
    
    % Transform X and Y coordinate of extrinsics
    [ extrinsicsOut(:,1) extrinsicsOut(:,2)]= localTransformPoints(localOrigin,localAngle,0,extrinsicsIn(:,1),extrinsicsIn(:,2));
    
    % Z, Tilt and Swing are the Same Since Just Horizontal Rot. and Tran
    extrinsicsOut(:,[ 3 5 6])= extrinsicsIn(:,[3 5 6]);
    
    % Rotate Azimuth
    extrinsicsOut(:,4)= extrinsicsIn(:,4)-[deg2rad(localAngle)];
    
end




