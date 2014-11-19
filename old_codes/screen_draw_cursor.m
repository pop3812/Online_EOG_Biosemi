function [cursor, src_rect] = screen_draw_cursor(X, Y)
%SCREEN_DRAW_FIXATION
% determines the cursor type and then returns the image of the cursor
%
% Input arguments
% window        : window object of Psychtoolbox kit that the fixation point
%                 would be shown
% X, Y          : X, Y position of the fixation point on the screen [degree]
% Output argument
% image         : image matrix [width x height x RGB] of the cursor image

global params;
global buffer;

rect = params.rect;
cursor = buffer.cursor_img;

half_size = fix(size(cursor, 1) / 2);

X = screen_degree_to_pixel('X', X);
Y = screen_degree_to_pixel('Y', Y);

x_min = X<rect(1)+half_size; y_min = Y<rect(2)+half_size;
x_max = X>rect(3)-half_size; y_max = Y>rect(4)-half_size;

% Cursor Change
if(x_min || x_max || y_min || y_max)
    is_out_of_bound = 1;
    cursor = buffer.out_of_bound_img;
    cursor(:,:,1) = cursor(:,:,1).*2;
    if x_min
        X = rect(1)+half_size;
    elseif x_max
        X = rect(3)-half_size;
        cursor = imrotate(cursor,180);
    end

    if y_min
        Y = rect(2)+half_size;
        cursor = imrotate(cursor,90);
    elseif y_max
        Y = rect(4)-half_size;
        cursor = imrotate(cursor,270);
    end
end

% Make a cursor
if ~is_out_of_bound 
    src_rect = [X-half_size+1, Y-half_size+1, size(cursor, 1), size(cursor, 2)];
else
    
end 

end

