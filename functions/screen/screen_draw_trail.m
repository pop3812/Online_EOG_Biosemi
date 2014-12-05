function screen_draw_trail()
%SCREEN_DRAW_TRAIL
% DRAWS THE CURSOR TRAIL OF POINTS THAT HAS BEEN UPDATED RECENTLY

global params;
global buffer;
% tic;
pen_width = 3.0;
n_trail_point = fix(params.screen_trail_point_per_sec * params.DelayTime);
n_skip = fix(params.SamplingFrequency2Use * params.DelayTime / n_trail_point);

n_data_sum = sum(buffer.recent_n_data);

n_data = buffer.recent_n_data(end);
eye_pos = circshift(buffer.eye_position_queue.data, -buffer.eye_position_queue.index_start+1);

%% Data Retrieving
end_idx = buffer.eye_position_queue.datasize;
eye_pos_trail = eye_pos(end_idx-n_data_sum+1:end_idx,:);
eye_pos = eye_pos(end_idx-n_data+1:end_idx,:);

[numPoints, two]=size(eye_pos_trail);
for i = 1:numPoints
    eye_pos_trail(i, 1) = screen_degree_to_pixel('X', eye_pos_trail(i, 1));
    eye_pos_trail(i, 2) = screen_degree_to_pixel('Y', eye_pos_trail(i, 2));
end

%% Concatenation of Out of Bound Data
eye_pos_trail(isnan(eye_pos_trail(:, 1)) | isnan(eye_pos_trail(:, 2)), :) = [];
if isfield(buffer, 'key_rect')
    key_rect = buffer.key_rect;
    eye_pos_trail(eye_pos_trail(:, 1)<=key_rect(1) | eye_pos_trail(:, 1)>=key_rect(3), :) = [];
    eye_pos_trail(eye_pos_trail(:, 2)<=key_rect(2) | eye_pos_trail(:, 2)>=key_rect(4), :) = [];
end
[numPoints, two]=size(eye_pos_trail);

%% Select range by using current index
% Check if new data has been updated
if buffer.current_buffer_end_idx ~= buffer.eye_position_queue.index_end;
    buffer.current_buffer_end_idx = buffer.eye_position_queue.index_end;
    ExtendFactor = fix(1/params.DelayTime);
    buffer.screen_refresh_idx = 1:ExtendFactor*params.screen_refresh_frequency;
end

current_idx = buffer.screen_refresh_idx(1);
buffer.screen_refresh_idx = circshift(buffer.screen_refresh_idx', -1);
buffer.screen_refresh_idx = buffer.screen_refresh_idx';

ExtendFactor = fix(1/params.DelayTime);
n_data = floor(n_data / params.screen_refresh_frequency * ExtendFactor);
eye_pos = eye_pos(n_data*(current_idx-1)+1:n_data*current_idx ,:);

%% Visualization

if params.window ~= -1
    X = nanmedian(eye_pos(:,1));
    Y = nanmedian(eye_pos(:,2));
    
    % Draw Trail
    end_idx = numPoints - buffer.recent_n_data(end) + n_data*current_idx;
    for i= 1:n_skip:end_idx% numPoints
        if i<=end_idx-n_skip
            Screen(params.window,'DrawLine', [255 128 128 128], ...
                eye_pos_trail(i,1), eye_pos_trail(i,2), ...
                eye_pos_trail(i+n_skip,1),eye_pos_trail(i+n_skip,2), pen_width);
        end
    end
    
    % Draw Pointer
    if ~isnan(X) && ~isnan(Y)
        % Normal eye gaze
        params.X = X;
        params.Y = Y;
        screen_draw_fixation(params.window, params.X, params.Y, 20, 5,...
            [255 255 0], 'X');
    else
        % Eye blink detected
        screen_draw_fixation(params.window, params.X, params.Y, 20, 5,...
            [255 0 0], '-');
    end
    
    Screen('Flip', params.window);
end

% toc;
end