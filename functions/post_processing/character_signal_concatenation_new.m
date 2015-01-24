function [concatenated] = character_signal_concatenation_new(char_sig, min_length, x_flat_threshold, y_flat_threshold, visualization)

if nargin < 5
   visualization = 0; 
end

blink_drift_threshold = 10; % in degree
nan_start_flag = 0;

if size(char_sig, 1) > 1 && isnan(char_sig(1, 1))
   char_sig = [zeros(5, 2); char_sig];
   nan_start_flag = 1;
end

[n_data, two] = size(char_sig);

[feature_matrix, slopes_x, slopes_y] = signal_feature_analysis(char_sig, min_length, x_flat_threshold, y_flat_threshold);

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

[xf_start_idx, xf_length, xf_end_idx, xfeatures, xn_feature] = signal_feature_info_extractor(feature_matrix(:, 1));
[f_start_idx, f_length, f_end_idx, features, n_feature] = signal_feature_info_extractor(feature_matrix(:, 2));

% Horizontal
x_cut_idx = cut_idx;
if xn_feature > 2
    for i = 2:xn_feature-1

       if xf_end_idx(i) >= cut_idx
           break;
       else
          if xfeatures(i) == 2
            left_mean = nanmean(char_sig(xf_start_idx(i-1):xf_end_idx(i-1),1));
            right_mean = nanmean(char_sig(xf_start_idx(i+1):xf_end_idx(i+1),1));
            
            if abs(left_mean - right_mean) > blink_drift_threshold  && (xf_length(i+1)<128)
                x_cut_idx = xf_start_idx(i-1);
                break;
            end
          end
       end
       
    end
end

% Vertical
y_cut_idx = cut_idx;
if n_feature > 2
    for i = 2:n_feature-1

       if f_end_idx(i) >= cut_idx
           break;
       else
          if features(i) == 2
            left_mean = nanmean(char_sig(f_start_idx(i-1):f_end_idx(i-1),2));
            right_mean = nanmean(char_sig(f_start_idx(i+1):f_end_idx(i+1),2));
            
            % if signal changing is big enough after the blink, it is
            % signal            
            % but if either leftside or rightside of blink is flat and
            % long enough (at least 1sec), the blink should not be classified as signal
            if abs(left_mean - right_mean) > blink_drift_threshold && (f_length(i+1)<128)
                y_cut_idx = f_start_idx(i-1);
                break;
            end
          end
       end
       
    end
end

cut_idx = min([x_cut_idx, y_cut_idx]);
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
% Horizontal
x_right_cut_idx = right_cut_idx;
if xn_feature > 2
    for i = xn_feature-1:-1:2

       if xf_start_idx(i) < right_cut_idx
           break;
       else
          if xfeatures(i) == 2
            left_mean = nanmean(char_sig(xf_start_idx(i-1):xf_end_idx(i-1),1));
            right_mean = nanmean(char_sig(xf_start_idx(i+1):xf_end_idx(i+1),1));
            
            if abs(left_mean - right_mean) > blink_drift_threshold  && (xf_length(i-1)<128)
                x_right_cut_idx = xf_end_idx(i+1);
                break;
            end
          end
       end
       
    end
end

% Vertical
y_right_cut_idx = right_cut_idx;
if n_feature > 2
    for i = n_feature-1:-1:2

       if f_start_idx(i) < right_cut_idx
           break;
       else
          if features(i) == 2
            left_mean = nanmean(char_sig(f_start_idx(i-1):f_end_idx(i-1),2));
            right_mean = nanmean(char_sig(f_start_idx(i+1):f_end_idx(i+1),2));
            
            if abs(left_mean - right_mean) > blink_drift_threshold  && (f_length(i-1)<128)
                y_right_cut_idx = f_end_idx(i+1);
                break;
            end
          end
       end
       
    end
end

right_cut_idx = max([x_right_cut_idx, y_right_cut_idx]);

%% Blink Removal

concatenated = char_sig(cut_idx:right_cut_idx, :);
concatenated(feature_matrix(cut_idx:right_cut_idx, 2)==2, :) = [];

if nan_start_flag && cut_idx == 1
    concatenated = concatenated(6:end, :);
end

%% EMG (e.g. frown) Noise Removal

concatenated = signal_emg_frown_remove(concatenated, y_flat_threshold);

%% Visualization

if visualization
    % Verbose cutting positions
    disp(['Signal from index ', num2str(cut_idx), ' to ', num2str(right_cut_idx)]);
    
    figure;
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

    figure; plot(concatenated); title('Concatenated Signal');
    
%     figure;
%     subplot(2,1,1); plot(slopes_x); title('X signal');
%     subplot(2,1,2); plot(slopes_y); title('Y signal');
end
