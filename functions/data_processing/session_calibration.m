function session_calibration(isFirstSec, isLastSec)
%DATA_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here

% tic;

global params;
global buffer;

%% Screen Control
if isFirstSec
    % Sound Beep
    [beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);
    sound(beep, Fs); % sound beep
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

    %% Reset Constant Drift Value
    params.DriftValues = params.DriftValues + nanmedian(EOG_concatenated);
    
    %% Linearly Increasing Drift Removal for Vertical Signal
    
    threshold = params.linear_baseline_slope_threshold;
    err_threshold = params.linear_baseline_err_threshold;
    
    t_total = 1:n_data_valid;
    y_data = EOG_concatenated(:, 2);
    
    % Plateau Find Function
    plateaus = signal_feature_find(y_data, 'flat');
    n_region = length(plateaus);

    if n_region > 0
        slope_mat = zeros(n_region, 1);
        err_mat = zeros(n_region, 1);

        for i = 1:n_region
            t = (1:plateaus(i).length)';
            region_data = y_data(plateaus(i).on:plateaus(i).off);
            
            pol = polyfit(t, region_data, 1);
            est = polyval(pol, t);
            
            plateaus(i).est = est;
            
            slope_mat(i) = pol(1);
            err_mat(i) = nansum(region_data - est);
        end % for n_region end
        
        buffer.drift_pol_y(1) = nanmean(slope_mat);
        buffer.drift_pol_y(2) = 0;
        err = nansum(err_mat);

        if abs(buffer.drift_pol_y(1)) > threshold
            if buffer.drift_pol_y(1)>0
            buffer.drift_pol_y(1) = threshold;
            else
            buffer.drift_pol_y(1) = 0;    
            end
        end
        
        draw_calibration_signal(t_total, y_data, plateaus, buffer.drift_pol_y(1), err);
        
        %% Re-do calibration if error is too big
        if abs(err)>=err_threshold 
            redo_calibration();
        
        else
            
        buffer.calibration_end_idx = buffer.dataqueue.index_end;
        buffer.Recalibration_status = 0;
        
        end
    else
    %% Re-do calibration if no flat-area has been found
        redo_calibration();

    end


end

% toc;

end

function redo_calibration()
global params;
global buffer;

move_time = (1./params.DelayTime) * params.CalibrationTime;
buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', +(move_time));
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

buffer.X_train = circshift(buffer.X_train, +(move_time));
buffer.Y_train = circshift(buffer.Y_train, +(move_time));

buffer.Recalibration_status = 1;

end