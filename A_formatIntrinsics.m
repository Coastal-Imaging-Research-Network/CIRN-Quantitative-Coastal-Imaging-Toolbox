
%% THIS FUNCTION IS NOT NEEDED IF SOLVING FOR IO

% % % A_formatIntrinsics
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  This function initializes the intrinsics matrix for a given camera.
% % 
% %  Input:
% %  Entered by user below in Sections 1,2, and possibly 3. User can either
% %  refer to Caltech calibration file or enter intrinsics manually.
% % 
% %  Output:
% %  A .mat file saved as directory/filename as specified by the user. 'IO'
% %  will be appended to the name. Will contain  intrinsic matrix .
% % 
% %  Required CIRN Functions:
% %  caltech2CIRN
% % 
% % 
% %  Required MATLAB Toolboxes:
% %  none
% % 
% %  It is to be run first in the progression. It should be run for each
% %  camera in a multi-camera fixed station, every time the focus is
% %  adjusted, a new lens is added, or a new enclosure is introduced.  For a
% %  UAS camera, it should be run for each type of recording mode (4K Video,
% %  12MP snapshot, etc).
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % 
% % % Housekeeping
% % close all
% % clear all
% % 
% % User should make sure that X_CoreFunctions and subfolders are made active
% % in their MATLAB path. Below is the standard location for demo, user will
% % need to change if X_CoreFunctions is moved and/or the current script.
% % addpath(genpath('./X_CoreFunctions/'))
% % 
% % 
% % 
% % 
% % 
% % % Section 1: User Input: Loading and Saving Information
% % 
% %  Enter the filename of the  .mat file that will be saved as. Name
% %  should be descriptive of the camera such as 'Solo_4KVideo' or 'Duck_C1.'
% % oname='uasDemo';
% % 
% %  Enter the directory where the mat file will be saved.
% % odir= './X_UASDemoData/extrinsicsIntrinsics/IntrinsicCalculations';
% % 
% % 
% % 
% % 
% % 
% % % Section 2: User Input: Intrinsics
% %  Enter the filepath of the saved Caltech calibration results. If user is
% %  going to enter the LCP manually, leave iopath={}; and enter in
% %  Section 3.
% % iopath= './X_UASDemoData/extrinsicsIntrinsics/IntrinsicCalculations/uasDemo_Calib_Results.mat';
% % 
% % 
% % 
% % 
% % 
% % % Section 3: Conversion of Caltech Intrinsics to LCP (Lens Calibration Profile)
% % 
% % For where a CalTech file is specified
% % if isempty(iopath)==0
% %     intrinsics = caltech2CIRN(iopath);
% % end
% % 
% % 
% % For where a CalTech file is NOT specified
% % if isempty(iopath)==1
% %     intrinsics(1) = {};     % number of pixel columns (NU)
% %     intrinsics(2) = {};     % number of pixel rows (NV)
% %     intrinsics(3) = {};     % U component of principal point (coU)
% %     intrinsics(4) = {};     % V component of principal point  (coV)
% %     intrinsics(5) = {};     % U components of focal lengths (in pixels) (fx)
% %     intrinsics(6) = {};     % V components of focal lengths (in pixels) (fy)
% %     intrinsics(7) = {};     % Radial distortion coefficient (d1)
% %     intrinsics(8) = {};     % Radial distortion coefficient (d2)
% %     intrinsics(9) = {};     % Radial distortion coefficient (d3)
% %     intrinsics(10) = {};    % Tangential distortion coefficient (t1)
% %     intrinsics(11) = {};    % Tangential distortion coefficient (t2)
% % end
% % 
% % 
% % 
% % 
% % 
% % % Section 4: Save File
% % save([odir '/' oname '_IO' ],'intrinsics')
% % 
% % Display Results
% % disp(' ')
% % disp(' ')
% % disp(['Intrinsics for ' oname])
% % disp(' ')
% % disp(['NU=' num2str(intrinsics(1))])
% % disp(['NV=' num2str(intrinsics(2))])
% % disp(['coU=' num2str(intrinsics(3))])
% % disp(['coV=' num2str(intrinsics(4))])
% % disp(['fx=' num2str(intrinsics(5))])
% % disp(['fy=' num2str(intrinsics(6))])
% % disp(['d1=' num2str(intrinsics(7))])
% % disp(['d2=' num2str(intrinsics(8))])
% % disp(['d3=' num2str(intrinsics(9))])
% % disp(['t1=' num2str(intrinsics(10))])
% % disp(['t2=' num2str(intrinsics(11))])
% % 
% % 
% % 
