function set_experiment_parameters()
%SET_PARAMETERS
% Experiment Parameter Settings
global params;

% modes
params.denosing = 1; % 1 = denoising, 0 = none
params.drift_removing = 1; % 1 = offline drift removing, ...
                           % 2 = online drift removing, ...
                           % 0 = none
params.use_real_dummy = 0; % 1 = realistic EOG sample signal, ...
                           % 0 = dummy signal with rectangular pulses

% signal acquisition parameters
params.SamplingFrequency2Use = 128; % default is 128
                                    % Sampling frequency limit for Biosemi is 2024

params.numEEG = 4; % number of EEG channels
params.numAIB = 0; % number of external channel
params.CompNum = 2; % Number of Components / Horizontal, Vertical

params.DelayTime = 1; % in sec
params.BufferTime = 15; % in sec
params.CalibrationTime = 2; % in sec
params.DataAcquisitionTime = 3; % in sec
params.ResultShowTime = 1; % in sec

% pre-processing parameters
params.blink_calibration_time = 5; % in sec
params.medianfilter_size = 10; % The number of samples to take median for denoising
                               % default is 10
params.drift_filter_time = 10; % in seconds (should < BufferTime)
                               % default is 10

% screen parameters
params.screen_width = 48; % the width of the screen (inner) [cm]
params.screen_height = 27; % the height of the screen (inner) [cm]
params.screen_distance = 50; % the viewer's distance from the screen's center [cm]
params.screen_refresh_frequency = 8; % should be 2^N.

% training parameters
params.time_per_stimulus = 1; % the length of each training stimulus [sec]
                              % should be > 1 and < BufferTime - 2.
params.stimulus_onset_angle = 12; % the angle where stimuli would be shown [degree]
                                  % should not exceed the maximum angle due
                                  % to the screen size and should be > 0
params.fit_type = 'linear';
                                  
% plot parameters
params.y_range = 10^-2; % 10^-2 is optimal for Biosemi EOG

end

