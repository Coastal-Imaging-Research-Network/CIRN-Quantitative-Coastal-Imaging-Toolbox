%% caltech2CIRN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function converts the intrinsics calcuated from the caltech toolbox
%  to nomenclature congruent with the CRIN architecture.


%  Input:
%  caltechpath = filepath of saved calibration results from Caltech Toolbox

%  Output:
%  intrinsics = 11x1 Vector of intrinsics

%  Required CIRN Functions:
%  None

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [intrinsics] =caltech2CIRN(caltechpath)

%% Load Function
load(caltechpath)

%% Conversion
intrinsics(1) = nx;            % Number of pixel columns
intrinsics(2) = ny;            % Number of pixel rows
intrinsics(3) = cc(1);         % U component of principal point
intrinsics(4)= cc(2);          % V component of principal point
intrinsics(5) = fc(1);         % U components of focal lengths (in pixels)
intrinsics(6) = fc(2);         % V components of focal lengths (in pixels)
intrinsics(7) = kc(1);         % Radial distortion coefficient
intrinsics(8) = kc(2);         % Radial distortion coefficient
intrinsics(9) = kc(5);         % Radial distortion coefficient
intrinsics(10) = kc(3);        % Tangential distortion coefficients
intrinsics(11) = kc(4);        % Tangential distortion coefficients




