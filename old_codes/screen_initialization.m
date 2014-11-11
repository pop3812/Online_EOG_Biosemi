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
    hold(stim_window.axes, 'on');
    
    set(stim_window.window, 'Position', [scrsz(3)+1 1 1280 1024]);
    set(stim_window.axes, 'Position', [1 1 1280 1024]);
    
    set(stim_window.axes, 'XTick', [], 'YTick', []);
    whitebg(stim_window.window, 'black'); % Change the background color

    
    scatter(stim_window.axes, 0, 0, 300, 'x', 'LineWidth', 3, ...
        'MarkerEdgeColor', 'w');

    params.DoubleMonitor = 1;
    
else
    disp('No additional monitor has been found.')
    params.DoubleMonitor = 0;
end

end

