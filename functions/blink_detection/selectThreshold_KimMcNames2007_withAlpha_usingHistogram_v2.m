% --------------------------------------
% selectThreshold_KimMcNames2007_withAlpha �Լ��� h ����.
% h �� �̸� ���Ǿ� �ִ� ��� h �� �Ķ���ͷ� �޾Ƽ� ó���Ѵ�.
% threshold = selectThreshold(data);
% threshold �� �ڵ����� ������ �ش�.
% algorithm by S.Kim & J. McNames (2007, J. Neuroscience Method: Automatic spike detection based on adaptive template matching for extracellular neural recordings)
% program by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
% start_index: start_index ������ ���� �����Ѵ�.
% nExpectedMaxEvent: ������ ������ ����Ǵ� event�� �ִ��
%---------------------------------------------------------------------
function threshold = selectThreshold_KimMcNames2007_withAlpha_usingHistogram_v2(histogram, alpha,v)
    
    if nargin<3
        v = 0.4;
    end
    h = histogram.bin;
    %h = fliplr(histogram.bin);
   % h2 = smoothts(h,'g');
    %half_delta = histogram.delta/2;
    %xi = fliplr(histogram.xi);
    
    threshold = -1;
    
    [min_ids_KS, max_ids_KS] = findLocalMinMaxs(h');
    nKSMax = size(max_ids_KS,1);
    nKSMin = size(min_ids_KS,1);
    if nKSMax==0 % �������� ������ ���� ���. �� dist �迭�� ��� �ִ� ���
        disp('Error:In func. selectThreshold. Input data is Empty');
        return;
    elseif nKSMax>1%������ ������ 2�� �̻��� ���
        %���� 1              : 
        %���� 2(by Dr. Chang): min���� index�� global max ���� index���� �۾ƾ� �Ѵ�.
        %���� 2�� max���� �����ϸ� ������� �ʱ� ���� ���Ǿ���.
        %�� ������ �������� �ʴ� min���� max ���� ���� ���� �����
        
        if max_ids_KS(nKSMax)< min_ids_KS(nKSMin) %������ local max ���Ŀ� local min �� �����Ѵٸ� ������ min�� �����Ѵ�.
            min_ids_KS(nKSMin)=[];
            nKSMin = nKSMin-1;
        end
        if max_ids_KS(1)> min_ids_KS(1)     %������local max ������ local min �� �����Ѵٸ� ������ min�� �����Ѵ�.
            min_ids_KS(1) = [];
            nKSMin = nKSMin-1;
        end
        
        %global max �� ã�´�
        global_max_id = 1;
        for i= 2:nKSMax
            if h(max_ids_KS(i))> h(max_ids_KS(global_max_id))
                global_max_id = i;
            end
        end
        global_max = h(max_ids_KS(global_max_id));
        
        %�Ʒ� �κ��� �ڵ�� ���������� ������ local max �� ������ local min�� �����Ѵٰ� �����Ѵ�.
        for i= global_max_id+1:nKSMax
            Max_i = h(max_ids_KS(i));
            if Max_i/global_max<v              %����
                km_idx_min = min_ids_KS(i-1);
                threshold = histogram.xi(km_idx_min);
                break;
            end
        end
    end
    
    if threshold<0 %���ǿ� �´� �������� ã�� ���� ���
        return;
    else 
        %�������� �������� std�� ���� ���� std�� ����������ŭ ��ġ�� �����Ѵ�.
        nDataE1 = sum(h(1:km_idx_min));
        meanE1 = sum(h(1:km_idx_min).*histogram.xi(1:km_idx_min))/nDataE1;
        varE1 = sum(h(1:km_idx_min).*(histogram.xi(1:km_idx_min) - meanE1).^2)/(nDataE1-1);
        threshold = threshold - sqrt(varE1) * alpha;
    end
        
end