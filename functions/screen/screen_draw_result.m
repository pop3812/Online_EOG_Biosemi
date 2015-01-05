function screen_draw_result(PointsArray)

global params;

width = params.rect(4) * 0.60;
pen_width = 4;
text_onset_angle = 12;

thePoints = PointsArray .* width;
[X,Y] = RectCenter(params.rect);

thePoints(:, 1) = fix(thePoints(:, 1) + X);
thePoints(:, 2) = fix(thePoints(:, 2) + Y);
thePoints(:, 2) = 2*Y - thePoints(:,2);

[numPoints, two] = size(thePoints);

%% Text
text = ['YOUR INPUT WAS'];
text_key = ['Press X or x : Reject' char(10) char(10) 'Press any other key : Continue'];
Screen('TextSize', params.window, 15);
Screen('TextStyle', params.window, 1);

X = screen_degree_to_pixel('X', text_onset_angle);
Y = screen_degree_to_pixel('Y', text_onset_angle);

DrawFormattedText(params.window, text, 'center', Y, [255, 255, 255]);
DrawFormattedText(params.window, text_key, X, Y, [255, 255, 255]);

%% Results on screen

for i= 1:numPoints-1

    Screen(params.window,'DrawLine', [128 255 128 128], ...
        thePoints(i,1),thePoints(i,2), ...
        thePoints(i+1,1),thePoints(i+1,2), pen_width);

end

screen_draw_keyboard();

Screen('Flip', params.window);

end

