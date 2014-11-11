function data_processing()
%DATAPROCESSING Summary of this function goes here
%   Detailed explanation goes here
tic;

global params;
global buffer;

%% EOG Components Calculation
if (params.DummyMode)
    % Make dummy signal to show
    c=clock; c=c(6);
    EOG = 3 * sin(2 * repmat(linspace(c, c+2*pi, params.BufferLength_Biosemi)',1,2)) ...
          + randn(params.BufferLength_Biosemi,2) ...
          + 10;
          % + 2 * ((randn(params.BufferLength_Biosemi,2))>0.1) ...
          % + 2 * sin(0.1 * repmat(linspace(c, c+5*pi, params.BufferLength_Biosemi)',1,2)) ...
          % for the case of linearly decreasing baseline drift 
          % - 2 * repmat(linspace(c, c+1, params.BufferLength_Biosemi)',1,2);
          
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

%% Data Registration to Buffer Queue
for i=1:n_data
    buffer.dataqueue.add(EOG(i,:));
    idx_cur = buffer.dataqueue.datasize; % current index calculation
end

%% Eye Blink Detection by using MSDW Algorithm

% Get Parameters related to Eye Blink Detection
p = params.blink;
b = buffer.blink;

% DownSampling
for i=1:p.DecimateRate:idx_cur
    % Only uses y component of EOG
    b.dataqueue.add(buffer.dataqueue.data(i,2));
end

idx_cur = b.dataqueue.datasize;

% Eye Blink Detection
[range, t, nDeletedPrevRange] = eogdetection_msdw_online(b.dataqueue,...
    b.v_dataqueue, b.acc_dataqueue, ...
    idx_cur, p.min_window_width, p.max_window_width, ...
    p.threshold, p.prev_threshold, ...
    b.msdw, b.windowSize4msdw, b.indexes_localMin, b.indexes_localMax, ...
    b.detectedRange_inQueue, p.min_th_abs_ratio, ...
    p.nMinimalData4HistogramCalculation, b.msdw_minmaxdiff, ...
    b.histogram, p.nBin4Histogram,p.alpha, p.v);

range %%%

% Detect Threshold Time
if t > 0
    p.prev_threshold = t;
end
% Add Blink Time Range
if size(range,1) > 0
    p.detectedRange_inQueue.add(range);
end

%% Visualization
draw_realtime_signal();
draw_graphs(EOG);

toc;
end