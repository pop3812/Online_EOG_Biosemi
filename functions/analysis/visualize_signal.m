dat_idx = 1;
n_char = 29;
n_set = 3;

figure;

%% Retrieve Data Region Only (Remove Stop Points from Signal)
  
for i = 1:n_char
    for j = 1:n_set

        flat_regions_x = signal_feature_find(alphabet_dict{i, j}(:,1), 'flat', 0.01, 0.005);
        flat_regions_y = signal_feature_find(alphabet_dict{i, j}(:,2), 'flat', 0.01, 0.005);
        
        % Remove the first region
        if ~isempty(flat_regions_x) && ~isempty(flat_regions_y)
            % Remove the first flat regions as it contains fixation point signal
            off_idx = min([flat_regions_x(1).off, flat_regions_y(1).off]);
            alphabet_dict_norm{i, j}(1:off_idx,:) = [];
        end

    end
end

%%
   for j = 1:29
       subaxis(8, 4, j, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.05);
       plot(alphabet_dict_norm{j, dat_idx});
       set(gca, 'XTick', []); set(gca, 'YTick', []);
   end

%% 
figure;
for i = 1:29
    subaxis(4, 8, i, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.05);
    draw_alphabet_on_plot(alphabet_dict_norm{i, dat_idx})
    axis('auto');
    set(gca, 'XTick', []); set(gca, 'YTick', []);
    
end

%%

figure;

subplot(1, 2, 1);
hist(alphabet_dict_norm{3, dat_idx}(:,1));

%%

subplot(1, 2, 2);
hist(alphabet_dict_norm{5, dat_idx}(:,1));

%%
[ dist ,table, match_pair] = fastDTW(alphabet_dict_norm{27, 1}, alphabet_dict_norm{21, 2}, 2, 1); 
draw_dtwmatching_graph3D(alphabet_dict_norm{27, 1}, alphabet_dict_norm{21, 2}, match_pair, 30);