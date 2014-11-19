function screen_draw_trail()
%SCREEN_DRAW_TRAIL
% DRAWS THE CURSOR TRAIL OF POINTS THAT HAS BEEN UPDATED RECENTLY

global params;
global buffer;
tic;

refresh_period = 1.0 / params.screen_refresh_frequency;

n_data = refresh_period * params.SamplingFrequency2Use;
eye_pos = circshift(buffer.eye_position_queue.data, -buffer.eye_position_queue.index_start+1);
end_idx = buffer.eye_position_queue.datasize;
eye_pos = eye_pos(end_idx-n_data+1:end_idx,:);

if params.window ~= -1
    X = nanmedian(eye_pos(:,1));
    Y = nanmedian(eye_pos(:,2));

    if ~isnan(X) && ~isnan(Y)
        screen_draw_fixation(params.window, X, Y, 25, 5, [255 255 0], 'X');
        disp([num2str(X), ', ', num2str(Y)]);
        Screen('Flip', params.window);
    end
end

toc;
end

