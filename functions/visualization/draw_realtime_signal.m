function draw_realtime_signal()
% This function has no output args.
% g_handles    handle to figures
% EOG          EOG signal containing matrix (N_data, N_components)

global g_handles;
global params;
global buffer;

y_range = params.y_range;
EOG = circshift(buffer.dataqueue.data, -buffer.dataqueue.index_start+1);

% Current Signal Plot
cla(g_handles.current_signal);

plot(g_handles.current_signal, EOG(:,1), '-b');
hold(g_handles.current_signal, 'on');
plot(g_handles.current_signal, EOG(:,2), '-r');
% plot(g_handles.current_signal, EOG(:,2)+y_range, '-r');

% Legend
text(0.01, 0.10,'EOG_x', 'Parent', g_handles.current_signal, 'Units','normalized', 'Color', 'b', 'FontName', 'Cambria', 'FontSize', 8, 'FontWeight', 'bold');
text(0.01, 0.20,'EOG_y', 'Parent', g_handles.current_signal, 'Units','normalized', 'Color', 'r', 'FontName', 'Cambria', 'FontSize', 8, 'FontWeight', 'bold');
% legend(g_handles.current_signal, {'EOG_x', 'EOG_y'}, ...
%     'Orientation', 'horizontal', 'Location', 'southwest', 'FontSize',8);

% Draw Grids
set(g_handles.current_signal,'TickLength', [0 0]);

tickValues = 0:fix(1/params.DelayTime)*params.BufferLength_Biosemi:params.QueueLength;
set(g_handles.current_signal,'XTick', tickValues);
set(g_handles.current_signal,'YTick', []);
grid(g_handles.current_signal, 'on');
set(g_handles.current_signal, 'box', 'on');

plot(g_handles.current_signal, [0 params.QueueLength], [0 0], 'color', 'black');
% plot(g_handles.current_signal, [0 params.QueueLength], [y_range y_range], 'color', 'black');

% X, Y Range Setting
xlim(g_handles.current_signal, [0 params.QueueLength]);

% Draw Blink Detection Rage
drawRange();

hold(g_handles.current_signal, 'off');

end

function drawRange()
global params;
global buffer;
global g_handles;

p = params.blink;
b = buffer.blink;

% Plot related Parameters
mark_position = 0.9; % Relative Position of Blink Detection Mark : Bottom 0 to Top 1
line_style = 'box'; % either horizon or vertical
alpha = 0.1;
color = [1 0 0];

% The number of ranges
ranges = blink_range_position_conversion();
nRange = size(ranges, 1);

y = get(g_handles.current_signal,'YLim');

if nRange > 0
    for i=1:nRange
        pos = ranges(i, :);
        
        if strcmp(line_style, 'horizon')
            y_h = ((1 - mark_position) * y(1) + mark_position * y(2));
            plot(g_handles.current_signal, pos, [y_h, y_h], '-r', 'LineWidth', 2);
        
        elseif strcmp(line_style, 'vertical')
            plot(g_handles.current_signal, [pos(1), pos(1)], y, ':r', 'LineWidth', 1);
            plot(g_handles.current_signal, [pos(2), pos(2)], y, ':r', 'LineWidth', 1);
        
        elseif strcmp(line_style, 'box')
            hold(g_handles.current_signal, 'on');
            H = area(g_handles.current_signal, pos, [y(2), y(2)]);
            H2 = area(g_handles.current_signal, pos, [y(1), y(1)]);
            hold(g_handles.current_signal, 'off');
            
            % Set alpha value for the area
            h=get(H,'children');
            set(h,'FaceAlpha', alpha, 'FaceColor', color, 'LineStyle', 'none');
            h=get(H2,'children');
            set(h,'FaceAlpha', alpha, 'FaceColor', color, 'LineStyle', 'none');
        end
    end
end
end