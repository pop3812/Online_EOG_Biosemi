function GDF_Header = signal_initialize_Biosemi()
%SIGNAL_INITIALIZE_BIOSEMI Summary of this function goes here
%   Detailed explanation goes here
global params;

S = biosemix; % run biosemi

GDF_Header.NS = 1 + params.numEEG + params.numAIB;
GDF_Header.TYPE = 'MAT';
GDF_Header.DATE = clock;

GDF_Header.ChannelLabel = cell(HDR.NS, 1);
for i = 1:params.numEEG
    HDR.label{1+i} = sprintf('Ch%03i', k);
end
for i = 1:params.numAIB
    HDR.label{1+params.numEEG+i} = sprintf('AIB%03i', k);
end

GDF_Header.ExperimentParameters = params;