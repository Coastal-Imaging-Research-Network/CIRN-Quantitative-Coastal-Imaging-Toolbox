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

%  flag= Nx1 vector marking if the UVd coordinate is valid(1) or not(0)


%  Required CIRN Functions:
%  intrinsicsExtrinsics2P
%  distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function  [UVd,flag] = xyz2DistUV(intrinsics,extrinsics,xyz)

% Take Calibration Information, combine it into a sigular P matrix
% containing both intrinsics and extrinsic information. Requires function
% intrinsicsExtrinsicsToP.
[P, K, R, IC] = intrinsicsExtrinsics2P( intrinsics, extrinsics );

% Find the Undistorted UV Coordinates atributed to each xyz point.
UV = P*[xyz'; ones(1,size(xyz,1))];
UV = UV./repmat(UV(3,:),3,1);  % Make Homogenenous

% So the camera image we are going to pull pixel values from is distorted. 
% Our P matrix transformation assumes no distortion. We have to correct for 
% this. So we distort our undistorted UV coordinates to pull the correct 
% pixel values from the distorted image. Flag highlights invalid points
% (=0) using intrinsic criteria.
[Ud,Vd,flag] = distortUV(UV(1,:),UV(2,:),intrinsics); 

% Find Negative Zc Camera Coordinates. Adds invalid point to flag (=0).
[P, K, R, IC] = intrinsicsExtrinsics2P( intrinsics, extrinsics );
xyzC = R*IC*[xyz'; ones(1,size(xyz,1))];
bind= find(xyzC (3,:)<=0);
flag(bind)=0;

% Make into a singular matrix for use in the non-linear solver
UVd = [Ud; Vd];


