function [ raw_signal ] = signal_receive_Biosemi()
%SIGNAL_RECEIVE_BIOSEMI
% Receives online raw data signal from Biosemi device

global params;
global buffer;

raw_signal = biosemix([params.numEEG params.numAIB]);

%% Translate [from bit to voltage value]
n_data = size(raw_signal,2);

% Change the signal from bit to voltage value
% data type is transformed into single for faster downsampling
sig = single(raw_signal(2:end,:)) * 0.262 / 2^31;

%% Downsampling
if(params.DownSample)
    [buffer.DM, sig] = online_downsample_apply(buffer.DM, sig);
end

% Data type recovery into double
raw_signal = double(sig)';

%% EOG Component Calculation

EOG_x = raw_signal(:, 1) - raw_signal(:, 2);
EOG_y = raw_signal(:, 3) - raw_signal(:, 4);

raw_signal = [EOG_x EOG_y];

end

