function linear_fitting_training()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;

window = params.window;

n_training = 10;

X_degree_rand = randi([-12, 12], 1, n_training);
Y_degree_rand = randi([-12, 12], 1, n_training);

for i = 1:n_training
    black = BlackIndex(window);
    Screen('FillRect', window, black);
    
    X = screen_degree_to_pixel('X', X_degree_rand(i));
    Y = screen_degree_to_pixel('Y', Y_degree_rand(i));

    screen_draw_fixation(window, X, Y);
    Screen('Flip', window);
    
    WaitSecs(1);
end

sca
end

