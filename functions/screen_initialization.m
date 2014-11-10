function screen_initialization()
%SCREEN_INITIALIZATION

global params;

monitor_positions = get(0, 'MonitorPositions');
n_monitor = size(monitor_positions, 1);
scrsz = get(0, 'ScreenSize');

if(n_monitor > 1) % Double monitor
    % Load the stimulus window
    stim_window = stimulus_window();
    set(stim_window.window, 'Units', 'pixels');
    set(stim_window.axes, 'Units', 'pixels');
    
    set(stim_window.window, 'Position', [scrsz(3)+1 1 1280 1024]);
    set(stim_window.axes, 'Position', [1 1 1280 1024]);
    
    scatter(stim_window.axes, 0, 0, 300, 'x', 'LineWidth', 3, ...
        'MarkerEdgeColor', 'k');
    
    params.DoubleMonitor = 1;
    
    %     % Initial Preference Setup
    %     Screen('Preference', 'SkipSyncTests', 2);
    %     Screen('Preference', 'ConserveVRAM', 64);
    %     
    %     screenNum = max(screenNumbers); % Use the second monitor
    %     [window, rect] = Screen('OpenWindow', screenNum, 1);
    %     
    %     % Make a fixation point
    %     [X,Y] = RectCenter(rect);
    %     FixCross = [X-1,Y-10,X+1,Y+10;X-10,Y-1,X+10,Y+1];
    %     Screen('FillRect', window, [255, 255, 255], FixCross');
    %     
    %     % Select specific text font, style and size:
    %     Screen('TextFont', window, 'Cambria');
    %     Screen('TextSize', window, 20);
    %     Screen('TextStyle', window, 1);
    %      
    %     DrawFormattedText(window, 'Initializing the screen', 'center', Y-150, [255, 255, 255]);
    %     Screen('Flip', window);  
else
    disp('No additional monitor has been found.')
    params.DoubleMonitor = 0;
end

end

