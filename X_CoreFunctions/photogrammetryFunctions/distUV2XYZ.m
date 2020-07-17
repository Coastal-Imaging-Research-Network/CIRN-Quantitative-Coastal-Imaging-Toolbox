%% distUV2XYZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function computes the world XYZ coordinates that correspond to a
%  set of distorted UV image coordinates for a given camera EO and IO
%  specified by extrinsics and intrinsics respectively. In order for UV to be solved,
%  one dimension of xyz must be specified and provided for each point.


%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics


%  extrinsics = 1x6 Vector representing [ x y z azimuth tilt swing] of the camera.
%  XYZ should be in the same units as xyz points to be converted and azimuth,
%  tilt and swing should be in radians.

%  UVd = Px2 list of distorted image UV coordinates of N points. Columns
%  represent U and V coordinates.

%  knownDim= string of either 'x','y', or 'z' specifiying which dimension
%  is known and provide by the user

%  knownVal=Px1 vector of known world coordinates of UV points specified.
%  World dimension is that of knownDim and rows should correspond to same
%  points as UVd.

%  Output:
%  xyz = Px3 list of world coordinates of N points. Columns represent X,Y,
%  and Z coordinates and rows should correspond to UVd points.


%  Required CIRN Functions:
%  intrinsicsExtrinsics2P
%  undistortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xyz] = distUV2XYZ(intrinsics,extrinsics,UVd,knownDim,knownVal)

%% Section 1: Undistort UV Coordinates
% So the camera image we pulled pixel values from is distorted.
% Our P matrix transformation assumes no distortion. We have to correct for
% this. So we  undistorted UV coordinates to correctly enter them in the
% transformation.
Ud=UVd(1,:);
Vd=UVd(2,:);
[U,V] = undistortUV(Ud,Vd,intrinsics);





%% Section 2: Format our P Matrix and DLT Coefficients
% Take Calibration Information, combine it into a sigular P matrix
% containing both intrinsics and extrinsic information. Requires function
% intrinsicsExtrinsics2P.
[P, K, R, IC] = intrinsicsExtrinsics2P( intrinsics, extrinsics );



% We will find the world coordinates atributed to each UV point using the
% Direct Linear Transformation Equations.
%       U = (Ax + By + Cz + D)/(Ex + Fy + Gz + 1);
%       V = (Hx + Jy + Kz + L)/(Ex + Fy + Gz + 1);
% These Coefficients are Moved around to solve for U and V depending on the
% known value.

% Convert P to DLT Coefficients
A = P(1,1);
B = P(1,2);
C = P(1,3);
D = P(1,4);
E = P(3,1);
F = P(3,2);
G = P(3,3);
H = P(2,1);
J = P(2,2);
K = P(2,3);
L = P(2,4);

% Convert Coefficients to Rearranged Combined Coefficients For Solution
M = (E*U - A);
N = (F*U - B);
O = (G*U - C);
P = (D - U);
Q = (E*V - H);
R = (F*V - J);
S = (G*V - K);
T = (L - V);





%% Section 3: Solve for XYZ Depending on Known Variable
% If the x coordinate is known
if strcmp(knownDim,'x')==1
    X =  knownVal;
    Y = ((O.*Q - S.*M).*X + (S.*P - O.*T))./(S.*N - O.*R);
    Z = ((N.*Q - R.*M).*X + (R.*P - N.*T))./(R.*O - N.*S);
end

% If the y coordinate is known
if strcmp(knownDim,'y')==1
    Y =  knownVal;
    X = ((O.*R - S.*N).*Y + (S.*P - O.*T))./(S.*M - O.*Q);
    Z = ((M.*R - Q.*N).*Y + (Q.*P - M.*T))./(Q.*O - M.*S);
end

% If the z coordinate is known
if strcmp(knownDim,'z')==1
    Z =  knownVal;
    X = ((N.*S - R.*O).*Z + (R.*P - N.*T))./(R.*M - N.*Q);
    Y = ((M.*S - Q.*O).*Z + (Q.*P - M.*T))./(Q.*N - M.*R);
end


% Reformat into one Matrix
xyz = [X' Y' Z'];



