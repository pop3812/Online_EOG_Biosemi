clc; clear; % clf;

data_acq_time = 8; % sec
SR = 128; % Hz
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
       alphabet_dict_norm_x{i, j} = alphabet_dict_norm{i, j}(:, 1);
       alphabet_dict_norm_y{i, j} = alphabet_dict_norm{i, j}(:, 2);
   end
end


clear sig x xq;

%% Template Matching

tic;

alphabet_seq = ('a':'z');

method_distanceMetrics = 3;
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

save('C:\Users\User\Documents\GitHub\Data\20141217_LeeKR\temp_match_with_DPW.mat');

% for tr_idx = 1:4 % training data idx
% 
%     tr =  alphabet_dict_norm(:, tr_idx);
%     test = alphabet_dict_norm(:, 1:4);
%     
% end

% data = File_Header.SessionData;
% 
% sig = data{1}.normalized_eye_position;
% 
% plot(sig);

