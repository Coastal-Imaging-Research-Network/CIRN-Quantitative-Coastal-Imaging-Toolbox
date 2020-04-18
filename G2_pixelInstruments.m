%% I_pixelInstruments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function generates pixel instruments for a given set of images and
%  corresponding extrinsics/extrinsics. It works very similar to
%  G_imageProducts however instead of rectifying a uniform grid for
%  rectified images, we rectify a set of points for runup, vbar, and cbathy
%  calculutions. Rectifications can be made in both world and a local
%  rotated coordinate system. However, for ease and accuracy,
%  if planned to use in cbathy,vbar or runup applications, it should occur
%  in local coordinates. This can function can be used for a collection
%  with variable (UAS) and fixed intriniscs. 

%  Note: This function is not intended to replace the CIRN pixeltoolbox.
%  That toolbox is for advanced users with more complicated fixed stations
%  with multiple cameras. This function is just for teaching purposes. It
%  will be refactored to include the pixel toolbox in the future for 
%  operational stations. 



%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-3. In Section 1 the user will input
%  output names.  Section 2 will require information for the collection, i.e. the 
%  directory of the images and extrinsics solutions calculated by 
%  C_singleExtrinsicSolution (Fixed Camera) or F_variableExtrinsicSolution
%  (UAS). Section 3 will require information concerning the pixel
%  instruments such as type, coordinate systems, and dimensions. 


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



%% Section 1: User Input:  Output

%  Enter the filename the instruments will be saved as. Name should be
%  descriptive of the collection and the instruments. 'pixInstruments' will
%  be appended to the saved file name.

oname='uasDemo';

%  Enter the directory where the instrument file will be saved.
odir= '.\X_UASDemoData\output\uasDemoFlightRectified';




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






%% Section 3: User Input: Fixed Station 
%  If a fixed station a time vector can be provided in the datenum format.
%  The length of the vector must match the number of images rectified and
%  coorectly correspond to each image. If using UAS or not desired, leave
%  empty. If a UAS collect this varibale is defined in 
%  F_variableExrtrinsicSolutions.
t={};

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
gridPath='.\X_UASDemoData\rectificationGrids\GRID_uasDemo_NCSP_1mResolution.mat';


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
    pixInst(2).dy =2;
    pixInst(2).z ={};  % Leave empty if you would like it interpolated from input
                    % Z grid or zFixedCam. If entered here it is assumed constant
                    % across domain and in time. 

    



    %  Runup (Cross-shore Transects)
    %  Enter the following parameters for a run up vector. 

    pixInst(3).type='xTransect';
    pixInst(3).y= 600;
    pixInst(3).xlim=[70 125];
    pixInst(3).dx =2;
    pixInst(3).z ={};  % Leave empty if you would like it interpolated from input
                    % Z grid or zFixedCam. If entered here it is assumed constant
                    % across domain and in time. 

    



    

                    
                    
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





%% Section 6: Initialize Pixel Instruments 

% Make XYZ Grids/Vectors from Specifications. 
[pixInst]=pixInstPrepXYZ(pixInst);

% Assign Z Elevations Depending on provided parameters.
% If pixInst.z is left empty, assign it correct elevation 
for k=1:length(pixInst)
if isempty(pixInst(k).z)==1
    if isempty(zFixedCam)==1 % If a Time-varying z is not specified
        pixInst(k).Z=interp2(X,Y,Z,pixInst(k).X,pixInst(k).Y); % Interpret from given grid
    end

    if isempty(zFixedCam)==0 % If a time varying z is specified
        pixInst(k).Z=pixInst(k).X.*0+zFixedCam(1); % Assign First Value for First Image, spatially constant elevation
    end
end
end





%% Section 7: Plot Pixel Instruments 

% Load and Display initial Oblique Distorted Image
I=imread(strcat(obliqueImageDirectory, '\', L(1)));

f1=figure;
imshow(I)
hold on
title('Pixel Instruments')

% For Each Instrument, Determin UVd points and plot on image
for k=1:length(pixInst)
    
    % Put in Format xyz for xyz2distUVd
    xyz=cat(2,pixInst(k).X(:),pixInst(k).Y(:),pixInst(k).Z(:));
    
    % Determine UVd Points from intrinsics and initial extrinsics
    [UVd] = xyz2DistUV(intrinsics,extrinsics(1,:),xyz);
    
    % Make A size Suitable for Plotting
    UVd = reshape(UVd,[],2);
    plot(UVd(:,1),UVd(:,2),'*')
    
    % Make legend
    le{k}= [num2str(k) ' ' pixInst(k).type ];
end
legend(le)


% Allows for the instruments to be plotted before processing
pause(1)




%% Section 7:  Loop for Collecting Pixel Instrument Data. 

for k=1:length(L)

% Load Image
I=imread(strcat(obliqueImageDirectory, '\', L(k)));

%  Loop for Each Pixel Instrument
    for j=1:length(pixInst)

    % Check if a time varying Z was specified. If not, wil just use constant Z
    % specified or interpolated from grid in Section 4 and 6 respectively.
    if isempty(pixInst(j).z)==1
    if isempty(zFixedCam)==0 % If a time varying z is specified
            pixInst(j).Z=pixInst(j).X.*0+zFixedCam(k); % Assign First Value for First Image, spatially constant elevation
    end
    end    


    % Pull RGB Pixel Intensities 
    [Irgb]= imageRectifier(I,intrinsics,extrinsics(k,:),pixInst(j).X,pixInst(j).Y,pixInst(j).Z,0);
  
    
    % Convert To Grayscale
    [Igray]=rgb2gray(Irgb);

    

    
    % If First frame, initialize pixInst structure entries
    if k==1
    pixInst(j).Igray=Igray;
    pixInst(j).Irgb=Irgb;
    end
    
    % If not First frame, tack on as last dimension (time).
    if k~=1
    s=size(Igray);
    nDim= length(find(s~=1)); % Finds number of actual dimension is =1 (transects) or 2 (cbathy)nDim
    
    % For Gray Scale it is straight forward
    pixInst(j).Igray=cat(nDim+1,pixInst(j).Igray,Igray); % Add on last dimension (third if cbathy, second if transects)
    
        % For RGB it is trickier since MATLAB always likes rgb values in
        % third dimension.
        % If a cbathyGrid Add in the fourth dimension
        if nDim==2
        pixInst(j).Irgb=cat(nDim+2,pixInst(j).Irgb,Irgb); % Add on last dimension (Always Fourth)
        end
        % If a Transect Grid Add in the second dimension
        if nDim==1
        pixInst(j).Irgb=cat(2,pixInst(j).Irgb,Irgb); % Add on last dimension (Always Fourth)
        end   

    end
    end
    
    
    % Display progress
    disp([ 'Frame ' num2str(k) ' out of ' num2str(length(L)) ' completed. ' num2str(round(k/length(L)*1000)/10) '%'])

end


%% Section 8: Plot Instrument Data
% For Each Instrument Plot the Data, note, if cbathy data only the first
% frame will be plotted.

for k=1:length(pixInst)
  
    %Create Figure and Add Title Specifying Instrument Number and Type
   figure;
   title([num2str(k) ' ' pixInst(k).type ])
   hold on
   
   % If cbathy use rectificationPlotter
   if strcmp(pixInst(k).type,'cbathyGrid')==1
   rectificationPlotter(pixInst(k).Irgb(:,:,:,1),pixInst(k).X,pixInst(k).Y,1); % Plot First Frame RGB    
   end
   
   % If Transect use stackPlotter
   
   
   if strcmp(pixInst(k).type,'xTransect')==1
     
       stackPlotter(pixInst(k).Irgb,pixInst(k).X,t, 'x', 1)
       
       %If t non empty, add datetick to axis
       if isempty(t)==0
            datetick('y')
       end
   end
    
    
   if strcmp(pixInst(k).type,'yTransect')==1
       stackPlotter(pixInst(k).Irgb,pixInst(k).Y,t, 'y', 1)
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



