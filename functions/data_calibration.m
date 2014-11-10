function data_calibration()
%DATA_CALIBRATION : Calibrate the initial parameters for the experiment
%   Detailed explanation goes here

global params;
global buffer;
global program_name;

buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.dataqueue.data(:,:) = NaN;

buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.raw_dataqueue.data(:,:) = NaN;

% Calculate the baseline drift value by using first buffer time [sec] data
if(params.drift_removing ~= 0)
    prog_bar = waitbar(0, 'Calibrating : 0 %', 'Name', program_name);
    median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;

    while(buffer.dataqueue.datasize < median_window_size)
        data_processing();
        progress_percentage = buffer.dataqueue.datasize / params.QueueLength;
        progress_percentage_val = fix(progress_percentage * 10^4)/100;
        waitbar(progress_percentage, prog_bar, ...
            ['Calibrating : ' num2str(progress_percentage_val) ' %'],...
            'Name', 'Calibrating ...');
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

