%% D_gridGenExampleRect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates grids for rectification in both world and a
% rotated local coordinate system. The function rectifies a single oblique
% image into rectified imagery for a one or multiple cameras. The user will
% load an intrinsic and extrinsicsolution (IOEO) for each camera via input
% files. The user will specify the resolution and limits of the rectified
% grid and local rotation parameters for a local coordinate system. The
% user can enter the grid parameters in local or world coordinates; the
% function will make a corresponding grid encompassing the other system.
% The function will produce figures and  save png images of the
% georectified imagery in both coordinate systems. In addition, the
% prescribed grids will be saved as well in a mat file.


%  Input:
%  Entered by user below in Sections 1-4. In Section 1 the user will input
%  output names. Section 2 will require specified oblique imagery and
%  corresponding intiailIOEO output from C_singleExtrinsicSolution. User will
%  specify grid specifications in Section 3 along with specifying if
%  georectification in local coordinates is desired in addtion to world.
% The user input of the code is prescribed for UASDemoData. However, one
% can uncomment lines in Section 4 for the FixedMultiCamDemoData.

%  Output:
%  Figures and .pngs saved as directory/filename as specified by the
%  user in Section 1. 'ExampleRect' will be appended to the names.  A .mat
%  file saved as directory/filename as specified by the
%  user in Section 1. The file will be prepended with GRID and
%  will contain the grids corresponding to the rectified imagery.

%  Required CIRN Functions:
%  imageRectifcation
%       -xyz2DistUV
%       -cameraSeamBlend
%  xyz2DistUV
%       -intrinsicsExtrinsics2P
%       -distortUV
%  localTransformExtrinsics
%       -localTransformPoints
%  localTransformEquiGrid
%       -localTransformPoints
%  localTransformPoints


%  Required MATLAB Toolboxes:
%  none


% This function is to be run fourth in the progression to evaluate camera
% extrinsic solutions and georectification grids. For UAS it should be run
% on the first image used for camera IOEO calibration. For fixed camera
% stations it can be ran on any imagery with the corresponding IOEO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Housekeeping
close all
clear all

% User should make sure that X_CoreFunctions and subfolders are made active
% in their MATLAB path. Below is the standard location for demo, user will
% need to change if X_CoreFunctions is moved and/or the current script.
addpath(genpath('./X_CoreFunctions/'))





%% Section 1: User Input:  Saving  + Output Information

%  Enter the filename the georectified images/figures will be saved as.
%  Name should be descriptive of the image timing, IOEO solution, and
%  camera name, and grid used.

oname='uasDemo_InitialFrame_2mdxdy';



%  Enter the filename of the of the grid .mat file. Name should be
%  descriptive of coordinate systems and resolution.

gname='demo_NCSP_2mResolution';

%  Enter the directory where the grid and image files will be saved.
odir= './X_UASDemoData/rectificationGrids';



% This is a flag to display intermediate steps in rectification, i.e.
% showing transformation of XYZ-->Image, etc. It is implemented in the
% function imageRectification. For this demo, DO NOT SET TO ZERO.
teachingMode=1;





%% Section 2: User Input: Loading Information

%  Filepath of the image you would like rectified. This should be the same
%  image used in B_gcpSelection and C_singleExtrinsicSolution (imagePath)
%  if you are doing a UAS collect or a moving camera. For a fixed camera,
%  it can be any image where intrinsics and extrinsics are valid.
imagePath{1}= './X_UASDemoData/collectionData/uasDemo_2Hz/uasDemo_1443742140000.tif';


%  Enter the filepath of the saved  IOEO calibration results produced by
%  C_singleExtrinsicSolution.
ioeopath{1}= './X_UASDemoData/extrinsicsIntrinsics/InitialValues/uasDemo_IOEOInitial.mat';

% NOTE: For multiple cameras, these values are entered as cell entries for
% each camera. The extrinsics for each camera should all be in the same
% world coordinate system. It is up to the user to make sure the entries
% for both variables correspond to the same cameras.Even for a single
% camera, both imagePath and ioeopath need to be entered as cell functions
% with one entry.





%% Section 3: User Input: Rectification Information

%  Enter a description of the  World coordinate system for your own
%  records. The world coordinate system of these should be the same as the
%  IOEO specified in C_singleExtrinsicSolution (gpsCoord,
%  camSolutionMeta.worldCoordSys).
worldCoord='NCSP, NAVD88; meters';



% Coordinate System Info: Enter the origin and angle if you would prefer
% rectified output to be in a local rotated right hand coordinate system.
% CIRN local coordinate  systems typically have the new local X pointed
% positive offshore, Y  oriented alongshore, and the origin onshore of the
% shoreline. If fields are entered, user will still  be able to rectify in
% both local and world coordinates. Note, if user already specified their
% world coordinates as a local system, or do not desire a rotation, set
% localOrigin and localAngle to [0,0] and 0.

localOrigin = [901951.6805  274093.1562 ]; % [ x y]
localAngle =[20.0253]; % Degrees +CCW from Original World X




% Enter if you would like to INPUT your grid in  rotated local
% coordinates. 1=local coordinates, 0= world coordinates.
% The function will still rectify both coordinate systems regardless
% of localFlagInput value. LocalFlagInput only dictates
% the coordinate system of the input and which direction the rotation
% will occur. If localOrigin and localAngle =0; this value is irrelevant.

localFlagInput=1;



% Grid Specification. Enter the limits (ixlim, iylim) and resolution(idxdy)
% of your rectified grid. Coordinate system entered will depend on
% localFlagInput. Units should be consistent with world Coordinate system
% (m vs ft, etc).


ixlim=[0 700];
iylim=[0 1000];
idxdy=2;


% Elevation Specification. Enter the elevation you would like your grid
% rectified as. Typically, CIRN specifies an constant elevation across the
% entire XY grid consistent with the corresponding tidal level the world
% coordinate system. For more accurate results a spatially variable
% elevation grid should be entered if available. However, this code is not
% designed for that. If you would like to enter a spatially variable
% elevation, say from SFM along with tidal elevation, enter your grid as iZ
% It is up to the user to make sure it is same size as iX and iY.Spatially
% variable  Z values are more significant for run up calculations than for
% surface current or bathymetric inversion calculations at a distance.
% It can also affect image rectifications if concerned with topography
% representation.

% What does alter bathymetric inversion, surface current, and run-up
% calculations is a temporally variable z elevation. So make sure the
% elevation value corresponds to the correct tidal value in time and
% location. For short UAS collects, we can assume the elevation is
% relatively constant during the collect. However for fixed stations we
% would need a variable z in time. This function is designed for
% rectification of a single frame, so z is considered constant in time.
% Value should be entered in the World Coordinate system and units.

iz=0;





%% Section 4: Uncomment for Multi-Camera Demo
% %  The Mult-Camera Demo will share the same grid parameters, but use
% %  different images, extrinsics, and save in a different location.
%
% % Output Name
% oname='fixedMultCamDemo_2mdxdy';
% % OutPut Directory
% odir='./X_FixedMultCamDemoData/rectificationGrids';
%
% % Image paths
% % Each value in the CAM structure represents a different camera. It is up to
% %  the user to ensure CAMERA IOEO and imagePaths match for the correct camera
% %  as well as images are taken simultaneously.
% imagePath{1}= './X_FixedMultCamDemoData/collectionData/c1/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c1.timex.jpg';
% imagePath{2}= './X_FixedMultCamDemoData/collectionData/c2/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c2.timex.jpg';
% imagePath{3}= './X_FixedMultCamDemoData/collectionData/c3/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c3.timex.jpg';
% imagePath{4}= './X_FixedMultCamDemoData/collectionData/c4/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c4.timex.jpg';
% imagePath{5}= './X_FixedMultCamDemoData/collectionData/c5/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c5.timex.jpg';
% imagePath{6}= './X_FixedMultCamDemoData/collectionData/c6/1444314601.Thu.Oct.08_14_30_01.GMT.2015.argus02b.c6.timex.jpg';
%
% %  IOEO Solutions
% %  Enter the filepath of the saved CIRN IOEO calibration results produced by
% %  C_singleExtrinsicSolution. Note extrinsics for all K cameras should be
% %  in same coordinate system.
%
% ioeopath{1}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C1_FixedMultiCamDemo.mat';
% ioeopath{2}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C2_FixedMultiCamDemo.mat';
% ioeopath{3}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C3_FixedMultiCamDemo.mat';
% ioeopath{4}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C4_FixedMultiCamDemo.mat';
% ioeopath{5}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C5_FixedMultiCamDemo.mat';
% ioeopath{6}=  './X_FixedMultCamDemoData/extrinsicsIntrinsics/C6_FixedMultiCamDemo.mat';
%




%% Section 5: Load Required Files for Rectification

for k=1:length(imagePath)
    %Load Image
    I{k}=imread(imagePath{k});
    
    % Load Solution from C_singleExtrinsicSolution
    load(ioeopath{k})
    
    % Save IOEO into larger structure
    % Take First Solution (Can be altered if non-first frame imagery desired
    Extrinsics{k}=extrinsics(1,:);
    Intrinsics{k}=intrinsics;
    
end

% Rename IEEO to original EOIO name so names consistent
extrinsics=Extrinsics;
intrinsics=Intrinsics;


%% Section 6: Load and Assign Extrinsics
%  For accurate rectification, the grid and the extrinsics solution must be
%  in the same coordinate system and units. The extrinsic output from
%  C_singleGeometrySolution is in world coordinates. Thus, to rectify in
%  local coordinates, we must rotate our world extrinsics to local
%  extrinsics.

for k=1:length(ioeopath)
    %  World Extrinsics
    extrinsics{k}=extrinsics{k};
    
    %  Local Extrinsics
    localExtrinsics{k} = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics{k});
end



%% Section 7: Generate Grids
%  This function will rectify the specified image in both world and local
%  (if specified) coordinates. The image rectification for each coordinate
%  system requires an equidistant grid. This cannot be done by simply
%  rotating one grid to another, the rotated resoltions will not be
%  equidistant and the images stretched. Thus the entered limits need to
%  rotated and new grids created. This is accomplished in gridEquiRotate.
%  Below creates the equidistant grids depending on localFlagInput.


%  Create Equidistant Input Grid
[iX iY]=meshgrid([ixlim(1):idxdy:ixlim(2)],[iylim(1):idxdy:iylim(2)]);

%  Make Elevation Input Grid
iZ=iX*0+iz;

%  Assign Input Grid to Wolrd/Local, and rotate accordingly depending on
%  inputLocalFlag

% If World Entered
if localFlagInput==0
    % Assign World Grid as Input Grid
    X=iX;
    Y=iY;
    Z=iZ;
    
    % Assign local Grid as Rotated input Grid
    [ localX localY]=localTransformEquiGrid(localOrigin,localAngle,1,iX,iY);
    localZ=localX.*0+iz;
    
end

% If entered as Local
if localFlagInput==1
    % Assign local Grid as Input Grid
    localX=iX;
    localY=iY;
    localZ=iZ;
    
    % Assign world Grid as Rotated local Grid
    [ X Y]=localTransformEquiGrid(localOrigin,localAngle,0,iX,iY);
    Z=X*.0+iz;
end







%% Section 8: Rectification

% The function imageRectification will perform the rectification for both
% world and local coordinates. The function utalizes xyz2DistUV to find
% corresponding UVd values to the input grid and pulls the rgb pixel
% intensity for each value. If the teachingMode flag is =1, the function
% will plot corresponding steps (xyz-->UVd transformation) as well as
% rectified output.

% World Rectification
[Ir]= imageRectifier(I,intrinsics,extrinsics,X,Y,Z,teachingMode);
% Specify Title
subplot(2,2,[2 4])
title(worldCoord)


% Local Rectification (If specified)
if localOrigin~=[0,0] & localAngle ~= 0
    
    [localIr]= imageRectifier(I,intrinsics,localExtrinsics,localX,localY,localZ,teachingMode);
    
    % Specify Title
    subplot(2,2,[2 4])
    title('Local Coordinates')
    
end





%% Section 9: Output/Saving
% Save Grids
save([odir '/GRID_' gname  ],'X','Y','Z','worldCoord','localAngle','localOrigin','localX','localY','localZ')

% Save Images
imwrite(flipud(Ir),[odir '/' oname '_World.png' ])

imwrite(flipud(localIr),[odir '/' oname '_Local.png' ])










