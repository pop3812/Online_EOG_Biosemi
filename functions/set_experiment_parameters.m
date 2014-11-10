function set_experiment_parameters()
%SET_PARAMETERS
% Experiment Parameter Settings
global params;

% modes
params.denosing = 1; % 1 = denoising, 0 = none
params.drift_removing = 1; % 1 = drift removing during calibration, ...
                           % 2 = online drift removing, ...
                           % 0 = none

% signal acquisition parameters
params.SamplingFrequency2Use = 128; % Default Sampling Frequency for Biosemi is 2024

params.numEEG = 4; % number of EEG channels
params.numAIB = 0; % number of external channel
params.CompNum = 2; % Number of Components / Horizontal, Vertical

params.DelayTime = 1; % in sec
params.BufferTime = 10; % in sec

% pre-processing parameters
params.medianfilter_size = 10; % The number of samples to take median for denoising
params.drift_filter_time = 10; % in seconds (should < BufferTime)    

% plot parameters
params.y_range = 10^-2; % 10^-2 is optimal for Biosemi EOG

end
