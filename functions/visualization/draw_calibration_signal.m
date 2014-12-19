function draw_calibration_signal(t, y_data, est, slope, err)
global g_handles;
global params;

cla(g_handles.current_calibration);
plot(g_handles.current_calibration, t, y_data);
hold(g_handles.current_calibration, 'on');
plot(g_handles.current_calibration, t, est, ':r', 'LineWidth', 2);

pol_str = sprintf('Slope : %1.3f', slope);
err_str = sprintf('Error : %0.3e', err);

text(0.05, 0.85, pol_str, 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 8);
text(0.05, 0.80, err_str, 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 8);
text(0.05, 0.95, 'Calibration Result', 'Parent', g_handles.current_calibration, 'Units','normalized', 'FontName', 'Cambria', 'FontSize', 10);


xlim(g_handles.current_calibration, [0 length(t)]);
y_range = params.y_range;
ylim(g_handles.current_calibration, [-y_range y_range]);


end

