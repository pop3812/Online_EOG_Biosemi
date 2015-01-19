function linear_fitting_training_3d()
%LINEAR_FITTING_TRAINING Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;
global g_handles;

window = params.window;
pos = params.stimulus_onset_angle;

X=[];
Y=[];
Vh=[];
Vv=[];

%% Stimulus

n_repeat = 1;

X_degree_training = [linspace(-pos, pos, 3), linspace(-pos, pos, 3), linspace(-pos, pos, 3)];
Y_degree_training = [linspace(pos, pos, 3), linspace(0, 0, 3), linspace(-pos, -pos, 3)];

X_degree_training = [X_degree_training, fliplr(X_degree_training)];
Y_degree_training = [Y_degree_training, fliplr(Y_degree_training)];

X_degree_training = repmat(X_degree_training, 1, n_repeat);
Y_degree_training = repmat(Y_degree_training, 1, n_repeat);

n_training = length(X_degree_training); % the number of training stimuli

% Random Permutation
R = 1:n_training; % When not using random permutation
% R = randperm(n_training);

X_degree_training = [0, X_degree_training(R)];
Y_degree_training = [0, Y_degree_training(R)];

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

% Show the instruction for 3 seconds.
Screen('TextFont', window, 'Cambria');
Screen('TextSize', window, 15);
Screen('TextStyle', window, 1);

[X_center,Y_center] = RectCenter(params.rect);

if params.default_fixation_y > 0
    Y_center = screen_degree_to_pixel('Y', params.default_fixation_y-3);
elseif params.default_fixation_y <= 0
    Y_center = screen_degree_to_pixel('Y', params.default_fixation_y+3);;
end

DrawFormattedText(window, 'Look at the point after the beep.', 'center', ...
    Y_center, [255, 255, 255]);
Screen('Flip', window);

[voice, Fs] = audioread([pwd, '\resources\sound\voice\beep_start_point.wav']);
Snd('Play', voice', Fs); WaitSecs(length(voice)/Fs);
            
WaitSecs(3.0);

for train_idx = 1:n_training+1
    % Rest for every 10 data point
    if mod(train_idx-1, 10) == 0 && train_idx ~= 1
        session_subject_rest(20);
        set(g_handles.console, 'String', 'Calibration');
    end
    
    % Calibration for every 5 data point
    if mod(train_idx-1, 5) == 0
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
    threshold = 5*10^3;
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
     
    % Update Progress Bar
    if (ishandle(g_handles.prog_bar))
    prog_ratio = 0.15 + 0.85 * train_idx/(n_training+1);
    prog_ratio_val = fix(prog_ratio * 10^4)/100;
    waitbar(prog_ratio, g_handles.prog_bar, [num2str(prog_ratio_val) ' % Done']);
    %['Stimulus : ' num2str(train_idx) ' / ' num2str(n_training)]);
    end
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

Surf_struct.XGrid = XGrid;
Surf_struct.YGrid = YGrid;
Surf_struct.Vh_surf = Vh_surf;
Surf_struct.Vv_surf = Vv_surf;
Surf_struct.n_Vh = n_Vh;
Surf_struct.n_Vv = n_Vv;
Surf_struct.X = X;
Surf_struct.Y = Y;
Surf_struct.Vh = Vh;
Surf_struct.Vv = Vv;

else
    throw(MException('TrainingDataFitting:InvalidFittingType',...
    'Invalid fitting type has been requested.'));
end

%% Pseudo eye movement for dummy mode
% buffer.X_train = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
% buffer.Y_train = -params.stimulus_onset_angle:3:params.stimulus_onset_angle;
buffer.X = 0;
buffer.Y = params.default_fixation_y;
buffer.X_train = [linspace(0, 0, params.CalibrationTime), ...
    linspace(-21,21,params.DataAcquisitionTime)];
buffer.X_train = [linspace(params.default_fixation_y, ...
    params.default_fixation_y, params.CalibrationTime), ...
    linspace(-21,21,params.DataAcquisitionTime)];

buffer.X_train = buffer.X_train';
buffer.Y_train = buffer.Y_train';

ExtendFactor = fix(1/params.DelayTime);
buffer.Calib_or_Acquisition = [ones(1, ExtendFactor*params.CalibrationTime), zeros(1, ExtendFactor*params.DataAcquisitionTime), 2.* ones(1, ExtendFactor*params.ResultShowTime)];

%% Calculate Transformation Matrix

b = 0;
% if c < 0
%     c = 0; %%%
% end

A = [a b; c d];
T_const = polyfit(Y, Vv-c.*X, 1);
T_const = [0; T_const(2)];
% T_const = [0; nanmean(Vv)];

if det(A)==0
   disp('Warning : Transformation Matrix might not exist. This might be an insoluable problem.');
end

buffer.Surf_struct = Surf_struct;
buffer.T_matrix = inv(A);
buffer.T_const = T_const;

%% Fitting Results Visualization

draw_fitting_plot_3d();

end