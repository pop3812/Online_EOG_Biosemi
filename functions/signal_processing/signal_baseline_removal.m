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
        % Constant Drift Value
        baseline_drift_cur = repmat(params.DriftValues, n_data, 1);
        
        % Linearly Changing Drift Value
        if buffer.Calib_or_Acquisition(1)==0;
            y_data = denoised_EOG(:, 2);
            n_data = length(y_data);
            t = 1:n_data;

            start_idx = buffer.calibration_end_idx;
            if buffer.dataqueue.index_end >= start_idx
                n_data_processed = buffer.dataqueue.index_end - start_idx;
            else
                n_data_processed = buffer.dataqueue.datasize - ...
                    start_idx + 1 + buffer.dataqueue.index_end;
            end

            pol = buffer.drift_pol_y;
            if n_data_processed ==0
                pol(2) = 0; %%% y_data(1);
            else
                pol(2) = 0; %%% buffer.raw_dataqueue.data(start_idx+1, 2);
            end

            fitted = polyval(pol, t+n_data_processed-1);
            fitted = fitted';
        else
            fitted = zeros(n_data, 1);
        end
%         if pol(1)~=0
%             figure(2); plot(y_data-baseline_drift_cur(:,2)); hold on; plot(y_data-baseline_drift_cur(:,2)-fitted, '-r'); hold off;
%         end
        
    % Online drift removal
    elseif(params.drift_removing == 2)
        % Baseline Drift of previous buffer data
        baseline_drift_cur = median(buffer.raw_dataqueue.data);
        baseline_drift_cur = repmat(baseline_drift_cur, ...
            n_data, 1);
        fitted = zeros(n_data, 1);
    
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
    baseline_removed_EOG(:, 1) = denoised_EOG(:, 1) - baseline_drift_cur(:, 1);
    baseline_removed_EOG(:, 2) = denoised_EOG(:, 2) - baseline_drift_cur(:, 2) - fitted;
end

end

