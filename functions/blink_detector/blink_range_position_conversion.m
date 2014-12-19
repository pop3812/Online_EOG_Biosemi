function [ ranges ] = blink_range_position_conversion()
%BLINK_RANGE_POSITION_CONVERSION Summary of this function goes here

global params;
global buffer;

p = params.blink;
b = buffer.blink;

nRange = b.detectedRange_inQueue.datasize;
if nRange > 0
    ranges = zeros(nRange, 2);
    for i=1:nRange
        pos = mod(b.dataqueue.index_start + ...
                b.detectedRange_inQueue.get(i) - 2, b.dataqueue.length) + 1;

        pos = pos * p.DecimateRate - buffer.dataqueue.index_start + 1;
        if pos <= 0
            pos = pos + buffer.dataqueue.datasize;
            % check if it is out of bound or not
        end

        if pos(1) > pos(2)
            pos(2) = pos(2) + buffer.dataqueue.datasize;
        end
        ranges(i,:) = pos;
    end
else
    ranges = [];
end

end

