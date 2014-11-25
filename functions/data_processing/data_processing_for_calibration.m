function data_processing_for_calibration()
% DATA PROCESSING FUNCTION THAT IS CALLED DURING THE CALIBRATION
tic;

global params;
global buffer;

%% Signal Processing
% - denoising, baseline removal, eye blink removal
EOG = signal_processing_main();

%% Visualization
draw_realtime_signal();
draw_graphs(EOG);

toc;
end

