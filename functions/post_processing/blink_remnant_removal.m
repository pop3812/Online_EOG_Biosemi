function [remnant_removed_signal] = blink_remnant_removal(eye_blink_contain_signal)

[n_data, two] = size(eye_blink_contain_signal);

onset_idx = find(diff([0; isnan(eye_blink_contain_signal(:,2)); 0])==1);
offset_idx = find(diff([0; isnan(eye_blink_contain_signal(:,2)); 0])==-1);

n_blink = length(onset_idx);

for i = 1:n_blink
    % find next flat region
    
    flats = signal_feature_find(eye_blink_contain_signal(offset_idx(i):end, 2), 'flat', 0.01, 0.03);  

    [n_flat, dim] = size(flats);
    
    if n_flat > 0
        if flats(1).on < 0.05 * n_data
        % remove middle region
        eye_blink_contain_signal(offset_idx(i):offset_idx(i)+flats(1).on, 1) = NaN;
        eye_blink_contain_signal(offset_idx(i):offset_idx(i)+flats(1).on, 2) = NaN;
        end
    end
end

remnant_removed_signal = eye_blink_contain_signal;

end

