clc; clear; % clf;

data_acq_time = 8; % sec
SR = 128; % Hz

D_Rate = 1;

data_length = data_acq_time * SR;

%% Retrieve all data
file_path = 'C:\Users\User\Documents\GitHub\Data\20141217_LeeKR\reform\';

data = cell(4, 1);
norm_pos = cell(26, 1);
alphabet_dict = cell(26, 4);

for i = 1:4
    file_name = ['data_' num2str(i) '.mat'];
    load([file_path file_name]);
    
    for j = 1:26
       norm_pos{j, 1} =  File_Header.SessionData{j}.normalized_eye_position;
    end
    
    data{i, 1} = norm_pos;
    
end

for i = 1:26
   for j = 1:4
       alphabet_dict{i, j} = data{j}{i};
   end
end

clear file_path file_name data File_Header norm_pos;

%% Normalize all data length

alphabet_dict_norm = cell(26, 4);

for i = 1:26
   for j = 1:4
       sig = alphabet_dict{i, j};
       if length(sig) < data_length
           x = 1:length(sig);
           xq = 1:length(sig)/(data_length+1):length(sig);
           alphabet_dict_norm{i, j} = interp1(x, sig, xq);
       else
           alphabet_dict_norm{i, j} = sig(1:data_length, :);
       end
       
       alphabet_dict_norm{i, j} = downsample(alphabet_dict_norm{i, j}, D_Rate);
       
       alphabet_dict_norm_x{i, j} = alphabet_dict_norm{i, j}(:, 1);
       alphabet_dict_norm_y{i, j} = alphabet_dict_norm{i, j}(:, 2);
   end
end


clear sig x xq;

%% Template Matching

tic;

alphabet_seq = ('a':'z');

method_distanceMetrics = 1;
mode_distance_template = 2;

result = cell(26, 12);

for tr_idx = 1:4
    test_idx_mat = 1:4;
    test_idx_mat(tr_idx) = [];
    for j = 1:3
        test_idx = test_idx_mat(j);
        column_idx = 3*(tr_idx-1) + j;
        for char_idx = 1:26
        
        
        template_x =  alphabet_dict_norm_x(:, tr_idx);
        template_y =  alphabet_dict_norm_y(:, tr_idx);

        test_x = alphabet_dict_norm_x(char_idx, test_idx); % 2nd 'a'
        test_y = alphabet_dict_norm_y(char_idx, test_idx); % 2nd 'a'

        % dist of x
        dist_mat_x = templateMatching(test_x{1, 1}, template_x, method_distanceMetrics, mode_distance_template);
        dist_mat_x = dist_mat_x(end, :);

        % dist of y
        dist_mat_y = templateMatching(test_y{1, 1}, template_y, method_distanceMetrics, mode_distance_template);
        dist_mat_y = dist_mat_y(end, :);
        
        % sum dist
        dist = dist_mat_x + dist_mat_y;
        
        [min_dist, min_idx] = min(dist);
        
        % result report
        result_struct.alphabet_ori = alphabet_seq(char_idx);
        result_struct.alphabet_decision = alphabet_seq(min_idx);
        result_struct.training_idx = tr_idx;
        result_struct.test_idx = test_idx;
        result_struct.dist_x = dist_mat_x;
        result_struct.dist_y = dist_mat_y;
        result_struct.dist = dist;
        
        result{char_idx, column_idx} = result_struct;
        end
    end

% title_str = ['Orig Char : ' char(double('a')-1 + char_idx) ' & Min at : ' char(double('a')-1 + min_idx)];
% figure; bar(dist); xlim([0 27]); title(title_str, 'FontSize', 12, 'FontWeight', 'bold');
% ylim([min(dist)-0.5 max(dist)+0.5]);
% 
% set(gca,'XTick', 1:26);
% set(gca,'XTickLabel', cellstr(('a':'z').'), 'fontsize',12);

end
toc;

clearvars -except method_distanceMetrics mode_distance_template result

%% Accuracy
% load('C:\Users\User\Documents\GitHub\Data\20141217_LeeKR\temp_match_with_corr.mat');

n_correct_alphabet = zeros(26, 1);
n_total = 12 * 26;
for i = 1:26
    for j = 1:12
        if result{i, j}.alphabet_ori == result{i, j}.alphabet_decision
            n_correct_alphabet(i) = n_correct_alphabet(i) + 1;
        end
    end
end

accuracy_mat = n_correct_alphabet ./ 12;
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

%% Bad case
min_x_mat = zeros(12, 1);
min_y_mat = zeros(12, 1); 

comp_x_dist = zeros(12, 2);
comp_y_dist = zeros(12, 2); 

idx_bad = 24;
idx_comp = 26;

for i = 1:12
    [min_val min_x_mat(i)] = min(result{idx_bad, i}.dist_x);
    [min_val min_y_mat(i)] = min(result{idx_bad, i}.dist_y);
    
    comp_x_dist(i, 1) = result{idx_bad, i}.dist_x(idx_bad);
    comp_x_dist(i, 2) = result{idx_bad, i}.dist_x(idx_comp);
    comp_y_dist(i, 1) = result{idx_bad, i}.dist_y(idx_bad);
    comp_y_dist(i, 2) = result{idx_bad, i}.dist_y(idx_comp);
end