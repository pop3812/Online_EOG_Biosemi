function draw_fitting_plot_uncoupling(signal_for_training, ...
    stimulus_for_training, coeff_1, coeff_2, idx)
%DRAW_FITTING_PLOT
% Visualize the fitting results
global buffer;
global g_handles;

n_data = stimulus_for_training.datasize;
width = max(signal_for_training.data(:,1));
height = max(signal_for_training.data(:,2));

if idx == 1

    g_handles.fit_result = figure('name', 'Fitting Results', 'NumberTitle', 'off');

    x_data = stimulus_for_training.data(1:n_data,2);
    x_x = [min(x_data), max(x_data)];
    x_str = 'y';

elseif idx == 2

    figure(g_handles.fit_result);
    
    x_data = stimulus_for_training.data(1:n_data,1);
    x_x = [min(x_data), max(x_data)];
    x_str = 'x';

end

y_data_hor = signal_for_training.data(1:n_data,1);
y_data_hor = y_data_hor - nanmedian(y_data_hor);
y_data_ver = signal_for_training.data(1:n_data,2);
y_data_ver = y_data_ver - nanmedian(y_data_ver);

subplot(2, 2, 2*(idx-1)+1); scatter(x_data, y_data_hor); hold on;
plot(x_x, polyval([coeff_1 0], x_x), '--r', 'LineWidth', 2);

title('Horizontal Component');
xlabel(['V_h = ', num2str(coeff_1), x_str], ...
    'Color', 'red');

subplot(2, 2, 2*(idx-1)+2); scatter(x_data, y_data_ver); hold on;
plot(x_x, polyval([coeff_2 0], x_x), '--r', 'LineWidth', 2);

title('Vertical Component');
xlabel(['V_v = ', num2str(coeff_2), x_str], ...
    'Color', 'red');

if idx == 2
     g_handles = rmfield(g_handles, 'fit_result');
end

end

