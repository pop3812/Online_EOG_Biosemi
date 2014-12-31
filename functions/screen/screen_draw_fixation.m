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
    screen_draw_keyboard(X, Y);
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

function screen_draw_keyboard(X, Y)
global params;
global buffer;
    
    type = 'Rectangle'; % or 'Circle'
    boarder = 10;
    width = 3;

    if strcmp(type, 'Rectangle')

    % Draw Number Keyboard on the Screen
    % '3 x 4 Rectangle' Keyboard
    size_x = 4;
    size_y = 4;
    
%     number_matrix = 1:size_x*size_y;
%     number_matrix = reshape(number_matrix, size_y, size_x);
%     
%     %%%
%     number_matrix(:, 1:3) = number_matrix(:, 1:3)';
%     number_matrix = num2cell(number_matrix);
%     number_matrix{1, size_x} = 'SPACE';
%     number_matrix{2, size_x} = 'BACKSPACE'; % BACKSPACE
%     number_matrix{3, size_x} = 'ENTER'; % ENTER
%     %%%
    
    x_L = params.screen_width/2;
    x_max_degree = atan(x_L/params.screen_distance) * 180 / pi;
    y_L = params.screen_height/2;
    y_max_degree = atan(y_L/params.screen_distance) * 180 / pi;

    % width and height of each key
    x_max_pixel = screen_degree_to_pixel('X', x_max_degree);
    y_max_pixel = screen_degree_to_pixel('Y', -y_max_degree);
    width_pixel = fix(x_max_pixel/size_x);
    height_pixel = fix(y_max_pixel/size_y);
    
    % Draw_Key boards
    key_buffer = '';
%     x_pos = (size_x-1)*width_pixel;
%     for y_pos = 0:height_pixel:y_max_pixel-1
%         x_idx = size_x;
%         y_idx = (y_pos)/height_pixel + 1;
%         key = num2str(number_matrix{y_idx, x_idx});
%         key_rect = [x_pos+boarder y_pos+boarder ...
%             x_pos+width_pixel-boarder y_pos+height_pixel-boarder];
% 
%         if (x_pos+boarder<=X && X<=x_pos+width_pixel-boarder && ...
%                 y_pos+boarder<=Y && Y<=y_pos+height_pixel-boarder)
%             % Focused
%             Screen('FillRect', params.window, [200 255 200 64], ...
%                 key_rect);
%             key_buffer = key;
%         else
%             % Normal
%             Screen('FillRect', params.window, [200 255 200 128], ...
%                 key_rect);
%         end
% 
%         % Keys on keyboard
%         Screen('TextFont', params.window, 'Cambria');
%         Screen('TextSize', params.window, 35);
%         DrawFormattedText(params.window, key, ...
%             'center', 'center',...
%             [255, 255, 255], [], [], [], [], [], ...
%             key_rect);
%     end
    
    % Draw Grids
    for x_grid = 1:size_x-1
        Screen('DrawLine', params.window, [255 255 255 32], x_grid*width_pixel, 0, x_grid*width_pixel, y_max_pixel, width);
    end
    for y_grid = 1:size_y-1 
        Screen('DrawLine', params.window, [255 255 255 32], 0, y_grid*height_pixel, x_max_pixel, y_grid*height_pixel, width);
    end
    
    % Draw Touch Screen
    buffer.key_rect = [0+boarder 0+boarder ...
            x_max_pixel-boarder y_max_pixel-boarder];
    Screen('FrameRect', params.window, 255, ...
        [0 0 x_max_pixel y_max_pixel], boarder);
    
    buffer.selected_key = key_buffer;
    
    end
end