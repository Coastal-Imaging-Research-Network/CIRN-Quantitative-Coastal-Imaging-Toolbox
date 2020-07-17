%% pixInstPrepXYZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function constructs XYZ vectors and matrices for pixel instruments
%  specfied in a pixInst structure.The vectors and matrices are of the
%  correct size for the function imageRectifier. The format of the input
%  structure is described below. Note: if the z coordinate is not known,
%  pixInst.z can be left empty.

%  Reference Slides:
%

%  Input:
%  pixInst structure with each entry having the following format.
%   pixInst.type = A string either 'Grid','yTransect',or 'xTransect'.
%   pixInst.xlim= Xlimits of grid or vector.
%   pixInst.ylim = Ylimits of grid or vector
%   pixInst.dx = X resolution
%   pixInst.dy = Y resolution
%   pixInst.x = X coordinate of a xTransect
%   pixInst.y = Y coordinate of a yTransect
%   pixInst.z = constant Z elevation across grid/transect. Can be empty.

%   Note, not all fields need to be populated for all types. Below are the
%   necessary fields for each type.

%   cbathyGrid: xlim,ylim,dx,dy,z
%   xTransect: y,dx,xlim,z
%   yTransect: x,dy,ylim,z


%  Output: For each entry
%  pixInst.X
%  pixInst.Y
%  pizInst.Z
%  pixInst.Irgb  (empty nan vectors of correct size for pixel intensities)
%  pixInst.Igray (empty nan vectors of correct size for pixel intensities)
%  Note if Z is prescribed as empty, pizInst.Z will be the same size as
%  pixInst.X but with nans.



%  Required CIRN Functions:
%  none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [pixInst]=pixInstPrepXYZ(pixInst);


%% Section 1: Initiate Loop

for k=1:length(pixInst)
    
    
    %% Section 2: Create Grid
    if strcmp(pixInst(k).type,'Grid')==1
        x=pixInst(k).xlim(1):pixInst(k).dx:pixInst(k).xlim(2);
        y=pixInst(k).ylim(1):pixInst(k).dy:pixInst(k).ylim(2);
        [pixInst(k).X pixInst(k).Y]=meshgrid(x,y);
        
    end
    
    
    %% Section 3: Create Grid for XTransect
    if strcmp(pixInst(k).type,'xTransect')==1
        pixInst(k).X=[pixInst(k).xlim(1):pixInst(k).dx:pixInst(k).xlim(2)]';
        pixInst(k).Y=pixInst(k).X.*0+pixInst(k).y;
        pixInst(k).Irgb=[];
    end
    
    
    %% Section 4: Create Grid for YTransect
    if strcmp(pixInst(k).type,'yTransect')==1
        pixInst(k).Y=[pixInst(k).ylim(1):pixInst(k).dy:pixInst(k).ylim(2)]';
        pixInst(k).X=pixInst(k).Y.*0+pixInst(k).x;
    end
    
    
    
    %% Section 5: Assign Z value if present
    if isempty(pixInst(k).z)==1
        pixInst(k).Z=pixInst(k).X.*nan;
    else
        pixInst(k).Z=pixInst(k).X*0+pixInst(k).z;
    end
    
    
    
end










