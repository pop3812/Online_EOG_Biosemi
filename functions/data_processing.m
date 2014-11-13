function data_processing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here
tic;

global params;
global buffer;

%% EOG Components Calculation
if (params.DummyMode)
    % Make dummy signal to show
    c=clock; c=c(6); % use clock for generating dummy signal
    d = c:3:c+6;
    t=repmat(linspace(c, c+6, 5.*params.BufferLength_Biosemi)',1,2);
    t=t(1:params.BufferLength_Biosemi,:);
    
    EOG = 15 * pulstran(t, d, 'rectpuls', 1/3) ...
           + randn(params.BufferLength_Biosemi,2) ...
           + 10;
          % + 2 * ((randn(params.BufferLength_Biosemi,2))>0.1) ...
          % + 2 * sin(0.1 * repmat(linspace(c, c+5*pi, params.BufferLength_Biosemi)',1,2)) ...
          % for the case of linearly decreasing baseline drift 
          % - 2 * repmat(linspace(c, c+1, params.BufferLength_Biosemi)',1,2);
          
    % Each component value should be proportional to the eye position
    EOG(:, 1) = EOG(:, 1) + buffer.X;
    EOG(:, 2) = EOG(:, 2) + buffer.Y;
    
    EOG = 10^-3 * EOG;
    n_data = params.BufferLength_Biosemi;
else
    EOG = signal_receive_Biosemi();
    n_data = size(EOG, 1);
end

%% EOG Denoising
if(params.denosing)
EOG = signal_denoising(EOG, buffer.buffer_4medianfilter, params.medianfilter_size);
end

%% EOG Baseline Drift Removal
if(params.drift_removing~=0)
EOG = signal_baseline_removal(EOG);
end

%% Downsampling for Blink Detection
[buffer.DM_BK, EOG_BK] = online_downsample_apply(buffer.DM_BK, EOG(:,2)');
% Blink Detection only uses y component of EOG
EOG_BK = EOG_BK';
n_data_bk = size(EOG_BK, 1);

%% Data Registration to Buffer Queue
for i=1:n_data
    buffer.dataqueue.add(EOG(i,:));
end

%% Eye Blink Detection by using MSDW Algorithm

% Get Parameters related to Eye Blink Detection
p = params.blink;
b = buffer.blink;

% Data Registration to Buffer Queue
for i=1:n_data_bk
    b.dataqueue.add(EOG_BK(i));
    
    idx_cur = b.dataqueue.datasize;
    
    % Eye Blink Detection for each data point
    [range, t, nDeletedPrevRange] = eogdetection_msdw_online(b.dataqueue,...
        b.v_dataqueue, b.acc_dataqueue, ...
        idx_cur, p.min_window_width, p.max_window_width, ...
        p.threshold, p.prev_threshold, ...
        b.msdw, b.windowSize4msdw, b.indexes_localMin, b.indexes_localMax, ...
        b.detectedRange_inQueue, p.min_th_abs_ratio, ...
        p.nMinimalData4HistogramCalculation, b.msdw_minmaxdiff, ...
        b.histogram, p.nBin4Histogram,p.alpha, p.v);
        
        % Detect Threshold Time
        if t > 0
            p.prev_threshold = t;
        end
        % Add Blink Time Range
        if size(range,1) > 0
            % b.detectedRange_inQueue.add(range);
        end
end



%% Visualization
draw_realtime_signal();
draw_graphs(EOG);

toc;
end