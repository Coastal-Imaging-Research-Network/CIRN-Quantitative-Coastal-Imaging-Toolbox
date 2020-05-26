%% G_imageProducts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function generates statistical image products for a given set of
%  images and corresponding extrinsics/intrinsics. The statistical image
%  products are the timex, brightest, variance, darkest. If specified,
%  rectified imagery for each image can be produced and saved as an png
%  file. Rectified images and image products can be produced in world or
%  local coordinates if specified in the grid provided by
%  D1_gridGenExampleRectSingleCam or D2_gridGenExampleRectMultiCam. 
%  This can function can be used for a collection with variable (UAS) 
%  and fixed intriniscs in addition to single/multi camera capability. 

%  The current code has input entered for UASDemoData. However, one can
%  uncomment lines directly below input for a multi-camera processing.


%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-4. In Section 1 the user will input
%  output names and whether individual rectified frames will be output.  
%  Section 2 will require information for the collection, i.e. the 
%  directory of the oblique images and extrinsics solutions calculated by 
%  C_singleExtrinsicSolution (Fixed Camera) or F_variableExtrinsicSolution
%  (UAS). Section 3 will require rectification grid information produced by
%  D1_gridGenExampleRectSingleCam or D2_gridGenExampleRectMultiCam. Section 4 will require any variation of z
%  elevation if known throughout the collect (only applicable for long term
%  fixed stations with temporally varying z grids, not short UAS collects). 


% Output:
% 5 Image Products  as well as individual rectified frames if desired saved 
% as pngs. The accompanying metadata will be saved along with grid
% information in a mat file in the same ouputdirectory as the images. If
% multi-camera data is selected, the rectified individual frames will share
% the same name as the fist cam. 


%  Required CIRN Functions: 
%  imageRectification
%  -cameraSeamBlend
%  xyz2DistUV
%   distortUV
%   intrinsicsExtrinsics2P
%  localTransformExtrinsics
%   localTransformPoints
%  plotRectification


%  Required MATLAB Toolboxes:
%  none


%  This function is to be run fifth (seventh) in the CIRN BOOTCAMP TOOLBOX
%  progression for fixed (UAS) collections.
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
%  For image products, a descriptor of the product type ('timex', etc) will
%  be appended to the name. For individual images, the oblique image name
%  will be appended. Name should be descriptive of collection and grid.

oname='uasDemo_rect10x10m';
         % For Multi Cam
         % oname='fixedMultCamDemo_rect5x5m';

%  Enter the directory where the images will be saved.
odir= '.\X_UASDemoData\output\uasDemoFlightRectified';
         % For Multi Cam
         % odir= '.\X_FixedMultCamDemoData\output\fixedMultCamDemoRectified';

%  Enter if you would like individual frames rectified and output. 1= yes,
%  output individual frames. 0= no, only output image products.
outputFlag=1;





%% Section 2: User Input:  Collection Information

%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution for fixed or F_variableExtrinsicSolutions for
%  UAS.
ioeopath{1}= '.\X_UASDemoData\extrinsicsIntrinsics\uasDemo_IOEOVariable.mat';

        % %  If multi-Camera, enter each filepath as a cell entry for each camera.
        % %  Note, all extrinsics must be in same coordinate system.
        % ioeopath{1}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c5_202003032100Photo_20200429Calib.mat';
        % ioeopath{2}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c6_202003032100Photo_20200429Calib.mat';
        % ioeopath{3}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c7_202003032100Photo_20200429Calib.mat';
        % ioeopath{4}= '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c8_202003032100Photo_20200429Calib.mat';






%  Enter the directory where your oblique imagery is stored. For UAS, the
%  names of the images must match those in imageNames output produced by
%  F_variableExtrinsicSolutions. For fixed cameras, the directory should
%  only have images in it, nothing else. 
obliqueImageDirectory{1}='.\X_UASDemoData\collectionData\uasDemo_2Hz\';

        % If a Multi-camera station, provide the directory containing the images
        % for each camera. Note in this example, each camera folder has the same amount
        % and order of images (The first image for camera 1 was taken at the same time
        % as the first image in camera 2 folder, etc). This code requires this but
        % can be altered for more complicated folder directories. Also, the order
        % of the obliqueImageDirectory{k) should match with the ieopath order so
        % the correct IOEO corresponds to the correct images.
        % obliqueImageDirectory{1}='.\X_FixedMultCamDemoData\collectionData\c5';
        % obliqueImageDirectory{2}='.\X_FixedMultCamDemoData\collectionData\c6';
        % obliqueImageDirectory{3}='.\X_FixedMultCamDemoData\collectionData\c7';
        % obliqueImageDirectory{4}='.\X_FixedMultCamDemoData\collectionData\c8';



%% Section 3: User Input: Grid Information

% Enter the filepath of the saved rectification grid created in
% D1_gridGenExampleRectSingleCam or D2_gridGenExampleRectMultiCam. Grid world coordinates need to be same coordinates
% as those in the extrinsics in ieopath. Grid needs to be meshgrid format
% with variables X,Y, and Z. 
gridPath='.\X_UASDemoData\rectificationGrids\GRID_uasDemo_NCSP_10mResolution.mat';

        % Grid for Multi-Camera Fixed Demo
        % gridPath='.\X_FixedMultCamDemoData\rectificationGrids\GRID_fixedMultiCamDemo_H3SP_5mResolution.mat';

        
% Enter if the user prefers local (localFlag==1) or world (localFlag==0)
% coordinates. Not if localFlag==1, localAngle, localOrigin, and localX,Y,Z
% in the ioeopath must all be non-empty.
localFlag=1;


%% Section 4: User Input: Fixed Station 
%  If a fixed station a time vector can be provided in the datenum format.
%  The length of the vector must match the number of images rectified and
%  coorectly correspond to each image. If using UAS or not desired, leave
%  empty. This was covered in F_variableExrtrinsicSolutions
t={};

    % For Multi Cam
    % t=[737835.791666667,737835.833333333,737835.875, 737835.916666667,737835.958333333];
        
%  If a Fixed station, most likely images will span times where Z is no
%  longer constant. We have to account for this in our Z grid. To do this,
%  enter a z vector below that is the same length as t. For each frame, the
%  entire z grid will be assigned to this value. If UAS or not desired,
%  leave empty. It is assumed elevation is constant during a short collect.
zFixedCam={};

%% Section 5: Load Files 

% Load Grid File And Check if local is desired
load(gridPath)
if localFlag==1
X=localX;
Y=localY;
Z=localZ;
end

% Load Camera IOEO and Image lists

%  Determine Number of Cameras
camnum=length(ioeopath);

for k=1:camnum
% Load List of Collection Images
L{k}=string(ls(obliqueImageDirectory{k}));
L{k}=L{k}(3:end); % First two are always empty

% Load Extrinsics
load(ioeopath{k})

% Check if fixed or variable. If fixed (length(extrinsics(:,1))==1), make
% an extrinsic matrix the same length as L, just with initial extrinsics
% repeated.
if length(extrinsics(:,1))==1
extrinsics=repmat(extrinsics,length(L{k}(:)),1);
end
if localFlag==1
extrinsics=localTransformExtrinsics(localOrigin,localAngle,1,extrinsics);
end

% Aggreate Camera Extrinsics Together
Extrinsics{k}=extrinsics;
Intrinsics{k}=intrinsics;

clear extrinsics
clear intrinsics
end




%% Section 6: Initiate Loop


for j=1:length(L{1}(:))

    % For Each Camera
    for k=1:camnum
    % Load Image
    I{k}=imread(strcat(obliqueImageDirectory{k}, '\', L{k}(j)));
    end




%% Section 7: Perform Rectification

% If fixed station and Z is not constant, assign a corresponding z
% elevation.
if isempty(zFixedCam)==0
    Z=Z.*0+z(j);
end

%Pull Correct Extrinsics out, Corresponding In time
for k=1:camnum 
extrinsics{k}=Extrinsics{k}(j,:);
end
intrinsics=Intrinsics;


[Ir]= imageRectifier(I,intrinsics,extrinsics,X,Y,Z,0);





%% Section 8: Initiate Image Product variables of correct size and format
if j==1
iDark=double(Ir).*0+255; % Can't initialize as zero, will always be dark
iTimex=double(Ir).*0;
iBright=uint8(Ir).*0;
end





%% Section 9: Perform Statistical Calcutions
% Timex: Sum Values, will divide by total number at last frame.
iTimex=iTimex+double(Ir);

% Darkest: Compare New to Old value, save only the mimumum intensity as
% iDark
iDark=min(cat(4,iDark,Ir),[],4);

% Brightest: Compare New to Old value, save only the maximum intensity as
% iBright
iBright=max(cat(4,iBright,Ir),[],4);


% If Last Frame...finish the Timex Caculation
if j==length(L{k}(:))
iTimex=uint8(iTimex./length(L{k}(:)));
end




%% Section 10: Output Frames (optional)
%  Name will be oname with epoch time in milliseconds appended to end. If t
%  is empty and not specified, it will be an indicie. 

if isempty(t)==0
    iname=num2str(round(1000*24*3600*(t(j)-datenum(1970,1,1))));
else
    
 mxdec=length(num2str(length(L{k}(:))))+1; %Determine max number of digits for frame numbers
 iname=repmat('0',1,mxdec); % Make Zero String for maximum needed length.
 inum=num2str(j); % Convert Indicie to string 
 iname( ((mxdec-length(inum)+1)  :end)) = inum; % Replace last zeros with indicie string
end

% Save Image
imwrite(flipud(Ir),strcat(odir, '\',oname, '_', iname,'.png'))

% Display progress
disp([ 'Frame ' num2str(j) ' out of ' num2str(length(L{k}(:))) ' completed. ' num2str(round(j/length(L{k}(:))*1000)/10) '%'])

end





%% Section 11: Plot  Image Products

f1=figure;
rectificationPlotter(iTimex,X,Y,1)
title('Timex')


f2=figure;
rectificationPlotter(iBright,X,Y,1)
title('Bright')


f3=figure;
rectificationPlotter(iDark,X,Y,1)
title('Dark')





%% Section 12: Save Image Products + Meta Data
% Save Products
imwrite(flipud(iTimex),strcat(odir, '\',oname, '_timex.png'))
imwrite(flipud(iBright),strcat(odir, '\',oname, '_bright.png'))
imwrite(flipud(iDark),strcat(odir, '\',oname, '_dark.png'))


% Flip XYZ, note- once saved as an image, we will have to flipUD so the
% image looks correct. THus, so XYZ correspond the the same pixels, we flip
% these as well.
X=flipud(X);
Y=flipud(Y);
Z=flipud(Z);


% Save metaData and Grid Data
rectMeta.solutionPath=ioeopath;
rectMeta.obliqueImageDirectory=obliqueImageDirectory;
rectMeta.gridPath=gridPath;
rectMeta.imageNames=L;
rectMeta.t=t;

% If A local Grid Add Information
if localFlag==1
rectMeta.localFlag=1;
rectMeta.localAngle=localAngle;
rectMeta.localOrigin=localOrigin;
end
rectMeta.worldCoord=worldCoord;


save(strcat(odir, '\',oname, '_gridMeta'), 'X','Y','Z','rectMeta','t')





























