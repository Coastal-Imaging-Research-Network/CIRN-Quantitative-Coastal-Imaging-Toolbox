%% undistortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function undistorts distorted UV coordinates using distortion
%  models from from the Caltech lens distortion manuals. This function is
%  solving distortUV backwards essentially. However, if one looks at
%  distortUV, it becomes very difficult to untangle all of the
%  coefficients to solve for undistorted camera coordinates x and y. In
%  fact, there is no analytical inverse distortion equation.  So we solve
%  for it iteratively. Aggregate Distortion coeffcients fr, dx, and dy
%  should be solved for with undistorted camera coordinates x and y.
%  However, we will solve for them using distorted xd and yd, and then use
%  fr,dx, and dy to to solve for x and y. Then, the new x and y will be
%  used to calculate fr, dx, and dy until the difference between subsequent
%  fr,dx,and dy solutions are less than .001%. Then the final dx,dy, and
%  fr will be used to solve for undistorted U,V.

%  Reference Slides:
%

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics


%  Ud = Px1 vector of distorted U coordinates for P points.
%  Vd = Px1 vector of distorted V coordinates for P points.


%  Output:
%  U= Px1 vector of undistorted U coordinates for P points.
%  V= Px1 vector of undistorted V coordinates for P points.


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [U,V] = undistortUV(Ud,Vd,intrinsics)



%% Section 1: Define Coefficients
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





%% Section 2: Provide first guess for dx, dy, and fr using distorted x,y
% Calculate Distorted camera coordinates x,y, and r
xd = (Ud-c0U)/fx;
yd = (Vd-c0V)/fy;
rd = sqrt(xd.*xd + yd.*yd);
r2d = rd.*rd;

% Calculate First Guess for Aggregate Coefficients
fr1 = 1 + d1*r2d + d2*r2d.*r2d + d3*r2d.*r2d.*r2d;
dx1=2*t1*xd.*yd + t2*(r2d+2*xd.*xd);
dy1=t1*(r2d+2*yd.*yd) + 2*t2*xd.*yd;





%% Section 3: Calculate Undistorted X and Y using first guess
% Work Backwards lines 57-58 in distortUV.
x= (xd-dx1)./fr1;
y= (yd-dy1)./fr1;





%% Section 4: Iterate on solution Until difference for all values is <.001%
% Initiate Variables for While Loop
chk1=1;
chk2=1;
chk3=1;


while isempty(chk1)==0 & isempty(chk2)==0 & isempty(chk3)==0
    
    
    % Calculate New Coefficients
    rn= sqrt(x.*x + y.*y);
    r2n=rn.*rn;
    frn = 1 + d1*r2n + d2*r2n.*r2n + d3*r2n.*r2n.*r2n;
    dxn=2*t1*x.*y + t2*(r2n+2*x.*x);
    dyn=t1*(r2n+2*y.*y) + 2*t2*x.*y;
    
    % Determine Percent change from fr,dx,and dy calculated with distorted
    % values
    chk1=100*(fr1-frn)./fr1;
    chk2=100*(dx1-dxn)./dx1;
    chk3=100*(dy1-dyn)./dy1;
    
    % Check if Percent Change is less than .1%
    chk1=find( (chk1-.001)>0);
    chk2=find( (chk2-.001)>0);
    chk3=find( (chk3-.001)>0);
    
    % Calculate New x,y for next iteration
    x= (xd-dxn)./frn;
    y= (yd-dyn)./frn;
    
    % Set the new coeffcients as previous solution for next iteration
    fr1=frn;
    dx1=dxn;
    dy1=dyn;
    
end





%% Section 5: Convert x and y to U V
U = x*fx + c0U;
V = y*fy + c0V;




