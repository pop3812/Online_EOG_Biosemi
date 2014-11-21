function initial_buffer_initiation()
%INITIAL_BUFFER_INITIATION
% Experiment Buffer Settings

global buffer;
global params;

buffer.X = 0; buffer.X_train = 0;
buffer.Y = 0; buffer.Y_train = 0;
buffer.Calib_or_Acquisition = [ones(1, params.CalibrationTime), zeros(1, params.DataAcquisitionTime)];

buffer.DM = online_downsample_init(params.DecimateFactor); % Online downsample buffer
buffer.DM_BK = online_downsample_init(params.blink.DecimateRate); % Online downsample buffer for Blink Detector
buffer.buffer_4medianfilter = circlequeue(params.medianfilter_size, params.CompNum);

buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.dataqueue.data(:,:) = NaN;

buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.raw_dataqueue.data(:,:) = NaN;

buffer.drift_removal_queue = circlequeue(params.DriftRemovalLength, params.CompNum);
buffer.drift_removal_queue.data(:,:) = NaN;

buffer.eye_position_queue = circlequeue(params.QueueLength, params.CompNum);
buffer.eye_position_queue.data(:,:) = NaN;

buffer.recent_n_data = zeros(params.DataAcquisitionTime, 1);
buffer.recent_n_data_valid = zeros(params.DataAcquisitionTime, 1);

buffer.screen_refresh_idx = 1:params.screen_refresh_frequency;
buffer.current_buffer_end_idx = 1;

buffer.dummy_idx = [0:9]';
end

