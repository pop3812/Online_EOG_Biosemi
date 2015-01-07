clc; clear; close all; % clf;
result_save_route = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\classification_results\';

n_set = 10;
D_Rate_iter = 2.^3;
method_str = 'DTW';
method_iter = 2;

%% 

save_route = [result_save_route, 'analysis_result_method_', num2str(method_iter), '_DR_', num2str(D_Rate_iter), '.mat'];
load(save_route);

%%

error_mat = zeros(26, 26);

for i = 1:26
    for j = 1:n_set*(n_set-1)

        if result{i, j}.alphabet_ori ~= result{i, j}.alphabet_decision
            error_alphabet_idx = double(result{i, j}.alphabet_decision)-double('a')+1;
            error_mat(i, error_alphabet_idx) = error_mat(i, error_alphabet_idx) + 1;
        end

    end
end

error_mat = error_mat./n_set*(n_set-1);

%% Template
Fontsize = 14;
Fontname = 'Cambria';
Fontweight = 'bold';
width = 8; % inches
height = 6; % inches
grid_color = [0.5 0.5 0.5];

hfig = figure; imagesc(error_mat); cb = colorbar;
colormap(hot); 

% Figure properties
% create figure window
set(hfig, 'Units', 'inches', ...
    'Color', [1,1,1], 'Position', [1 1 width height]);

set(gca, 'Ytick', (1:26));
set(gca,'YTickLabel', cellstr(('a':'z').'), 'FontName', 'Courier', 'FontSize', Fontsize);
set(gca, 'Xtick', (1:26));
set(gca,'XTickLabel', cellstr(('a':'z').'), 'FontName', 'Courier', 'FontSize', Fontsize);

% Set labels
ylabel(cb,'Error Rate [%]', 'FontName', Fontname, 'FontSize', Fontsize, 'FontWeight', Fontweight);

xlabel({'', 'Predicted Label', ''}, 'FontName', Fontname, 'FontSize', Fontsize, 'FontWeight', Fontweight);
ylabel({'', 'True Label', ''}, 'FontName', Fontname, 'FontSize', Fontsize, 'FontWeight', Fontweight);

% Set Grids
set(gca,'TickLength',[0, 0]);
for i = 1.5:1:26
   line([i, i], [0.5, 26.5], 'Color', grid_color); hold on;
   line([0.5, 26.5], [i, i], 'Color', grid_color);
end

%% MDS
error_sym = (triu(error_mat) + tril(error_mat)')/2;
error_sym = (max(max(error_sym))+1)-error_sym;
error_sym = error_sym + error_sym';
error_sym(logical(eye(26))) = 0;

Y = mdscale(error_sym, 3, 'Criterion', 'sstress');

figure;
cc = jet(26);
alphabet_set = ('a':'z').';
for i = 1: 26
    scatter3(Y(i,1), Y(i,2), Y(i,3), [], cc(i,:), 'filled');
    text(Y(i,1), Y(i,2), Y(i,3)+1, alphabet_set(i));
    hold on;
end

%%
eucD = pdist(Y, 'euclidean');
clustTreeEuc = linkage(eucD,'average');
[h,nodes] = dendrogram(clustTreeEuc,0);

h_gca = gca;
set(h_gca, 'TickDir', 'out', 'TickLength', [.002 0]);

alphabet_set = cellstr(('a':'z').');

order_tree = get(h_gca, 'XTickLabel');
order_tree = str2num(order_tree);

set(h_gca, 'XTickLabel', alphabet_set(order_tree));

%% Dist Comparison between two class
interest_idx = 18; % 8 22

for i = 1:n_set*(n_set-1)
    dist(i) = result{interest_idx, i}.dist(interest_idx) - result{interest_idx, i}.dist(8);
end

figure; stem(dist);

% dist mean
dist_mean = zeros(1, 26);
for i = 1:n_set*(n_set-1)
    dist_mean = dist_mean + result{interest_idx, i}.dist;
end

dist_mean = dist_mean ./ (n_set*(n_set-1));

figure; plot(dist_mean);