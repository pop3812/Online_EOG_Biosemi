%checkLocalMinMax �Լ�
% �ֱ� 3���� �����͸� ������ local min max�� ã���ִ� �Լ�
% data �� circlequeue �������� �� ������, idx_cur�� circlequeue ���� current �������� index
% tmp_max_id, tmp_min_id, bTmpUp, bTmpDown, bMinFound �� ���ʿ� 0���� ���õǾ� �ԷµǾ��
% �ϸ�, �Լ��� �ݺ��Ǿ� ȣ��Ǹ鼭 ���� ��ȭ�ȴ�.
% indexes_localMin��  indexes_localMax �� circle queue �������� local min& max ��
% index ������ ����ȴ�.
function [tmp_max_id, tmp_min_id, bTmpUp, bTmpDown, bMinFound] = checkLocalMinMax(data, tmp_max_id, tmp_min_id, bTmpUp, bTmpDown, indexes_localMin, indexes_localMax, idx_cur)
    bMinFound = 0;
    data_recent = [ data.get(idx_cur-2), data.get(idx_cur-1), data.get(idx_cur)];
    if(data_recent(1)<data_recent(2) && data_recent(2) == data_recent(3))  %������ ���� ���������� ���� ������ flat �� ��� /-
        tmp_max_id = idx_cur-1;
        bTmpUp = 1;     bTmpDown = 0;
    elseif(data_recent(1)>data_recent(2) && data_recent(2) == data_recent(3))  %������ ���� ���������� ���� ������ flat �� ��� /-
        tmp_min_id = idx_cur-1;
        bTmpDown = 1;   bTmpUp = 0;
    elseif(data_recent(1)==data_recent(2))
        if(data_recent(2) > data_recent(3)) %������ flat�Ͽ��� ���� ������ �������� ���
            if bTmpUp==1    %������ �ö�Ծ��� ���
                indexes_localMax.add(round((idx_cur-1 + tmp_max_id)/2));
            end
            %��� �������� �ִ� ���, ������ edge ������ ��ȿ�� �Ѵ�
            %local max �� ���õ� ��쿡��, ������ edge ������ ��ȿ�� �Ѵ�
            bTmpUp =0; bTmpDown = 0;
        elseif(data_recent(2) < data_recent(3)) %������ flat�Ͽ��� ���� ������ �ö󰡴� ���
            if bTmpDown==1  %������ �����Ծ��� ���
                indexes_localMin.add(round((idx_cur-1 + tmp_min_id)/2));

                bMinFound = 1;
            end
            %��� �ö󰡰� �ִ� ���, ������ edge ������ ��ȿ�� �Ѵ�
            %local min �� ���õ� ��쿡��, ������ edge ������ ��ȿ�� �Ѵ�
            bTmpUp =0; bTmpDown = 0;
        end %��� flat �� ��쿡�� �ƹ��͵� ���� �ʴ´�.


    %�Ϲ����� local min/max detection
    elseif(data_recent(1)<data_recent(2) && data_recent(2) > data_recent(3) )
        indexes_localMax.add(idx_cur-1);

    elseif(data_recent(1)>data_recent(2) && data_recent(2) < data_recent(3))
        indexes_localMin.add(idx_cur-1);
        bMinFound = 1;
    end
end