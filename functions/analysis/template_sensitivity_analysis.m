clc; clear; % clf;
result_save_route = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\classification_results\';

n_set = 10;
D_Rate_iter = 2.^3;
method_str = 'DTW';
method_iter = 2;

%% 

save_route = [result_save_route, 'analysis_result_method_', num2str(method_iter), '_DR_', num2str(D_Rate_iter), '.mat'];
load(save_route);

n_correct_alphabet = zeros(10, 26);
n_total = n_set*(n_set-1) * 26;

for temp_idx = 1:n_set
    start_idx = (temp_idx-1)*(n_set-1);
    
    for i = 1:26
        for j = 1:n_set-1
            
            if result{i, start_idx+j}.alphabet_ori == result{i, start_idx+j}.alphabet_decision
                n_correct_alphabet(temp_idx, i) = n_correct_alphabet(temp_idx, i) + 1;
            end
            
        end
    end

end

n_correct_alphabet = n_correct_alphabet./(n_set-1).*100;
mean_acc = mean(n_correct_alphabet, 2);

hfig = figure; cc=hot(length(mean_acc));
for i=1:n_set
bar(i, mean_acc(i), 1.0, 'FaceColor', cc(i,:));
hold on;
end

bar(n_set+2, mean(mean_acc), 1.0, 'FaceColor', [0.5 0.5 0.5]);
errorbar(n_set+2, mean(mean_acc), mean(mean_acc)-min(mean_acc), max(mean_acc)-mean(mean_acc), ...
    'kx', 'LineWidth', 2, 'MarkerSize', 10);

%% Plot Template 
Fontsize = 12;
Fontname = 'Arial';

xlabel('Template index', 'FontName', Fontname, 'FontSize', Fontsize);
ylabel('Accuracy', 'FontName', Fontname, 'FontSize', Fontsize);

ylim([0 100]);
set(gca, 'Ytick', (0:20:100));
set(gca,'YTickLabel', sprintf('%3.0f%%|',(0:20:100)))
set(gca, 'Xtick', (1:n_set+2));
set(gca,'XTickLabel', [sprintf('%2.0f|',(1:n_set)), '|', 'mean'])
set(gca, 'FontName', Fontname, 'FontSize', Fontsize);

% Figure properties
% create figure window
set(hfig, 'Units', 'inches', ...
    'Color', [1,1,1]);
