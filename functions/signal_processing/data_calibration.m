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

% Buffer Initiation for Blink Detection related Buffers
set_blink_detection_parameters();

%% Baseline Drift Removal Calibration
% Calculate the baseline drift value by using first buffer time [sec] data
prog_bar = waitbar(0, 'Calibrating : 0 %', 'Name', program_name);

timer_id_data= timer('TimerFcn','data_processing_for_calibration', ...
    'StartDelay', 0, 'Period', params.DelayTime, 'ExecutionMode', 'FixedRate');
start(timer_id_data);

if(params.drift_removing ~= 0)
    median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;
    
    while(buffer.dataqueue.datasize < median_window_size)
        progress_percentage = buffer.dataqueue.datasize / params.QueueLength * 0.75;
        progress_percentage_val = fix(progress_percentage * 10^4)/100;
        if (ishandle(prog_bar))
            waitbar(progress_percentage, prog_bar, ...
                ['Calibrating : ' num2str(progress_percentage_val) ' %'],...
                'Name', 'Calibrating ...');
        end
        pause(params.DelayTime);
    end
    
    % Save the calculated drift values when user wants to use
    % off-line drift removal
    if(params.drift_removing == 1)
        params.DriftValues = median(buffer.raw_dataqueue.data);
    end
end

stop(timer_id_data);
clear biosemix;

if (ishandle(prog_bar))
waitbar(0.75, prog_bar, ['Calibrating : ' num2str(75) ' %'],...
    'Name', 'Calibrating ...');
end

%% Linear Fitting Calibration

if params.window ~= -1 % if there is another monitor
    linear_fitting_training();
end

if (ishandle(prog_bar))
        waitbar(1.0, prog_bar, ['Calibrating : ' num2str(100) ' %'],...
            'Name', 'Calibrating ...');
        close(prog_bar);
end

end

