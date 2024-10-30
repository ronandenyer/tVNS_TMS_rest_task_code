DISPLAY_FULL_SCREEN = 1;
DISPLAY_RESOLUTION = [1360 768]; %[1680 1050];
DISPLAY_SIZE_CM = [51  29]; %[47 47*1050/1680];
VIEWING_DISTANCE = 60; % Monitor-subject distance (cm)
BACKGROUND_LUMINANCE = 0;


% EYELINK - STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION
%----------------------------------------------------------------------------------------------    
% Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
dummymode = 0;

% Optional: Set IP address of eyelink tracker computer to connect to.
% Call this before initializing an EyeLink connection if you want to use a non-default IP address for the Host PC.
%Eyelink('SetAddress', '10.10.10.240');
EyelinkInit(dummymode); % Initialize EyeLink connection
status = Eyelink('IsConnected');

%STEP 4: SET CALIBRATION SCREEN COLOURS/SOUNDS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE
%% Init Display
startpsych(DISPLAY_FULL_SCREEN, DISPLAY_RESOLUTION, [0 0 0]+BACKGROUND_LUMINANCE);
setscreensizecm(DISPLAY_SIZE_CM);
setviewingdistancecm(VIEWING_DISTANCE);
colorMaxVal = Screen('ColorRange');
% Return width and height of the graphics window/screen in pixels


[width, H] = Screen('WindowSize');

% Provide EyeLink with some defaults, which are returned in the structure "el".
%Initially it was:     el = EyelinkInitDefaults(window); But windiw
%couldn't be creqted given the current workflow using CosyGraphics
el = EyelinkInitDefaults;

% set calibration/validation/drift-check(or drift-correct) size as well as background and target colors. 
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based 
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 3;% Outer target size as percentage of the screen
el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
el.backgroundcolour = repmat(165,1,3); 
%     el.calibrationtargetcolour = repmat(BlackIndex(window),1,3);
el.calibrationtargetcolour = [0 0 0];

% set "Camera Setup" instructions text colour so it is different from background colour
%      el.msgfontcolour = repmat(BlackIndex(window),1,3);
 el.msgfontcolour = [0 0 0];

% Set calibration beeps (0 = sound off, 1 = sound on)
el.targetbeep = 0;  % sound a beep when a target is presented
el.feedbackbeep = 0;  % sound a beep after calibration or drift check/correction

% Initialize PsychSound for calibration/validation audio feedback
% EyeLink Toolbox now supports PsychPortAudio integration and interop
% with legacy Snd() wrapping. Below we open the default audio device in
% output mode as master, create a slave device, and pass the device
% handle to el.ppa_pahandle.
% el.ppa_handle supports passing either standard mode handle, or as
% below one opened as a slave device. When el.ppa_handle is empty, for
% legacy support EyelinkUpdateDefaults() will open the default device
% and use that with Snd() interop, and close the device handle when
% calling Eyelink('Shutdown') at the end of the script.
InitializePsychSound();
pamaster = PsychPortAudio('Open', [], 8+1);
PsychPortAudio('Start', pamaster);
pahandle = PsychPortAudio('OpenSlave', pamaster, 1);
el.ppa_pahandle = pahandle;

% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, H-1);
% Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
% See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, H-1);    
% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
% Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
Eyelink('Command', 'button_function 5 "accept_target_fixation"');
% Hide mouse cursor
%     HideCursor(window);

% Suppress keypress output to command window.
Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
WaitSecs(0.1)
% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);    
%     EyelinkDoDriftCorrection(el);
WaitSecs(1)
EyelinkClearCalDisplay(el)
Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
clearbuffer;