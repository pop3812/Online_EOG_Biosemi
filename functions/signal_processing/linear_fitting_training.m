function linear_fitting_training()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;

window = params.window;
pos = params.stimulus_onset_angle;

%% Stimulus
X_degree_training = [0 -pos 0 pos pos pos 0 -pos -pos];
Y_degree_training = [0 pos pos pos 0 -pos -pos -pos 0];

n_training = length(X_degree_training); % the number of training stimuli

black = BlackIndex(window);
Screen('FillRect', window, black);

%% Set Parameters

% buffers for training
training_data_length = 9 * params.time_per_stimulus * params.SamplingFrequency2Use;

signal_for_training = circlequeue(training_data_length, params.CompNum);
signal_for_training.data(:,:) = NaN;

stimulus_for_training = circlequeue(training_data_length, params.CompNum);
stimulus_for_training.data(:,:) = NaN;

%% Get Training Data


for train_idx = 1:n_training
    
    stimulus_onset_idx = buffer.dataqueue.index_start;
    
    buffer.X = X_degree_training(train_idx);
    buffer.Y = Y_degree_training(train_idx);
    
    X = screen_degree_to_pixel('X', buffer.X);
    Y = screen_degree_to_pixel('Y', buffer.Y);

    screen_draw_fixation(window, X, Y);
    [beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);
    sound(beep, Fs); % sound beep
    Screen('Flip', window);
    
    pause(1.0); % wait 1 sec for settling down the eye position
    
    % Data acquisition for this training stimulus
    for j = 1:params.time_per_stimulus * (1.0/params.DelayTime)
        data_processing();
        pause(params.DelayTime);
    end
    clear biosemix;
    
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
    
    % Reconstruction of EOG during the stimulus
    EOG = circshift(buffer.dataqueue.data, -stimulus_onset_idx+1);
    EOG = EOG(1:stimulus_n_data, :);
    
    for i=1:stimulus_n_data
        signal_for_training.add(EOG(i,:));
        stimulus_for_training.add([buffer.X, buffer.Y]);
    end
    
end

buffer.X = 0;
buffer.Y = 0;

%% Blink Range Removal during the Training

sca
end

