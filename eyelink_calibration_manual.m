% Initialize Psychtoolbox and open a screen
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0);

% Set dot color and size
dotColor = [255 255 255];  % White color
dotSize = 10;  % Size of each dot in pixels

% Define coordinates for each dot
% You can adjust these coordinates to place dots in your desired positions
x_left = 61;
x_mid = 512;
x_right = 963;

y_top = 65;
y_mid = 384;
y_bottom = 703;

dotCoords = [x_left, y_bottom;  % Dot 1
             x_mid, y_bottom;  % Dot 2
             x_right, y_bottom;  % Dot 3
             x_left, y_mid;  % Dot 4
             x_mid, y_mid;  % Dot 5
             x_right, y_mid;  % Dot 6
             x_left, y_top;  % Dot 7
             x_mid, y_top;  % Dot 8
             x_right, y_top]; % Dot 9
% Define key mappings for each dot
keys = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
exitKey = '0';  % '*' key on the numeric keypad

% Loop to show each dot based on key press
while true
    % Check for key press
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        % Exit if '*' is pressed
        if keyCode(KbName(exitKey))
            break;
        end
        % Check which key was pressed (1 to 9)
        for i = 1:9
            if keyCode(KbName(keys{i}))
                % Clear the screen
                Screen('FillRect', window, 0);
                
                % Draw the specified dot at its coordinate
                Screen('DrawDots', window, dotCoords(i, :)', dotSize, dotColor, [], 2);
                
                % Flip to update the screen
                Screen('Flip', window);
            end
        end
    end
end

% Close the screen
sca;
