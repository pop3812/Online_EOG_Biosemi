function fitting_correction(error_dist_mat, eye_pos_mat)

global buffer;
global params;

window = params.window;
pos = params.stimulus_onset_angle;

[n_stim, two] = size(error_dist_mat); 

%% Constant Correction
buffer.T_const(2) = buffer.T_const(2) + mean(error_dist_mat(:, 2))./(n_stim * buffer.T_matrix(2, 2));

%% Y-axis matrix Correction
eval_delta_y = eye_pos_mat(8, 2) - eye_pos_mat(2, 2);
actual_delta_y = 2.* pos;

% y - Vv correction
buffer.T_matrix(2, 2) = abs(actual_delta_y ./ eval_delta_y) .* buffer.T_matrix(2, 2);

% y - Vh correction
delta = buffer.T_matrix(1, 1) * (eye_pos_mat(6, 2)-eye_pos_mat(4, 2))/(eye_pos_mat(6, 1)-eye_pos_mat(4, 1));
buffer.T_matrix(2, 1) = buffer.T_matrix(2, 1) - delta;

%% Display
disp('Adjusted Transformation Matrix T ([x; y] = T x ([V_h; V_v] - C)) : ');
disp(buffer.T_matrix);

disp('Adjusted Transformation Matrix C ([x; y] = T x ([V_h; V_v] - C)) : ');
disp(buffer.T_const);
end

