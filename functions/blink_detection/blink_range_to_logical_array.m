function [logical_array] = blink_range_to_logical_array(range)
%BLINK_RANGE_TO_LOGICAL_ARRAY
% changes blink range array into the logical array

global params;

logical_array = zeros(params.QueueLength, 1);
n_range = size(range, 1);

if (n_range~=0)
    for i=1:n_range
        pos = range(i, :);
        logical_array(pos(1):pos(2)) = 1;
    end
end

logical_array =logical(logical_array);

end

