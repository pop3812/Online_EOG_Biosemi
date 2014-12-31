function data_processing_for_calibration()
% DATA PROCESSING FUNCTION THAT IS CALLED DURING THE CALIBRATION
tic;

global params;
global buffer;
global raw_signal_reserve;

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();
n_data = size(EOG, 1);

%% Data Registration to Raw Signal Reserve
raw_signal_reserve.mat(raw_signal_reserve.n_data-n_data+1:raw_signal_reserve.n_data,3) = 50.*ones(n_data, 1);


%% Visualization
draw_realtime_signal();
% draw_graphs(EOG);

toc;
end

