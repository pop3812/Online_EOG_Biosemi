%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calMultiSDW_onebyone
%
% �¶��� ������ calMultiSDW
% calMultiSDW �� �����ϳ�, ���� �ֱٿ� ���� �����͸� ����Ͽ� msdw�� �߰��� ����Ѵ�.
% �Ķ���� data, v_data, acc_v �� ��� circlequeue type�̸� idx_cur�� circule queue�� �ܺ� index ��ȣ,
%return ���� ������ ������ msdw�� window size�̴�.
%
function [ msdw, windowSize4msdw, v_data, acc_v ] = calMultiSDW_onebyone( data, v_data, acc_v, min_windowwidth, max_windowwidth )
    %�����Ͱ� ������� ���� ��� empty matrix�� �����Ѵ�
    msdw = [];
    windowSize4msdw = [];

    if v_data.datasize==0
        v_data.add(0);
        acc_v.add(0);
        return;
    end

    v_data.add(data.getLast() - data.get_fromEnd(2));
    acc_v.add (acc_v.getLast()+v_data.getLast());
    
    if v_data.datasize==1   %���� ������������ ����� �� ���� ���
        return;
    end
    
    windowSize4msdw = 0;

    % window width�� ��ȭ��Ű�� �� �� ������������ ���밪�� �ִ밡 �ǰ� �ϴ� window size�� �� ���� ������������ ����Ѵ�.
    %�̶� �� ���� ������ �¾ƾ� �Ѵ�. 1.���⼺�� �¾ƾ� �Ѵ�. �� ������ ������ �ٲ�� ���� ¦������ ��츸 ����Ѵ�
    %                               2.�������� �����Ϳ� window width ������ ������ ���̿� �� �������� ���� ������ ����� �����Ͱ� �־�� �ȵȴ�.
    max_abs_window_acc_v = 0; 
    sign_change_counter = 0;
    prev_sign = v_data.getLast();
    bBiggerDataFound    = 0;
    bSmallerDataFound   = 0;
    for j = 1:max_windowwidth-1
        sign = v_data.get_fromEnd(j+1);
        if isempty(sign)
            break;
        end

        %if(idx_cur-j-1>0) %���� isEmpty ���� ������
            if(sign*prev_sign <0)
                sign_change_counter = sign_change_counter+1;
            end

            %2.�������� �����Ϳ� window width ������ ������ ���̿� �� �������� ���� ������ �����
            % �����Ͱ� �־�� �ȵȴ�. �̸� üũ�ϰ� �߽߰ÿ��� ��ٷ� ���߸�, max id �� ã������ ���� ����
            % ��쿡�� �ּ� window size��  max id�� ������ �ش�.
            %if(v_data.get(idx_cur)<v_data.get(idx_cur-j))       
            if(v_data.getLast()<v_data.get_fromEnd(j+1))       
                bBiggerDataFound = 1;   
            %elseif(v_data.get(idx_cur)>v_data.get(idx_cur-j))   
            elseif(v_data.getLast()>v_data.get_fromEnd(j+1))   
                bSmallerDataFound = 1;   
            end
            if bBiggerDataFound *bSmallerDataFound==1
                break;
            end

            %abs_win_acc_v = abs(acc_v.get(idx_cur) - acc_v.get(idx_cur-j-1));
            abs_win_acc_v = abs(acc_v.getLast() - acc_v.get_fromEnd(j+1));
            %if (j>=min_windowwidth && abs_win_acc_v> max_abs_window_acc_v && mod(sign_change_counter,2)==0 && v_data.get(idx_cur)*v_data.get(idx_cur-j)>=0 )   %���⼺�� �°� min max ���� ���� �ִ� �͵� �� �ִ밪 % bug_fixed. however, it should be checked again
            if (j>=min_windowwidth && abs_win_acc_v> max_abs_window_acc_v && mod(sign_change_counter,2)==0 && v_data.getLast()*v_data.get_fromEnd(j+1)>=0 )   %���⼺�� �°� min max ���� ���� �ִ� �͵� �� �ִ밪 % bug_fixed. however, it should be checked again
                max_abs_window_acc_v = abs_win_acc_v;
                windowSize4msdw= j+1;
            end
            if(sign~=0)
                prev_sign = sign;
            end
       % end
    end
    if windowSize4msdw==0
        windowSize4msdw = min_windowwidth;
    end

    tmp = acc_v.get_fromEnd(windowSize4msdw);
    if isempty(tmp)
        msdw = 0;
    else
        msdw = acc_v.getLast() - acc_v.get_fromEnd(windowSize4msdw);
    end


end

