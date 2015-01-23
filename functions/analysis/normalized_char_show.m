for dat_idx = 1:5
n_char = 29;

figure;

for i = 1:n_char
    subaxis(4, 8, i, 'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
    signal = alphabet_dict_norm{i, dat_idx};
    
    [dData, minmax, stats] = AnalyzeEdges(signal(:,1));
    dif_f_x = dData(:,2);
    [dData, minmax, stats] = AnalyzeEdges(signal(:,2));
    dif_f_y = dData(:,2);
    
%     plot(signal);
%     axis('tight');
    draw_alphabet_on_plot(alphabet_dict_norm{i, dat_idx});
    axis('on'); xlim([-0.5 0.5]); ylim([-0.5 0.5]); grid on;
end

end