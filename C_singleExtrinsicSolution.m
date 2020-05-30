%% C_singleExtrinsicSolution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function solves the extrinsics (EO) for a given camera for use in 
% the toolbox.  The user will load gcp and intrinsic  (IO) information via 
% input files. The user will specify coordinate system information as well 
% as initial extrinsic guesses. The function will output the solved 
% extrinsics in the form of the vector extrinsics, metadata  information in 
% initialCamSolutionMeta, and a reprojection error figure.


%  Input:
%  Entered by user below in Sections 1-4. Function requires output from
%  A_ioInitialization (Section 2) and B_gcpSelection (Section 3).  In 
%  addition, function requires corresponding GCP world coordinates via a 
%  text file created and specified by the user in Section 3.The user will
%  provide an initial guess for extrinsics in Section 4. 

%  Note, the extrinsics solution will be in the same coordinate system as 
%  the GCPs. Regardless of what the user enters, this will be referred to 
%  as the world coordinate system. It is encouraged that the user 
%  enter GCPs in a geographic coordinate system (State Plane, UTM, etc). 
%  The toolbox will complete a coordinate system rotation in subsequent 
%  functions. Also, the nlinfit solver is very sensitive to the initial 
%  guess; so it must be an educated guess. It is particularly sensitive to 
%  the guessed azimuth, tilt, and swing. If incorrect, nlinfit will error 
%  or provide an nonsensical answer. Please check veracity of provided 
%  extrinsics. 


%  Output:
%  A .mat file saved as directory/filename as specified by the user in 
%  Section 1. 'initialIOEO' will be appended to the name. 

%  Required CIRN Functions:
%  extrinsicsSolver
%       -xyz2DistUV
%  xyz2DistUV
%       -intrinsicsExtrinsics2P
%       -distortUV
%  distUV2XYZ
%       -undistortUV
%       -intrinsicsExtrinsics2P



%  Required MATLAB Toolboxes:
%  Statistical Toolbox (for nlinfit)


% This function is to be run third in the progression for each camera in a 
% multi-camera fixed station or for each  collection for a UAS platform. 
% GCP calibration and geometry solution calculation should occur any time a 
% camera has moved for a fixed  station, the first frame in a new UAS 
% collect, or intrinsics has changed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Housekeeping
close all
clear all

% User should make sure that X_CoreFunctions and subfolders are made active
% in their MATLAB path. Below is the standard location for demo, user will
% need to change if X_CoreFunctions is moved and/or the current script.
addpath(genpath('./X_CoreFunctions/'))





%% Section 1: User Input: Saving Information

%  Enter the filename of the IOEO .mat file that will be saved as. Name 
%  should be descriptive of the camera/recording mode, GCP 
%  deployment, and solution.
oname='uasDemo';

%  Enter the directory where the IOEO file will be saved.
odir= '.\X_UASDemoData\extrinsicsIntrinsics\InitialValues\';





%% Section 2: User Input: Intrinsics 
%  Filepath of the intrinsics matfile output by A_formatIntrinsics. Matfile 
%  should contain at minimum the following variable. Note, the intrinsics 
%  should correspond to the recording mode and camera/lens for the image 
%  taken in B_gcpSelection, imagePath.
iopath= '.\X_UASDemoData\extrinsicsIntrinsics\IntrinsicCalculations\uasDemo_IO.mat';





%% Section 3: User Input: GCP Information 
%  Enter the filepath of the GCP UVd Coordinates produced by B_gcpSelection. 
%  The intinsics of the corresponding image from which the UVd GCP
%  coordinates were derived from should match that entered in Section 2.
gcpUvdPath= '.\X_UASDemoData\extrinsicsIntrinsics\InitialValues\uasDemo_gcpUVdInitial.mat';

%  Enter the filepath of the GCP World coordinates. File should be a
%  four column comma delimted txt file with columns representing gcp
%  number, x coordinate, y coordinate, and z coordinate. Rows will
%  correspond to each GCP. GCP numbers should match with those entered in
%  B_gcpSelection ((gcp().num)). 
gcpXyzPath='.\X_UASDemoData\extrinsicsIntrinsics\uasDemoFlight_NCSP_GCPS.txt';

%  Enter a description of the GCP World coordinate system for your own 
%  records.
gcpCoord='North Carolina State Plane, NAVD88; meters';

% Enter the path of the image you would like GCP reprojection checked
% against (plotted in). This should be the same image used in 
% B_gcpSelection (imagePath) if you are doing a UAS collect or a moving 
% camera.
imagePath='.\X_UASDemoData\collectionData\uasDemo_2Hz\uasDemo_1443742140000.tif';

%  Enter the numbers of GCPs you would like to use for the solution.
%  Numbers must match gcp.num values found in gpcUvPath file. You do not
%  have to use all of the clicked GCPS or GCPS listed in the file. 
gcpsUsed=[1 2 3 4 5];





%% Section 4: User Input: Solution Information
%  Enter the initial guess of extrinsics, for the corresponding camera 
%  image. Extrinsics is formatted as [ x y z azimuth tilt swing] where xyz 
%  correspond to the same  world coordinate system as GCPs entered in 
%  gcpXyzPath in Section 3. Azimuth, tilt and swing should be in radians. 
%  For UAS, this information can be estimated from the autopilot. For fixed 
%  camera stations it is suggested you survey in the location of the 
%  cameras.

extrinsicsInitialGuess= [ 901726 274606 100 deg2rad(80) deg2rad(60) deg2rad(0)]; % [ x y z azimuth tilt swing]

%  Enter the number of knowns, or what you would like fixed in your EO
%  solution. 1 represents fixed where 0 represents floating (solvable) for
%  each value in beta. 
extrinsicsKnownsFlag= [ 0 0 0 0 0 0];  % [ x y z azimuth tilt swing]


% Section 4 Note: 
%  The nlinfit solver is very sensitive to the initial guess; so it must be
%  an educated guess. It is particularly sensitive to the guessed azimuth,
%  tilt, and swing. If incorrect, nlinfit will error or provide an
%  nonsensical answer. Please check veracity of provided extrinsics. 

%  To help provide better orientation guesses, azimuth,
%  tilt, and swing are defined below.

%  Azimuth is the horizontal direction the camera is pointing and positive CW 
%  from World Z Axis. 

%  Tilt is the up/down tilt of the camera. 0 is the camera looking nadir,
%  +90 is the camera looking at the horizon right side up. 180 is looking
%  up at the sky and so on.

%  Swing is the side to side tilt of the camera.  0 degrees is a horizontal 
%  flat camera. Looking from behind the camera, CCW rotation of the camera
%  would provide a positve swing.

%  Diagrams of these defintions are in Section 6 of the user manual. 





%% Section 5: Load IO and GCP Files

% Load IO
load(iopath)

% Load GCP UV
load(gcpUvdPath)

% Load GCP World Cooridinate Text File
F=fopen(gcpXyzPath);
A=textscan(F,'%f%f%f%f','delimiter',',');

% Associate GCP UVs with World Coordinates
for k=1:length(gcp)
    n=gcp(k).num;

    i=find(A{1}==n); % Find coresponding GCP Number
    
    %Put World Coordinates into GCP structure along with UV
    gcp(k).x=A{2}(i);
    gcp(k).y=A{3}(i);
    gcp(k).z=A{4}(i);
    gcp(k).CoordSys=gcpCoord;
end

% Display GCP Information
disp(' ')
disp('Added GCP Information')
disp(gcp)





%% Section 6: Solve for Beta (EO)
% Format GCP World and UV coordinates into correctly sized matrices for
% non-linear solver and transformation functions (xyzToDistUV). Also, use only 
% selected GCPs specified by gcps_used in Section 3. 

% Match gcp numbers with those specified
for k=1:length(gcp)
    gnum(k)=gcp(k).num;
end
[Lia,gcpInd] = ismember(gcpsUsed,gnum);

% Format into matrix for extrinsicsSolver
x=[gcp(gcpInd).x];
y=[gcp(gcpInd).y];
z=[gcp(gcpInd).z];
xyz = [x' y' z'];  % N x 3 matrix with rows= N gcps, columns= x,y,z
UVd=reshape([gcp(gcpInd).UVd],2,length(x))'; % N x 2 matrix with rows=gcps, columns= U,V


%  Function extrinsicsolver will solve for the unknown extrinsics EO as well as
%  provide error estimates for each value. Function extrinsicsSolver requires the
%  function xyzToDistUV, which requires intrinsicsExtrinsics2P and distortUV.

[extrinsics extrinsicsError]= extrinsicsSolver(extrinsicsInitialGuess,extrinsicsKnownsFlag,intrinsics,UVd,xyz);


% Display the results
disp(' ')
disp('Solved Extrinsics and NLinfit Error')
disp( [' x = ' num2str(extrinsics(1)) ' +- ' num2str(extrinsicsError(1))])
disp( [' y = ' num2str(extrinsics(2)) ' +- ' num2str(extrinsicsError(2))])
disp( [' z = ' num2str(extrinsics(3)) ' +- ' num2str(extrinsicsError(3))])
disp( [' azimuth = ' num2str(rad2deg(extrinsics(4))) ' +- ' num2str(rad2deg(extrinsicsError(4))) ' degrees'])
disp( [' tilt = ' num2str(rad2deg(extrinsics(5))) ' +- ' num2str(rad2deg(extrinsicsError(5))) ' degrees'])
disp( [' swing = ' num2str(rad2deg(extrinsics(6))) ' +- ' num2str(rad2deg(extrinsicsError(6))) ' degrees'])





%% Section 7: Reproject GCPs into UVd Space
%  Use the newly solved  extrinsics to calculate new UVd coordinates for the
%  GCP xyz points and compare to original clicked UVd. All GCPs will be
%  evaluated, not just those used for the solution.

% Format All GCP World and UVd coordinates into correctly sized matrices for
% non-linear solver and transformation functions (xyzToDistUV).
xCheck=[gcp(:).x];
yCheck=[gcp(:).y];
zCheck=[gcp(:).z];
xyzCheck = [xCheck' yCheck' zCheck'];  % N x 3 matrix with rows= N gcps, columns= x,y,z

% Transform xyz World Coordinates to Distorted Image Coordinates
[UVdReproj ] = xyz2DistUV(intrinsics,extrinsics,xyzCheck);

%  Reshape UVdCheck so easier to interpret
UVdReproj = reshape(UVdReproj ,[],2);


% Load Specified Image and Plot Clicked and Reprojected UV GCP Coordinates
f1=figure;
imshow(imagePath)
hold on

for k=1:length(gcp)
    % Clicked Values
    h1=plot(gcp(k).UVd(1),gcp(k).UVd(2),'ro','markersize',10,'linewidth',3);
    text(gcp(k).UVd(1)+30,gcp(k).UVd(2),num2str(gcp(k).num),'color','r','fontweight','bold','fontsize',15)
    
    % New Reprojected Values
    h2=plot(UVdReproj(k,1),UVdReproj(k,2),'yo','markersize',10,'linewidth',3);
    text(UVdReproj(k,1)+30,UVdReproj(k,2),num2str(gcp(k).num),'color','y','fontweight','bold','fontsize',15)
end
legend([h1 h2],'Clicked UVd','Reprojected UVd')





%% Section 8: Determine Reprojection Error
%  Use the newly solved  extrinsics to calculate new xyz coordinates for the
%  clicked UVd points and compare to original gcp xyzs. All GCPs will be
%  evaluated, not just those used for the solution.
for k=1:length(gcp)

% Assumes Z is the known value; Reproject World XYZ from Clicked UVd    
[xyzReproj(k,:)] = distUV2XYZ(intrinsics,extrinsics,[gcp(k).UVd(1); gcp(k).UVd(2)],'z',gcp(k).z);

% Calculate Difference from Surveyd GCP World Coordinates
gcp(k).xReprojError=xyzCheck(k,1)-xyzReproj(k,1);
gcp(k).yReprojError=xyzCheck(k,2)-xyzReproj(k,2);


end

rms=sqrt(nanmean((xyzCheck-xyzReproj).^2));

% Display the results
disp(' ')
disp('Horizontal GCP Reprojection Error')
disp( (['GCP Num \ X Err \  YErr']))

for k=1:length(gcp)
    disp( ([num2str(gcp(k).num) '\' num2str(gcp(k).xReprojError) '\' num2str(gcp(k).yReprojError) ]));
end





%% Section 9: Save Results & MetaData

% Construct the MetaData Structure
% Identify files used for GCP XYZ and UV Coord
initialCamSolutionMeta.iopath=iopath;
initialCamSolutionMeta.gcpUvPath=gcpUvdPath;
initialCamSolutionMeta.gcpXyzPath=gcpXyzPath;

% Identify Solution Parameters
initialCamSolutionMeta.gcpsUsed=gcpsUsed;
initialCamSolutionMeta.gcpRMSE=rms; 
initialCamSolutionMeta.gcps=gcp;
initialCamSolutionMeta.extrinsicsInitialGuess=extrinsicsInitialGuess;
initialCamSolutionMeta.extrinsicsKnownsFlag=extrinsicsKnownsFlag;
initialCamSolutionMeta.extrinsicsUncert=extrinsicsError';
initialCamSolutionMeta.imagePath=initialCamSolutionMeta.gcps(1).imagePath;

% Coordinate System Information
initialCamSolutionMeta.worldCoordSys=gcpCoord;



% Save Results
save([odir '/' oname '_IOEOInitial' ],'initialCamSolutionMeta','extrinsics','intrinsics')


% Display
disp(' ')
disp('Finished Solution')   

disp(initialCamSolutionMeta)   




