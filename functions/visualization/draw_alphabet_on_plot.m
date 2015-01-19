function draw_alphabet_on_plot(alphabet_signal)

n_color = 256;

% Distance Calculation
Disp_X = alphabet_signal(:, 1);
Disp_Y = alphabet_signal(:, 2);

d_X = diff(Disp_X);
d_Y = diff(Disp_Y);

trail_dist = sqrt(d_X.^2 + d_Y.^2);
trail_dist = cumsum(trail_dist);

trail_dist = n_color/trail_dist(end) * trail_dist;

% Displaying Preparation

cc = jet(n_color);
cc = flipud(cc);
[numPoints, two]=size(Disp_X);

for i = 1:numPoints-1
    color_idx = ceil(trail_dist(i));
    if color_idx == 0
        color_idx = 1;
    end
    plot([Disp_X(i), Disp_X(i+1)], ...
        [Disp_Y(i), Disp_Y(i+1)], ...
        '-', 'LineWidth', 3, 'Color', cc(color_idx, :));
    hold on;

end
xlim([-0.5 0.5]); ylim([-0.5 0.5]);
axis('tight'); 
axis('off');
end

