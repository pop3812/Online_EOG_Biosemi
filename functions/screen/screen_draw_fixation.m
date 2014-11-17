function screen_draw_fixation(window, X, Y, size, color)
%SCREEN_DRAW_FIXATION
% shows the fixation point (cross) on the designated point (X, Y) of 
% the screen
%
% Input arguments
% window        : window object of Psychtoolbox kit that the fixation point
%                 would be shown
% X, Y          : X, Y position of the fixation point on the screen [degree]
% size          : size of the fixation point (default is 15)
% color         : R, G, B value of the color > e.g. [255, 255, 255] = white
global params;

if(nargin < 3) % not enough arguments
    throw(MException('Screen_Draw_Fixation:NotEnoughArguments',...
        'There are not enough arguments.'));
elseif(nargin == 3) % arguments except size and color
    size = 15;
    color = [255, 255, 255]; % default color is white
elseif(nargin == 4) % arguments except color
    color = [255, 255, 255]; % default color is white    
elseif(nargin > 5) % too many arguments
    throw(MException('Screen_Draw_Fixation:TooManyArguments',...
        'There are too many arguments.'));
end

rect = params.rect;

width = 5;

X = screen_degree_to_pixel('X', X);
Y = screen_degree_to_pixel('Y', Y);

x_min = X<rect(1)+size; y_min = Y<rect(2)+size;
x_max = X>rect(3)-size; y_max = Y>rect(4)-size;

if x_min
    X = rect(1);
elseif x_max
    X = rect(3);
end

if y_min
    Y = rect(2);
elseif y_max
    Y = rect(4);
end

% Color becomes red if the gaze is out of monitor bound
if(x_min || x_max || y_min || y_max)
   color = [255 0 0];
end

% Make a fixation point
if (x_min&&y_min || x_min&&y_max || x_max&&y_min || x_max&&y_max)
    % '+' pointer
    Screen('DrawLine', window, color, X-size, Y, X+size, Y, width);
    Screen('DrawLine', window, color, X, Y-size, X, Y+size, width);
else
    % 'X' pointer
    Screen('DrawLine', window, color, X-size, Y-size, X+size, Y+size, width);
    Screen('DrawLine', window, color, X-size, Y+size, X+size, Y-size, width);
end

end

