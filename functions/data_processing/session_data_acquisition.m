function session_data_acquisition()
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

buffer.recent_n_data(1) = n_data;
buffer.recent_n_data_valid(1) = n_data_valid;

buffer.recent_n_data = circshift(buffer.recent_n_data, -1);
buffer.recent_n_data_valid = circshift(buffer.recent_n_data_valid, -1);

% Check if previous queue is correct
% if incorrect due to new eye blink update, renew it
blink_detected = blink_range_to_logical_array(ranges);
if sum(blink_detected(end-n_data-1:end-n_data+2)) >= 1 % this range might contain previous data points
    blink_detected = blink_detected(1:end-n_data);
    
%     blink_detected = logical(blink_detected);
    df = diff([0 blink_detected' 0]);
    s = struct('on',num2cell(find(df==1)), ...
    'off',num2cell(find(df==-1)-1));
    
    if length(s) > 0 && s(end).off == length(blink_detected)
        n_contig = s(end).off - s(end).on + 1; % # of wrong data
        for idx = 1:n_contig
            % Remove wrong data
            buffer.eye_position_queue.pop();
            buffer.eye_position_queue_px.pop();
        end
        for idx = 1:n_contig
            % Renew
            buffer.eye_position_queue.add([NaN, NaN]);
            buffer.eye_position_queue_px.add([NaN, NaN]);
        end
    end
end
    
%% Reconstructing Eye Positions from EOG signal

if params.window ~= -1
    
    if params.is_coupled
        %%% Coupled
        eye_pos = buffer.T_matrix * (EOG' - repmat(buffer.T_const, 1, n_data));
        eye_pos = eye_pos';
    else
        %%% Non-uncoupled
        X_eye_pos = polyval(buffer.pol_x, EOG(:, 1)); % position of eye in [degree]
        Y_eye_pos = polyval(buffer.pol_y, EOG(:, 2)); % position of eye in [degree]
        eye_pos = [X_eye_pos, Y_eye_pos];
    end

    % Registration to the queue
    for i=1:n_data
        buffer.eye_position_queue.add(eye_pos(i,:));
        px = [screen_degree_to_pixel('X', eye_pos(i,1)), ...
            screen_degree_to_pixel('Y', eye_pos(i,2))];
        buffer.eye_position_queue_px.add(px);
    end
    
    median_eye_pos = nanmedian(eye_pos);
end

%% Visualization
draw_realtime_signal();

% toc;
end