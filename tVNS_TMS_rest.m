function tVNS_TMS_rest(subj_num, block_num)
% RandDotsMotionTask(subj_num,block_nums,num_trials)
%    RandDotsMotionTask(subj_num,block_nums,num_trials)
%
%  Examples:
%
%       tVNS_TMS_rest(1,2)     % run 4 blocks of 20 trials
%       RandDotsMotionTask(99,1:8,30)  % run 8 blocks of 30 trials
%    
%
%  Benvenuto Jacob, UCLouvain, Apr 2023
%     Apr 2023      "Pretest version": Pretest done by Su.
%     May 2023      "*_LP_test": Corrections from Su -- checked and re-tested by Ben
%     May 2023      "Experimental vesrsion" Added triggers (Ben) Tested May 3 (Ben, Su)


% subj_num=99 %<DEBUG - COMMENT-ME!>
% block_nums=1 %<DEBUG - COMMENT-ME!>


setupcosy 3-beta80


%% Params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BASE_DIRECTORY = 'C:\MATLAB\Ronan\tVNS_rest\Task_data\';
USE_PARALLEL_PORT = 1; % 1: use parallel port (must have one on PC), 0: ignore parallel port commands
INPOUT_LIBRARY_DIRECTORY = 'C:\MATLAB\TOOLBOX+\ParallelPort_InpOut\'; % lib must be present there
PARALLEL_PORT_HEX_ADDRESS = '2020'; % x2020 on PAENULTIMUS (hexadecimal)
TRIGGER_TMS  = 2; % pre onset, D1
TRIGGER_SHAM = 4; % fix + 3.5s, sham_protocol_1, D2
TRIGGER_TVNS = 8; % fix + 3.5s, tVNS_protocol_1, D3
TRIGGER_EMG = 16; % mark trial start, D4


TRAIN_ONSET_TIME = 2;
TRIAL_DURATION = 13;

DISPLAY_FULL_SCREEN = 1;
DISPLAY_RESOLUTION = [1360 768]; %[1680 1050];
DISPLAY_SIZE_CM = [51  29]; %[47 47*1050/1680];
VIEWING_DISTANCE = 60; % Monitor-subject distance (cm)
BACKGROUND_LUMINANCE = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup Visual Stimulus display
%% Start Display
startpsych(DISPLAY_FULL_SCREEN, DISPLAY_RESOLUTION, [0 0 0]+BACKGROUND_LUMINANCE);
setscreensizecm(DISPLAY_SIZE_CM);
setviewingdistancecm(VIEWING_DISTANCE);


%% Eyelink initialization - inspired by/adapted from exemple from SR Research

% EYELINK - STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION
%----------------------------------------------------------------------------------------------    
% Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
dummymode = 0;

% Optional: Set IP address of eyelink tracker computer to connect to.
% Call this before initializing an EyeLink connection if you want to use a non-default IP address for the Host PC.
%Eyelink('SetAddress', '10.10.10.240');
EyelinkInit(dummymode); % Initialize EyeLink connection
status = Eyelink('IsConnected');
if status < 1 % If EyeLink not connected
    return; 
end

% Open dialog box for EyeLink Data file name entry. File name up to 8 characters

edfFile = [num2str(subj_num), '_blk', num2str(block_num)];

disp(edfFile);
% Print some text in Matlab's Command Window if file name is longer than 8 characters
if length(edfFile) > 8
    fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
    error('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)');
end

% Open an EDF file and name it
failOpen = Eyelink('OpenFile', edfFile);
if failOpen ~= 0 % Abort if it fails to open
    fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
    error('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
end

% Get EyeLink tracker and software version
% <ver> returns 0 if not connected
% <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
screenNumber = [];
ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
[ver, versionstring] = Eyelink('GetTrackerVersion');
if dummymode == 0 % If connected to EyeLink
    % Extract software version number. 
    [~, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
    ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo         
    % Print some text in Matlab's Command Window
    fprintf('Running experiment on %s version %d\n', versionstring, ver );
end
% Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
% If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
% the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);

% EYELINK - STEP 2: SELECT AVAILABLE SAMPLE/EVENT DATA
%------------------------------------------------------    
% See EyeLinkProgrammers Guide manual > Useful EyeLink Commands > File Data Control & Link Data Control

% Select which events are saved in the EDF file. Include everything just in case
Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
% Select which events are available online for gaze-contingent experiments. Include everything just in case
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
% Select which sample data is saved in EDF file or available online. Include everything just in case
if ELsoftwareVersion > 3  % Check tracker version and include 'HTARGET' to save head target sticker data for supported eye trackers
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

%% Init Parallel Port
if USE_PARALLEL_PORT
    clear ParallelPort_InpOut
    addpath(INPOUT_LIBRARY_DIRECTORY)
    ParallelPort_InpOut('INIT', [INPOUT_LIBRARY_DIRECTORY 'inpoutx64.dll'], hex2dec(PARALLEL_PORT_HEX_ADDRESS));
    ParallelPort_InpOut('OUTPUT',0);
    
else
%     % No parallel port: Let's create a dummy function (so we can run the code on any PC)
%     ParallelPort_InpOut = @(~,~)(0); % dummy function (does nothing)
    
end

% Start Eyelink recording
Eyelink('SetOfflineMode'); % second time?
WaitSecs(0.05); % Allow some time for transition
Eyelink('StartRecording'); % Start tracker recording !!! in the demo this is sent after trial ID


%% Load trial block form participant directory

BLOCK_FILENAME = char(strcat(BASE_DIRECTORY, string(subj_num), '\', 'tVNS_TMS_rest_subject-', string(subj_num), '_block-', string(block_num), '.mat'));
disp(BLOCK_FILENAME);
load(BLOCK_FILENAME, 'T');

disp(T);
%% Loop thrrough trial rows
% Display the fixation cross:
drawtext('+',0, [0 0], [.1 .1 .1], 50);
displaybuffer(0);

for tr = 1:height(T) %<todo>
    STIM_CONDITION = T.stim_condition{tr};
    TMS_ONSET_TIME = T.tms_asynchrony(tr);
    TMS_BASELINE_TIMING = T.tms_baseline_timing(tr);
    JITTER = T.jitter(tr);
    
    disp(STIM_CONDITION);
    disp(TMS_ONSET_TIME);
    %% Starttrial
    fprintf('Trial #%d:\n',tr)

    trial_start_time = GetSecs();
    disp('Trial start time: ');
    disp(trial_start_time);
    Eyelink('Message', 'TRIALID %d', tr); % Trial start event code for Eyelink

    
    while GetSecs() - trial_start_time < abs(TMS_BASELINE_TIMING)
        ParallelPort_InpOut('OUTPUT',0);
    end
    
    if TMS_ONSET_TIME < 0
        ParallelPort_InpOut('OUTPUT', TRIGGER_EMG); %for TMS baseline trials, trigger EMG then immeadiately trigger TMS
        ParallelPort_InpOut('OUTPUT', TRIGGER_TMS);
        disp(GetSecs() - trial_start_time);
        disp('TMS triggered');
    else
        ParallelPort_InpOut('OUTPUT', TRIGGER_EMG); % for all non-baseline trials, just trigger EMG sweep 
    end

    % While loop to wait for onset of tVNS/Sham Train
    disp('Waiting for tVNS');
    while GetSecs() - trial_start_time < TRAIN_ONSET_TIME
        ParallelPort_InpOut('OUTPUT',0);
    end

    % Waiting period over, initate tVNS/Sham train
    if STIM_CONDITION == 'REAL'
        ParallelPort_InpOut('OUTPUT', TRIGGER_TVNS);
        tvns_trigger_time = GetSecs();
        disp('Real tVNS triggered');
        disp(GetSecs() - trial_start_time);
    elseif STIM_CONDITION == 'SHAM'
        ParallelPort_InpOut('OUTPUT', TRIGGER_SHAM);
        tvns_trigger_time = GetSecs();
        disp('Sham tVNS triggered');
        disp(GetSecs() - trial_start_time);
    end

    % While loop to wait for onset of TMS pulse
    
    if TMS_ONSET_TIME > 0 && TMS_ONSET_TIME < 6.5 % Only trigger for pulses timed after TVNS onset
        disp('Waiting for TMS trigger');
        while GetSecs() - tvns_trigger_time < TMS_ONSET_TIME
            ParallelPort_InpOut('OUTPUT', 0);
        end
        ParallelPort_InpOut('OUTPUT', TRIGGER_TMS);
        disp('TMS triggered');
        disp(GetSecs() - trial_start_time);
    end
    
    disp('Waiting for trial end');

    while GetSecs() - trial_start_time < TRIAL_DURATION + JITTER
        ParallelPort_InpOut('OUTPUT', 0);
    end
    
    disp(GetSecs() - trial_start_time);
    disp('Trial ended');
end

%% Stop Display
stopcosy;
%% End Of Block
% Stop recordig eyetracking and transfer data to host PC
Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
WaitSecs(0.5); % Allow some time before closing and transferring file
Eyelink('CloseFile'); % Close EDF file on Host PC
% Transfer a copy of the EDF file to Display PC
transferFile; % See transferFile function below


function transferFile
        try
            if dummymode == 0 % If connected to EyeLink                
                % Transfer EDF file to Host PC
                % [status =] Eyelink('ReceiveFile',['src'], ['dest'], ['dest_is_path'])
                % status = Eyelink('ReceiveFile');
                % Optionally uncomment below to change edf file name when a copy is transferred to the Display PC
                % % If <src> is omitted, tracker will send last opened data file.
                % % If <dest> is omitted, creates local file with source file name.
                % % Else, creates file using <dest> as name.  If <dest_is_path> is supplied and non-zero
                % % uses source file name but adds <dest> as directory path.
                newDir = char(strcat(BASE_DIRECTORY, string(subj_num), '\'));
                status = Eyelink('ReceiveFile', [], newDir, 1);
                
                % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
                if status > 0
                    fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
                end
                % Print transferred EDF file path in Matlab's Command Window
                fprintf('Data file ''%s.edf'' can be found in ''%s''\n', edfFile, pwd);
            else
                fprintf('No EDF file saved in Dummy mode\n');
            end
        catch % Catch a file-transfer error and print some text in Matlab's Command Window
            fprintf('Problem receiving data file ''%s''\n', edfFile);
            psychrethrow(psychlasterror);
        end
end
end
%% Helper function to transfer pupilsize data to display PC



