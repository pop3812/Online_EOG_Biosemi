

S = biosemix; % run biosemi

numEEG = 16; % number of EEG channels
numAIB = 0;  % number of external channel

% online function parameters
cfg.ftOutput = 'buffer://localhost:1972'; % output port
cfg.gdfOutput = 'biosemi.gdf'; % file name, current folder
cfg.decimate = 1; % decimation factor (sampling rate) ,1 = 2048, 2 = 1024, ...., 8 = 256
cfg.order = 4; % online filter order
% online downsample 
DM = online_downsample_init(cfg.decimate);


%% gdf header information
HDR.SampleRate = S.fSample;
HDR.NS = 1+numEEG+numAIB;
HDR.SPR = 1; 
HDR.NRec = 1; % always continuous
HDR.FileName = cfg.gdfOutput;
HDR.TYPE = 'GDF';
HDR.T0 = clock;

HDR.label   = cell(HDR.NS,1);
HDR.label{1} = 'Trigger';
for k=1:numEEG
	HDR.label{1+k} = sprintf('EEG%03i',k);
end
for k=1:numAIB
	HDR.label{1+numEEG+k} = sprintf('AIB%03i',k);
end

[datatyp,limits,datatypes,HDR.Bits,HDR.GDFTYP]=gdfdatatype('int32');

HDR.PhysDimCode = 512*ones(HDR.NS,1); % physicalunits('-')
HDR.DigMin = limits(1)*ones(HDR.NS,1);
HDR.DigMax = limits(1)*ones(HDR.NS,1);
HDR.PhysMin = HDR.DigMin;
HDR.PhysMax = HDR.DigMax;
HDR.FLAG.UCAL = 1;

HDR = sopen(HDR,'w');


hdr.Fs = S.fSample;
hdr.nChans  = numEEG+numAIB;
hdr.label = HDR.label(2:end);


ft_write_data(cfg.ftOutput, single(zeros(hdr.nChans,0)), 'header', hdr, 'append', false);
dummy = biosemix;	
