function draw_calibration_signal(t_total, y_data, plateaus, slope, err)
global g_handles;
global params;

cla(g_handles.current_calibration);
plot(g_handles.current_calibration, t_total, y_data);
hold(g_handles.current_calibration, 'on');

for i = 1:length(plateaus)
    t = plateaus(i).on:plateaus(i).off;
    est = plateaus(i).est;
    plot(g_handles.current_calibration, t, est, ':r', 'LineWidth', 1);
end

n_str = sprintf('# of Region : %1.0f', length(plateaus));
pol_str = sprintf('Slope : %1.3f', slope);
err_str = sprintf('Error : %0.3e', err);

text(0.05, 0.85, n_str, 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 8);
text(0.05, 0.80, pol_str, 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 8);
text(0.05, 0.75, err_str, 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 8);
text(0.05, 0.95, 'Calibration Result', 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 10);


xlim(g_handles.current_calibration, [0 length(t_total)]);
y_range = params.y_range;
% ylim(g_handles.current_calibration, [-y_range y_range]);

draw_region_ranges(plateaus);

set(g_handles.current_calibration, 'XTick', []);
set(g_handles.current_calibration, 'YTick', []);
box(g_handles.current_calibration, 'on');

hold(g_handles.current_calibration, 'off');

end

function draw_region_ranges(plateaus)
global g_handles;

color = [0 0 0];
% height = 0.1;
% y = get(g_handles.current_calibration,'YLim');

for i = 1:length(plateaus)
%     pos = [plateaus(i).on, plateaus(i).off];
    leng = plateaus(i).length;
%     plot(g_handles.current_calibration, [pos(1) pos(1)], [y(1), y(2)], '-b', 'LineWidth', 2);
%     plot(g_handles.current_calibration, [pos(2) pos(2)], [y(1), y(2)], '-b', 'LineWidth', 2);
    y_lim_dat = [min(plateaus(i).est)-5 max(plateaus(i).est)+5];
    height = y_lim_dat(2) - y_lim_dat(1);
    
    H = rectangle('Position', [plateaus(i).on, y_lim_dat(1), leng, height], 'Parent', g_handles.current_calibration);
%     H = area(g_handles.current_calibration, pos, height*[y(2), y(2)]);
%     H2 = area(g_handles.current_calibration, pos, height*[y(1), y(1)]);

    % Set alpha value for the area
    set(H,'EdgeColor', color, 'LineStyle', ':', 'LineWidth', 1);
%     h=get(H2,'children');
%     set(h,'FaceAlpha', 0.1, 'FaceColor', color, 'LineStyle', 'none');
end
end