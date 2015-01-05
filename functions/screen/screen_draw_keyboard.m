function screen_draw_keyboard()
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