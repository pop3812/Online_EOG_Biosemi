function [filtered_EOG] = signal_denoising(raw_EOG, ...
    buffer_4medianfilter, medianfilter_size)
%APPLY_MEDIAN_FILTER : Noise Removal by Applying Median Filter
% Input arguments
% raw_EOG : Buffer Length x Channel Number matrix with raw signals
% buffer_4medianfilter : circular queue buffer for median filter
% median_filter_size : median filter range of interest
%
% Output argument
% filtered_EOG : Buffer Length x Channel Number matrix with denoised signal

t_num = size(raw_EOG, 1);
ch_num = size(raw_EOG, 2);

filtered_EOG = raw_EOG;

for i=1:t_num
    buffer_4medianfilter.add(raw_EOG(i,:));
    if(buffer_4medianfilter.datasize >= medianfilter_size)
        filtered_EOG(i,:) = median(buffer_4medianfilter.data);
    end
end

end

