clc; clear; % clf;

database_path = 'C:\Users\User\Documents\GitHub\Data\DB\KimSK\reform\';
result_save_route = 'C:\Users\User\Documents\GitHub\Data\Analysis_Results\wo_norm\';

n_set = 4; % number of alphabet set in the database
n_char = 29;
data_acq_time = 8; % sec
SR = 128; % Hz

D_Rate = 16; % Downsample factor for fast calculation 
max_slope_length = 2;
smoothing_window = 1;
last_padding_sec = 0.0;

data_concatenation = 1;

method_str = {'Correlation', 'DTW', 'DPW', 'Kurtosis', 'MSE'};
data_length = data_acq_time * SR;

%% Retrieve all data
data = cell(n_set, 1);
norm_pos = cell(n_char, 1);
alphabet_dict = cell(n_char, n_set);

for i = 1:n_set

    file_name = ['data_' num2str(i) '.mat'];
    load([database_path file_name]);

    for j = 1:n_char
        pos_dat =  File_Header.SessionData{j}.eye_position_queue;

        pos_dat = blink_remnant_removal(pos_dat);
        pos_dat(isnan(pos_dat(:,1)),:) = [];

        % normalize
        AbsolutePoints = pos_dat;
        
        NormalizedPoints = character_normalization(AbsolutePoints);
        norm_pos{j, 1} = NormalizedPoints;
    end

    data{i, 1} = norm_pos;
    
end

for i = 1:n_char
   for j = 1:n_set
       alphabet_dict{i, j} = data{j}{i};
   end
end

clear file_path file_name data File_Header norm_pos;

%% Retrieve Data Region Only (Remove Stop Points from Signal)

if data_concatenation
    
for i = 1:n_char
    for j = 1:n_set
        alphabet_dict{i, j} = character_signal_concatenation(alphabet_dict{i, j}, SR, last_padding_sec);
    end
end

end

%% Normalize All Characters

alphabet_dict_norm = cell(n_char, n_set);

for i = 1:n_char
   for j = 1:n_set
       sig = alphabet_dict{i, j};
       if length(sig) < data_length
           x = 1:length(sig);
           xq = 1:(length(sig)-1)/(data_length-1):length(sig);
           alphabet_dict_norm{i, j} = interp1(x, sig, xq);
       else
           x = 1:length(sig);
           xq = 1:(length(sig)-1)/(data_length-1):length(sig);
           alphabet_dict_norm{i, j} = interp1(x, sig, xq);
       end
       
       % Smoothing
       alphabet_dict_norm{i, j} = medfilt1(alphabet_dict_norm{i, j}, smoothing_window);
       
       % Downsampling
       alphabet_dict_norm{i, j} = downsample(alphabet_dict_norm{i, j}, D_Rate);
       
       % Normalization
       alphabet_dict_norm{i, j} = character_normalization(alphabet_dict_norm{i, j});
   end
end

clear sig x xq;

%% Template Matching

t_init = tic;
t_init_date = now;

alphabet_seq = [cellstr(('a':'z').'); 'S'; 'B'; 'E'];

for method_distanceMetrics = 2
% method_distanceMetrics = 1;
mode_distance_template = 2;

result = cell(n_char, n_set*(n_set-1));

prog_bar = waitbar(0, '0 %');

for tr_idx = 1:n_set
    test_idx_mat = 1:n_set;
    test_idx_mat(tr_idx) = [];
    for j = 1:n_set-1
        test_idx = test_idx_mat(j);
        column_idx = (n_set-1)*(tr_idx-1) + j;
        for char_idx = 1:n_char

            
        template_alphabet = alphabet_dict_norm(:, tr_idx);
        test_alphabet = alphabet_dict_norm(char_idx, test_idx);
        
        % dist of x
        dist_mat = templateMatching(test_alphabet{1, 1}, template_alphabet, method_distanceMetrics, mode_distance_template, max_slope_length);
        dist_mat = dist_mat(end, :);
        
        [min_dist, min_idx] = min(dist_mat);
        
        % result report
        result_struct.alphabet_ori = alphabet_seq{char_idx};
        result_struct.alphabet_decision = alphabet_seq{min_idx};
        result_struct.training_idx = tr_idx;
        result_struct.test_idx = test_idx;

        result_struct.dist = dist_mat;
        
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
    save_route = [result_save_route, 'analysis_result_method_', num2str(method_distanceMetrics), '_DR_', num2str(D_Rate), '_slope_', num2str(max_slope_length), '.mat'];
    disp('Classification Done');
    disp(['Method : ', method_str{method_distanceMetrics}]);
    disp(['Downsampling Factor : ', num2str(D_Rate)]);
    disp(['Elapsed time : ', num2str(t_calculation)]);
    
    save(save_route, 'result', 'mode_distance_template', 'method_distanceMetrics', ...
        'n_set', 'data_acq_time', 'SR', 'D_Rate', 'data_length', 't_calculation');
    
%     %% Accuracy
% 
%     n_correct_alphabet = zeros(n_char, 1);
%     n_total = n_set*(n_set-1) * n_char;
%     for i = 1:n_char
%         for j = 1:n_set*(n_set-1)
%             if result{i, j}.alphabet_ori == result{i, j}.alphabet_decision
%                 n_correct_alphabet(i) = n_correct_alphabet(i) + 1;
%             end
%         end
%     end
% 
%     accuracy_mat = n_correct_alphabet ./ (n_set*(n_set-1));
%     total_acc = sum(n_correct_alphabet) / n_total;
% 
%     figure;
%     y = bar(accuracy_mat, 0.5, 'r'); xlim([0 27]);
%     title_str = sprintf('Mean Accuracy : %2.2f %%', total_acc .* 100);
%     title(title_str, 'FontSize', 12, 'FontWeight', 'bold');
% 
%     x_loc = get(y, 'XData');
%     y_height = get(y, 'YData');
%     arrayfun(@(x,y) text(x-0.25, y+0.03, [num2str(fix(y*10^2)) '%'], 'Color', 'k'), x_loc, y_height);
% 
%     set(gca,'XTick', 1:n_char);
%     set(gca,'XTickLabel', cellstr(('a':'z').'), 'fontsize', 12, 'FontWeight', 'bold');
%     
%     % Report results by e-mail
%     message = ['Method : ', method_str{method_distanceMetrics}, char(10), ...
%         'Downsampling Factor : ', num2str(D_Rate), char(10),...
%         'Max Slope Length : ', num2str(max_slope_length), char(10),...
%         'Elapsed time : ', num2str(t_calculation), char(10),...
%         'Mean Accuracy : ', num2str(fix(total_acc .* 10^4)/100), ' %'];
%     send_email('pop3812@gmail.com', ['Analysis Results Report ', ...
%         method_str{method_distanceMetrics}, ' DR_', num2str(D_Rate), ...
%         ], message);
end

clearvars -except method_distanceMetrics mode_distance_template result n_set n_char

%% Accuracy

n_correct_alphabet = zeros(n_char, 1);
n_total = n_set*(n_set-1) * n_char;
for i = 1:n_char
    for j = 1:n_set*(n_set-1)
        if strcmp(result{i, j}.alphabet_ori, result{i, j}.alphabet_decision)
            n_correct_alphabet(i) = n_correct_alphabet(i) + 1;
        end
    end
end

accuracy_mat = n_correct_alphabet ./ (n_set*(n_set-1));
total_acc = sum(n_correct_alphabet) / n_total;

figure;
y = bar(accuracy_mat, 1.0, 'r');

xlim([0 30]);
title_str = sprintf('Mean Accuracy : %2.2f %%', total_acc .* 100);
title(title_str, 'FontSize', 14, 'FontWeight', 'bold');

x_loc = get(y, 'XData');
y_height = get(y, 'YData');
arrayfun(@(x,y) text(x, y./2, [num2str(fix(y*10^2)) '%'], 'Color', 'w', 'Rotation', 90), x_loc, y_height);

set(gca, 'YTick', 0:0.2:1, 'fontsize', 14, 'FontWeight', 'bold');
set(gca, 'YTickLabel', 100.*get(gca,'YTick'), 'fontsize', 14, 'FontWeight', 'bold');
set(gca,'XTick', 1:n_char);
set(gca,'XTickLabel', [cellstr(('a':'z').'); 'S'; 'B'; 'E'], 'fontsize', 14, 'FontWeight', 'bold');