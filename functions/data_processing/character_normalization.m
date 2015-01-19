function [NormalizedPoints] = character_normalization(AbsolutePoints)

NormalizedPoints = AbsolutePoints;

% Position Normalization
NormalizedPoints(:,1) = AbsolutePoints(:,1) - ((max(AbsolutePoints(:,1))+min(AbsolutePoints(:,1)))/2);
NormalizedPoints(:,2) = AbsolutePoints(:,2) - ((max(AbsolutePoints(:,2))+min(AbsolutePoints(:,2)))/2);

% Size Normalization
x_width = max(NormalizedPoints(:,1))-min(NormalizedPoints(:,1));
y_width = max(NormalizedPoints(:,2))-min(NormalizedPoints(:,2));
width = max([x_width y_width]);

NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);

%% 박사님 제안 방식
% 
% % Size Normalization
% width = max([max(abs(NormalizedPoints(:,1))), max(abs(NormalizedPoints(:,2)))]);
% 
% NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
% NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);
% 
% % height = max(NormalizedPoints(:,2)) - min(NormalizedPoints(:,2));
% % NormalizedPoints(:,2) = NormalizedPoints(:,2)./(height).*2;

end

