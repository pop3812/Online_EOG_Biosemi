function screen_draw_fixation(window, X, Y, size, width, color, type)
%SCREEN_DRAW_FIXATION
% shows the fixation point (cross) on the designated point (X, Y) of 
% the screen
%
% Input arguments
% window        : window object of Psychtoolbox kit that the fixation point
%                 would be shown
% X, Y          : X, Y position of the fixation point on the screen [degree]
% size          : size of the fixation point (default is 10)
% width         : width of the fixation point (in case of 'X' shape point)
% color         : R, G, B value of the color > e.g. [255, 255, 255] = white
% type          : type of fixation point. either 'X' or '.' (dot)
global params;

if(nargin < 3) % not enough arguments
    throw(MException('Screen_Draw_Fixation:NotEnoughArguments',...
        'There are not enough arguments.'));
elseif(nargin == 3) % arguments except size and color
    size = 10;
    width = 2;
    color = [255, 255, 255]; % default color is white
    type = '.';
elseif(nargin == 4) % arguments except color
    width = 2;
    color = [255, 255, 255]; % default color is white
    type = '.';
elseif(nargin == 5) % arguments except color
    color = [255, 255, 255]; % default color is white
    type = '.';
elseif(nargin == 6) % arguments except color
    type = '.';
elseif(nargin > 7) % too many arguments
    throw(MException('Screen_Draw_Fixation:TooManyArguments',...
        'There are too many arguments.'));
end

rect = params.rect;

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

% Draw Keyboards
if ~strcmp(type, '.') && ~strcmp(type, '+')
    screen_draw_keyboard();
end

% Color becomes red if the gaze is out of monitor bound
if(x_min || x_max || y_min || y_max)
   color = [255 0 0];
end

% Make a fixation point
if (x_min&&y_min || x_min&&y_max || x_max&&y_min || x_max&&y_max)
    % '+' pointer
    size = size + 10;
    Screen('DrawLine', window, color, X-size, Y, X+size, Y, width);
    Screen('DrawLine', window, color, X, Y-size, X, Y+size, width);
else
    if strcmp(type, '.')
        % 'Dot' pointer
        Screen('DrawDots', window, [X, Y], size, color, [0, 0], 2);
    elseif strcmp(type, '+')    
        % '+' pointer
            Screen('DrawLine', window, color, X, Y-size, X, Y+size, width);
            Screen('DrawLine', window, color, X-size, Y, X+size, Y, width);
    elseif strcmp(type, '-')
        if (x_min || x_max || y_min || y_max)
            % 'X' pointer
            Screen('DrawLine', window, color, X-size, Y-size, X+size, Y+size, width);
            Screen('DrawLine', window, color, X-size, Y+size, X+size, Y-size, width);
        else
            % '-' pointer
            Screen('DrawLine', window, color, fix(X-1.5*size), ...
                Y, fix(X+1.5*size), Y, width);
            Screen('FrameArc', params.window, color, ...
                [fix(X-1.5*size) Y fix(X+1.5*size) Y+size], 120, 120, fix(1.5*width));
%             Screen('TextFont', params.window, 'Cambria');
%             Screen('TextSize', params.window, 10);
%             DrawFormattedText(params.window, 'BLINK', X-15, Y-30, [255, 255, 255]);
        end
    else
        % 'X' pointer
        Screen('DrawLine', window, color, X-size, Y-size, X+size, Y+size, width);
        Screen('DrawLine', window, color, X-size, Y+size, X+size, Y-size, width);
    end
end

end