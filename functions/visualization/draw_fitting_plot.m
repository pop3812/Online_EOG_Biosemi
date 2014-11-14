function draw_fitting_plot(signal_for_training, stimulus_for_training)
%DRAW_FITTING_PLOT
% Visualize the fitting results
global buffer;

n_data = stimulus_for_training.datasize;
width = max(signal_for_training.data(:,1));
height = max(signal_for_training.data(:,2));

figure('name', 'Fitting Results', 'NumberTitle', 'off');
    
subplot(1, 2, 1); scatter(signal_for_training.data(1:n_data,1),...
    stimulus_for_training.data(1:n_data,1)); hold on;
x_x = [min(signal_for_training.data(:,1)), max(signal_for_training.data(:,1))];
plot(x_x, polyval(buffer.pol_x, x_x), '--r', 'LineWidth', 2);

title('Horizontal Component');
xlabel([num2str(buffer.pol_x(1)), 'X + ', num2str(buffer.pol_x(2)) ], ...
    'Color', 'red');


subplot(1, 2, 2); scatter(signal_for_training.data(1:n_data,2),...
    stimulus_for_training.data(1:n_data,2)); hold on;
x_y = [min(signal_for_training.data(:,2)), max(signal_for_training.data(:,2))];
plot(x_y, polyval(buffer.pol_y, x_y), '--r', 'LineWidth', 2);

title('Vertical Component');
xlabel([num2str(buffer.pol_y(1)), 'X + ', num2str(buffer.pol_y(2)) ], ...
    'Color', 'red');

end

