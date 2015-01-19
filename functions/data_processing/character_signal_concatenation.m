function [concatenated] = character_signal_concatenation(char_sig, SR, last_padding_sec)
% This function removes stop points in (front & back) of the data signal

removal_ratio = 0.05;
flat_min_length = 0.01;
flat_threshold = 0.003;
[n_data, two] = size(char_sig);

flat_regions_x = signal_feature_find(char_sig(:,1), 'flat', flat_min_length, flat_threshold);
flat_regions_y = signal_feature_find(char_sig(:,2), 'flat', flat_min_length, flat_threshold);

% Remove the last flat region
if ~isempty(flat_regions_x) && ~isempty(flat_regions_y)
    on_idx = max([flat_regions_x(length(flat_regions_x)).on, flat_regions_y(length(flat_regions_y)).on]);
    off_idx = min([flat_regions_x(length(flat_regions_x)).off, flat_regions_y(length(flat_regions_y)).off]);

    flag_last_valid = off_idx >= fix((1-removal_ratio) * n_data);
    
    if flag_last_valid
        % Removal of the last flat region
        last_point_median = nanmedian(char_sig(on_idx:end,:));
        char_sig(on_idx:end,:) = [];
        
        % Add last point padding as it contains critical information
        last_padding = repmat(last_point_median, fix(SR * last_padding_sec), 1);
        char_sig = [char_sig; last_padding];
    else
        last_point_median = char_sig(end,:);
        % Add last point padding as it contains critical information
        last_padding = repmat(last_point_median, fix(SR * last_padding_sec), 1);
        char_sig = [char_sig; last_padding];
    end
    
    
    % Remove the first flat regions as it contains fixation point signal
    off_idx = min([flat_regions_x(1).off, flat_regions_y(1).off]);
    on_idx = max([flat_regions_x(1).on, flat_regions_y(1).on]);

    flag_first_valid = on_idx <= fix(removal_ratio * n_data);
    
    if flag_first_valid
    char_sig(1:off_idx,:) = [];
    end
end

concatenated = char_sig;

end

