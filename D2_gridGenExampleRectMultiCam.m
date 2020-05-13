%% D2_gridGenExampleRectMultiCam
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function generates grids for rectification in both world and a 
%  rotated local coordinate system for multiple cameras. Ultimately, it 
%  runs analogous to D1_gridGenExampleRectSingleCam however can handle
%  input of multiple oblique images with each unique EOIO. The only
%  significant difference is the different camera locations for the demo
%  data (Sections 1-3) and the use of for loops for multiple
%  images in Sections 4 and 5. 
%  If not for the different coordinate systems, D1 could easily be
%  modified to handle both multi and single camera. %The user will load an 
%  intrinsic and extrinsicsolution (IOEO) for a given camera via input 
%  files. The user will specify the resolution and limits of the 
%  rectified grid and local rotation parameters. The function
%  will produce figures and  images of the merged georectified imagery. In
%  addition, the prescribed grids will be saved as well in a mat file. 


%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-3. In Section 1 the user will input
%  output names. Section 2 will require specified oblique imagery and  
%  corresponding intiailIOEO output from C_singleExtrinsicSolution for each camera. User will 
%  specify grid specifications in Section 3 along with specifying if 
%  georectification in local coordinates is desired in addtion to world.


%  Output:
%  1-2 Figures and .pngs saved as directory/filename as specified by the 
%  user in Section 1. 'ExampleRect' will be appended to the names.  A .mat 
%  file saved as directory/filename as specified by the 
%  user in Section 1. The file will be prepended with Grid and
%  will contain the grids corresponding to the rectified imagery.

%  Required CIRN Functions:
%  imageRectifcation
%       -xyz2DistUV
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


%  This function is to be run fourth in the CIRN BOOTCAMP TOOLBOX
%  progression to evaluate camera solutions and georectification grids for 
%  multiple cameras. For fixed camera stations it can be ran on any imagery 
%  with the corresponding IOEO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Housekeeping
close all
clear all

% User should make sure that X_CoreFunctions and subfolders are made active
% in their MATLAB path. Below is the standard location for demo, user will
% need to change if X_CoreFunctions is moved and/or the current script.
addpath(genpath('./X_CoreFunctions/'))


%% Section 1: User Input:  Output

%  Enter the filename the georectified images/figures will be saved as. 
%  Name should be descriptive of the image timing, IOEO solution, and 
%  camera name, and grid used.

oname='fixedMultiCamDemo_5mdxdy';

%  Enter the filename of the of the grid .mat file. Name should be
%  descriptive of coordinate systems and resolution.

gname='fixedMultiCamDemo_H3SP_1mResolution';

%  Enter the directory where the grid and image files will be saved.
odir= '.\X_FixedMultCamDemoData\rectificationGrids';

% This is a flag to display intermediate steps in rectification, i.e.
% showing transformation of XYZ-->Image, etc. It is implemented in the
% function imageRectification. For this demo, DO NOT SET TO ZERO.
teachingMode=1;


%% Section 2: User Input: File Paths

%  Enter the filepath of the images to be rectified. Note, the images should
%  have been taken when the IOEO calibration entered below is current. Each
%  value in the CAM structure represents a different camera. It is up to
%  the user to ensure CAMERA IOEO and impaths match for the correct camera
%  as well as images are taken simultaneously. 
impath{1}= '.\X_FixedMultCamDemoData\collectionData\c5\1581706800.Fri.Feb.14_19_00_00.GMT.2020.SBA.c5.snap.jpg';
impath{2}= '.\X_FixedMultCamDemoData\collectionData\c6\1581706800.Fri.Feb.14_19_00_00.GMT.2020.SBA.c6.snap.jpg';
impath{3}= '.\X_FixedMultCamDemoData\collectionData\c7\1581706800.Fri.Feb.14_19_00_00.GMT.2020.SBA.c7.snap.jpg';
impath{4}= '.\X_FixedMultCamDemoData\collectionData\c8\1581706800.Fri.Feb.14_19_00_00.GMT.2020.SBA.c8.snap.jpg';



%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution. Note extrinsics for all K cameras should be 
%  in same coordinate system.

ioeopath{1}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c5_202003032100Photo_20200429Calib.mat';
ioeopath{2}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c6_202003032100Photo_20200429Calib.mat';
ioeopath{3}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c7_202003032100Photo_20200429Calib.mat';
ioeopath{4}= '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c8_202003032100Photo_20200429Calib.mat';




%% Section 3: User Input: Rectification Information

%  Enter a description of the  World coordinate system for your own 
%  records. The world coordinate system of these should be the same as the 
%  IOEO specified in C_singleExtrinsicSolution (gpsCoord, 
%  camSolutionMeta.worldCoordSys).
worldCoord='Hawaii State Plane Zone 3, NAVD88; meters';



%  Enter the origin and angle if you would prefer rectified output to be in 
%  a local rotated right hand coordinate system. CIRN local coordinate 
%  systems typically have the new local X pointed positive offshore, Y 
%  oriented alongshore, and the origin onshore of the shoreline. 
%  localOrigin should be in the same coordinate system of GCPs 
%  entered in gcpXyzPath. The localAngle should be the relative angle 
%  between the new (local) X axis  and old (RW) X axis, positive counter-
%  clockwise from the old (RW) X. If fields are entered, user will still
%  be able to rectify in both local and world coordinates. The coordinate
%  system  and units of these inputs should be the same as the 
%  IOEO specified in C_singleExtrinsicSolution (gpsCoord, 
%  camSolutionMeta.worldCoordSys). Note, if user already specified their
%  world coordinates as a local system, or do not desire a rotation, set
%  localOrigin and localAngle to [0,0] and 0.

localOrigin = [496206.1012  56561.9193 ]; % [ x y]
localAngle =[134]; % Degrees +CCW from Original World X 




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


ixlim=[00 800];
iylim=[-200 1800];
idxdy=5;


% Elevation Specification. Enter the elevation you would like your grid
% rectified as. Typically, CIRN specifies an constant elevation across the
% entire XY grid consistent with the corresponding tidal level the world
% coordinate system. For more accurate results a spatially variable elevation grid
% should be entered if available. However, this code is not designed for
% that. If you would like to enter a spatially variable elevation, say from
% SFM along with tidal elevation, enter your grid as iZ in line 190. It is
% up to the user to make sure it is same size as iX and iY.Spatially variable 
% Z values are more significant for run up calculations than for cbathy or 
% vbar calculations.  It can also affect image rectifications if
% concerned with topography representation.

% What does alter cbathy, vbar, and run-up calculations is a temporally
% varible z elevation. So make sure the elevation value corresponds to the
% correct tidal value in time and location. For short UAS collects, we can
% assume the elevation is relatively constant during the collect. However
% for fixed stations we would need a variable z in time. This function is
% designed for rectification of a single frame, so z is considered constant
% in time. 

iz=5;



%% Section 4: Load Required Files for Rectification


for k=1:length(impath)
%Load Image
I{k}=imread(impath{k});

% Load Solution from C_singleExtrinsicSolution 
load(ioeopath{k})

% Save IOEO into larger structure
% Take First Solution (Can be altered if non-first frame imagery desired
Extrinsics{k}=extrinsics(1,:);
Intrinsics{k}=intrinsics;

end

% Rename IEEO to original EOIO name so congruent with
% D2_gridGenExampleSingleCam code.
extrinsics=Extrinsics;
intrinsics=Intrinsics;





%% Section 5: Load and Assign Extrinsics
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




% Note, from this point onward, the code is identical to
% D1_gridGenExampleRectSingleCam.

%% Section 6: Generate Grids 
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
   

    
    





%% Section 6: Rectification

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





%% Section 7: Output/Saving
% Save Grids
save([odir '/GRID_' gname  ],'X','Y','Z','worldCoord','localAngle','localOrigin','localX','localY','localZ')

% Save Images
imwrite(flipud(Ir),[odir '/' oname '_World.png' ])

imwrite(flipud(localIr),[odir '/' oname '_Local.png' ])










