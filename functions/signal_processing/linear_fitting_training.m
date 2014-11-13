function linear_fitting_training()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;

window = params.window;
pos = params.stimulus_onset_angle;

X_degree_training = [0 -pos 0 pos pos pos 0 -pos -pos];
Y_degree_training = [0 pos pos pos 0 -pos -pos -pos 0];

n_training = length(X_degree_training); % the number of training stimuli

black = BlackIndex(window);
Screen('FillRect', window, black);
    
for train_idx = 1:n_training
    
    buffer.X = screen_degree_to_pixel('X', X_degree_training(train_idx));
    buffer.Y = screen_degree_to_pixel('Y', Y_degree_training(train_idx));

    screen_draw_fixation(window, buffer.X, buffer.Y);
    Screen('Flip', window);
    
    pause(1.0); % wait 1 sec for settling down the eye position
    for j = 1:params.time_per_stimulus * (1.0/params.DelayTime)
        data_processing();
        pause(params.DelayTime);
    end
end

sca
end

