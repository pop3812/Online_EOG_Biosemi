function data_calibration()
%DATA_CALIBRATION : Calibrate the initial parameters for the experiment
%   Detailed explanation goes here

global params;
global buffer;


buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.dataqueue.data(:,:) = NaN;

buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.raw_dataqueue.data(:,:) = NaN;

% Calculate the baseline drift value by using first buffer time [sec] data
if(params.drift_removing ~= 0)
    prog_bar = waitbar(0, 'Calibrating ...');
    median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;

    while(buffer.dataqueue.datasize < median_window_size)
        data_processing();
        progress_percentage = buffer.dataqueue.datasize / params.QueueLength;
        waitbar(progress_percentage, prog_bar, 'Calibrating ...');
        pause(params.DelayTime);
    end

        close(prog_bar);
    
    % Save the calculated drift values when user wants to use
    % off-line drift removal
    if(params.drift_removing == 1)
        params.DriftValues = median(buffer.raw_dataqueue.data);
    end
end
    
end

