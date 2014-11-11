function data_calibration()
%DATA_CALIBRATION : Calibrate the initial parameters for the experiment
%   Detailed explanation goes here

global params;
global buffer;
global program_name;

%% Buffer Initiation
buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.dataqueue.data(:,:) = NaN;

buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.raw_dataqueue.data(:,:) = NaN;

%% Baseline Drift Removal Calibration
% Calculate the baseline drift value by using first buffer time [sec] data
prog_bar = waitbar(0, 'Calibrating : 0 %', 'Name', program_name);
if(params.drift_removing ~= 0)
    median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;

    while(buffer.dataqueue.datasize < median_window_size)
        data_processing();
        progress_percentage = buffer.dataqueue.datasize / params.QueueLength * 0.5;
        progress_percentage_val = fix(progress_percentage * 10^4)/100;
        waitbar(progress_percentage, prog_bar, ...
            ['Calibrating : ' num2str(progress_percentage_val) ' %'],...
            'Name', 'Calibrating ...');
        pause(params.DelayTime);
    end

    % Save the calculated drift values when user wants to use
    % off-line drift removal
    if(params.drift_removing == 1)
        params.DriftValues = median(buffer.raw_dataqueue.data);
    end
else
    waitbar(0.5, prog_bar, ['Calibrating : ' num2str(50) ' %'],...
        'Name', 'Calibrating ...');
end

%% Linear Fitting Calibration
%%% should be implemented here

    close(prog_bar);
end

