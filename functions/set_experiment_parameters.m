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

params.numEEG = 6; % number of EEG channels
params.numAIB = 0; % number of external channel
params.CompNum = 2; % Number of Components / Horizontal, Vertical

params.DelayTime = 0.25; % in sec
params.BufferTime = 15; % in sec
params.CalibrationTime = 4; % in sec
params.DataAcquisitionTime = 8; % in sec
params.ResultShowTime = 2; % in sec
params.RestForEveryNSession = 15; % Subject would take a rest (10 sec) for every N session.

% pre-processing parameters
params.blink_calibration_time = 5; % in sec
params.medianfilter_size = 20; % The number of samples to take median for denoising
                               % default is 10
params.drift_filter_time = 10; % in seconds (should < BufferTime)
                               % default is 10

% calibration parameters
params.slope_threshold = 10^0;
params.linear_baseline_slope_threshold = 0.0 * 10^-1; % 1.0 * 10^-1;
params.linear_baseline_err_threshold = 10^-10; % 10^-12;
                               
% screen parameters
params.screen_width = 48; % the width of the screen (inner) [cm]
params.screen_height = 27; % the height of the screen (inner) [cm]
params.screen_distance = 50; % the viewer's distance from the screen's center [cm]
params.screen_refresh_frequency = 32; % should be 2^N.
params.screen_trail_point_per_sec = 32;
params.default_fixation_y = -10; % in degree

% training parameters
params.time_per_stimulus = 1; % the length of each training stimulus [sec]
                              % should be > 1 and < BufferTime - 2.
params.stimulus_onset_angle = 14; % the angle where stimuli would be shown [degree]
                                  % should not exceed the maximum angle due
                                  % to the screen size and should be > 0
params.fit_type = 'linear';
params.is_coupled = 1;
                                  
% plot parameters
params.y_range = 5.*10^2; % 3.*10^2 is optimal for Biosemi EOG

% result parametmers
params.emergency_save_path = 'C:\Users\User\Documents\GitHub\Data';
end

