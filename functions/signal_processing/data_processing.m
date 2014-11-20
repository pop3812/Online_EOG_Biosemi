function data_processing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here
% tic;

global params;
global buffer;

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();
n_data = size(EOG, 1);

%% Removal of Eye Blink Detected Range

ranges = blink_range_position_conversion();
blink_detected = blink_range_to_logical_array(ranges);
blink_detected = blink_detected(end-n_data+1:end);

% Blink range removed EOG
EOG(logical(blink_detected), :) = NaN;
EOG_concatenated = EOG(logical(1-blink_detected), :);
n_data_valid = size(EOG_concatenated, 1);

buffer.recent_n_data = n_data;
buffer.recent_n_data_valid = n_data_valid;

%% Reconstructing Eye Positions from EOG signal

if params.window ~= -1
    X_eye_pos = polyval(buffer.pol_x, EOG(:, 1)); % position of eye in [degree]
    Y_eye_pos = polyval(buffer.pol_y, EOG(:, 2)); % position of eye in [degree]

    eye_pos = [X_eye_pos, Y_eye_pos];

    % Registration to the queue
    for i=1:n_data
        buffer.eye_position_queue.add(eye_pos(i,:));
    end

    median_eye_pos = nanmedian(eye_pos);
end

%% Visualization
draw_realtime_signal();

% toc;
end