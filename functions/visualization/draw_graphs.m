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
    ', ' num2str(fix(100*mean_y)/100), ' uV']);

end
