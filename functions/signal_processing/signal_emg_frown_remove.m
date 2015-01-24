function [emg_removed_sig] = signal_emg_frown_remove(concatenated, y_flat_threshold)
%SIGNAL_EMG_FROWN_REMOVE : removes EMG signal caused by frowning
%   Detailed explanation goes here

edge_threshold = 2.5; % for detecting edge noises
up_threshold = 5; % for detecting start of edge noises
height_threshold = 40; % in degree

SR = 128;
emg_max_duration = SR * 2; % in sec

[n_data, two] = size(concatenated);

[dData, minmax, stats] = AnalyzeEdges(concatenated(:,2));
edge_slopes = dData(:, 1);

[dData, minmax, stats] = AnalyzeEdges(concatenated(:,1));
x_slopes = dData(:,1);

if ~isempty(find(abs(edge_slopes) > edge_threshold, 1))
[pks, minmax] = findpeaks(abs(edge_slopes), 'MinPeakHeight', edge_threshold);

% edges to removed region idx
edge_idx = minmax;
df = diff(edge_idx);
frown_flags = zeros(n_data, 1);

% two edges are close enough (suspected EMG signal might exist btw these edges)
suspected_emg_start_edge = find(df < emg_max_duration);
if ~isempty(suspected_emg_start_edge)
    % for all suspected regions, judge if it is EMG frown signal or not
    for i_e=1:length(suspected_emg_start_edge)
        
        i = suspected_emg_start_edge(i_e);
        % if the signal has been rapidly increased and then decreased, it
        % is EMG frown signal
        if (edge_slopes(edge_idx(i)) >= up_threshold && ...
            edge_slopes(edge_idx(i+1)) <= -edge_threshold) || ...
            (edge_slopes(edge_idx(i)) >= edge_threshold && ...
            edge_slopes(edge_idx(i+1)) <= -up_threshold)

            % looking for the start point of frown signal by tracking back
            % from the max peak (looking for the first stabilized point)
            for j = edge_idx(i):-1:1
                start_idx = j;
                if abs(edge_slopes(j)) < y_flat_threshold
                    break;
                end
            end
            
            % looking for the end point of frown signal by inspecting
            % right side of the min peak (looking for the first stabilized
            % point)
            for j = edge_idx(i+1):1:n_data
                end_idx = j;
                if abs(edge_slopes(j)) < y_flat_threshold
                    break;
                end
            end
            
            % if height is big enough, and horizontal signal is changing as
            % well, it is frown signal
            if max(concatenated(start_idx:end_idx, 2)) - ...
                    min(concatenated(start_idx:end_idx, 2)) >= height_threshold
                
            frown_flags(start_idx:end_idx) = 1;
            end
        end
    end
end

concatenated(logical(frown_flags), :) = [];

end

emg_removed_sig = concatenated;
    
end

