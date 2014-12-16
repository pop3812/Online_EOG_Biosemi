function initial_calibration()
%DATA_CALIBRATION : Calibrate the initial parameters for the experiment
%   Detailed explanation goes here

global params;
global buffer;
global program_name;
global g_handles;

screen_init_psy();

%% Buffer Initiation
initial_buffer_initiation()
params.DriftValues = zeros(1, params.CompNum);

% Buffer Initiation for Blink Detection related Buffers
set_blink_detection_parameters();

%% Baseline Drift Removal Calibration
% Calculate the baseline drift value by using first buffer time [sec] data
g_handles.prog_bar = waitbar(0, '0 %');
set(g_handles.prog_bar, 'Name', 'Calibration Progress');

set(g_handles.console, 'String', 'Calibration');
cla(g_handles.current_position);

screen_init_psy('Blink your eyes.');

timer_id_data= timer('TimerFcn','data_processing_for_calibration', ...
    'StartDelay', 0, 'Period', params.DelayTime, 'ExecutionMode', 'FixedRate');
start(timer_id_data);

if(params.drift_removing ~= 0)
    median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;
    blink_window_size = params.blink_calibration_time * params.SamplingFrequency2Use;
    
    while(buffer.dataqueue.datasize < median_window_size)
        if (buffer.dataqueue.datasize > blink_window_size)
            screen_init_psy();
        end
        progress_percentage = buffer.dataqueue.datasize / params.QueueLength * 0.15;
        progress_percentage_val = fix(progress_percentage * 10^4)/100;
        if (ishandle(g_handles.prog_bar))
            waitbar(progress_percentage, g_handles.prog_bar, ...
                [num2str(progress_percentage_val) ' % Done']);
        end
        pause(params.DelayTime);
    end
    
    % Save the calculated drift values when user wants to use
    % off-line drift removal
    if(params.drift_removing == 1)
        params.DriftValues = median(buffer.raw_dataqueue.data(1:median_window_size, :));
    end
end

stop(timer_id_data);
delete(timer_id_data);
clear biosemix;

if (ishandle(g_handles.prog_bar))
waitbar(0.15, g_handles.prog_bar, [num2str(15) ' % Done']);

end

%% Linear Fitting Calibration

buffer.calibration_end_idx = buffer.dataqueue.index_end;

if params.window ~= -1 % if there is another monitor
    if params.is_coupled
        linear_fitting_training_3d();
    else
        linear_fitting_training();
    end
end

if (ishandle(g_handles.prog_bar))
        waitbar(1.0, g_handles.prog_bar, [num2str(100) ' % Done']);
        close(g_handles.prog_bar);
end

screen_init_psy('Calibration has been done. Take a rest.');
set(g_handles.console, 'String', 'Resting');

end

