%% cameraSeamBlend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function takes rectifications from different cameras (but same grid)
%  and merges them together into a single rectification. To do this, the function
%  performs a weighted average where pixels closest to the seams are not
%  represented as strongly as those closest to the center of the camera
%  rectification.


%  Input:
%  IrIndv= A NxMxCxK matrix where N and M are the grid lengths for the
%  rectified image. C is the number of color channels (3 for rgb, 1 for bw)
%  and K is the number of cameras. Even if using bw images, the matrix must
%  be four dimensions with C=1; Each k entry is a rectified image of a
%  camera.


%  Output:
%  Ir= A NxMxC uint8 matrix of the merged rectified image. N and M are the grid lengths for the
%  rectified image. C is the number of color channels (3 for rgb, 1 for bw)
%  and K is the number of cameras. Even if using bw images, the matrix must
%  be four dimensions with C=1;


%  Required CIRN Functions:
%  None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function [Ir] =cameraSeamBlend(IrIndv);

%% Section 1:  Weighting Functions

% Intialize Weighting Functions For seams
[m,n,c,camnum]=size(IrIndv(:,:,:,:));
IrIndvW = zeros([m n c camnum]);
indvW = IrIndvW ;
IrIndv=double(IrIndv);




%% Section 2: Determine Weighting Function for Each Camera
for k=1:camnum
    
    % Pull Individual Rectification
    ir=((IrIndv(:,:,:,k)));
    
    % Find Points that Are [0 0 0] rgb and turn them to nan; Assuming if
    % one channel has exactly 0, they all will.
    bind=find(ir(:)==0);
    ir(bind)=nan;
    % Turn image into binary image (1 for nan, 0 for nonnan).
    binI=isnan(ir(:,:,1));
    
    % For each pixel that =0 (non-nan pixels), find shortest distance to pixel that =1 (nan pixels, edges). For
    % pixels that ==1 (nan pixels), the distance is 0. Valid non-nan pixels
    % near the edges will have smaller D than those in the center of the
    % rectified image.
    D = bwdist(binI);
    
    % Weight all Pixels Equally if all are non-zero (W is inf, No edges or nanned areas).
    if( isinf(max(D(:))) )
        W = ones(size(D));
    else
        
        % Normalize Distances by max Distance to create Weighting Function for pixels.
        % Pixels furthest away from the edges (Largest D) will have maximum
        % weights near 1. Pixels near edges(smallest D), weighed less.
        W = D ./ max(D(:));
    end
    
    % Replicate the Weighting Function for Each Color Channel, Remove any
    % nans
    W = repmat(W, [1 1 c]);
    W(isnan(W(:))) = 0;
    
    % Apply Weight to OrthoPhoto and save in Matrix
    IrIndvW(:,:,:,k)=ir.*(W);
    % Save Weights to perform Weighted Average
    indvW(:,:,:,k)=W;
end





%% Section 3: Calculate Weighted Average

% Perform Weighted Average and format
Ir=uint8(nansum(IrIndvW,4)./nansum(indvW,4));