function screen_init_psy()
%SCREEN_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here

screenNumbers=Screen('Screens');

if(length(screenNumbers) > 2) % Double monitor
    % Initial Preference Setup
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'ConserveVRAM', 64);

    screenNum = max(screenNumbers); % Use the second monitor
    [window, rect] = Screen('OpenWindow', screenNum, 1);

    % Make a default fixation point (center)
    [X,Y] = RectCenter(rect);
    screen_draw_fixation(window, X, Y);

    % Select specific text font, style and size:
    Screen('TextFont', window, 'Cambria');
    Screen('TextSize', window, 20);
    Screen('TextStyle', window, 1);

    DrawFormattedText(window, 'Screen', 'center', Y-150, [255, 255, 255]);
    Screen('Flip', window);  

    WaitSecs(2);
end

end

