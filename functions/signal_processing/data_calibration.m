function data_calibration(isFirstSec, isLastSec)
%DATA_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here

tic;

global params;
global buffer;

%% Screen Control
if isFirstSec
    screen_init_psy();
end

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();
n_data = size(EOG, 1);

% Registration to the queue
if params.window ~= -1
    for i=1:n_data
        buffer.eye_position_queue.add([NaN NaN]);
    end
end

%% Removal of Eye Blink Detected Range

ranges = blink_range_position_conversion();
blink_detected = blink_range_to_logical_array(ranges);
blink_detected = blink_detected(end-n_data+1:end);

% Blink range removed EOG
EOG(logical(blink_detected), :) = NaN;
EOG_concatenated = EOG(logical(1-blink_detected), :);
n_data_valid = size(EOG_concatenated, 1);

%% Registration
for i=1:n_data_valid
    buffer.drift_removal_queue.add(EOG_concatenated(i,:));
end

%% Visualization
draw_realtime_signal();

%% Parameter Re-assignment

if(params.drift_removing ~= 0) && isLastSec
    % Reset Drift Value
    params.DriftValues = params.DriftValues + nanmedian(buffer.drift_removal_queue.data);
    
    % Reset Linear Function's y-intercept
    buffer.pol_x(2) = 0; % - buffer.pol_x(1) * params.DriftValues(1);
    buffer.pol_y(2) = 0; % - buffer.pol_y(1) * params.DriftValues(2);
end

toc;

end

