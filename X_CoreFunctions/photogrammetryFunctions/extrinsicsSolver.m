%% extrinsicsolver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function solves for a camera geometry EO (extrinsics) and associated
%  errors given specified known values for extrinsics, initial guesses for
%  unknown values of extrinsics, camera IO (intrinsics), real world GCP coordinates
%  (xyz), and corresponding distorted UV coordinates of GCPs (UV).

%  Input:
%  intrinsics = 1x11 Intrinsics Vector Formatted as in A_formatIntrinsics

%  extrinsicsInitialGuess = 1x6 Vector representing [ x y z azimuth tilt swing] of
%  the camera EO. Include both known and initial guesses of unknown values.
%  x, y, and z should be in the same units and coordinate system of GCP xyz
%  points. Azimuth, tilt, and swing should be in radians.

%  extrinsicsKnownFlags= 1x6 Vector of 1s and 0s marking whether values in
%  betaInitialGuess are known or are initial guesses and should be solved
%  for.

%  xyz = Px3 list of world coordinates of P GCP points. Columns represent
%  GCP x,y, and z coordinates.

%  UV = Px2 list of image UV coordinates of P GCP points. Columns represent
%  GCP U and V coordinates. Rows should correspond to same GCP point as
%  xyz.


%  Output:
%  extrinsics = 1x6 Vector representing [ x y z azimuth tilt swing] of the camera.
%  Units of values are same as entered extrinsicsInitialGuess

%  extrinsics Error= 1x6 Vector of errors for value of beta. Units of values are
%  same as entered extrinsics.

%  Required CIRN Functions:
%  xyz2DistUV
%       -intrinsicsExtrinsics2P
%       -distortUV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [IOEO IOEOError]= extrinsicsSolver(IOEOInitialGuess,IOEOKnownsFlag,UV,xyz)


options.Tolfun = 1e-12;
options.TolX = 1e-12;
    
    
%% Section 1: If All Values of beta are Unknown
if sum(IOEOKnownsFlag)==0  %all values are zero
    
    %  The following command actually uses two functions: CIRN xyz2DistUV and
    %  nlinfit. xyzToDistUV transforms a set of real world coordinates (XYZ) to
    %  distorted (UV) coordinates given an intrinsic matrix (I), extrinsics (EO), and XYZ points.
    %  Nlinfit solves the inverse of the xyzToDistUV function: it finds the
    %  optimum extrinsics (EO) that minimizes error given a set of UV, XYZ, an intrinsics matrix (IO,
    %  an initial guess for extrinsics (extrinsicsInitialGuess).
    
    %  Ultimately we are telling nlinfit- our UV results are a function of extrinsics
    %  and xyz [@(extrinsics,xyz)], all input left out of those brackets (intrinsics) should
    %  not be solved for and taken as constants in this solution.
    
    [IOEO,R,J,CovB]   = nlinfit(xyz,[UV(:,1); UV(:,2)],@(IOEO,xyz)xyz2DistUV(IOEO,xyz), IOEOInitialGuess,options);
    
    %   extrinsics is the solved camera EO where R,J,CovB are metrics of the solution
    %   and can be explored in nlinfit documentation.
    
    IOEOError=sqrt(diag(CovB));
    
end





%% Section 2: If any values of extrinsics are known
if sum(IOEOKnownsFlag)>0  %if any value is not zero
    
    % The following section essentially does the same thing as Section 1.
    % However, due to the limitations of nlinfit we have to be a bit clever. In
    % nlinfit we cannot specfiy that only some values of extrinsics should be solved
    % for; it has to be all known or all unknown. What is known has to be
    % passed as a seperate variable like intrinsics etc. To account for this, we will
    % solve for a new function (xyz2DistUVforNLinFit existing only below in
    % Section 3). Ultimately this function just runs xyzToDistUV, but it parses
    % known extrinsics from unknown extrinsics so nlinfit can solve unknowns individually.
    
    
    % Parse out what part of extrinsics is known and what is unknown
    knownInd=find(IOEOKnownsFlag==1); % knowns are 1s
    unKnownInd=find(IOEOKnownsFlag==0);% unknowns are 0s
    
    IOEOKnown=IOEOInitialGuess(knownInd);
    IOEOUnknownInitialGuess=IOEOInitialGuess(unKnownInd);
    
    % Solve for Unknown Component
    [eunknownSol,R,J,CovB]   = nlinfit(xyz,[UV(:,1); UV(:,2)],@(IOEOUnknown,xyz)xyz2DistUVforNLinFit(IOEOKnownsFlag,IOEOKnown,IOEOUnknown,xyz),IOEOUnknownInitialGuess,options);
    
    %  Ultimately we are telling nlinfit- our UV results are a function of extrinsics
    %  Unknowns and xyz [@(extrinsicsUnknown,xyz)], all input left out of those
    %  brackets (intrinsics, extrinsicsKnown,extrinsicsKnownsFlag) should not be solved for and
    %  taken as constants in this solution.
    
    eunknownSolError=sqrt(diag(CovB));
    
    % Put Back into extrinsics [1x6] format
    IOEO=nan(1,11);
    IOEO(knownInd)=IOEOKnown;
    IOEO(unKnownInd)=eunknownSol;
    
    IOEOError=nan(1,11);
    IOEOError(knownInd)=0; % Assumed Known so Error is 0
    IOEOError(unKnownInd)=eunknownSolError;
    
end





%% Section 3: Modified xyzToDistUV Function for nLinFit
    function [UVd]= xyz2DistUVforNLinFit(IOEOKnownsFlag,IOEOKnown, IOEOUnknown, xyz)
        
        % Identify where in extrinsics does the knowns and unknowns belong
        kInd=find(IOEOKnownsFlag==1);
        ukInd=find(IOEOKnownsFlag==0);
        
        % Formulate an intermediate extrinsics to put into xyzToDistUV
        iIOEO=nan(1,11);
        iIOEO(kInd)=IOEOKnown;
        iIOEO(ukInd)=IOEOUnknown;
        
        
        [UVd]= xyz2DistUV(iIOEO,xyz);
    end






end



