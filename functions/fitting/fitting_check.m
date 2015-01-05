function [error_dist_mat, err_distances, eye_pos_mat] = fitting_check()
%SCREEN_FITTING_CHECK Summary of this function goes here
%   Detailed explanation goes here

global params;
global buffer;
global g_handles;

window = params.window;
pos = params.stimulus_onset_angle;

screen_init_psy();

%% Reset X, Y Train
temp_X_train = buffer.X_train;
temp_Y_train = buffer.Y_train;

buffer.X_train = 0;
buffer.Y_train = 0;

%% Stimulus

X_stim_train = [-pos 0 pos -pos 0 pos -pos 0 pos];
Y_stim_train = [pos pos pos 0 0 0 -pos -pos -pos];

n_training = length(X_stim_train); % the number of training stimuli

R_perm = randperm(n_training);
X_stim_train = X_stim_train(R_perm);
Y_stim_train = Y_stim_train(R_perm);

% X_stim_train = randi([-pos pos], 1, n_stim);
% Y_stim_train = randi([-pos pos], 1, n_stim);

error_dist_mat = zeros(n_training, 2);
eye_pos_mat = zeros(n_training, 2);
err_distances = zeros(1, n_training);

black = BlackIndex(window);
Screen('FillRect', window, black);
[beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);

%% Get Stimulus Data

% Show the instruction for 3 seconds.
Screen('TextFont', window, 'Cambria');
Screen('TextSize', window, 15);
Screen('TextStyle', window, 1);

[X_center,Y_center] = RectCenter(params.rect);

if params.default_fixation_y > 0
    Y_center = screen_degree_to_pixel('Y', params.default_fixation_y-3);
elseif params.default_fixation_y <= 0
    Y_center = screen_degree_to_pixel('Y', params.default_fixation_y+3);
end

DrawFormattedText(window, 'Look at the point after the beep.', 'center', ...
    Y_center, [255, 255, 255]);
Screen('Flip', window);  
WaitSecs(3.0);

for train_idx = 1:n_training
    % Rest for every 10 data point
    if mod(train_idx-1, 10) == 0 && train_idx ~= 1
        session_subject_rest();
        set(g_handles.console, 'String', 'Calibration');
    end
    
    % Calibration for every 5 data point
    if mod(train_idx-1, 1) == 0
        sound(beep, Fs); % sound beep
        buffer.Recalibration_status = 1;
        while buffer.Recalibration_status == 1
            for calib_sec = 1:params.CalibrationTime
               isFirst = (calib_sec == 1);
               isLast = (calib_sec == params.CalibrationTime);

               session_calibration(isFirst, isLast);
               WaitSecs(1.0);
            end
        end
    end
    
    % Stimulus onset
    stimulus_onset_idx = buffer.dataqueue.index_end;
    
    buffer.X = X_stim_train(train_idx);
    buffer.Y = Y_stim_train(train_idx);
    
    screen_draw_fixation(window, buffer.X, buffer.Y);

    sound(beep, Fs); % sound beep
    Screen('Flip', window);
    
    WaitSecs(1.0); % wait 1 sec for settling down the eye position
    
    % Data acquisition for this training stimulus
    for j = 1:params.time_per_stimulus * (1.0/params.DelayTime)
        data_processing_for_calibration();
        pause(params.DelayTime);
    end
%     clear biosemix;
    
    % Stimulus range calculation
    stimulus_off_idx = buffer.dataqueue.index_end;
    if (stimulus_onset_idx > stimulus_off_idx)
        stimulus_n_data = buffer.dataqueue.length ...
                          - (stimulus_onset_idx - stimulus_off_idx) + 1;
    elseif (stimulus_onset_idx < stimulus_off_idx)
        stimulus_n_data = stimulus_off_idx - stimulus_onset_idx + 1;
    else
        throw(MException('LinearFittingTraining:TooLongTimePerStimulus',...
        'The time per stimulus is too long. It should be less than BufferTime - 2.'));
    end
    
    % Blink range position calculation
    ranges = blink_range_position_conversion();
    blink_detected = blink_range_to_logical_array(ranges);
    blink_detected = circshift(blink_detected, buffer.dataqueue.index_start-stimulus_onset_idx);
    
    % Reconstruction of EOG during the stimulus
    
    EOG = circshift(buffer.dataqueue.data, -stimulus_onset_idx+1);
    supposed_data_n = params.time_per_stimulus * params.SamplingFrequency2Use;
    if stimulus_n_data-supposed_data_n+1>0
        EOG = EOG(stimulus_n_data-supposed_data_n+1:stimulus_n_data, :);
        blink_detected = blink_detected(stimulus_n_data-supposed_data_n+1:stimulus_n_data, :);
    else
        EOG = EOG(1:stimulus_n_data, :);
        blink_detected = blink_detected(1:stimulus_n_data, :);
    end
    
    % Blink range removal and concatenation
    EOG = EOG(logical(1-blink_detected), :);
    
    % Outliar removal
    if ~params.DummyMode
    threshold = 5*10^3;
    EOG(EOG(:,1)<-threshold | EOG(:,1)>threshold, :) = [];
    EOG(EOG(:,2)<-threshold | EOG(:,2)>threshold, :) = [];
    end
    
    stimulus_n_data = size(EOG, 1);
    
    eye_pos = buffer.T_matrix * (EOG' - repmat(buffer.T_const, 1, stimulus_n_data));
    eye_pos = eye_pos';
    
    median_eye_pos = nanmedian(eye_pos);
    
    %% Draw Fixation
    
    screen_draw_fixation(window, buffer.X, buffer.Y);
    screen_draw_fixation(window, median_eye_pos(1), median_eye_pos(2), 30, 2, [255 0 0 255], '+');
    
    error_dist_mat(train_idx, :) = [buffer.X, buffer.Y]-[median_eye_pos(1), median_eye_pos(2)];
    err_distances(train_idx) = norm(error_dist_mat(train_idx,:), 2);
    eye_pos_mat(train_idx, :) = [median_eye_pos(1), median_eye_pos(2)];
    
    DrawFormattedText(window, sprintf('Error Distance : %2.2f%c', ...
        err_distances(train_idx), char(176)), 'center', ...
    Y_center, [255, 255, 255]);

    Screen('Flip', window);
    WaitSecs(2.0);
end

screen_init_psy(sprintf('Check Done.%cMean distance : %2.2f%c', char(10), mean(err_distances), char(176)));
disp('CHECK DONE');
fprintf('Mean distance : %2.2f%c', mean(err_distances), char(176));

iri(R_perm) = 1:n_training;
X_stim_train = X_stim_train(iri);
Y_stim_train = Y_stim_train(iri);
eye_pos_mat(:, 1) = eye_pos_mat(iri, 1);
eye_pos_mat(:, 2) = eye_pos_mat(iri, 2);
error_dist_mat(:, 1) = error_dist_mat(iri, 1);
error_dist_mat(:, 2) = error_dist_mat(iri, 2);
err_distances = err_distances(iri);

figure;
cc = jet(n_training);
for train_idx = 1:n_training
    scatter(X_stim_train(train_idx), Y_stim_train(train_idx), 100, cc(train_idx, :), 'filled', 'o'); hold on;
    scatter(eye_pos_mat(train_idx, 1), eye_pos_mat(train_idx, 2), 100, cc(train_idx, :), 'd', 'MarkerEdgeColor','r'); hold on;
end
xlim([-20 20]); ylim([-20 20]); grid on;

%% Reset X, Y Train
buffer.X_train = temp_X_train;
buffer.Y_train = temp_Y_train;

%% Fitting Correction

corr_or_not = input('Do you want to adjust the fitting function? [y/n] ','s');

if strcmp(corr_or_not, 'y')
    fitting_correction(error_dist_mat, eye_pos_mat);
    disp('Successfully adjusted the fitting function.');
end

end

