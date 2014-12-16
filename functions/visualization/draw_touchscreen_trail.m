function draw_touchscreen_trail()
global buffer;
global params;
global g_handles;

deg_bound = 50;
deg_bound_pix_x = screen_degree_to_pixel('X', deg_bound);
deg_bound_pix_y = screen_degree_to_pixel('Y', deg_bound);
deg_bound_pix_x_neg = screen_degree_to_pixel('X', -deg_bound);
deg_bound_pix_y_neg = screen_degree_to_pixel('Y', -deg_bound);

%% Data Retrieve
thePoints = buffer.session_data{buffer.n_session}.eye_position_queue_px;

%% Concatenation of Out of Bound Data
key_rect = buffer.key_rect;
thePoints(isnan(thePoints(:, 1)) | isnan(thePoints(:, 2)), :) = [];
% thePoints(thePoints(:, 1)<=deg_bound_pix_x_neg | thePoints(:, 1)>=deg_bound_pix_x, :) = [];
% thePoints(thePoints(:, 2)>=deg_bound_pix_y_neg | thePoints(:, 2)<=deg_bound_pix_y, :) = [];

thePoints(thePoints(:, 1)<=key_rect(1), 1) = key_rect(1);
thePoints(thePoints(:, 1)>=key_rect(3), 1) = key_rect(3);
thePoints(thePoints(:, 2)<=key_rect(2), 2) = key_rect(2);
thePoints(thePoints(:, 2)>=key_rect(4), 2) = key_rect(4);

pen_width = 4;
D_Rate = 4;
n_mark = 16;
NormalizedPoints = [];
[numPoints, two]=size(thePoints);
n_trail_point = fix(params.screen_trail_point_per_sec * params.DelayTime);
n_skip = fix(params.SamplingFrequency2Use * params.DelayTime / n_trail_point);

if numPoints > 1
%% Visualization on Psychtoolbox Screen
text = ['Your input was : ', buffer.selected_key];
Screen('TextSize', params.window, 15);
Screen('TextStyle', params.window, 1);

DrawFormattedText(params.window, text, 'center', 150, [255, 255, 255]);

for i= 1:n_skip:numPoints
    if i<=numPoints-n_skip
                Screen(params.window,'DrawLine', [255 255 255 255], ...
                    thePoints(i,1),thePoints(i,2), ...
                    thePoints(i+n_skip,1),thePoints(i+n_skip,2), pen_width);
    end
end
Screen('Flip', params.window);

%% Eye Position Normailization

AbsolutePoints = [thePoints(:,1), key_rect(RectBottom)-thePoints(:,2)];

% Position Normalization
NormalizedPoints(:,1) = AbsolutePoints(:,1) - ((max(AbsolutePoints(:,1))+min(AbsolutePoints(:,1)))/2);
NormalizedPoints(:,2) = AbsolutePoints(:,2) - ((max(AbsolutePoints(:,2))+min(AbsolutePoints(:,2)))/2);

% Size Normalization
x_width = max(NormalizedPoints(:,1))-min(NormalizedPoints(:,1));
y_width = max(NormalizedPoints(:,2))-min(NormalizedPoints(:,2));
width = max([x_width, y_width]);
NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);

%% Save Normalized Eye Position
buffer.session_data{buffer.n_session}.normalized_eye_position = NormalizedPoints;

%% Downsampling for Displaying
DispPoints = [NormalizedPoints(1:D_Rate:end,1), NormalizedPoints(1:D_Rate:end,2)];
[numPoints, two]=size(DispPoints);

%% Plot the contour in a Matlab figure

n_color = 256;

% Distance Calculation
Disp_X = DispPoints(:, 1);
Disp_Y = DispPoints(:, 2);

d_X = diff(Disp_X);
d_Y = diff(Disp_Y);

trail_dist = sqrt(d_X.^2 + d_Y.^2);
trail_dist = cumsum(trail_dist);

trail_dist = n_color/trail_dist(end) * trail_dist;

% Displaying Preparation

cc = jet(n_color);
cc = flipud(cc);
hold(g_handles.current_position, 'off');

for i = 1:numPoints-1
    color_idx = ceil(trail_dist(i));
    plot(g_handles.current_position, [DispPoints(i, 1), DispPoints(i+1, 1)], ...
        [DispPoints(i, 2), DispPoints(i+1, 2)], ...
        '-', 'LineWidth', pen_width, 'Color', cc(color_idx, :));
    
    hold(g_handles.current_position, 'on');
end

xlim(g_handles.current_position, [-0.6 0.6]);
ylim(g_handles.current_position, [-0.6 0.6]);
hold(g_handles.current_position, 'off');

set(g_handles.current_position, 'XTick', []);
set(g_handles.current_position, 'YTick', []);
box(g_handles.current_position, 'on');

else
    %% Save Normalized Eye Position
    buffer.session_data{buffer.n_session}.normalized_eye_position = 'No Data';
    
    cla(g_handles.current_position);
    xlim(g_handles.current_position, [-0.6 0.6]);
    ylim(g_handles.current_position, [-0.6 0.6]);
    hold(g_handles.current_position, 'off');

    set(g_handles.current_position, 'XTick', []);
    set(g_handles.current_position, 'YTick', []);
    box(g_handles.current_position, 'on');
end
end
