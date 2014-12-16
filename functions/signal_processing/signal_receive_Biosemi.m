function [ raw_signal ] = signal_receive_Biosemi()
%SIGNAL_RECEIVE_BIOSEMI
% Receives online raw data signal from Biosemi device

global params;
global buffer;
global g_handles;

try
    raw_signal = biosemix([params.numEEG params.numAIB]);
catch me
	if strfind(me.message,'BIOSEMI device')
%         [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
%         sound(beep, Fs); % sound beep
        set(g_handles.system_message, 'String', ...
            strrep([me.message 'Recalling the BIOSEMI device again.'], sprintf('\n'),'. '));
        
        clear biosemix;
        raw_signal = biosemix([params.numEEG params.numAIB]);
    else
        rethrow(me);
	end
end

%% Translate [from bit to voltage value]

% Change the signal from bit to voltage value
% data type is transformed into single for faster downsampling
sig = single(raw_signal(2:end,:)) * 0.262 / 2^31;

%% Downsampling
if(params.DownSample)
    [buffer.DM, sig] = online_downsample_apply(buffer.DM, sig);
end

% Data type recovery into double
raw_signal = double(sig)';
n_data = size(raw_signal,1);

%% EOG Component Calculation

if n_data <= 0
    raw_signal = [0 0];
else
    EOG_x = raw_signal(:, 1) - raw_signal(:, 2);

    if params.numEEG == 6 % Vertical Component is the sum of L, R eyes
        EOG_y_L = raw_signal(:, 3) - raw_signal(:, 4);
        EOG_y_R = raw_signal(:, 5) - raw_signal(:, 6);
        EOG_y = EOG_y_L + EOG_y_R;
    else
        EOG_y = raw_signal(:, 3) - raw_signal(:, 4);
    end

    raw_signal = 10^6.*[EOG_x EOG_y]; % Conversion into [uV]
end

end

