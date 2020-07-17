%% A0_movie2frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function output frames (images) from a movie file with a specified
%  frame rate.

%  Input:
%  Entered by user below in Sections 1 and 2. User will input movie file
%  location as well as output filenames etc in Section 1 and in Section 2
%  specify timing information and desired framerate.

%  Output:
%  A series of images(.tif) in the specified output folder. Timing
%  information will be saved in the name of the file in epoch time. If
%  initial time not specified, timing will be referenced to the first frame
%  at 0s. Times will be rounded to the nearest milliscond and expressed in
%  milliseconds.

%  Required CIRN Functions:
%  none


%  Required MATLAB Toolboxes:
%  none

%  This function may or may not need to be run first in the progression.
%  It will typically be needed for movie files from UAS collects to obtain
%  images for analysis. However, it can be utilized for any movie file even
%  from a fixed station.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Housekeeping
close all
clear all

% User should make sure that X_CoreFunctions and subfolders are made active
% in their MATLAB path. Below is the standard location for demo, user will
% need to change if X_CoreFunctions is moved and/or the current script.
addpath(genpath('./X_CoreFunctions/'))





%% Section 1: User Input: Loading and Saving Information

%  Enter the filepath where the movie is located.
mpath='./X_UASDemoData/collectionData/uasDemo_20151001_2329.mp4';


%  Enter the base name for the image files  will be saved under. Name
%  should be descriptive of the camera such as 'Solo_4KVideo' or 'Duck_C1.'
oname='uasDemo';

%  Enter the directory where the images will be saved.
odir= './X_UASDemoData/collectionData/uasDemo_2Hz/';





%% Section 2: User Input: Timing Information and Framerate

% Enter the time of the first frame in [year,month,day,hr,min,sec] format.
% If unknown leave as all zeros. Timing will just refer the the first frame
% as t=0s.
to= datenum(2015,10,1,23,29,0);


% Enter the Desired Frame Rate in frames/second (fps). Note, desired frame rate
% should be a multiple or factor of the video orginal frame rate for equally
% timed frames. Example: for a video at 30 fps one can accurately export
% frames at 1,2,3,5,6,10,15 or 30 fps (multiples). Or for lower framerates
% (<1 fps) the framerate would be (1./(N+n/30)) where N is the integer
% number of seconds between frames and n is the fractional number of
% frames (A Frame every 2.5 seconds would be  1./(2+15/30)=.4 fps).

frameRate=2; %fps





%% Section 3: Load Video, Pull Frames, and Save

% Load Video
v=VideoReader(mpath);

% Intialize Time
if to==datenum(0,0,0,0,0,0) % If to unknown
    to=0;
else % if to known
    to=(to-datenum(1970,1,1))*24*3600; % convert to epoch time in seconds
end

% Initialize Loop
k=1;
count=1;
numFrames= v.Duration.*v.FrameRate;

while k<=numFrames
    
    % Read Frame
    I=read(v,k);
    
    % Get time
    if k==1
        vto=v.CurrentTime;
    end
    t=v.CurrentTime;
    ts= (t-vto)+to; % Make sure time is referenced to user specified time
    % useful in case video encoded time is incorrect.
    
    %Because of the way Matlab defines time. 
    if k==numFrames
        ts=ts+1./v.FrameRate;
    end
    
    % Record Time in millisecons (Avoid '.' in file names)
    ts=round(ts.*1000);
    
    % Write Image
    imwrite(I,[odir oname '_' num2str(ts) '.tif'])
    
    % Display Completion Rate
    disp([ num2str( k./numFrames*100) '% Extraction Complete'])
    
    % Get Indicie of Next Frame
    k=k+round(v.FrameRate./frameRate);
    
    % Save timing information
    T(count)=ts/1000; % In Seconds
    count=count+1;
    
    
end





%% Section 4: Display FrameRates
% Output Framerate of orginal Video
disp(' ')
disp(' ')
disp(['Original Video Framerate: ' num2str(v.FrameRate) ' fps'])
disp(['Specified Video Framerate: ' num2str(frameRate) ' fps']);
disp(['Specified dt: ' num2str(1./frameRate) ' s']);
disp(['Actual Average dt: ' num2str(nanmean(diff(T(1:(end-1))))) ' s']);
disp(['STD of actual dt: ' num2str(sqrt(var(diff(T(1:(end-1))),'omitnan'))) ' s']);






