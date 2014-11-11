%MSDW�� ����Ͽ� spike�� ������ �����Ѵ�.
% threshold�� -1�� ��쿡�� automatic thresholding ����� �����Ѵ�.
% nDeletedPrevRange �� ������ record �� artifact range �� ���Ӱ� detected �� range��
% �������� ������ ������ ��
function [range, threshold, nDeletedPrevRange] = eogdetection_msdw_online(dataqueue, v_dataqueue, acc_dataqueue, idx_cur, min_windowwidth, max_windowwidth, threshold, prev_threshold, msdw, windowSize4msdw,indexes_localMin, indexes_localMax, detectedRange_inQueue, min_th_abs_ratio, nMinimalData4HistogramCalculation, msdw_minmaxdiff, histogram, nBin4Histogram,alpha, v, bEnableAdaption)
%EOGDETECTION_MSDW_ONLINE Summary of this function goes here
%   Detailed explanation goes here
    global bTmpUp;
    global bTmpDown;
    global tmp_max_id;
    global tmp_min_id;
%    global bMinFound;
   % global detectedRange_inQueue;
    
    if nargin<14
        min_th_abs_ratio = 0.4;
    end
    if nargin<21
        bEnableAdaption = 1;
    end
    
    %�ʱ�ȭ
    if idx_cur==1
        bTmpUp =0; bTmpDown = 0;    tmp_max_id= 0; tmp_min_id = 0;
    end
    range = [];
    nDeletedPrevRange = 0;
    
    %�����͸� �Է��ϱ� ���� �̹� queue �� �� �� �ִ� �������� üũ data�� shift Ȯ�� � �ʿ�
    % �̰� 1�̸� calMultiSDW_onebyone �Լ��� ȣ��Ǹ鼭 queue�� ������/������ shift�ϰ� ��
    if v_dataqueue.datasize == v_dataqueue.length
        bDataFull_beforeAddingData = 1;
    else
        bDataFull_beforeAddingData = 0;
    end

    %��������� �����͸� ����� MSDW ���
    [ msdw_cur, windowSize4msdw_cur ] = calMultiSDW_onebyone( dataqueue, v_dataqueue, acc_dataqueue, min_windowwidth, max_windowwidth );
    if isempty(msdw_cur)
        msdw.add(0);
        windowSize4msdw.add(0);
    else
        msdw.add(msdw_cur);
        windowSize4msdw.add(windowSize4msdw_cur);
    end
    
    %�����Ͱ� ����� ������ ���� ��� ó��
    if idx_cur<3
        return;
    end
    
    %queue�� shift �Ǹ�, queue�� �ִ� range, indexes_localMax, indexes_localMin �� invalid �Ǵ� ���� �����ϴ� �ڵ�
    ProcessQueueIntegrity(bDataFull_beforeAddingData, detectedRange_inQueue);
    ProcessQueueIntegrity(bDataFull_beforeAddingData, indexes_localMax);
    ProcessQueueIntegrity(bDataFull_beforeAddingData, indexes_localMin);
    
    % i-2, i-1, i �� �� �׸��� �����Ͽ� local min/max �� ����Ѵ�.
    %peak�� ��ī���� ���� ��츦 ���� ���
    [tmp_max_id, tmp_min_id, bTmpUp, bTmpDown, bMinFound] = checkLocalMinMax(msdw, tmp_max_id, tmp_min_id, bTmpUp, bTmpDown, indexes_localMin, indexes_localMax, idx_cur);
    
    %local minimum�� ���Ӱ� �߰ߵ� ���, msdw�� minmax diff ���·� ��ȯ�Ѵ�.
    if bMinFound==1
        MSDW2minmaxdiff_online(msdw, max_windowwidth, indexes_localMin, indexes_localMax, msdw_minmaxdiff);
        
        %automatic thresholding �� ��� threshold�� ����Ѵ�.
        if threshold<0 
            if dataqueue.datasize>=nMinimalData4HistogramCalculation
                if histogram.nBin ==0
                    histogram.Init(msdw_minmaxdiff.data(1:msdw_minmaxdiff.datasize,:),nBin4Histogram);
                else
                    if bEnableAdaption ==1
                        histogram.add(msdw_minmaxdiff.getLast());
                    end
                end
            else
                %�����Ͱ� ���� ������� ���� ��� histogram�� ������� �ʰ�,
                %range�� ������� �ʴ´�.
                return;
            end
            %threshold = selectThreshold_KimMcNames2007_withAlpha_usingHistogram(histogram,ceil(totalTimePassed),0);
            threshold = selectThreshold_KimMcNames2007_withAlpha_usingHistogram_v2(histogram, alpha,v);
            if threshold<0 %���� �˰������� threshold ����� �ȵǴ� ��� �� ���� threshold�� �״�� ����Ѵ�.
                threshold = prev_threshold;
            end
        end
    end
    
    
    
    %���� local maxima �� �ϳ��� ���캸�鼭 ������ũ�� �� �� �ִ��� ���θ� ������.
    if bMinFound ==1 && indexes_localMax.datasize>0 %minimum ���� �߰ߵǰ�, ������ maximum ���� �߰ߵǾ��� ���
        id_min = indexes_localMin.getLast();
        sum = msdw.get(indexes_localMax.getLast()) - msdw.get(id_min);
        tmp_max_sum = sum;
        curmax_pos = indexes_localMax.getLast();
        r_start = -1;

        bAccept = isCriteriaSatisfied(sum,threshold, min_th_abs_ratio, msdw.get(curmax_pos), msdw.get(id_min));
        if(bAccept==1)   %������ �����ϴ� ���
            %ó���� ���õ� ������ ���� ������ ��ġ�� ��� starting point�� �����Ѵ�.
            %�̶� �� ������ ������ ������ �����ϴ� ���� �ٶ������� �ʴ�.

            r_start = curmax_pos - windowSize4msdw.get(curmax_pos);
            if(detectedRange_inQueue.datasize>0)
                prev_range = detectedRange_inQueue.getLast();
                if r_start<=prev_range(2)
                    r_start = prev_range(2);
                end
            end
        end

        for k=0:indexes_localMax.datasize-2 %������ max ������ ���ٷ� �ϳ��� ¤�� ���鼭 ������ max ���� �������� range�� ���� �� �ִ��� üũ�Ѵ�.
            if(id_min - indexes_localMax.get_fromEnd(2+k)>max_windowwidth)        %���� ���� (max_windowwidth *2) ���� maximum value�� �ƴ� ��� �ߴ�
                break;
            end
            prev_range = [];
            if(detectedRange_inQueue.datasize>0)
                prev_range = detectedRange_inQueue.getLast();
            end

            %������ range�� ��ġ�� �����鼭 sum�� �ִ��� ��츦 ã�´�. (���� range�� �����ϴ� ���� ������.)
            curmax_pos  = indexes_localMax.get_fromEnd(k+2);                  %���� ���캼 max ������ �ε���
            prevmax_pos = indexes_localMax.get_fromEnd(k+1);                    %������ ���캻 max������ �ε���
            sum = sum + msdw.get(curmax_pos) - msdw.get(prevmax_pos);  %�� ���� ������ ������ ���� ���� ��������� ���� ���Ѵ�.

            r_start_tmp = curmax_pos - windowSize4msdw.get(curmax_pos);            %range�� ������

            tmp_check_result = isCriteriaSatisfied(sum,threshold,min_th_abs_ratio, msdw.get(curmax_pos), msdw.get(id_min));%, id_min, curmax_pos,max_id_window_acc_v(id_min), nLocalMin-1-k, LRValues_Spike, LRWidths_Spike, bAccept);
            if(sum>tmp_max_sum  && tmp_check_result==1) %������ �����ϴ� ���

                tmp_max_sum = sum;
                if(detectedRange_inQueue.datasize==0 || r_start_tmp>=prev_range(2))  %������ range�� ��ġ�� �ʴ´ٸ� starting point�� Ȯ���Ѵ�
                    r_start = r_start_tmp; 
                end

                while(detectedRange_inQueue.datasize>0 && r_start_tmp<=prev_range(1))  %���� range�� �����Ѵٸ�, (2�� �̻��� range�� ���ÿ� �����Ͽ� ������ ���ɼ��� �����Ƿ� if ��� while�� ����.)
                    detectedRange_inQueue.pop();%������ range�� �����Ѵ�. 
                    nDeletedPrevRange = nDeletedPrevRange +1;
                    %�̹� range�� ����������, ���� range�͵� ��ġ�� ���������� ���ϴ� ��� ó��
                    %range�� ���� range�� �������� �����ϵ��� �Ѵ�.
                    if(detectedRange_inQueue.datasize>0) 
                        prev_range = detectedRange_inQueue.getLast();
                        if r_start_tmp<prev_range(2) %���� range�� ��ġ�� ��� �ϴ� �� range�� ������ ���������� �� �ΰ�, �����ϴ� ��쿡�� while ���� ������ iteration ���� ó���Ѵ�.
                            r_start = prev_range(2);     
                        else
                            r_start = r_start_tmp;
                        end
                    else
                        r_start = r_start_tmp;
                    end
                end
            end
        end

        if(r_start>0)
            range = [r_start id_min];
            detectedRange_inQueue.add(range);
        end
    end
end

function [bYes] = isCriteriaSatisfied(sum, threshold, min_th_abs_ratio, window_acc_v_max, window_acc_v_min)%, min_id,max_id,windowwidth_at_min, prev_minID,  LRValues_Spike, LRWidths_Spike, bAccept)
    bYes = (sum>threshold && window_acc_v_max>threshold*min_th_abs_ratio && window_acc_v_min<-threshold*min_th_abs_ratio);% && min_id - windowwidth_at_min>=max_id);
end



%queue�� shift �Ǹ�, queue�� �ִ� range ���� data �� invalid �Ǵ� ���� �����ϴ� �ڵ�
function ProcessQueueIntegrity(bDataFull_beforeAddingData, queue)
    if queue.datasize>0 && bDataFull_beforeAddingData ==1
        queue.data = queue.data -1;
        theFirstRange = queue.get(1);
        if theFirstRange(1)==0
            queue.pop_fromBeginning();
        end
    end
end