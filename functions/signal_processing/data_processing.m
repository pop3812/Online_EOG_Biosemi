function data_processing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here
tic;

global params;
global buffer;

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();
n_data = size(EOG, 1);

%% Removal of Eye Blink Detected Range

ranges = blink_range_position_conversion();
blink_detected = blink_range_to_logical_array(ranges);
blink_detected = circshift(blink_detected, -buffer.dataqueue.index_start+1);
blink_detected = blink_detected(end-n_data+1:end);

% Blink range removed EOG
EOG(logical(blink_detected), :) = NaN;
EOG_concatenated = EOG(logical(1-blink_detected), :);
n_data_valid = size(EOG_concatenated, 1);

%% Reconstructing Eye Positions from EOG signal

X_eye_pos = polyval(buffer.pol_x, EOG(:, 1)); % position of eye in [degree]
Y_eye_pos = polyval(buffer.pol_y, EOG(:, 2)); % position of eye in [degree]

eye_pos = [X_eye_pos, Y_eye_pos];

% Registration to the queue
for i=1:n_data
    buffer.eye_position_queue.add(eye_pos(i,:));
end

median_eye_pos = nanmedian(eye_pos);

%% Visualization
draw_realtime_signal();
% draw_graphs(EOG_concatenated);

% Real-time Tracking
if params.window ~= -1
screen_draw_fixation(params.window, median_eye_pos(1), median_eye_pos(2), ...
    25, [255 255 0]);
Screen('Flip', params.window); 
end

toc;
end