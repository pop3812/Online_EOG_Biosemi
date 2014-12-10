function linear_fitting_training_3d()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;

window = params.window;
pos = params.stimulus_onset_angle;

X=[];
Y=[];
Vh=[];
Vv=[];

%% Stimulus
%%%

X_degree_training = [0, linspace(-pos, pos, 5), linspace(-pos, pos, 5), linspace(-pos, pos, 5), linspace(-pos, pos, 5)];
Y_degree_training = [0, linspace(pos, pos, 5), linspace(pos/2, pos/2, 5), linspace(-pos/2, -pos/2, 5), linspace(-pos, -pos, 5)];

n_training = length(X_degree_training); % the number of training stimuli

black = BlackIndex(window);
Screen('FillRect', window, black);
[beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);

%% Set Parameters

% buffers for training
training_data_length = length(X_degree_training) * ...
    params.time_per_stimulus * params.SamplingFrequency2Use;

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
WaitSecs(3.0);

for train_idx = 1:n_training
    
    % Stimulus onset
    stimulus_onset_idx = buffer.dataqueue.index_end;
    
    buffer.X = X_degree_training(train_idx);
    buffer.Y = Y_degree_training(train_idx);
    
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
    threshold = 5*10^-3;
    EOG(EOG(:,1)<-threshold | EOG(:,1)>threshold, :) = [];
    EOG(EOG(:,2)<-threshold | EOG(:,2)>threshold, :) = [];
    end
    
    stimulus_n_data = size(EOG, 1);
    
    for i=1:stimulus_n_data
        signal_for_training.add(EOG(i,:));
        stimulus_for_training.add([buffer.X, buffer.Y]);
    end
    
    Vh = [Vh, nanmedian(EOG(:,1))];
    Vv = [Vv, nanmedian(EOG(:,2))];
    X = [X, buffer.X];
    Y = [Y, buffer.Y];
end

%% Linear fitting using training data

if strcmp(params.fit_type, 'linear')

    if (~params.DummyMode)
%         buffer.pol_y(1) = buffer.pol_y(1) .* 2.0; %%%
    end
    
%% Draw 3D Plane Plot
XGrid = linspace(-15, 15, 20);
YGrid = linspace(-15, 15, 20);
% [xg,yg]=meshgrid(XGrid, YGrid);

Vh_surf = gridfit(X, Y, Vh, XGrid, YGrid);
Vv_surf = gridfit(X, Y, Vv, XGrid, YGrid);

n_Vh = fitNormal([X', Y', Vh']);
n_Vv = fitNormal([X', Y', Vv']);

a = -n_Vh(1)/n_Vh(3);
b = -n_Vh(2)/n_Vh(3);
c = -n_Vv(1)/n_Vv(3);
d = -n_Vv(2)/n_Vv(3);

% figure;
% subplot(1,2,1);
% colormap(hot(256));
% surf(XGrid,YGrid,Vh_surf);
% subplot(1,2,2);
% colormap(hot(256));
% surf(XGrid,YGrid,Vv_surf);

else
    throw(MException('TrainingDataFitting:InvalidFittingType',...
    'Invalid fitting type has been requested.'));
end

% Pseudo eye movement for dummy mode
% buffer.X_train = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
% buffer.Y_train = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
buffer.X = 0;
buffer.Y = 0;
buffer.X_train = [linspace(0, 0, params.CalibrationTime), linspace(-21,21,params.DataAcquisitionTime)];

buffer.X_train = buffer.X_train';
buffer.Y_train = buffer.X_train;

A = [a b; c d];
disp('Transformation Matrix T ([x; y] = T x [V_h; V_v]) : ');
disp(inv(A));

buffer.T_matrix=inv(A);

end