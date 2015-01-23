function [concatenated] = character_signal_concatenation_new(char_sig, min_length, flat_threshold, visualization)

if nargin < 4
   visualization = 0; 
end

blink_drift_threshold = 10; % in degree

[n_data, two] = size(char_sig);

feature_matrix = signal_feature_analysis(char_sig, min_length, flat_threshold);

%% Left-side concatenation
cut_idx = find(abs(feature_matrix(:,1))==1, 1, 'first');

if ~isempty(cut_idx)
    for i = 1:cut_idx
        if abs(feature_matrix(i, 1))==1 || abs(feature_matrix(i, 2))==1
            cut_idx = i;
            break;
        end
    end
else
    cut_idx = 1;
end

%% Left-side eye blink and signal increase distinction

sig = feature_matrix(:, 2);

diff_f = diff([10 sig']);
f_start_idx = find(diff_f);
f_length = diff([f_start_idx, length(sig)+1]);
f_end_idx = f_start_idx + f_length-1;
features = sig(f_start_idx);

n_feature = length(f_start_idx);

if n_feature > 2
    for i = 2:n_feature-1

       if f_end_idx(i) >= cut_idx
           break;
       else
          if features(i) == 2
            left_mean = nanmean(char_sig(f_start_idx(i-1):f_end_idx(i-1),2));
            right_mean = nanmean(char_sig(f_start_idx(i+1):f_end_idx(i+1),2));
            
            if abs(left_mean - right_mean) > blink_drift_threshold
                cut_idx = f_start_idx(i-1);
                break;
            end
          end
       end
       
    end
end

%% Right-side concatenation
right_cut_idx = find(abs(feature_matrix(:,1))==1, 1, 'last');

if ~isempty(right_cut_idx)
    for i = n_data:-1:right_cut_idx
        if abs(feature_matrix(i, 1))==1 || abs(feature_matrix(i, 2))==1
            right_cut_idx = i;
            break;
        end
    end
else
    right_cut_idx = n_data;
end

%% Right-side eye blink and signal increase distinction

if n_feature > 2
    for i = n_feature-1:-1:2

       if f_start_idx(i) < right_cut_idx
           break;
       else
          if features(i) == 2
            left_mean = nanmean(char_sig(f_start_idx(i-1):f_end_idx(i-1),2));
            right_mean = nanmean(char_sig(f_start_idx(i+1):f_end_idx(i+1),2));
            
            if abs(left_mean - right_mean) > blink_drift_threshold
                right_cut_idx = f_end_idx(i+1);
                break;
            end
          end
       end
       
    end
end

%% Blink Removal

concatenated = char_sig(cut_idx:right_cut_idx, :);
concatenated(feature_matrix(cut_idx:right_cut_idx, 2)==2, :) = [];

%% Visualization

if visualization
    figure;
    cut_idx
    right_cut_idx
    subplot(2,1,1); plot(5.*feature_matrix(:,1), '-r'); hold on;
    plot(char_sig(:,1));
    plot([cut_idx cut_idx], get(gca, 'YLim'), ':r', 'LineWidth', 2);
    plot([right_cut_idx right_cut_idx], get(gca, 'YLim'), ':r', 'LineWidth', 2);
    title('X signal');

    subplot(2,1,2); plot(5.*feature_matrix(:,2), '-r'); hold on;
    plot(char_sig(:,2));
    plot([cut_idx cut_idx], get(gca, 'YLim'), ':r', 'LineWidth', 2);
    plot([right_cut_idx right_cut_idx], get(gca, 'YLim'), ':r', 'LineWidth', 2);
    title('Y signal');

    figure; plot(concatenated); title('Signal');

end
