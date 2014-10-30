% inital version of Matlab acquisition and saving tool for BIOSEMI amp
% TODO: add proper configuration, turn into function
% (C) 2010 S. Klanke 

clear;
close all;

%% Dump if exist
try
	dummy = biosemix([0 0]); %실행될때마다 버퍼에서 데이터 가져오기, 일단 한번 실행하는 것.
catch me
	if strfind(me.message,'BIOSEMI device')
		clear biosemix
	else
		rethrow(me);
	end
end

%% Initialize Biosemi 
   Biosemi_Initialize
   
%% Basic Parameter Initialization
   % modes 
   DummyMode = 1; % 0 : biosemi, 1 : Dummy (fs : 2048Hz, white noise)
   DownSample = 1; % 1 = downsample, 0 = 안해, Downsampleing according to Biosemi_Initialize
   
   % buffer setting for 
   nBufferLength=512*6;
   signalBuffer=zeros(numEEG,nBufferLength);
   
   % *** recorded signal ***
   recordedSig = [];
   
   % counters
   numBlocks = 0;
   numSamples = 0;   
   
while 1
    %% Receive
    pause(0.1); % rest
    
    if( DummyMode )
        temp = rand(numEEG+1, 2048); % random data
    else
        temp = biosemix([numEEG numAIB]);  % get data from biosemi
    end
	if isempty(temp)
		continue % loop initialize
    end

%% Translate
	N = size(temp,2);
    sig = single(temp(2:end,:)) * 0.262 / 2^31; % bit -> V
    if(DownSample)
        [DM, sig] = online_downsample_apply(DM, sig);
    end
%% Filtering    
    sigD=double(sig);
    nSigD=size(sig,2);	
    signalBuffer=[signalBuffer(:,size(sigD,2)+1:nBufferLength),sigD ];
    recordedSig = [recordedSig sigD];
    
%% Write raw signal
% 	ft_write_data(cfg.ftOutput, sig, 'header', hdr, 'append', true);
% 	HDR = swrite(HDR, dat');

%% Report
    DruidWavePlot(double(signalBuffer), true)
	numBlocks = numBlocks + 1;
	numSamples = numSamples + N;
	fprintf(1,'%i blocks, %i samples\n', numBlocks, numSamples);
%% Clearance
    clear temp sig N sigD nSigD singalBuffer;
end
