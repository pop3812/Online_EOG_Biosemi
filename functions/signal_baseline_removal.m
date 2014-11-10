function [ baseline_removed_EOG ] = signal_baseline_removal(denoised_EOG)
%SIGNAL_BASELINE_REMOVAL : Apply baseline drift removal algorithm using median value
% This function assumes constant baseline drift for local time window
% Input argument
% raw_EOG : Buffer Length x Channel Number matrix with denoised signals
%
% Output argument
% baseline_removed_EOG : Buffer Length x Channel Number matrix with
%                        baseline drift removed signals

global buffer;
global params;

% baseline_removed_EOG = zeros(n_data, params.CompNum);
median_window_size = params.drift_filter_time * params.SamplingFrequency2Use;
n_data = size(denoised_EOG, 1);

if(buffer.raw_dataqueue.datasize < median_window_size)
    % Data Add to raw data queue
    for i=1:n_data
        buffer.raw_dataqueue.add(denoised_EOG(i,:));
    end
    
    baseline_removed_EOG = denoised_EOG;
else
    
    % Off-line drift removal
    if(params.drift_removing == 1)
        % Baseline Drift Value
        baseline_drift_cur = repmat(params.DriftValues, n_data, 1);
        disp(params.DriftValues)
        
    % Online drift removal
    elseif(params.drift_removing == 2)
        % Baseline Drift of previous buffer data
        baseline_drift_cur = median(buffer.raw_dataqueue.data);
        baseline_drift_cur = repmat(baseline_drift_cur, ...
            n_data, 1);
    
    % Error throwing when parameter value is out of range 
    else
       exception = MException('VerifyOutput:OutOfBounds', ...
       'params.drift_removing value is outside the allowable range.');
       throw(exception);
    end
    
    % Data Add to raw data queue
    for i=1:n_data
        buffer.raw_dataqueue.add(denoised_EOG(i,:));
    end

    % Baseline Drift Removal
    baseline_removed_EOG = denoised_EOG - baseline_drift_cur;
end

end

