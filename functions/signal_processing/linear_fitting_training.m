function linear_fitting_training()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;

window = params.window;
pos = params.stimulus_onset_angle;

%% Stimulus
% 3 x 3 Grid Stimulus
% X_degree_training = [0 -pos 0 pos pos pos 0 -pos -pos];
% Y_degree_training = [0 pos pos pos 0 -pos -pos -pos 0];

% X shape Stimulus
X_degree_training = [0 -pos -pos/2 pos/2 pos pos pos/2 -pos/2 -pos];
Y_degree_training = [0 pos pos/2 -pos/2 -pos pos pos/2 -pos/2 -pos];

n_training = length(X_degree_training); % the number of training stimuli

black = BlackIndex(window);
Screen('FillRect', window, black);
[beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);

%% Set Parameters

% buffers for training
training_data_length = 9 * params.time_per_stimulus * params.SamplingFrequency2Use;

signal_for_training = circlequeue(training_data_length, params.CompNum);
signal_for_training.data(:,:) = NaN;

stimulus_for_training = circlequeue(training_data_length, params.CompNum);
stimulus_for_training.data(:,:) = NaN;

%% Get Training Data

% Show the instruction for 2 seconds.
Screen('TextFont', window, 'Cambria');
Screen('TextSize', window, 15);
Screen('TextStyle', window, 1);

[X_center,Y_center] = RectCenter(params.rect);

DrawFormattedText(window, 'Look at the point after the beep.', 'center', ...
    Y_center-100, [255, 255, 255]);
Screen('Flip', window);  
WaitSecs(2);

for train_idx = 1:n_training
    
    % Stimulus onset
    stimulus_onset_idx = buffer.dataqueue.index_start;
    
    buffer.X = X_degree_training(train_idx);
    buffer.Y = Y_degree_training(train_idx);
    
    screen_draw_fixation(window, buffer.X, buffer.Y);

    sound(beep, Fs); % sound beep
    Screen('Flip', window);
    
    pause(1.0); % wait 1 sec for settling down the eye position
    
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
    EOG = EOG(1:stimulus_n_data, :);
    blink_detected = blink_detected(1:stimulus_n_data, :);
    
    % Blink range removal and concatenation
    EOG = EOG(logical(1-blink_detected), :);
    stimulus_n_data = size(EOG, 1);
    
    for i=1:stimulus_n_data
        signal_for_training.add(EOG(i,:));
        stimulus_for_training.add([buffer.X, buffer.Y]);
    end
    
end

% Pseudo eye movement for dummy mode
buffer.X = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
buffer.Y = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
buffer.X = [linspace(-21,21,params.DataAcquisitionTime),  linspace(0, 0, params.CalibrationTime)];

buffer.X = buffer.X';
buffer.Y = buffer.X;

%% Linear fitting using training data

if strcmp(params.fit_type, 'linear')
    n_data = stimulus_for_training.datasize;
    buffer.pol_x = polyfit(signal_for_training.data(1:n_data,1),...
        stimulus_for_training.data(1:n_data,1), 1);
    buffer.pol_y = polyfit(signal_for_training.data(1:n_data,2),...
        stimulus_for_training.data(1:n_data,2), 1);
    
    buffer.pol_y(1) = buffer.pol_y(1) .* 2.0; %%%
    
    % Visualize the fitting results
    draw_fitting_plot(signal_for_training, stimulus_for_training);

else
    throw(MException('TrainingDataFitting:InvalidFittingType',...
    'Invalid fitting type has been requested.'));
end

end