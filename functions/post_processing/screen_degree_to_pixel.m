function [pos] = screen_degree_to_pixel(comp, degree)
%SCREEN_DEGREE_TO_PIXEL Summary of this function goes here
%
% Input Arguments
% comp          : states which component it is. either 'X' or 'Y' (case-sensitive)
% degree        : the angle that you want to convert [degree]

global params;

rect = params.rect;
[X_center,Y_center] = RectCenter(rect);

% calculate max degree
if (comp == 'X')
    L = params.screen_width/2;
    PL = rect(3); % Pixel Width
    max_degree_rad = atan(L/params.screen_distance);
    center = X_center;
elseif (comp == 'Y')
    L = params.screen_height/2;
    PL = rect(4); % Pixel Height
    max_degree_rad = atan(L/params.screen_distance);
    center = Y_center;
else
   throw(MException('Screen:DegreeToPixel', 'Argument comp has unexpected value.'));
end
    
% deg to rad conversion
degree_rad = degree * pi / 180;

% if (max_degree_rad < degree_rad)
%     degree_rad = max_degree_rad;
% %     throw(MException('Screen:DegreeToPixel', 'Degree is out of range.'));
% elseif (degree_rad < -max_degree_rad)
%     degree_rad = -max_degree_rad;
% end

% calculate deviation length in cm by using trigonomial function
dist = params.screen_distance * tan(degree_rad); % [cm]
dist_pixel = (PL/2) * (dist/L);

if(comp=='Y')
    pos = center - dist_pixel;
elseif(comp=='X')
    pos = center + dist_pixel;
end

pos=fix(pos);
    

end

