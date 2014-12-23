function [plateaus] = signal_feature_find(signal, feature, min_length)
%SIGNAL_PLATEAU_FIND : finds plateau-like regions in the signal
% INPUT ARGUMENTS
% signal : [n_data x 1] Matrix containing EOG signal
% feature : feature that you want to find
%           e.g. 'flat', 'increasing', 'decreasing'
%
% OUTPUT
% plateaus : [N x 1] structure that contains the information of detected
%            ranges (including onset & offset time and length)

global params;

[n_data, two] = size(signal);
slope_threshold = params.slope_threshold;
[dData, minmax, stats] = AnalyzeEdges(signal);

dif_f = dData(:,end);

slopes = dif_f;

slopes(dif_f>slope_threshold) = 1; % increasing
slopes(dif_f<-slope_threshold) = -1; % decreasing
slopes(dif_f<=slope_threshold & dif_f>=-slope_threshold) = 0; % flat

if strcmp(feature, 'flat')
    feature = 0;
elseif strcmp(feature, 'increasing')
    feature = 1;
elseif strcmp(feature, 'decreasing')
    feature = -1;
end

plateau_detection = (slopes == feature);

% figure; plot(signal); 
% figure; plot(dif_f, 'g'); hold on;
% plot(plateau_detection, 'r');

df = diff([0; plateau_detection; 0]);

plateaus = struct('on',num2cell(find(df==1)), ...
    'off',num2cell(find(df==-1)-1));

reject_idx = zeros(length(plateaus), 1);
for i = 1:length(plateaus)
    i_length = plateaus(i).off - plateaus(i).on + 1;
    plateaus(i).length = i_length;
    
    % reject if the range length is too short
    reject_idx(i) = plateaus(i).length < ceil(n_data * min_length);
end

plateaus(find(reject_idx==1)) = [];

end

