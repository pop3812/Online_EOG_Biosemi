function draw_realtime_signal()
% This function has no output args.
% g_handles    handle to figures
% EOG          EOG signal containing matrix (N_data, N_components)

global g_handles;
global params;
global buffer;

y_range = params.y_range;
EOG = circshift(buffer.dataqueue.data, -buffer.dataqueue.index_start);

% Current Signal Plot
cla(g_handles.current_signal);

plot(g_handles.current_signal, EOG(:,1));
hold(g_handles.current_signal, 'on');
plot(g_handles.current_signal, EOG(:,2), '-r');
% plot(g_handles.current_signal, EOG(:,2)+y_range, '-r');

% Draw Grids
tickValues = 0:2 * params.BufferLength_Biosemi:params.QueueLength;
set(g_handles.current_signal,'XTick', tickValues);
grid(g_handles.current_signal, 'on');

plot(g_handles.current_signal, [0 params.QueueLength], [0 0], 'color', 'black');
% plot(g_handles.current_signal, [0 params.QueueLength], [y_range y_range], 'color', 'black');

% X, Y Range Setting
xlim(g_handles.current_signal, [0 params.QueueLength]);
% ylim(g_handles.current_signal, [-y_range 2*y_range]);
set(g_handles.current_signal, 'YTickLabel', '');

% Legend
h_legend = legend(g_handles.current_signal, 'EOG_x', 'EOG_y', ...
    'Orientation', 'horizontal', 'Location', 'southwest');
set(h_legend,'FontSize',8);

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
% alpha = 0.1;
% color = [1 0 0];

nRange = b.detectedRange_inQueue.datasize;

y = get(g_handles.current_signal,'YLim');
y = (y(1) +y(2)) * 4/5;
x = get(g_handles.current_signal,'XLim');

if nRange > 0
    for i=1:nRange
        pos = mod(b.dataqueue.index_start + ...
                b.detectedRange_inQueue.get(i) - 2, b.dataqueue.length) + 1;
    
        pos = pos * p.DecimateRate - buffer.dataqueue.index_start;
        if pos(1) > pos(2)
            plot(g_handles.current_signal, [pos(1) x(2)] , [y, y], '--r', 'LineWidth', 2);
            plot(g_handles.current_signal, [x(1) pos(2)] , [y, y], '--r', 'LineWidth', 2);
%             H = area(g_handles.current_signal, [pos(1) x(2)], [y,y]);
%             H2 = area(g_handles.current_signal, [x(1) pos(2)], [y,y]);
%             
%             % Set alpha value for the areas
%             h=get(H,'children');
%             set(h,'FaceAlpha', alpha, 'FaceColor', color);
%             h2=get(H2,'children');
%             set(h2,'FaceAlpha', alpha, 'FaceColor', color);
        else
            plot(g_handles.current_signal, pos, [y, y], '--r', 'LineWidth', 2);
%             hold(g_handles.current_signal, 'on');
%             H = area(g_handles.current_signal, pos, [y,y]);
%             hold(g_handles.current_signal, 'off');
%             
%             % Set alpha value for the area
%             h=get(H,'children');
%             set(h,'FaceAlpha', alpha, 'FaceColor', color);
        end
    end
end
end