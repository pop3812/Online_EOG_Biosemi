for dat_idx = 1:4
n_char = 29;

figure;

for i = 1:n_char
    subaxis(4, 8, i, 'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
%     plot(alphabet_dict_norm{i, dat_idx});
    draw_alphabet_on_plot(alphabet_dict_norm{i, dat_idx});
    axis('on'); xlim([-0.5 0.5]); ylim([-0.5 0.5]); grid on;
end

end