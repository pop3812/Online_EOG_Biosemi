function [f_start_idx, f_length, f_end_idx, features, n_feature] = signal_feature_info_extractor(feature_sequence)

diff_f = diff([10 feature_sequence']);
f_start_idx = find(diff_f);
f_length = diff([f_start_idx, length(feature_sequence)+1]);
f_end_idx = f_start_idx + f_length-1;
features = feature_sequence(f_start_idx);

n_feature = length(f_start_idx);

end

