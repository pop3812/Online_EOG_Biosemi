% MSDW2minmaxdiff_online
% MSDW2minmaxdiff �� �¶��� ���� �Լ�
%
% msdw �� ���� ���¿��� ������ threshold ���� ������ �� �ֵ��� minmax �� ���� ���·� �ٲ۴�.
% local minimum�� ���Ӱ� insert �� ������ ȣ��Ǿ�� �Ѵ�.
%
% msdw: msdw (circlequeue type)
% max_windowwidth: msdw ��꿡�� ���� window�� ũ��
% indexes_localMin: msdw �� local min�� ����ִ� circlequeue
% indexes_localMax: msdw �� local max�� ����ִ� circlequeue
%
% minmaxdiff: circlequeue type�� output (handle �����̱� ������ return�� �ʿ� ����)
%
function MSDW2minmaxdiff_online(msdw, max_windowwidth, indexes_localMin, indexes_localMax, minmaxdiff)
    
    if indexes_localMin.datasize<1 || indexes_localMax.datasize<1
        return;
    end
    

    %���� �ֱ��� local min�� ���ؼ� msdw�� min-max difference ���·� conversion �Ѵ�. (���⼭
    %max�� min�� �տ� �����ϴ� max�̸�, min-max �� index ���̰� max_windowwidth ���� Ŀ����
    %�ȵȴ�.
    min_id = indexes_localMin.getLast();
    nPrevLocalMax = indexes_localMax.datasize;
    
    for j=1:nPrevLocalMax % ���⼭ j�� prev_max �� reversed id�� �ȴ�.
        max_id = indexes_localMax.get_fromEnd(j);
        if min_id - max_id > max_windowwidth  %min-max �� index ���̰� max_windowwidth ���� ũ�� �����
            break;
        end
        tmp_minmaxdiff = msdw.get(max_id) - msdw.get(min_id);
        if j==1
            minmaxdiff.add(tmp_minmaxdiff);
        elseif tmp_minmaxdiff> minmaxdiff.getLast()
            minmaxdiff.data(minmaxdiff.index_end,:) = tmp_minmaxdiff;
        end
    end

end