function session_calibration(isFirstSec, isLastSec)
%DATA_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here

% tic;

global params;
global buffer;
global g_handles;

%% Screen Control
if isFirstSec
    screen_init_psy('');
    buffer.X = 0;
    buffer.Y = params.default_fixation_y;
    buffer.drift_removal_queue = circlequeue(params.DriftRemovalLength, params.CompNum);
    buffer.drift_removal_queue.data(:,:) = NaN;
end

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();
n_data = size(EOG, 1);

% Registration to the queue
if params.window ~= -1
    for i=1:n_data
        buffer.eye_position_queue.add([NaN NaN]);
        buffer.eye_position_queue_px.add([NaN NaN]);
    end
end

%% Registration
for i=1:n_data
    buffer.drift_removal_queue.add(EOG(i,:));
end

%% Visualization
draw_realtime_signal();

%% Parameter Re-assignment

if(params.drift_removing ~= 0) && isLastSec
    
    %% Removal of Eye Blink Detected Range
    n_data= buffer.drift_removal_queue.datasize;
    EOG = buffer.drift_removal_queue.data(1:n_data, :);
    
    ranges = blink_range_position_conversion();
    blink_detected = blink_range_to_logical_array(ranges);
    blink_detected = blink_detected(end-n_data+1:end);

    % Blink range removed EOG
    EOG(logical(blink_detected), :) = NaN;
    
    EOG_concatenated = EOG(logical(1-blink_detected), :);
    n_data_valid = size(EOG_concatenated, 1);

    % Reset Drift Value
    params.DriftValues = params.DriftValues + nanmedian(EOG_concatenated);
    
    % Linearly Increasing Drift Removal for Vertical Signal
    
    y_data = EOG_concatenated(:, 2);
    t = (1:n_data_valid)';
    
    threshold = 10^0;
    err_threshold = 5*10^-12; %%%
    
    buffer.drift_pol_y = polyfit(t, y_data, 1);
    est = polyval(buffer.drift_pol_y, t);
    err = nansum(y_data - est);
    
    buffer.drift_pol_y(2) = 0;
    
    if abs(buffer.drift_pol_y(1)) > threshold
        if buffer.drift_pol_y(1)>0
        buffer.drift_pol_y(1) = threshold;
        else
        buffer.drift_pol_y(1) = 0;    
        end
    end
    
    draw_calibration_signal(t, y_data, est, buffer.drift_pol_y(1), err);

    % Re-do calibration if error is too big
    if abs(err)>=err_threshold 
       
       buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', +(params.CalibrationTime-1));
       buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';
       
       buffer.X_train = circshift(buffer.X_train', +(params.CalibrationTime-1));
       buffer.X_train = buffer.X_train';
       buffer.Y_train = circshift(buffer.Y_train', +(params.CalibrationTime-1));
       buffer.Y_train = buffer.Y_train';
    end
    
    % Reset Linear Function's y-intercept
%     buffer.pol_x(2) = 0; % - buffer.pol_x(1) * params.DriftValues(1);
%     buffer.pol_y(2) = 0; % - buffer.pol_y(1) * params.DriftValues(2);
end

% toc;

end

