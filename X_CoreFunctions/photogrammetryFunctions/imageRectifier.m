%% imageRectifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function performs image rectifications given the associated
%  extrinsics, intrinsics, distorted image, and xyz points. The function utalizes 
%  xyz2DistUV to find corresponding UVd values to the input grid and pulls 
%  the rgb pixel intensity for each value. If the teachingMode flag is =1, 
%  the function will plot corresponding steps (xyz-->UV transformation) as 
%  well as rectified output. 
  
%  Reference Slides:
%  

%  Input:
%  I= NxMx3 image to be rectified. Should have been taken when entered
%  intrinsics and extrinsics are valid and be distorted.

%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsics = 1x6 Vector representing [ x y z yaw pitch roll] of 
%  the camera EO.  All values should be in the same units and coordinate 
%  system of X,Y, and Z grids. Yaw, pitch, and roll should be in radians. 

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


%% Section 1: Format Grid for xyz2DistUV

x=reshape(X,1,numel(X)); 
y=reshape(Y,1,numel(Y));
z=reshape(Z,1,numel(Z));
xyz=cat(2,x',y',z'); 





%% Section 2: Determine Distorted UVd points for each xyz point

% Determine UVd Points
[UVd] = xyz2DistUV(intrinsics,extrinsics,xyz);


% Reshape UVd Matrix so in size of input X,Y,Z
UVd = reshape(UVd,[],2);
s=size(X);
Ud=(reshape(UVd(:,1),s(1),s(2)));
Vd=(reshape(UVd(:,2),s(1),s(2)));

% Round UVd coordinates so it cooresponds to matrix indicies in image I
Ud=round(Ud);
Vd=round(Vd);

% Algorithm will find UV coordinates whether real or not ( xyz not in the
% field of view) This gets rid of bad UV points that don' exist.

    %Find negative UV coordinates
    bind=find(Ud<=0 | Vd<=0); 
    Ud(bind)=nan;
    Vd(bind)=nan;
    
    % Find UVd coordinates greater than the image size
    NU=intrinsics(1);
    NV=intrinsics(2);
    bind =find( Ud>=NU | Vd>= NV); 
    Ud(bind)=nan;
    Vd(bind)=nan;
    

    
    
    
%% Section 3: Pull Image Pixel Intensities from Image
    


% Initiate Ir matrix as same size as input X,Y,Z but with aditional third
% dimension for rgb values.
    Ir=nan(s(1),s(2),3);

% Pull rgb pixel intensities for each point in XYZ
for kk=1:s(1)
    for j=1:s(2)
        % Make sure not a bad coordinate
        if isnan(Ud(kk,j))==0 & isnan(Vd(kk,j))==0 
            % Note how Matlab organizes images, V coordinate corresponds to
            % rows, U to columns. V is 1 at top of matrix, and grows as it
            % goes down. U is 1 at left side of matrix and grows from left
            % to right.
            Ir(kk,j,:)=I(Vd(kk,j),Ud(kk,j),:);
        end
    end
end

% Make a uint8 for image formatting
Ir=uint8(Ir);


    
    

%% Section 4: Optional for Teaching Mode

  if teachingMode==1
      f1=figure;
      
      % Plot UVd values for each XYZ point on oblique image
      % Colorize by X coordinate
      subplot(2,2,1)
      imshow(I)
      hold on
      scatter(Ud(:),Vd(:),10,X(:),'filled')
      xlabel( 'U')
      ylabel( 'V')
      colorbar 
      title('X')
      
      % Colorize by Y coordinate
      subplot(2,2,3)
      imshow(I)
      hold on
      scatter(Ud(:),Vd(:),10,Y(:),'filled')
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
















