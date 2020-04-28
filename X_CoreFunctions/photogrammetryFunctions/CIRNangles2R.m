%% CIRNangles2R
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function creates a Rotation matrix R that takes real world 
%  coordinates and converts them to camera coordinates (Not UV, but rather
%  Xc,Yc, and Zc. The inputs are the pose angles as defined by CIRN,
%  referenced and explained below. The camera axes are defined as Zc
%  positive out of the lens, positive Yc pointing towards the top of the
%  image plane, and positive Xc pointing from right to left if looking from
%  behind the camera. 
  

%  Reference Slides:
%  

%  Input:
%  All Values should be in radians.
%  Azimuth is the horizontal direction the camera is pointing and positive CW 
%  from World Z Axis. 

%  Tilt is the up/down tilt of the camera. 0 is the camera looking nadir,
%  +90 is the camera looking at the horizon right side up. 180 is looking
%  up at the sky and so on.

%  Swing is the side to side tilt of the camera.  0 degrees is a horizontal 
%  flat camera. Looking from behind the camera, CCW rotation of the camera
%  would provide a positve swing.



%  Output:
%  R = [3 x 3] rotation matrix to transform World to Camera Coordinates. 


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R] = CIRNangles2R(azimuth,tilt,swing)

%% Section 1: Define R
% The Rotation follows a ZXZ rotation with Azimuth, Tilt, Swing
R(1,1) = -cos(azimuth) * cos(swing) - sin(azimuth) * cos(tilt) * sin(swing);
R(1,2) = cos(swing) * sin(azimuth) - sin(swing) * cos(tilt) * cos(azimuth);
R(1,3) = -sin(swing) * sin(tilt);
R(2,1) = -sin(swing) * cos(azimuth) + cos(swing) * cos(tilt) * sin(azimuth);
R(2,2) = sin(swing) * sin(azimuth) + cos(swing) * cos(tilt) * cos(azimuth);
R(2,3) = cos(swing) * sin(tilt);
R(3,1) = sin(tilt) * sin(azimuth);
R(3,2) = sin(tilt) * cos(azimuth);
R(3,3) = -cos(tilt);

