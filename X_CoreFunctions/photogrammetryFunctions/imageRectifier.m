%% imageRectifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function performs image rectifications given the associated
%  extrinsics, intrinsics, distorted image, and xyz points. The function utalizes
%  xyz2DistUV to find corresponding UVd values to the input grid and pulls
%  the rgb pixel intensity for each value. If the teachingMode flag is =1,
%  the function will plot corresponding steps (xyz-->UV transformation) as
%  well as rectified output. If a multi-camera rectification is desired, I,
%  intrinsics, and extrinsics can be input as cell values for each camera.
%  The function will then call on cameraSeamBlend to merge the values.

%  Input:
%  Note k can be 1:K, where K is the number of cameras.

%  I{k}= NNxMMx3 image to be rectified. Should have been taken when entered
%  intrinsics and extrinsics are valid and be distorted.

%  intrinsics{k} = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsics{k} = 1x6 Vector representing [ x y z azimuth tilt swing] of
%  the camera EO.  All values should be in the same units and coordinate
%  system of X,Y, and Z grids. Azimuth, Tilt and Swing should be in radians.
%  Note extrinsics for all K cameras should be in same coordinate system.

%  Note, all K cameras will share the same grid.
%  X = Vector or Grid of X coordinates to rectify.
%  Y = Vector or Grid of Y coordinates to rectify.
%  Z = Vector or Grid of Z coordinates to rectify.

%  Note, X,Y, and Z should all be the same size. Also, they should be in
%  the same coordinate system of extrinsics.

%  teachingMode = Flag to indicate whether intermediate steps and output
%  will be plotted.


%  Output:
%  Ir = Image intensities for xyz points. Dimensions depend if input
%  entered as a grid or vector. For both, an additional dimension with size
%  3 is added for r, g, and b intensities. Output will be a uint8 format.


%  Required CIRN Functions:
%  xyz2DistUV
%       -intrinsicsExtrinsics2P
%       -distortUV
%  plotRectification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Ir]= imageRectification(I,intrinsics,extrinsics,X,Y,Z,teachingMode)

%% Section 1: Determine if MultiCam or Single Cam
% If input is for a singular camera and not already a cell, it will make it
% a single entry cell so the loops below will work.

chk=iscell(intrinsics);
if chk==1
    camnum=length(intrinsics);
else
    camnum=1;
    Ip=I;
    extrinsicsp=extrinsics;
    intrinsicsp=intrinsics;
    
    clear I extrinsics intrinsics
    I{1}=Ip;
    extrinsics{1}=extrinsicsp;
    intrinsics{1}=intrinsicsp;
    
end





%% Section 2: Format Grid for xyz2DistUV

x=reshape(X,1,numel(X));
y=reshape(Y,1,numel(Y));
z=reshape(Z,1,numel(Z));
xyz=cat(2,x',y',z');





%% Section 3: Determine Distorted UVd points for each xyz point
% For Each Camera
for k=1:camnum
    
    % Determine UVd Points
    [UVd, flag] = xyz2DistUV(intrinsics{k},extrinsics{k},xyz);
    
    
    % Reshape UVd Matrix so in size of input X,Y,Z
    UVd = reshape(UVd,[],2);
    s=size(X);
    Ud=(reshape(UVd(:,1),s(1),s(2)));
    Vd=(reshape(UVd(:,2),s(1),s(2)));
    
    % Round UVd coordinates so it cooresponds to matrix indicies in image I
    Ud=round(Ud);
    Vd=round(Vd);
    
    % Utalize Flag to remove invalid points. See xyzDistUV and distortUV to see
    % what is considered an invalid point.
    Ud(find(flag==0))=nan;
    Vd(find(flag==0))=nan;
    
    
    
    
    
    %% Section 4: Pull Image Pixel Intensities from Image
    
    % Initiate Ir matrix as same size as input X,Y,Z but with aditional third
    % dimension for rgb values.
    ir=nan(s(1),s(2),3);
    
    % Pull rgb pixel intensities for each point in XYZ
    for kk=1:s(1)
        for j=1:s(2)
            % Make sure not a bad coordinate
            if isnan(Ud(kk,j))==0 & isnan(Vd(kk,j))==0
                % Note how Matlab organizes images, V coordinate corresponds to
                % rows, U to columns. V is 1 at top of matrix, and grows as it
                % goes down. U is 1 at left side of matrix and grows from left
                % to right.
                ir(kk,j,:)=I{k}(Vd(kk,j),Ud(kk,j),:);
            end
        end
    end
    
    % Save Rectifications from Each Camera into A Matrix
    IrIndv(:,:,:,k)=uint8(ir);
    
    % Save Ud Vd coordinates for Plotting in Teaching Mode
    if teachingMode==1
        Udp{k}=Ud;
        Vdp{k}=Vd;
    end
    
    
    clear ir
end






%% Section 5: Merge rectifications of multiple cameras
Ir=cameraSeamBlend(IrIndv);

%% Section 6: Optional for Teaching Mode

if teachingMode==1
    for k=1:camnum
        f1=figure;
        
        % Plot UVd values for each XYZ point on oblique image
        % Colorize by X coordinate
        subplot(2,2,1)
        imshow(I{k})
        hold on
        scatter(Udp{k}(:),Vdp{k}(:),10,X(:),'filled')
        xlabel( 'U')
        ylabel( 'V')
        colorbar
        title('X')
        
        % Colorize by Y coordinate
        subplot(2,2,3)
        imshow(I{k})
        hold on
        scatter(Udp{k}(:),Vdp{k}(:),10,Y(:),'filled')
        xlabel( 'U')
        ylabel( 'V')
        colorbar
        title('Y')
        
        
        
        % Plot Rectified Image only if Matrix Input
        if s(2)>1
            subplot(2,2,[2 4])
            rectificationPlotter(Ir,X,Y,1)
        end
    end
    
end
















