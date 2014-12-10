function retrieve_session_data()
% RETRIEVE_SESSION_DATA
% retrieves data from the last data acquisition session,
% and saves it in session_data of the buffer
%
% OUTPUT
% buffer.session_data : <1 x n_session cell> i'th cell contains all data 
%                       from i'th acquisition session

global buffer;
global params;

buffer.session_data{buffer.n_session, 1} = struct();

%% Data Retrieving
% Get the number of data point of this session
n_data_sum = nansum(buffer.recent_n_data);

% Get eye position queue
eye_position_queue = circshift(buffer.eye_position_queue.data, ...
    -buffer.eye_position_queue.index_start+1);
end_idx = buffer.eye_position_queue.datasize;
eye_position_queue = eye_position_queue(end_idx-n_data_sum+1:end_idx, :);

% Get eye position queue_in_px
eye_position_queue_px = circshift(buffer.eye_position_queue_px.data, ...
    -buffer.eye_position_queue_px.index_start+1);
eye_position_queue_px = eye_position_queue_px(end_idx-n_data_sum+1:end_idx, :);

% Get baseline drift removed data queue
data_queue = circshift(buffer.dataqueue.data, ...
    -buffer.dataqueue.index_start+1);
end_idx = buffer.dataqueue.datasize;
data_queue = data_queue(end_idx-n_data_sum+1:end_idx, :);

%% Data Saving
buffer.session_data{buffer.n_session, 1}.session = buffer.n_session;
buffer.session_data{buffer.n_session, 1}.saved_time = fix(clock);
buffer.session_data{buffer.n_session, 1}.n_data = n_data_sum;
buffer.session_data{buffer.n_session, 1}.data_queue = data_queue;
buffer.session_data{buffer.n_session, 1}.eye_position_queue = eye_position_queue;
buffer.session_data{buffer.n_session, 1}.eye_position_queue_px = eye_position_queue_px;
buffer.session_data{buffer.n_session, 1}.selected_keyboard = buffer.selected_key;

end

