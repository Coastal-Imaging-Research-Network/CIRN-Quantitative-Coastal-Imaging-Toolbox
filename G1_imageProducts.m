%% G_imageProducts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function generates statistical image products for a given set of
%  images and corresponding extrinsics/intrinsics. The statistical image
%  products are the timex, brightest, variance, darkest. If specified,
%  rectified imagery for each image can be produced and saved as an png
%  file. Rectified images and image products can be produced in world or
%  local coordinates if specified in the grid provided by
%  D_gridGenExampleRect. This can function can be used for a collection
%  with variable (UAS) and fixed intriniscs. 


%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-4. In Section 1 the user will input
%  output names and whether individual rectified frames will be output.  
%  Section 2 will require information for the collection, i.e. the 
%  directory of the oblique images and extrinsics solutions calculated by 
%  C_singleExtrinsicSolution (Fixed Camera) or F_variableExtrinsicSolution
%  (UAS). Section 3 will require rectification grid information produced by
%  D_gridGenExampleRect. Section 4 will require any variation of z
%  elevation if known throughout the collect (only applicable for long term
%  fixed stations with temporally varying z grids, not short UAS collects). 


% Output:
% 5 Image Products  as well as individual rectified frames if desired saved 
% as pngs. The accompanying metadata will be saved along with grid
% information in a mat file in the same ouputdirectory as the images.


%  Required CIRN Functions: 
%  imageRectification
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

oname='uasDemo';

%  Enter the directory where the images will be saved.
odir= '.\X_UASDemoData\output\uasDemoFlightRectified';


%  Enter if you would like individual frames rectified and output. 1= yes,
%  output individual frames. 0= no, only output image products.
outputFlag=1;





%% Section 2: User Input:  Collection Information

%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution for fixed or F_variableExtrinsicSolutions for
%  UAS.
ioeopath= '.\X_UASDemoData\extrinsicsIntrinsics\uasDemo_IOEOVariable.mat';

%  Enter the directory where your oblique imagery is stored. For UAS, the
%  names of the images must match those in imageNames output produced by
%  F_variableExtrinsicSolutions. For fixed cameras, the directory should
%  only have images in it, nothing else. 

obliqueImageDirectory='.\X_UASDemoData\collectionImages\uasDemoFlight\';




%% Section 3: User Input: Grid Information

% Enter the filepath of the saved rectification grid created in
% D_gridGenExampleRect. Grid world coordinates need to be same coordinates
% as those in the extrinsics in ieopath. Grid needs to be meshgrid format
% with variables X,Y, and Z. 
gridPath='.\X_UASDemoData\rectificationGrids\GRID_uasDemo_NCSP_1mResolution.mat';


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

%  If a Fixed station, most likely images will span times where Z is no
%  longer constant. We have to account for this in our Z grid. To do this,
%  enter a z vector below that is the same length as t. For each frame, the
%  entire z grid will be assigned to this value. If UAS or not desired,
%  leave empty. It is assumed elevation is constant during a short collect.
zFixedCam={};

%% Section 5: Load Files 

% Load List of Collection Images
L=string(ls(obliqueImageDirectory));
L=L(3:end); % First two are always empty

% Load Extrinsics
load(ioeopath)

% Check if fixed or variable. If fixed (length(extrinsics(:,1))==1), make
% an extrinsic matrix the same length as L, just with initial extrinsics
% repeated.
if length(extrinsics(:,1))==1
extrinsics=repmat(extrinsics,length(L),1);
end

% Load Grid File
load(gridPath)

% Check if Local  Desired
if localFlag==1
extrinsics=localTransformExtrinsics(localOrigin,localAngle,1,extrinsics);
X=localX;
Y=localY;
Z=localZ;
end



%% Section 6: Initiate Loop


for k=1:length(L)

% Load Image
I=imread(strcat(obliqueImageDirectory, '\', L(k)));






%% Section 7: Perform Rectification

% If fixed station and Z is not constant, assign a corresponding z
% elevation.
if isempty(zFixedCam)==0
    Z=Z.*0+z(k);
end

%Rectify
[Ir]= imageRectifier(I,intrinsics,extrinsics(k,:),X,Y,Z,0);





%% Section 8: Initiate Image Product variables of correct size and format
if k==1
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
if k==length(L)
iTimex=uint8(iTimex./length(L));
end




%% Section 10: Output Frames (optional)
% Remove oblique FileExtension So it can be appended to rectified image
% name
iname=strsplit(L(k),'.');
iname=iname(end-1);

% Save Image
imwrite(flipud(Ir),strcat(odir, '\',oname, '_', iname,'.png'))

% Display progress
disp([ 'Frame ' num2str(k) ' out of ' num2str(length(L)) ' completed. ' num2str(round(k/length(L)*1000)/10) '%'])

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





























