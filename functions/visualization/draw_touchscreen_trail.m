function draw_touchscreen_trail()
global buffer;
global g_handles;

%% Data Retrieve
thePoints = buffer.session_data{buffer.n_session}.eye_position_queue;

[numPoints, two]=size(thePoints);
for i = 1:numPoints
    thePoints(i, 1) = screen_degree_to_pixel('X', thePoints(i, 1));
    thePoints(i, 2) = screen_degree_to_pixel('Y', thePoints(i, 2));
end

%% Concatenation of Out of Bound Data
key_rect = buffer.key_rect;
thePoints(isnan(thePoints(:, 1)) | isnan(thePoints(:, 2)), :) = [];
thePoints(thePoints(:, 1)<=key_rect(1) | thePoints(:, 1)>=key_rect(3), :) = [];
thePoints(thePoints(:, 2)<=key_rect(2) | thePoints(:, 2)>=key_rect(4), :) = [];

pen_width = 4;
D_Rate = 4;
n_mark = 8;
NormalizedPoints = [];

%% Visualization on Psychtoolbox Screen
% for i= 1:numPoints-1
%                 Screen(params.window,'DrawLine', [255 128 128 192],thePoints(i,1),thePoints(i,2),thePoints(i+1,1),thePoints(i+1,2), pen_width);
% end

%% Eye Position Normailization

AbsolutePoints = [thePoints(:,1), key_rect(RectBottom)-thePoints(:,2)];

% Position Normalization
NormalizedPoints(:,1) = AbsolutePoints(:,1) - ((max(AbsolutePoints(:,1))+min(AbsolutePoints(:,1)))/2);
NormalizedPoints(:,2) = AbsolutePoints(:,2) - ((max(AbsolutePoints(:,2))+min(AbsolutePoints(:,2)))/2);

% Size Normalization
width = max([max(NormalizedPoints(:,1))-min(NormalizedPoints(:,1)), max(NormalizedPoints(:,2))-min(NormalizedPoints(:,2))]);
NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);

%% Plot the contour in a Matlab figure

DispPoints = [NormalizedPoints(1:D_Rate:end,1), NormalizedPoints(1:D_Rate:end,2)];
[numPoints, two]=size(DispPoints);

num = 1;
cc = jet(n_mark);
cc = flipud(cc);
hold(g_handles.current_position, 'off');

plot(g_handles.current_position, DispPoints(:, 1), DispPoints(:, 2), ...
    '-b', 'LineWidth', pen_width);
hold(g_handles.current_position, 'on');
for i = 1:numPoints
    if mod(i, fix(numPoints/n_mark))==0
    plot(g_handles.current_position, DispPoints(i, 1), DispPoints(i, 2), ...
        '-ok', 'markersize', 15, 'markerfacecolor', cc(num, :), 'LineWidth', pen_width);
    num = num+1;
    end
hold(g_handles.current_position, 'on');
xlim(g_handles.current_position, [-0.5 0.5]);
ylim(g_handles.current_position, [-0.5 0.5]);
end

axis(g_handles.current_position, 'off');

end
