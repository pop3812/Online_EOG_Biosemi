%% Initiation
clc; clear; % clf;

database_path = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\alphabet_dataset\';
result_save_route = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\';

n_set = 10; % number of alphabet set in the database
data_acq_time = 8; % sec
SR = 128; % Hz

D_Rate = 32; % Downsample factor for fast calculation 
max_slope_length = 3;
candidate_threshold = 0.2;

save_tag = '_hist_feature';

%% Retrieve all data

method_str = {'Correlation', 'DTW', 'DPW', 'Kurtosis', 'MSE'};
data_length = data_acq_time * SR;

data = cell(n_set, 1);
norm_pos = cell(26, 1);
alphabet_dict = cell(26, n_set);
last_point_median = cell(26, n_set);

for i = 1:n_set
    file_name = ['data_' num2str(i) '.mat'];
    load([database_path file_name]);
    
    for j = 1:26
       norm_pos{j, 1} =  File_Header.SessionData{j}.normalized_eye_position;
    end
    
    data{i, 1} = norm_pos;
    
end

for i = 1:26
   for j = 1:n_set
       alphabet_dict{i, j} = data{j}{i};
   end
end

clear file_path file_name data File_Header norm_pos;

%% Retrieve Data Region Only (Remove Stop Points from Signal)

for i = 1:26
    for j = 1:n_set

        flat_regions_x = signal_feature_find(alphabet_dict{i, j}(:,1), 'flat', 0.01, 0.005);
        flat_regions_y = signal_feature_find(alphabet_dict{i, j}(:,2), 'flat', 0.01, 0.005);
        
        % Remove the last flat region
        if ~isempty(flat_regions_x) && ~isempty(flat_regions_y)
            % Remove the last flat regions as it contains stop point signal
            on_idx = max([flat_regions_x(length(flat_regions_x)).on, flat_regions_y(length(flat_regions_y)).on]);
            last_point_median{i, j} = nanmedian(alphabet_dict{i, j}(on_idx:end,:));
            alphabet_dict{i, j}(on_idx:end,:) = [];
            
            last_padding = repmat(last_point_median{i, j}, fix(on_idx * 0.1), 1);
            alphabet_dict{i, j} = [alphabet_dict{i, j}; last_padding];
        end
        
        % Remove the first flat region
        if ~isempty(flat_regions_x) && ~isempty(flat_regions_y)
            % Remove the first flat regions as it contains fixation point signal
            off_idx = min([flat_regions_x(1).off, flat_regions_y(1).off]);
            alphabet_dict{i, j}(1:off_idx,:) = [];
        end

    end
end


%% Normalize all data length

alphabet_dict_norm = cell(26, n_set);
alphabet_dict_hist = cell(26, n_set);

for i = 1:26
   for j = 1:n_set
       sig = alphabet_dict{i, j};
       if length(sig) < data_length
           x = 1:length(sig);
           xq = 1:length(sig)/(data_length+1):length(sig);
           alphabet_dict_norm{i, j} = interp1(x, sig, xq);
       else
           alphabet_dict_norm{i, j} = sig(1:data_length, :);
       end
       
       alphabet_dict_norm{i, j} = downsample(alphabet_dict_norm{i, j}, D_Rate);
       alphabet_dict_hist{i, j} = hist3(alphabet_dict_norm{i, j});
       alphabet_dict_hist{i, j} = alphabet_dict_hist{i, j}./sum(sum(alphabet_dict_hist{i, j}));

   end
end

clear sig x xq;

%% Template Matching

t_init = tic;
t_init_date = now;

alphabet_seq = ('a':'z');

for method_distanceMetrics = 2
% method_distanceMetrics = 1;
mode_distance_template = 2;

result = cell(26, n_set*(n_set-1));

prog_bar = waitbar(0, '0 %');

for tr_idx = 1:n_set
    test_idx_mat = 1:n_set;
    test_idx_mat(tr_idx) = [];
    for j = 1:n_set-1
        test_idx = test_idx_mat(j);
        column_idx = (n_set-1)*(tr_idx-1) + j;
        for char_idx = 1:26

            
        template_alphabet = alphabet_dict_norm(:, tr_idx);
        test_alphabet = alphabet_dict_norm(char_idx, test_idx);
        
        % dist of x
        dist_mat = templateMatching(test_alphabet{1, 1}, template_alphabet, method_distanceMetrics, mode_distance_template, max_slope_length);
        dist_mat = dist_mat(end, :);
        
        [min_dist, min_idx] = min(dist_mat);
        
        % hist feature
        last_diff_threshold_val = (max(dist_mat) - min(dist_mat)) * candidate_threshold;
        candidate_idx = find(dist_mat < min(dist_mat) + last_diff_threshold_val);

        last_point_dist_mat = NaN(1, 26);
        if length(candidate_idx) <= 1
            [min_dist, min_idx] = min(dist_mat);
        else
            test_last_point = alphabet_dict_hist{char_idx, test_idx};
            temp_last_point = {alphabet_dict_hist{candidate_idx, tr_idx}};
            
            for candidate_i = 1:length(candidate_idx)
                last_point_dist_mat(candidate_idx(candidate_i)) = max(max(corr2(test_last_point, temp_last_point{candidate_i})));
            end
            
            [min_dist_l, min_idx] = nanmax(last_point_dist_mat);
            min_dist = dist_mat(min_idx);
            
        end
        
        % result report
        result_struct.alphabet_ori = alphabet_seq(char_idx);
        result_struct.alphabet_decision = alphabet_seq(min_idx);
        result_struct.training_idx = tr_idx;
        result_struct.test_idx = test_idx;

        result_struct.dist = dist_mat;
        result_struct.candidate_num = length(candidate_idx);
        result_struct.last_point_dist = last_point_dist_mat;

        result{char_idx, column_idx} = result_struct;
        end
        
        if (ishandle(prog_bar))
        progress_percentage = column_idx / (n_set*(n_set-1));
        tt = toc(t_init);
        expected_finish_time = datestr(t_init_date + (tt ./ (progress_percentage))/86400, 'dd-mmm-yyyy HH:MM:SS');
        waitbar(progress_percentage, prog_bar, ...
                [sprintf('%3.2f %% Done / Elapsed Time : %.2f sec', progress_percentage*10^2, tt), ...
                char(10), 'Expected End : ', expected_finish_time]);
        end
    end
end
    t_calculation = toc(t_init);

    if (ishandle(prog_bar))
            waitbar(1.0, prog_bar, [num2str(100) ' % Done']);
            close(prog_bar);
    end
    
    % Save results
    save_route = [result_save_route, 'analysis_result_method_', num2str(method_distanceMetrics), '_DR_', num2str(D_Rate), save_tag, '.mat'];
    disp('Classification Done');
    disp(['Method : ', method_str{method_distanceMetrics}]);
    disp(['Downsampling Factor : ', num2str(D_Rate)]);
    disp(['Elapsed time : ', num2str(t_calculation)]);
    
    save(save_route, 'result', 'mode_distance_template', 'method_distanceMetrics', ...
        'n_set', 'data_acq_time', 'SR', 'D_Rate', 'data_length', 't_calculation');
    
    %% Accuracy

    n_correct_alphabet = zeros(26, 1);
    n_total = n_set*(n_set-1) * 26;
    for i = 1:26
        for j = 1:n_set*(n_set-1)
            if result{i, j}.alphabet_ori == result{i, j}.alphabet_decision
                n_correct_alphabet(i) = n_correct_alphabet(i) + 1;
            end
        end
    end

    accuracy_mat = n_correct_alphabet ./ (n_set*(n_set-1));
    total_acc = sum(n_correct_alphabet) / n_total;

    figure;
    y = bar(accuracy_mat, 0.5, 'r'); xlim([0 27]);
    title_str = sprintf('Mean Accuracy : %2.2f %%', total_acc .* 100);
    title(title_str, 'FontSize', 12, 'FontWeight', 'bold');

    x_loc = get(y, 'XData');
    y_height = get(y, 'YData');
    arrayfun(@(x,y) text(x-0.25, y+0.03, [num2str(fix(y*10^2)) '%'], 'Color', 'k'), x_loc, y_height);

    set(gca,'XTick', 1:26);
    set(gca,'XTickLabel', cellstr(('a':'z').'), 'fontsize', 12, 'FontWeight', 'bold');
    
    % Report results by e-mail
    message = ['Method : ', method_str{method_distanceMetrics}, char(10), ...
        'Downsampling Factor : ', num2str(D_Rate), char(10),...
        'Max Slope Length : ', num2str(max_slope_length), char(10),...
        'Elapsed time : ', num2str(t_calculation), char(10),...
        'Mean Accuracy : ', num2str(fix(total_acc .* 10^4)/100), ' %'];
    send_email('pop3812@gmail.com', ['Analysis Results Report ', ...
        method_str{method_distanceMetrics}, ' DR_', num2str(D_Rate), ...
        ], message);
end

clearvars -except method_distanceMetrics mode_distance_template result n_set

%% Accuracy

n_correct_alphabet = zeros(26, 1);
n_total = n_set*(n_set-1) * 26;
for i = 1:26
    for j = 1:n_set*(n_set-1)
        if result{i, j}.alphabet_ori == result{i, j}.alphabet_decision
            n_correct_alphabet(i) = n_correct_alphabet(i) + 1;
        end
    end
end

accuracy_mat = n_correct_alphabet ./ (n_set*(n_set-1));
total_acc = sum(n_correct_alphabet) / n_total;

figure;
y = bar(accuracy_mat, 0.5, 'r'); xlim([0 27]);
title_str = sprintf('Mean Accuracy : %2.2f %%', total_acc .* 100);
title(title_str, 'FontSize', 12, 'FontWeight', 'bold');

x_loc = get(y, 'XData');
y_height = get(y, 'YData');
arrayfun(@(x,y) text(x-0.25, y+0.03, [num2str(fix(y*10^2)) '%'], 'Color', 'k'), x_loc, y_height);

set(gca,'XTick', 1:26);
set(gca,'XTickLabel', cellstr(('a':'z').'), 'fontsize', 12, 'FontWeight', 'bold');