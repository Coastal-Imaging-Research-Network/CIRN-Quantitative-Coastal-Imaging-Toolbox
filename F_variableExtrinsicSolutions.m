%% F_variableExtrinsicSolutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates extrinsics for a series of subsequent images for 
% where the extrinsic solution of the first frame is known, calculated in 
% C_singleExtrinsicSoltuion. Given a list of images, Stabilization Control 
% Points UVd coordinates (from E_scpSelection), and SCP elevations, this 
% function will determine the extrinsics of each subsequent frames. 

% Similarly to C_singleExtrinsicSolution, the script uses a nonlinear 
% solver to minimize the error between the reprojected XYZ values 
% reprojected in UV space and those indentified in the imagery. However, 
% the images are not ‘clicked’ but rather found by the threshold center of 
% area calculations. The XYZ SCP files are not provided by a text file, but 
% rather determined from georectifying the UV coordinates using the 
% previous frames extrinsics (the user does specify a SCP elevation 
% estimate in the script). The script runs autonomously with no user-
% interaction, calculated SCP center of areas are plotted for each new 
% frame in a figure; the function outputs a mat file with IOEO solutions 
% for each frame as well as figure plotting the camera extrinsics as a 
% function of time.

%  Input:
%  Entered by user below in Sections 1-3. In Section 1 the user will input
%  output names.  Section 2 will require information for the initial
%  solution including as the initial EOIO and image calculated in 
%  C_singleExtrinsicSolutions and the SCP selection in E_scpSelection. 
%  Section 3 will require the location of the oblique imagery
%  to be stabilized. Imaging timing can also be entered, if not, images 
%  times will be entered as numbers, 1,2,3..etc. 


% Output:
% A mat file with an extrinsics matrix for each image in world coordinates
% as well as an imname as well as cell with  corresponding image names. 
% Metadata structures will also be saved named variableCamSolutionMeta and 
% initialCamSolutionMeta. The mat filename will be appended with 
% IOEOVariable. Figures of extrinsics variation in time will also be
% presented.


%  Required CIRN Functions:
%  thresholdCenter
%  extrinsicsSolver
%       xyz2DistUV
%  distUV2XYZ
%       intrinsicsExtrinsics2P
%       undistortUV
%  xyz2DistUV
%       distortUV
%       intrinsicsExtrinsics2P


%  Required MATLAB Toolboxes:
%  statistics Toolbox


%  This function is to be run sixth in the progression to solve extrinsics 
%  for a moving camera.
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
%  Name should be descriptive of the image timing, IOEO solution, and 
%  camera name, and grid used.

oname='uasDemo';

%  Enter the directory where the IOEO file will be saved.
odir= '.\X_UASDemoData\extrinsicsIntrinsics\';





%% Section 2: User Input:  Initial Frame information

%  Enter the filename of the first image where IOEO is known. It should be
%  the same image you did the initial solution for in 
%  C_singleExtrinsicsSolution (initialCamSolutionMeta.impath). It should be
%  in the same directory as your other colleciton images imagesDirectory.

firstFrame= 'uasDemo_1443742140000.tif';


%  Enter the filepath of the saved CIRN IOEO calibration results produced by 
%  C_singleExtrinsicSolution for image in impath. 
ioeopath= '.\X_UASDemoData\extrinsicsIntrinsics\InitialValues\uasDemo_IOEOInitial.mat';





%   Enter the filepath of the Stabilization Control Points (SCP)  calculated
%   for the image in impath found in E_scpSelection. 
scppath= '.\X_UASDemoData\extrinsicsIntrinsics\InitialValues\uasDemo_scpUVdInitial.mat';

% Enter the elevations, or z values for each SCP entry in the scp structure
% saved in scppath. The first column is the corresponding scp.num and the
% second value is the estimated zvalue for the point. Z value should be in
% same world coordinate system as IOEO
% (initailCamSolutionMeta.worldCoordSys)

scpz=[ 1  7; % scp.num   z value
       2  7;
       3  7;
       4  7];

%  Enter the coordinate system of the elevations entered in for scp. Z 
%  value should be in same world coordinate system as IOEO
% (initailCamSolutionMeta.worldCoordSys)

scpZcoord='NAVD88; m units';





%% Section 3: User Input:  Collection Imagery

%  Enter the directory where the collection images are stored. Note, the
%  names of the images should be so that MATLAB lists them in order in the
%  current directory window. To do this, images must be numbered with the
%  same number of digits. Example: numbering should be 00001,00002,00003
%  etc. NOT 1,2,3. Also acceptible is any date number either in matlab
%  datenum or epochtime as output in A0_move2frames. Also, only have the 
%  images in the folder. Nothing else.

imageDirectory='.\X_UASDemoData\collectionData\uasDemo_2Hz\';


%  Enter the dt in seconds of the collect. If not known, leave as {}. Under
%  t, images will just be numbered 1,2,3,4. 

dts= .5; %Seconds


%  Enter the time of the initial image in MATLAB Datenum format; if unknown
%  leave empty {}, to will be set to 0.
to=datenum(2015,10,1,23,29,0);





%% Section 4: Load IOEO and SCP files 

% Load IOEO
load(ioeopath)

% Load SCP
load(scppath);

% Assign SCP Elevations to each SCP Point.
for k=1:length(scp)
i=find(scpz(:,1)==scp(k).num);
scp(k).z=scpz(i,2);
end

% Put SCP in format for distUV2XYZ
for k=1:length(scp)
scpZ(k)=scp(k).z;
scpUVd(:,k)=[scp(k).UVdo'];
end





%% Section 5: Find List of Images and Assign TIme


% Get List of images in directory
L=string(ls(imageDirectory));

% Find Indicie of First Image. Assumes it is in same folder as
% ImageDirectory
chk=cellfun(@isempty,strfind(L,firstFrame));
ffInd=find(chk==0);

% Get List of Indicies (first frame to last). (Assumes that images are in
% order, and only images are in folder). 
ind=ffInd:length(chk);

% Assign time vector, if dts is left empty, vector will just be image
% number
if isempty(dts)==0
    t=(dts./24./3600).*([1:length(ind)]-1)+ to;
else if isempty(dts)==1
    t=(1:length(ind))-1;
end
end





%% Section 6: Initialize Extrinsic Values and Figures for Loop

% Plot Initial Frame and SCP Locations
In=imread(strcat(imageDirectory, '\', L(ffInd,:)));
f1=figure;
imshow(In)
hold on
for k=1:length(scp)
plot(scp(k).UVdo(1),scp(k).UVdo(2),'ro','linewidth',2,'markersize',10)
end

if isempty(dts)==1
title(['Frame: ' num2str(t(1))])
else
title(['Frame 1: ' datestr(t(1))])
end


% Initiate Extrinsics Matrix and First Frame Imagery
extrinsicsVariable=nan(length(ind),6);
extrinsicsVariable(1,:)=extrinsics; % First Value is first frame extrinsics.
extrinsicsUncert(1,:)=initialCamSolutionMeta.extrinsicsUncert;


%  Determine XYZ Values of SCP UVdo points
%  We find the XYZ values of the first frame SCP UVdo points, assuming the 
%  z coordinate is the elevations we entered in Section 2. We find xyz, 
%  so when we find the corresponding SCP feature in our next images In, 
%  we can treat our SCPs as gcps, and solve for a new extrinsics_n for each
 % iteration
[xyzo] = distUV2XYZ(intrinsics,extrinsics,scpUVd,'z',scpZ);



% Initiate and rename initial image, Extrinsics, and SCPUVds for loop

extrinsics_n=extrinsics;
scpUVdn=scpUVd;





%% Section 7: Start Solving Extrinsics for Each image.
imCount=1;

for k=ind(2:end)

% Assign last Known Extrinsics and SCP UVd coords
extrinsics_o=extrinsics_n; 
scpUVdo=scpUVdn;


%  Load the New Image
In=imread(strcat(imageDirectory, '\', L(k,:)));


% Find the new UVd coordinate for each SCPs
for j=1:length(scp)
% Using the Previous scpUVdo as a guess, find the new SCP with prescribed
% Radius and Threshold

[ Udn, Vdn, i, udi,vdi] = thresholdCenter(In,scpUVdo(1,j),scpUVdo(2,j),scp(j).R,scp(j).T);
    % If the function errors here, most likely your threshold was too high or
    % your radius too small for  a scp. Look at scpUVdo to see if there is a
    % nan value, if so  you will have to redo E_scpSelection with bigger
    % tolerances.
    
%Assingning New Coordinate Location
scpUVdn(:,j)=[Udn; Vdn];
end


% Solve For new Extrinsics using last frame extrinsics as initial guess and
% scps as gcps
extrinsicsInitialGuess=extrinsics_o;
extrinsicsKnownsFlag=[0 0 0 0 0 0];
[extrinsics_n extrinsicsError]= extrinsicsSolver(extrinsicsInitialGuess,extrinsicsKnownsFlag,intrinsics,scpUVdo',xyzo);


% Save Extrinsics in Matrix
imCount=imCount+1;
extrinsicsVariable(imCount,:)=extrinsics_n;
extrinsicsUncert(imCount,:)=extrinsicsError;



% Plot new Image and new UV coordinates, found by threshold and reprojected
cla
imshow(In)
hold on

% Plot Newly Found UVdn by Threshold
plot(scpUVdn(1,:),scpUVdn(2,:),'ro','linewidth',2,'markersize',10)

% Plot Reprojected UVd using new Extrinsics and original xyzo coordinates
[UVd] = xyz2DistUV(intrinsics,extrinsics_n,xyzo);
uvchk = reshape(UVd,[],2);
plot(uvchk(:,1),uvchk(:,2),'yo','linewidth',2,'markersize',10)

% Plotting Clean-up
if isempty(dts)==1
title(['Frame: ' num2str(t(imCount))])
else
title(['Frame ' num2str(imCount) ': ' datestr(t(imCount))])
end
legend('SCP Threshold','SCP Reprojected')
pause(.05)

end





%% Section 8: Plot Change in Extrinsics from Initial Frame

f2=figure;

% XCoordinate
subplot(6,1,1)
plot(t,extrinsicsVariable(:,1)-extrinsicsVariable(1,1))
ylabel('\Delta x')
title('Change in Extrinsics over Collection')

% YCoordinate
subplot(6,1,2)
plot(t,extrinsicsVariable(:,2)-extrinsicsVariable(1,2))
ylabel('\Delta y')

% ZCoordinate
subplot(6,1,3)
plot(t,extrinsicsVariable(:,3)-extrinsicsVariable(1,3))
ylabel('\Delta z')

% Azimuth
subplot(6,1,4)
plot(t,rad2deg(extrinsicsVariable(:,4)-extrinsicsVariable(1,4)))
ylabel('\Delta Azimuth [^o]')

% Tilt
subplot(6,1,5)
plot(t,rad2deg(extrinsicsVariable(:,5)-extrinsicsVariable(1,5)))
ylabel('\Delta Tilt[^o]')

% Swing
subplot(6,1,6)
plot(t,rad2deg(extrinsicsVariable(:,6)-extrinsicsVariable(1,6)))
ylabel('\Delta Swing [^o]')


% Set grid and datetick if time is provided
for k=1:6
subplot(6,1,k)
grid on

    if isempty(dts)==0
    datetick
    end
end





%% Section 9: Saving Extrinsics and Metadata
%  Saving Extrinsics and corresponding image names
extrinsics=extrinsicsVariable;
imageNames=L(ind);


% Saving MetaData
variableCamSolutionMeta.scpPath=scppath;
variableCamSolutionMeta.scpo=scp;
variableCamSolutionMeta.scpZcoord=scpZcoord;
variableCamSolutionMeta.ioeopath=ioeopath;
variableCamSolutionMeta.imageDirectory=imageDirectory;
variableCamSolutionMeta.dts=dts;
variableCamSolutionMeta.to=to;


% Calculate Some Statsitics
variableCamSolutionMeta.solutionSTD= sqrt(var(extrinsics));

%  Save File
save([odir '/' oname '_IOEOVariable' ],'extrinsics','variableCamSolutionMeta','imageNames','t','intrinsics')


%  Display
disp(' ')
disp(['Extrinsics for ' num2str(length(L)) ' frames calculated.'])
disp(' ')
disp(['X Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(1))])
disp(['Y Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(2))])
disp(['Z Standard Dev: ' num2str(variableCamSolutionMeta.solutionSTD(3))])
disp(['Azimuth Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(4))) ' deg'])
disp(['Tilt Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(5))) ' deg'])
disp(['Swing Standard Dev: ' num2str(rad2deg(variableCamSolutionMeta.solutionSTD(6))) ' deg'])









