% [mins maxs] = findLocalMinMaxs(data)
% data ���� local minmax (�� index) �� ã�� �ִ� �Լ�
% data�� zero padding ���� �Ǿ� ������ �ȵȴ�.
function [mins, maxs] = findLocalMinMaxs(data)
    
    nRow = max(size(data,1), size(data,2));
    
    mins = zeros(nRow,1);
    maxs = zeros(nRow,1);
    min_count = 0;
    max_count = 0;
    bTmpUp = 0;     bTmpDown = 0;
    for i=2:nRow-1
        %�Ϲ����� local min/max detection
        if(data(i)<data(i-1) && data(i) < data(i+1)) %min
            min_count = min_count+1;
            mins(min_count) = i;
            bTmpUp = 0;     bTmpDown = 0;
        elseif(data(i)>data(i-1) && data(i) > data(i+1)) %max
            max_count = max_count+1;
            maxs(max_count) = i;
            bTmpUp = 0;     bTmpDown = 0;
        %peak�� ��ī���� ���� ��츦 ���� ���
        elseif(data(i)>data(i-1) && data(i) == data(i+1))  %������ ���� ���������� ���� ������ flat �� ��� /-
            tmp_max_id = i;
            bTmpUp = 1;     bTmpDown = 0;
        elseif(data(i)<data(i-1) && data(i) == data(i+1))  %������ ���� ���������� ���� ������ flat �� ��� /-
            tmp_min_id = i;
            bTmpDown = 1;   bTmpUp = 0;
        elseif(data(i)==data(i-1))
            if(data(i) > data(i+1)  ) %������ flat�Ͽ��� ���� ������ �������� ���
                if bTmpUp==1  %������ �ö�Ծ��� ���
                    max_count = max_count +1;
                    maxs(max_count) = round((i + tmp_max_id)/2);
                end
                %��� �������� �ִ� ���, ������ edge ������ ��ȿ�� �Ѵ�
                %local max �� ���õ� ��쿡��, ������ edge ������ ��ȿ�� �Ѵ�
                bTmpUp =0; bTmpDown = 0;
            elseif(data(i) < data(i+1)) %������ flat�Ͽ��� ���� ������ �ö󰡴� ���
                if bTmpDown==1  %������ �����Ծ��� ���
                    min_count = min_count+1;
                    mins(min_count) = round((i + tmp_min_id)/2);
                end
                %��� �ö󰡰� �ִ� ���, ������ edge ������ ��ȿ�� �Ѵ�
                %local min �� ���õ� ��쿡��, ������ edge ������ ��ȿ�� �Ѵ�
                bTmpUp =0; bTmpDown = 0;
            end %��� flat �� ��쿡�� �ƹ��͵� ���� �ʴ´�.
        end
    end
    mins(min_count+1:nRow,:) = [];
    maxs(max_count+1:nRow,:) = [];
    
end