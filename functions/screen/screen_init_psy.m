function screen_init_psy(text)
%SCREEN_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here
global params;

if nargin < 1
text = 'Look at the point.';
end

screenNumbers=Screen('Screens');

if(length(screenNumbers) > 2) % Double monitor
    
    % Check if the window is open
    windowPtrs=Screen('Windows');
    if isempty(windowPtrs)
        % New Window Open
        % Initial Preference Setup
        Screen('Preference', 'SkipSyncTests', 2);
        Screen('Preference', 'ConserveVRAM', 64);

        params.screen_number = max(screenNumbers); % Use the second monitor

        [window, rect] = Screen('OpenWindow', params.screen_number, 1);
        Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        params.rect = rect;
        params.window = window;
    end
    
    % Make a default fixation point (center)
    [X,Y] = RectCenter(params.rect);
    
    if params.default_fixation_y > 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y-3);
    elseif params.default_fixation_y <= 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y+3);
    end
    
    screen_draw_fixation(params.window, 0, params.default_fixation_y);

    % Select specific text font, style and size:
    Screen('TextFont', params.window, 'Cambria');
    Screen('TextSize', params.window, 15);
    Screen('TextStyle', params.window, 1);
    
    DrawFormattedText(params.window, text, 'center', Y, [255, 255, 255]);
    Screen('Flip', params.window);  

%     WaitSecs(2);
else
    params.rect = [0 0 0 0];
    params.window = -1;
end

end

