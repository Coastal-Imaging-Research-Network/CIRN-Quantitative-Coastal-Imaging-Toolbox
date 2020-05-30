%% G1_imageProducts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates statistical image products for a given set of 
% images and corresponding extrinsics/intrinsics. The statistical image 
% products are the timex, brightest, variance, darkest. If specified, 
% rectified imagery for each image/frame can be produced and saved as an 
% png file. Rectified images and image products can be produced in world 
% or local coordinates if specified in the grid provided by 
% D_gridGenExampleRect. This can function can be used for a collection with 
% variable (UAS)  and fixed intrinsics in addition to single/multi camera 
% capability. 


%  Input:
%  Entered by user below in Sections 1-5. In Section 1 the user will input
%  output names and whether individual rectified frames will be output.  
%  Section 2 will require information for the collection, i.e. the 
%  directory of the oblique images and extrinsics solutions calculated by 
%  C_singleExtrinsicSolution) or F_variableExtrinsicSolution. Section 3 
%  will require rectification grid information produced by 
%  D_gridGenExampleRect. Section  4 will require any variation of z 
%  elevation if known throughout the collect (only applicable for long term 
%  fixed stations with temporally varying z grids, not short UAS collects). 


% The user input of the code is prescribed for UASDemoData. However, one 
% can uncomment lines in Section 5 for the FixedMultiCamDemoData.

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


%% Section 1: User Input:  Saving Information

%  Enter the filename the georectified images/figures will be saved as. 
%  For image products, a descriptor of the product type ('timex', etc) will
%  be appended to the name. For individual images, the oblique image name
%  will be appended. Name should be descriptive of collection and grid.

oname='uasDemo_rect10x10m';


%  Enter the directory where the images will be saved.
odir= '.\X_UASDemoData\output\uasDemoFlightRectified';
         

%  Enter if you would like individual frames rectified and output. 1= yes,
%  output individual frames. 0= no, only output image products.
outputFlag=1;





%% Section 2: User Input:  Collection Information

%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution for fixed or F_variableExtrinsicSolutions for
%  UAS.
ioeopath{1}= '.\X_UASDemoData\extrinsicsIntrinsics\uasDemo_IOEOVariable.mat';







%  Enter the directory where your oblique imagery is stored. For UAS, the
%  names of the images must match those in imageNames output produced by
%  F_variableExtrinsicSolutions. For fixed cameras, the directory should
%  only have images in it, nothing else. 
imageDirectory{1}='.\X_UASDemoData\collectionData\uasDemo_2Hz\';




%% Section 3: User Input: Grid Information

% Enter the filepath of the saved rectification grid created in
% D1_gridGenExampleRectSingleCam  Grid world coordinates need to be same coordinates
% as those in the extrinsics in ieopath. Grid needs to be meshgrid format
% with variables X,Y, and Z. 
gridPath='.\X_UASDemoData\rectificationGrids\GRID_demo_NCSP_10mResolution.mat';


        
% Enter if the user prefers local (localFlag==1) or world (localFlag==0)
% coordinates. Not if localFlag==1, localAngle, localOrigin, and localX,Y,Z
% in the ioeopath must all be non-empty.
localFlag=1;


%% Section 4: User Input: Manual Entry of Time and Elevation
%  If a fixed station a time vector can be provided in the datenum format.
%  The length of the vector must match the number of images rectified and
%  coorectly correspond to each image. If using UAS or not desired, leave
%  empty. This was covered in F_variableExrtrinsicSolutions
t={};

   
        
%  If a Fixed station, most likely images will span times where Z is no
%  longer constant. We have to account for this in our Z grid. To do this,
%  enter a z vector below that is the same length as t. For each frame, the
%  entire z grid will be assigned to this value. If UAS or not desired,
%  leave empty. It is assumed elevation is constant during a short collect.

% Function can either have a temporally constant elevation grid with 
% spatially varying Z or a spatially constant elevation grid with a 
% temporally varying elevation value. The code needs to be modified to 
% have both. If zVariable is non-empty, this will take precedent and make 
% a spatially constant but temporally varying Z grid to rectify to
zVariable={};





%% Section 5: Multi-Cam Demo input
% Uncomment this section for the multi-camera demo. ImageDirectory and 
% ioeopath should be entered as cells, with each entry representing a 
% different camera. It is up to the user that entries between the two 
% variables correspond. Extrinsics between all cameras should be in the 
% same World Coordinate System. Note that no new grid is specified, the 
% cameras and images are all rectified to the same grid and time varying 
% elevation. Also it is important to note for imageDirectory, each camera 
% should have its own directory for images. The number of images in each 
% directory should be the same (T) as well as ordered by MATLAB so images 
% in the same order are simultaneous across cameras (i.e. the third image 
% in c1 is taken at t=1s, the third image in c2 is taken at t=1s, etc). 
% zVariable is from NOAA Tide Station at NAVD88 in meters.

%  oname='fixedMultCamDemo_rect10x10m';
%        
%  odir= '.\X_FixedMultCamDemoData\output\fixedMultCamDemoRectified';
% 
% ioeopath{1}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C1_FixedMultiCamDemo.mat';
% ioeopath{2}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C2_FixedMultiCamDemo.mat';
% ioeopath{3}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C3_FixedMultiCamDemo.mat';
% ioeopath{4}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C4_FixedMultiCamDemo.mat';
% ioeopath{5}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C5_FixedMultiCamDemo.mat';
% ioeopath{6}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\C6_FixedMultiCamDemo.mat';%         
% 
%  imageDirectory{1}='.\X_FixedMultCamDemoData\collectionData\c1';
%  imageDirectory{2}='.\X_FixedMultCamDemoData\collectionData\c2';
%  imageDirectory{3}='.\X_FixedMultCamDemoData\collectionData\c3';
%  imageDirectory{4}='.\X_FixedMultCamDemoData\collectionData\c4';
%  imageDirectory{5}='.\X_FixedMultCamDemoData\collectionData\c5';
%  imageDirectory{6}='.\X_FixedMultCamDemoData\collectionData\c6';
% 

%  t=[datenum(2015,10,8,14,30,0):.5/24:datenum(2015,10,8,22,00,0)];
%  
% zVariable=[-.248 -.26 -.252 -.199 -.138 -.1 -.04 .112 .2 .315 .415 .506 .57 .586 .574 .519];
 




%% Section 6: Load Files 

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
L{k}=string(ls(imageDirectory{k}));
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





%% Section 7: Initiate Loop


for j=1:length(L{1}(:))

    % For Each Camera
    for k=1:camnum
    % Load Image
    I{k}=imread(strcat(imageDirectory{k}, '\', L{k}(j)));
    end




    
%% Section 8: Perform Rectification

% If fixed station and Z is not constant, assign a corresponding z
% elevation.
if isempty(zVariable)==0
    Z=Z.*0+zVariable(j);
end

%Pull Correct Extrinsics out, Corresponding In time
for k=1:camnum 
extrinsics{k}=Extrinsics{k}(j,:);
end
intrinsics=Intrinsics;


[Ir]= imageRectifier(I,intrinsics,extrinsics,X,Y,Z,0);





%% Section 9: Initiate Image Product variables of correct size and format
if j==1
iDark=double(Ir).*0+255; % Can't initialize as zero, will always be dark
iTimex=double(Ir).*0;
iBright=uint8(Ir).*0;
end





%% Section 10: Perform Statistical Calcutions
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





%% Section 11: Output Frames (optional)
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





%% Section 12: Plot  Image Products

f1=figure;
rectificationPlotter(iTimex,X,Y,1)
title('Timex')


f2=figure;
rectificationPlotter(iBright,X,Y,1)
title('Bright')


f3=figure;
rectificationPlotter(iDark,X,Y,1)
title('Dark')





%% Section 13: Save Image Products + Meta Data
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
rectMeta.imageDirectory=imageDirectory;
rectMeta.gridPath=gridPath;
rectMeta.imageNames=L;
rectMeta.t=t;
rectMeta.zVariable=zVariable;
% If A local Grid Add Information
if localFlag==1
rectMeta.localFlag=1;
rectMeta.localAngle=localAngle;
rectMeta.localOrigin=localOrigin;
end
rectMeta.worldCoord=worldCoord;


save(strcat(odir, '\',oname, '_gridMeta'), 'X','Y','Z','rectMeta','t')





























