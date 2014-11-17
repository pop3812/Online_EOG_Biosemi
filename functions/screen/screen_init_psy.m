function screen_init_psy()
%SCREEN_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here
global params;

screenNumbers=Screen('Screens');

if(length(screenNumbers) > 2) % Double monitor
    % Initial Preference Setup
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'ConserveVRAM', 64);

    params.screen_number = max(screenNumbers); % Use the second monitor
    
    [window, rect] = Screen('OpenWindow', params.screen_number, 1);

    params.rect = rect;
    params.window = window;
    
    % Make a default fixation point (center)
    [X,Y] = RectCenter(rect);
    screen_draw_fixation(window, 0, 0);

    % Select specific text font, style and size:
    Screen('TextFont', window, 'Cambria');
    Screen('TextSize', window, 15);
    Screen('TextStyle', window, 1);

    DrawFormattedText(window, 'Look at the cross.', 'center', Y-100, [255, 255, 255]);
    Screen('Flip', window);  

    WaitSecs(2);
else
    params.rect = [0 0 0 0];
    params.window = -1;
end

end

