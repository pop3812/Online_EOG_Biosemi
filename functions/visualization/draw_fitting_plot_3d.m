function draw_fitting_plot_3d()
%DRAW_FITTING_PLOT_3D Summary of this function goes here
%   Detailed explanation goes here
global buffer;
global g_handles;

font_size = 12;

if isfield(buffer, 'Surf_struct')
    
% Draw
if isfield(g_handles, 'fitting_plot') && ishandle(g_handles.fitting_plot)
    figure(g_handles.fitting_plot);
    clf(g_handles.fitting_plot);
else
g_handles.fitting_plot = figure('name', '3D Fitting Results', 'NumberTitle', 'off');
end

% V_h
subplot(1,2,1);
colormap(hot(256));
L=surf(buffer.Surf_struct.XGrid, buffer.Surf_struct.YGrid, buffer.Surf_struct.Vh_surf);

hold on;

set(get(get(L,'parent'),'XLabel'),'String','x','FontSize', font_size,'FontWeight','bold')
set(get(get(L,'parent'),'YLabel'),'String','y','FontSize', font_size,'FontWeight','bold')
set(get(get(L,'parent'),'ZLabel'),'String','V_h','FontSize', font_size,'FontWeight','bold')

grid on;
axis square;

% V_v
subplot(1,2,2);
colormap(hot(256));
L=surf(buffer.Surf_struct.XGrid, buffer.Surf_struct.YGrid, buffer.Surf_struct.Vv_surf);

hold on;

set(get(get(L,'parent'),'XLabel'),'String','x','FontSize', font_size,'FontWeight','bold')
set(get(get(L,'parent'),'YLabel'),'String','y','FontSize', font_size,'FontWeight','bold')
set(get(get(L,'parent'),'ZLabel'),'String','V_v','FontSize', font_size,'FontWeight','bold')

grid on;
axis square;

%% Verbose Matrix

disp('Transformation Matrix T ([x; y] = T x ([V_h; V_v] - C)) : ');
disp(buffer.T_matrix);

disp('Transformation Matrix C ([x; y] = T x ([V_h; V_v] - C)) : ');
disp(buffer.T_const);

set(g_handles.system_message, 'String', 'Fitting visualization has been done.');

else
    
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);

    set(g_handles.system_message, 'String', 'There is no fitting results to plot.');
end

end

