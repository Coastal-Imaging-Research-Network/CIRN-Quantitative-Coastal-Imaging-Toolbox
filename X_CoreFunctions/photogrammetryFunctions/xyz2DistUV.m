%% xyzToDistUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the distorted UV coordinates (UVd)  that
% correspond to a set of world xyz points for a given camera EO and IO
% specified by extrinsics and intrinsics respectively. Function also
% produces a flag variable to indicate if the UVd point is valid.


%  Input:
%  IOEO = 1x7 Vector representing [ x y z azimuth tilt swing focallength] of the camera.
%  XYZ should be in the same units as xyz points to be converted and azimuth,
%  tilt and swing should be in radians. Focal length is in pixels

%  xyz = Px3 list of world coordinates of P points to be transformed to UV
%  coordinates. Columns represent X,Y, and Z coordinates.


%  Output:
%  UVd= 2Px1 list of distorted UV coordinates for specified xyz world
%  coordinates with 1:P being U and (P+1):2P being V coordinates. It is
%  formatted as a 2Px1 vector so it can be used in an nlinfit solver in
%  extrinsicsSolver.

%  flag= Px1 vector marking if the UVd coordinate is valid(1) or not(0)


%  Required CIRN Functions:
%  intrinsicsExtrinsics2P
%  distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function  [UVd,flag] = xyz2DistUV(IOEO,xyz)

% Take Calibration Information, combine it into a sigular P matrix
% containing both intrinsics and extrinsic information. Requires function
% intrinsicsExtrinsicsToP.
[P, K, R, IC] = intrinsicsExtrinsics2P( IOEO );

% Find the Undistorted UV Coordinates atributed to each xyz point.
UV = P*[xyz'; ones(1,size(xyz,1))];
UV = UV./repmat(UV(3,:),3,1);  % Make Homogenenous

% No Need to distort or undistort

intrinsics=[IOEO(9),IOEO(10),IOEO(11),IOEO(12),IOEO(7),IOEO(8),IOEO(13),IOEO(14),IOEO(15),IOEO(16),IOEO(17)];
[Ud,Vd,flag] = distortUV(UV(1,:),UV(2,:),intrinsics);
xyzC = R*IC*[xyz'; ones(1,size(xyz,1))];
bind= find(xyzC (3,:)<=0);
flag(bind)=0;


% Make into a singular matrix for use in the non-linear solver
UVd = [Ud; Vd];


