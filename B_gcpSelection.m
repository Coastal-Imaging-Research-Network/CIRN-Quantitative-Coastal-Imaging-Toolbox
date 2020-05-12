%% B_gcpSelection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function initializes the GCP structure for a given camera for
%  use in the CIRN BOOTCAMP TOOLBOX.  The user will load a given DISTORTED 
%  image, click on GCPS, and the function will save the DISTORTED UVd 
%  coordinates and image metadata for a given camera.

%  How to use clicking mechanism: The user can zoom and move the image how
%  they please and then hit 'Enter' to begin clicking mode. A left click
%  will select a point, a right click will delete the nearest point to the
%  click. After a left click, the user will be asked to enter a GCP number
%  to identify the GCP in the command window. The user can then zoom again
%  until hitting enter to select the next point. To end the collection, hit
%  enter to enter clicking mode (the cross hairs) and click below the image
%  where it says 'Click Here to End Collection.' The user can click GCPs in
%  any order they would like.

%  Reference Slides:
%  

%  Input:
%  Entered by user below in Sections 1-2. User will enter naming and 
%  location of output in Section 1 and which DISTORTED image to use for GCP
%  clicking. 

%  Output:
%  A .mat file saved as directory/filename as specified by the user.'gcpUVdInitial'
%  will be appended to the name. Will contain gcp structure.

%  Required CIRN Functions:
%  None

%  Required MATLAB Toolboxes:
%  None

%  This function is to be run second in the CIRN BOOTCAMP TOOLBOX
%  progression for each camera in a multi-camera fixed station or for each 
%  recording mode for a UAS platform. GCP calibration should occur any time 
%  a camera has moved for a fixed  station, the first frame in a new UAS 
%  collect, or IO has changed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Housekeeping
close all
clear all

% User should make sure that X_CoreFunctions and subfolders are made active
% in their MATLAB path. Below is the standard location for demo, user will
% need to change if X_CoreFunctions is moved and/or the current script.
addpath(genpath('./X_CoreFunctions/'))



%% Section 1: User Input: Metadata Output

%  Enter the filename of the gcp .mat file that will be saved as. Name 
%  should be descriptive of the camera/recording mode as well as GCP 
%  deployment.
oname='uasDemo';

%  Enter the directory where the mat file will be saved.
odir= '.\X_UASDemoData\extrinsicsIntrinsics\InitialValues';





%% Section 2: User Input: GCP Image
%  Enter the filepath of the saved image for clicking. For UAS, this should
%  be the first image of the collect.
imagePath= '.\X_UASDemoData\collectionImages\uasDemoFlight\00001000.jpg';





%% Section 4: Clicking and Saving GCPS: 
    
if isempty(imagePath)==0

    % Display Image    
    f1=figure;
    
    I=imread(imagePath);
    [r c t]=size(I);

    imagesc(1:c,1:r,I)
    axis equal
    xlim([0 c])
    ylim([0 r])
    xlabel({ 'Ud';'Click Here in Cross-Hair Mode To End Collection '})
    ylabel('Vd')
    hold on

    % Clicking Mechanism
    x=1;
    y=1;
    button=1;
    UVclick=[];

    while x<=c & y<=r % Clicking figure bottom will end clicking opportunity

        % Allow User To Zoom
        title('Zoom axes as Needed. Press Enter to Initiate Click')
        pause

        % Allow User to Click
        title('Left Click to Save. Right Click to Delete')
        [x,y,button] = ginput(1);


        % If a left click, ask user for number, store, and display
        if button==1  & (x<=c & y<=r) 
            
            % Plot GCP in Image
            plot(x,y,'ro','markersize',10,'linewidth',3)
            
            title('Enter GCP Number in Command Window')
            
            % User Input for Number
            num=input('Enter GCP Number:');
            
            % Store Values
            UVclick=cat(1,UVclick, [num x y]);
            
            % Display GCP Number In Image
            text(x+30,y,num2str(num),'color','r','fontweight','bold','fontsize',15)
            
            % Display Values
            disp(['GCP ' num2str(num) ' [U V]= [' num2str(x) ' ' num2str(y) ']'])
            disp(' ')
            figure(f1)
            zoom out
        end   
        
        % If a right click, program will delete nearest point, mark UVClick
        % Entry as unusable with value -99.
        if button==3 & (x<=c & y<=r) 
            % Find Nearest Marker 
            Idx = knnsearch(UVclick(:,2:3),[x y]);
            
            % Turn the visual display off.
            N=length(UVclick(:,1,1))*2+1; % Total Figure Children (Image+ 1 Text + 1 Marker for each Click)
            f1.Children(1).Children(N-(Idx*2)).Visible='off';   % Turn off Text
            f1.Children(1).Children(N-(Idx*2-1)).Visible='off'; % Turn off Marker
            
            %Display Deleted GCP
            disp(['Deleted GCP ' num2str(UVclick(Idx,1))]);
            
            % Set UVclick GCP number to Unusable Value
            UVclick(Idx,1)=-99;
            zoom out
        end

               

    end
     
    % Filter out values that were to be deleted
    IND=find(UVclick(:,1) ~= -99);
    UVsave=UVclick(IND,:);
    
    % Sort so GCP Numbers are in order
    [ia ic]=sort(UVsave(:,1));
    UVsave(:,:)=UVsave(ic,:);
    
    % Place in GCP Format
    for k=1:length(UVsave(:,1))
        gcp(k).UVd=UVsave(k,2:3);
        gcp(k).num=UVsave(k,1);
    end
    

end





%% Section 5: Display Results
disp(['GCPs Entered for ' oname ':'])
disp(' ')

for k=1:length(gcp)
    disp(['gcp(' num2str(k) ').num = ' num2str(gcp(k).num(1)) ] )  
    disp(['gcp(' num2str(k) ').UVd = [' num2str(gcp(k).UVd(1)) ' ' num2str(gcp(k).UVd(2)) ']'])   
end



          

%% Section 6: Save File

% Incorporate imagePath in structure
for k=1:length(gcp)
    if isempty(imagePath)==0  
    gcp(k).imagePath=imagePath;
    else
    gcp(k).imagePath=imagePath_noclick;    
    end
end

% Save Results
save([odir '/' oname '_gcpUVdInitial' ],'gcp')





