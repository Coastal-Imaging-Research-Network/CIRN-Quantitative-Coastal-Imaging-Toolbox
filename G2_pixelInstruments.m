%% I_pixelInstruments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function generates pixel instruments for a given set of images and
%  corresponding extrinsics/extrinsics. It works very similar to
%  G_imageProducts however instead of rectifying a uniform grid for
%  rectified images, we rectify a set of points for runup, vbar, and cbathy
%  calculutions. Rectifications can be made in both world and a local
%  rotated coordinate system. However, for ease and accuracy,
%  if planned to use in cbathy,vbar or runup applications, it should occur
%  in local coordinates. 

%  This can function can be used for a collection with variable (UAS) 
%  and fixed intriniscs in addition to single/multi camera capability. 

%  The current code has input entered for UASDemoData. However, one can
%  uncomment lines directly below input for a multi-camera processing.
%  Users will have to uncomment lines in Sections 1-4.


%  Note: This function is not intended to replace the CIRN pixeltoolbox.
%  That toolbox is for advanced users with more complicated fixed stations
%  with multiple cameras. This function is just for teaching purposes. 



%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-3. In Section 1 the user will input
%  output names.  Section 2 will require information for the collection, i.e. the 
%  directory of the images and extrinsics solutions calculated by 
%  C_singleExtrinsicSolution (Fixed Camera) or F_variableExtrinsicSolution
%  (UAS). Section 3 will require information concerning the pixel
%  instruments such as type, coordinate systems, and dimensions. For
%  multi-camera processing, users will have to uncomment lines in Sections
%  1-4.


% Output:
% A .mat file with the pixel instruments as well as images with the
% instruments plotted as well as run up and vbar stack images.
% Rectification metadata will be included in the matfile.


%  Required CIRN Functions: 
%  imageRectification
%  xyz2DistUV
%   distortUV
%   intrinsicsExtrinsics2P
%  localTransformExtrinsics
%   localTransformPoints



%  Required MATLAB Toolboxes:
%  none


%  This function is to be run sixth (eigth) in the CIRN BOOTCAMP TOOLBOX
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

%  Enter the filename the instruments will be saved as. Name should be
%  descriptive of the collection and the instruments. 'pixInstruments' will
%  be appended to the saved file name.

oname='uasDemo';
        
        % For Multi Cam
        %oname='fixedMultiCamDemo';
        
        
        
%  Enter the directory where the instrument file will be saved.
odir= '.\X_UASDemoData\output\uasDemoFlightRectified';
        
        % For Multi Cam
        %odir= '.\X_FixedMultCamDemoData\output\fixedMultCamDemoRectified';
        


%% Section 2: User Input:  Collection Information

%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution for fixed or F_variableExtrinsicSolutions for
%  UAS.
ioeopath{1}= '.\X_UASDemoData\extrinsicsIntrinsics\uasDemo_IOEOVariable.mat';
 
        % %  If multi-Camera, enter each filepath as a cell entry for each camera.
        % %  Note, all extrinsics must be in same coordinate system.
        %ioeopath{1}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c5_202003032100Photo_20200429Calib.mat';
        %ioeopath{2}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c6_202003032100Photo_20200429Calib.mat';
        %ioeopath{3}=  '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c7_202003032100Photo_20200429Calib.mat';
        %ioeopath{4}= '.\X_FixedMultCamDemoData\extrinsicsIntrinsics\c8_202003032100Photo_20200429Calib.mat';
        
        

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
        %obliqueImageDirectory{1}='.\X_FixedMultCamDemoData\collectionData\c5';
        %obliqueImageDirectory{2}='.\X_FixedMultCamDemoData\collectionData\c6';
        %obliqueImageDirectory{3}='.\X_FixedMultCamDemoData\collectionData\c7';
        %obliqueImageDirectory{4}='.\X_FixedMultCamDemoData\collectionData\c8';




%% Section 3: User Input: Fixed Station 
%  If a fixed station a time vector can be provided in the datenum format.
%  The length of the vector must match the number of images rectified and
%  coorectly correspond to each image. If using UAS or not desired, leave
%  empty. If a UAS collect this varibale is defined in 
%  F_variableExrtrinsicSolutions.
t={};
        % For Multi Cam
        %t=[737835.791666667,737835.833333333,737835.875, 737835.916666667,737835.958333333];
        


%  If a Fixed station, most likely images will span times where Z is no
%  longer constant. We have to account for this in our Z grid. To do this,
%  enter a z vector below that is the same length as t. For each frame, the
%  entire z grid will be assigned to this value.  It is assumed elevation 
%  is constant during a short
%  collect. If you would like to enter a z grid that is variable in space
%  and time, the user would have to alter the code to assign a unique Z in
%  every loop iteration. See section 3 of D_gridGenExampleRect for more
%  information. If UAS or not desired, leave empty.
zFixedCam={};






%% Section 4: User Input: Instrument Information


% Enter the filepath of the saved rectification grid created in
% D_gridGenExampleRect. Grid world coordinates need to be same coordinates
% as those in the extrinsics in ieopath. Note, resolution of the grid is
% irrelvant for instruments you desire. THe grid is used for defining a
% local coordinate system, and pulling z elevation values. THus, if you
% have a spatially variable Z grid, you may want grid dx,dy resolutions to be
% similar to your instruments. 
gridPath='.\X_UASDemoData\rectificationGrids\GRID_uasDemo_NCSP_10mResolution.mat';
        
        % Grid for Multi-Camera Fixed Demo
        %gridPath='.\X_FixedMultCamDemoData\rectificationGrids\GRID_fixedMultiCamDemo_H3SP_1mResolution.mat';

% Enter if the user prefers local (localFlag==1) or world (localFlag==0)
% coordinates as input. Not if localFlag==1, localAngle, localOrigin, and localX,Y,Z
% in the ioeopath must all be non-empty.
localFlag=1;


% Instrument Entries
%  Enter the parameters for the isntruments below. If more than one insturment
%  is desired copy and paste the entry with a second entry in the structure. 
%  Note, the coordinate system
%  should be the same as specified above, if localFlag==1 the specified 
%  parameters should be in local coordinates and same units. 

%  Note: To reduce clutter in the code, pixel instruments were input in
%  local coordinates so it could be used for both mulit and Uas demos. The
%  entered coordinates are optimized for the UASDemo and may not be
%  optmized for the multi-camera demo.



%  Example CBathy Grid
%  Enter the following parameters for a cbathy grid. Note, dx and dy do not
%  need to be equal. 
    pixInst(1).type='cbathyGrid';
    pixInst(1). dx =5;
    pixInst(1). dy =5;
    pixInst(1). xlim =[80 400];
    pixInst(1). ylim =[450 900];
    pixInst(1).z={}; % Leave empty if you would like it interpolated from input
                    % Z grid or zFixedCam. If entered here it is assumed constant
                    % across domain and in time. 




    %  VBar (Alongshore Transects)
    %  Enter the following parameters for a vbar vector. 

    pixInst(2).type='yTransect';
    pixInst(2).x= 225;
    pixInst(2).ylim=[450 900];
    pixInst(2).dy =1;
    pixInst(2).z ={};  % Leave empty if you would like it interpolated from input
                    % Z grid or zFixedCam. If entered here it is assumed constant
                    % across domain and in time. 

    



    %  Runup (Cross-shore Transects)
    %  Enter the following parameters for a run up vector. 

    pixInst(3).type='xTransect';
    pixInst(3).y= 600;
    pixInst(3).xlim=[70 125];
    pixInst(3).dx =1;
    pixInst(3).z ={};  % Leave empty if you would like it interpolated from input
                    % Z grid or zFixedCam. If entered here it is assumed constant
                    % across domain and in time. 

    



    

                    
                    
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






%% Section 6: Initialize Pixel Instruments 

% Make XYZ Grids/Vectors from Specifications. 
[pixInst]=pixInstPrepXYZ(pixInst);

% Assign Z Elevations Depending on provided parameters.
% If pixInst.z is left empty, assign it correct elevation 
for p=1:length(pixInst)
if isempty(pixInst(p).z)==1
    if isempty(zFixedCam)==1 % If a Time-varying z is not specified
        pixInst(p).Z=interp2(X,Y,Z,pixInst(p).X,pixInst(p).Y); % Interpret from given grid
    end

    if isempty(zFixedCam)==0 % If a time varying z is specified
        pixInst(p).Z=pixInst(p).X.*0+zFixedCam(1); % Assign First Value for First Image, spatially constant elevation
    end
end
end





%% Section 7: Plot Pixel Instruments 
f1=figure;
hold on
for k=1:camnum
% Load and Display initial Oblique Distorted Image
I=imread(strcat(obliqueImageDirectory{k}, '\', L{k}(1)));
subplot(1,camnum,k)

imshow(I)
hold on
title('Pixel Instruments')

% For Each Instrument, Determin UVd points and plot on image
for p=1:length(pixInst)
    
    % Put in Format xyz for xyz2distUVd
    xyz=cat(2,pixInst(p).X(:),pixInst(p).Y(:),pixInst(p).Z(:));
    
    %Pull Correct Extrinsics out, Corresponding In time
   
    extrinsics=Extrinsics{k}(1,:);
    intrinsics=Intrinsics{k};
    
    
    % Determine UVd Points from intrinsics and initial extrinsics
    [UVd] = xyz2DistUV(intrinsics,extrinsics,xyz);
    
    % Make A size Suitable for Plotting
    UVd = reshape(UVd,[],2);
    plot(UVd(:,1),UVd(:,2),'*')
    xlim([0 intrinsics(1)])
    ylim([0  intrinsics(2)])
    
    % Make legend
    le{p}= [num2str(p) ' ' pixInst(p).type ];
end
legend(le)
clear I
clear extrinsics
clear intrinsics
end

% Allows for the instruments to be plotted before processing
pause(1)




%% Section 7:  Loop for Collecting Pixel Instrument Data. 

for j=1:length(L{1}(:))

    % For Each Camera
    for k=1:camnum
    % Load Image
    I{k}=imread(strcat(obliqueImageDirectory{k}, '\', L{k}(j)));
    end

%  Loop for Each Pixel Instrument
    for p=1:length(pixInst)

    % Check if a time varying Z was specified. If not, wil just use constant Z
    % specified or interpolated from grid in Section 4 and 6 respectively.
    if isempty(pixInst(p).z)==1
    if isempty(zFixedCam)==0 % If a time varying z is specified
            pixInst(p).Z=pixInst(p).X.*0+zFixedCam(j); % Assign First Value for First Image, spatially constant elevation
    end
    end    

    %Pull Correct Extrinsics out, Corresponding In time
    for k=1:camnum 
    extrinsics{k}=Extrinsics{k}(j,:);
    end
    intrinsics=Intrinsics;

    % Pull RGB Pixel Intensities 
    [Irgb]= imageRectifier(I,intrinsics,extrinsics,pixInst(p).X,pixInst(p).Y,pixInst(p).Z,0);
  
    
    % Convert To Grayscale
    [Igray]=rgb2gray(Irgb);

    

    
    % If First frame, initialize pixInst structure entries
    if j==1
    pixInst(p).Igray=Igray;
    pixInst(p).Irgb=Irgb;
    end
    
    % If not First frame, tack on as last dimension (time).
    if j~=1
    s=size(Igray);
    nDim= length(find(s~=1)); % Finds number of actual dimension is =1 (transects) or 2 (cbathy)nDim
    
    % For Gray Scale it is straight forward
    pixInst(p).Igray=cat(nDim+1,pixInst(p).Igray,Igray); % Add on last dimension (third if cbathy, second if transects)
    
        % For RGB it is trickier since MATLAB always likes rgb values in
        % third dimension.
        % If a cbathyGrid Add in the fourth dimension
        if nDim==2
        pixInst(p).Irgb=cat(nDim+2,pixInst(p).Irgb,Irgb); % Add on last dimension (Always Fourth)
        end
        % If a Transect Grid Add in the second dimension
        if nDim==1
        pixInst(p).Irgb=cat(2,pixInst(p).Irgb,Irgb); % Add on last dimension (Always Fourth)
        end   

    end
    end
    
    
    % Display progress
    disp([ 'Frame ' num2str(j) ' out of ' num2str(length(L{k}(:))) ' completed. ' num2str(round(j/length(L{k}(:))*1000)/10) '%'])

end


%% Section 8: Plot Instrument Data
% For Each Instrument Plot the Data, note, if cbathy data only the first
% frame will be plotted.

for p=1:length(pixInst)
  
    %Create Figure and Add Title Specifying Instrument Number and Type
   figure;
   title([num2str(p) ' ' pixInst(p).type ])
   hold on
   
   % If cbathy use rectificationPlotter
   if strcmp(pixInst(p).type,'cbathyGrid')==1
   rectificationPlotter(pixInst(p).Irgb(:,:,:,1),pixInst(p).X,pixInst(p).Y,1); % Plot First Frame RGB    
   end
   
   % If Transect use stackPlotter
   
   
   if strcmp(pixInst(p).type,'xTransect')==1
     
       stackPlotter(pixInst(p).Irgb,pixInst(p).X,t, 'x', 1)
       
       %If t non empty, add datetick to axis
       if isempty(t)==0
            datetick('y')
       end
   end
    
    
   if strcmp(pixInst(p).type,'yTransect')==1
       stackPlotter(pixInst(p).Irgb,pixInst(p).Y,t, 'y', 1)
       %If t non empty, add datetick to axis
       if isempty(t)==0
            datetick('x')
       end
   end
    
    
    
    
end






%% Section 9: Save Instruments and Meta Data

% Save metaData and Grid Data
rectMeta.solutionPath=ioeopath;
rectMeta.obliqueImageDirectory=obliqueImageDirectory;
rectMeta.imageNames=L;
rectMeta.t=t;
rectMeta.worldCoord=worldCoord;

% If A local Grid Add Information
if localFlag==1
rectMeta.localFlag=1;
rectMeta.localAngle=localAngle;
rectMeta.localOrigin=localOrigin;
end


save(strcat(odir, '\',oname, '_pixInst'), 'pixInst','rectMeta','t')



