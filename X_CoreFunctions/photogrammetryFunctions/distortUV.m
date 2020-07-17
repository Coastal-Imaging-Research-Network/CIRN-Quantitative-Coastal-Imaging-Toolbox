%% distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function distorts undistorted UV coordinates using distortion
%  models from from the Caltech lens distortion manuals.The function also
%  suggests whether the UVd coordinate is valid (not having tangential
%  distortion values bigger than what is at the corners and being within
%  the image).

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  U = Px1 vector of undistorted U coordinates for N points.
%  V = Px1 vector of undistorted V coordinates for N points.


%  Output:
%  Ud= Px1 vector of distorted U coordinates for N points.
%  Vd= Px1 vector of distorted V coordinates for N points.
%  flag= Px1 vector marking if the UVd coordinate is valid(1) or not(0)


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Ud,Vd,flag] = distortUV(U,V,intrinsics)


%% Section 1: Assign Coefficients out of Intrinsic Matrix
NU=intrinsics(1);
NV=intrinsics(2);
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


%% Section 3: Determine if Points are within the Image

% Initialize Flag that all are accpetable.
flag=Ud.*0+1;

% Find negative UV coordinates
bind=find(round(Ud)<=0 | round(Vd)<=0);
flag(bind)=0;

% Find UVd coordinates greater than the image size
bind =find( round(Ud)>=NU | round(Vd)>= NV);
flag(bind)=0;



%% Section 4: Determine if Tangential Distortion is within Range

%  Find Maximum possible tangential distortion at corners
Um=[0 0 NU NU ];
Vm=[0 NV NV 0];

% Normalization
xm = (Um(:)-c0U)/fx;
ym = (Vm(:)-c0V)/fy;
r2m = xm.*xm + ym.*ym;


% Tangential Distortion
dxm=2*t1*xm.*ym + t2*(r2m+2*xm.*xm);
dym=t1*(r2m+2*ym.*ym) + 2*t2*xm.*ym;

% Find Values Larger than those at corners
bind=find(abs(dy)>max(abs(dym)));
flag(bind)=0;

bind=find(abs(dx)>max(abs(dxm)));
flag(bind)=0;
