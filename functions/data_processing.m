function DataProcessing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here
tic;

global params;
global buffer;

%% EOG components calculation
if (params.DummyMode)
    % Make dummy signal to show
    c=clock; c=c(6);
    EOG = 3 * sin(repmat(linspace(c, c+2*pi, params.BufferLength_Biosemi)',1,2)) ...
          + 2 * sin(repmat(linspace(c, c+5*pi, params.BufferLength_Biosemi)',1,2)) ...
          + randn(params.BufferLength_Biosemi,2) ...
          + 10;
          % for the case of linearly decreasing baseline drift 
          % - 2 * repmat(linspace(c, c+1, params.BufferLength_Biosemi)',1,2);
else
    EOG = signal_receive_Biosemi();
end

%% EOG denoising
if(params.denosing)
EOG = signal_denoising(EOG, buffer.buffer_4medianfilter, params.medianfilter_size);
end

%% EOG baseline drift removal
if(params.drift_removing)
EOG = signal_baseline_removal(EOG);
end

%% Data registration to buffer queue
for i=1:params.BufferLength_Biosemi
    buffer.dataqueue.add(EOG(i,:));
    % idx_cur = buffer.dataqueue.datasize; % current index calculation
end

%% Visualization
draw_realtime_signal();
draw_graphs(EOG);

toc;
end

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

plot(g_handles.current_signal, EOG(:,2)+y_range, '-r');
plot(g_handles.current_signal, [0 params.QueueLength], [0 0], 'color', 'black');
plot(g_handles.current_signal, [0 params.QueueLength], [y_range y_range], 'color', 'black');
xlim(g_handles.current_signal, [0 params.QueueLength]);
ylim(g_handles.current_signal, [-y_range 2*y_range]);
h_legend = legend(g_handles.current_signal, 'EOG_x', 'EOG_y', 'Orientation', 'horizontal');
set(h_legend,'FontSize',8);

end

function draw_graphs(EOG)
% This function has no output args.
% g_handles    handle to figures
% EOG          EOG signal containing matrix (N_data, N_components)

global g_handles;

% Histogram Plot
hist(g_handles.current_hist, EOG);
legend(g_handles.current_hist, 'EOG_x', 'EOG_y');

% Mean Compass Plot
mean_x = mean(EOG(:,1));
mean_y = mean(EOG(:,2));

compass(g_handles.current_position, mean_x,mean_y);

set(g_handles.console, 'String', [num2str(fix(100*mean_x)/100), ...
    ', ' num2str(fix(100*mean_y)/100)]);

end