clc; clear; % clf;
result_save_route = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\classification_results\';

n_set = 10;
D_Rate_iter = 2.^(6:-1:3);
method_str = {'Correlation', 'DTW', 'DPW', 'MSE'};
method_iter = [1, 2, 3, 5];

%% D_Rate - Accuracy Plot
N_Rate = length(D_Rate_iter);
N_method = length(method_iter);

Accuracy_mat = zeros(N_Rate, N_method);

for m_i = 1:N_method
    for D_j = 1:N_Rate
        
        save_route = [result_save_route, 'analysis_result_method_', num2str(method_iter(m_i)), '_DR_', num2str(D_Rate_iter(D_j)), '.mat'];
        load(save_route);
        
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
        
        Accuracy_mat(D_j, m_i) = total_acc * 100;

    end
end

%% Template 

x_axis = 1024./(D_Rate_iter);
figure;
plot(x_axis, Accuracy_mat); legend(method_str);

opt = [];
opt.XLabel = 'The number of data points';   % xlabel
opt.YLabel = 'Accuracy [%]'; % ylabel
opt.Title = 'Classification Accuracy';

opt.FontName = 'Cambria';      % string: font name; default: 'Arial'
opt.FontSize = 12;     % integer; default: 26
opt.FontWeight = 'bold';     % integer; default: 26

opt.XScale = 'log';     % 'linear' or 'log'
opt.YLim = [35 85]; % [min, max]
opt.XLim = [16 128]; % [min, max]
opt.XTick = x_axis;

opt.YGrid = 'on';       % 'on' or 'off'
opt.XGrid = 'on';       % 'on' or 'off'

opt.Markers = {'^', 'o', 's', 'd'};

% opt.LineStyle = {'-', ':', '--', '-.'};
opt.BoxDim = [5, 4];
opt.LegendLoc = 'SouthEastOutside';

% apply the settings
setPlotProp(opt);