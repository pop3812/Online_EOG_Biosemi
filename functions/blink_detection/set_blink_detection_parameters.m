function set_blink_detection_parameters()
%SET_BLINK_DETECTION_PARAMETERS Summary of this function goes here
% Set parameters for eye blink detection algorithm

global buffer;
global params;

%% Parameters for Eye Blink Detection Setup

blink.min_window_width = 6;  % default is 6 = 6/64  = about 93.8 ms
blink.max_window_width = 14; % default is 14 = 14/64  = 448/2048 = about 220 ms
blink.SR = 64; % Sampling Rate for eye detection
               % (should be < than SR of the raw data). default is 64

blink.threshold  =-1; % default is -1
blink.prev_threshold = -1; % default is -1
blink.min_th_abs_ratio = 0.4; % default is 0.4

blink.queuelength = blink.SR * params.BufferTime;
blink.DecimateRate = params.SamplingFrequency2Use / blink.SR;

% Histogram related Parameters
% bHistogramAvailable = 0;
blink.nBin4Histogram = 50; % The number of bins to use for eye blink
                           % detection. default is 50
blink.nMinimalData4HistogramCalculation = 5 * blink.SR;
% default is 5 secs. It should be < than blink.queuelength
% means the length of source data

blink.alpha = 0;
blink.v = 0.1; % default is 0.1

% Assign structure blink into global parameter
params.blink = blink;
clear blink;

%% Buffers for Eye Blink Detection Setup
blink.dataqueue = circlequeue(params.blink.queuelength,1);
blink.v_dataqueue = circlequeue(params.blink.queuelength,1);
blink.acc_dataqueue = circlequeue(params.blink.queuelength,1);
blink.msdw = circlequeue(params.blink.queuelength,1);
blink.windowSize4msdw = circlequeue(params.blink.queuelength,1);
blink.indexes_localMax = circlequeue(params.blink.queuelength/2,1);
blink.indexes_localMin = circlequeue(params.blink.queuelength/2,1);
blink.detectedRange_inQueue =  circlequeue(params.blink.queuelength/2,2);

blink.msdw_minmaxdiff =  circlequeue(params.blink.queuelength/2,1);
% saves the differences btw local mins and maxs of MSDW
blink.msdw_minmaxdiff.data(:,:) = Inf;

blink.histogram = accHistogram();

% Assign structure blink into global parameter
buffer.blink = blink;
clear blink;

end

