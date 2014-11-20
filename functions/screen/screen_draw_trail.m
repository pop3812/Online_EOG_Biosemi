function screen_draw_trail()
%SCREEN_DRAW_TRAIL
% DRAWS THE CURSOR TRAIL OF POINTS THAT HAS BEEN UPDATED RECENTLY

global params;
global buffer;

n_data = buffer.recent_n_data;
eye_pos = circshift(buffer.eye_position_queue.data, -buffer.eye_position_queue.index_start+1);

end_idx = buffer.eye_position_queue.datasize;
eye_pos = eye_pos(end_idx-n_data+1:end_idx,:);

% Select range by using current index

% Check if new data has been updated
if buffer.current_buffer_end_idx ~= buffer.eye_position_queue.index_end;
    buffer.current_buffer_end_idx = buffer.eye_position_queue.index_end;
    buffer.screen_refresh_idx = 1:params.screen_refresh_frequency;
end

current_idx = buffer.screen_refresh_idx(1);
buffer.screen_refresh_idx = circshift(buffer.screen_refresh_idx', -1);
buffer.screen_refresh_idx = buffer.screen_refresh_idx';

n_data = floor(n_data / params.screen_refresh_frequency);
eye_pos = eye_pos(n_data*(current_idx-1)+1:n_data*current_idx ,:);

if params.window ~= -1
    X = nanmedian(eye_pos(:,1));
    Y = nanmedian(eye_pos(:,2));
    
    if ~isnan(X) && ~isnan(Y)
        % Normal eye gaze
        params.X = X;
        params.Y = Y;
        screen_draw_fixation(params.window, params.X, params.Y, 25, 5,...
            [255 255 0], 'X');
        Screen('Flip', params.window);
    else
        % Eye blink detected
        screen_draw_fixation(params.window, params.X, params.Y, 25, 5,...
            [255 0 0], '-');
        Screen('Flip', params.window);
    end
end

end

