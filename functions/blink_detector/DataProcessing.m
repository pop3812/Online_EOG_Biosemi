%1�ʸ��� ȣ��ȴ�.
%ȣ��� ������ RawData�� �ִ� �� �� �ʿ��� ���� ��� ó���ؾ� �Ѵ�.
%RawData�� 512Hz�� ���ø� �Ǿ� ������,
%���⼭�� 64 Hz ������ �����͸� ����Ѵ�.
function DataProcessing()
    tic
    global rawData;     %Laxtha ��񿡼� �����Ͱ� ������ ����
    global p;
 %   global g_handles;
%    plot(g_handles.axes_source,rawData.Value);
%    return;

    d = rawData.Value(1:8:p.BufferLength_Laxtha,1);
    nData = 64;

    
    for i=1:nData

        %Apply Median Filter using buffer
        p.buffer_4medianfilter.add(d(i));
        if(p.buffer_4medianfilter.datasize<p.medianfilter_size)
            return;
        else
            d(i)= median(p.buffer_4medianfilter.data);
        end

        %data add to queue
        p.dataqueue.add(d(i));
        idx_cur = p.dataqueue.datasize; % index calculation

         [range, t, nDeletedPrevRange] = eogdetection_msdw_online(p.dataqueue, p.v_dataqueue, p.acc_dataqueue, idx_cur, p.min_window_width, p.max_window_width, p.threshold, p.prev_threshold, p.msdw, p.windowSize4msdw, p.indexes_localMin, p.indexes_localMax, p.detectedRange_inQueue, p.min_th_abs_ratio, p.nMinimalData4HistogramCalculation, p.msdw_minmaxdiff, p.histogram, p.nBin4Histogram,p.alpha, p.v);
         if t>0
             p.prev_threshold = t;
         end
         if size(range,1)>0
            % p.detectedRange_inQueue.add(range);
         end

        
    end
    drawData_withRange();
    toc
end

function drawData_withRange()
    global p;
    global g_handles;
    plot(g_handles.axes_source, p.dataqueue.data);
    xlim([0 p.queuelength]);
    drawRange();
end
    
function drawRange()
    global p;
    global g_handles;
   % axes(g_handles.axes_source);
    nRange = p.detectedRange_inQueue.datasize;
    y = get(gca,'YLim');
    y = (y(1) +y(2))/2;
    x = get(gca,'XLim');
    
    for i=1:nRange
        pos = mod(p.dataqueue.index_start + p.detectedRange_inQueue.get(i) - 2,p.dataqueue.length)+1;
  %      pos = pos * resamplingRate;
        if pos(1)>pos(2)
            %line([pos(1) x(2)] , [y, y],'color','red');
            %line([x(1) pos(2)] , [y, y],'color','red');
            area(g_handles.axes_source, [pos(1) x(2)], [y,y]);
            area(g_handles.axes_source, [x(1) pos(2)], [y,y]);
        else
            %line(pos, [y, y],'color','red');
            hold on;
            area(g_handles.axes_source, pos, [y,y]);
            hold off;
        end
    end
end