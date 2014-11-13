function screen_draw_fixation(window, X, Y, size, color)
%SCREEN_DRAW_FIXATION
% shows the fixation point (cross) on the designated point (X, Y) of 
% the screen
%
% Input arguments
% window        : window object of Psychtoolbox kit that the fixation point
%                 would be shown
% X, Y          : X, Y position of the fixation point on the screen [pixel]
% size          : size of the fixation point (default is 15)
% color         : R, G, B value of the color > e.g. [255, 255, 255] = white

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

% Make a fixation point
FixCross = [X-2,Y-size,X+2,Y+size;X-size,Y-2,X+size,Y+2];
Screen('FillRect', window, color, FixCross');

end

