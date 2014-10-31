function DataProcessing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here

global g_handles;
global p;

tic;

c=clock;
c=c(6);
EOG = 3 * sin(5*repmat(linspace(c, c+2*pi, 100)',1,2)) + randn(100,2);

drawGraphs(EOG);

toc;
end

function drawGraphs(EOG)
% This function has no output args.
% g_handles    handle to figures
% EOG          EOG signal containing matrix (N_data, N_components)

global g_handles;
global p;

% Current Signal Plot
cla(g_handles.current_signal);
plot(g_handles.current_signal, EOG(:,1));
hold(g_handles.current_signal, 'on');

plot(g_handles.current_signal, EOG(:,2)+10, '-r');
plot(g_handles.current_signal, [0 100], [0 0], 'color', 'black');
plot(g_handles.current_signal, [0 100], [10 10], 'color', 'black');
ylim(g_handles.current_signal, [-10 20]);
legend(g_handles.current_signal, 'Vx', 'Vy', 'Orientation', 'horizontal');

% Histogram Plot
hist(g_handles.current_hist, EOG);
legend(g_handles.current_hist, 'Vx', 'Vy');

% Mean Compass Plot
mean_x = mean(EOG(:,1));
mean_y = mean(EOG(:,2));

compass(g_handles.current_position, mean_x,mean_y);

set(g_handles.console, 'String', [num2str(fix(100*mean_x)/100), ...
    ', ' num2str(fix(100*mean_y)/100)]);

end