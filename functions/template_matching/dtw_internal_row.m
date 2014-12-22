%----------------------------------------------------------------------
% [table_p] = dtw_internal_row(data_ref, data_test_row, table_p,test_index, sc, table_local_dist_p, bCDP, bDataVector, bDPW, v_ref_p,v_test_p)
%
% calculate DP table for a test data
% �ϳ��� test �����Ϳ� ���� table�� ����Ѵ�.
% ref: reference data set (1 pattern)
% test: test data (1 row)
% table_index: the index of table to calculate
% sc: slope constraint
%
% bDataVector: parameter�� �Ѿ�� data�� �̺е� �������� ��Ÿ����. �̺е� ���� ��� CDP �� starting
% point ���� �Ÿ���� ������� ���̰� ���� �ȴ�.
% max_jump_Test, max_jump_Ref: diamond ���·� path�� �����ؼ� �ӵ��� ������ �ϱ� ���Ͽ� �ʿ��ϴ�.
% ���� ����(skip)�� �� �ִ� �ִ� ���� ������ �ǹ��Ѵ�. �� slope�� ���̰� 2�� ��� �� ���� 1�� �ȴ�.
% max_jump_Test, max_jump_Ref �� ũ�Ⱑ �ٸ� ��쿡 ���ؼ��� ���� �ڵ尡 �������� �ʾ����Ƿ�, ��а� �� ��
% ���� ���� ũ��� �ؼ� ����ϵ��� �Ѵ�.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [table_p] = dtw_internal_row(data_ref, data_test_row, table_p,test_index, sc, table_local_dist_p, bCDP, bDataVector, bDPW, v_ref_p,v_test_p,max_jump_Test, max_jump_Ref)
    if nargin<9
        bDPW = 0;
    end
    if nargin<10 || bCDP == 1
        bFast = 0;
    else
        bFast = 1;
    end
    %�ʱ�ȭ
    size_ref  = size(data_ref,1);
    size_sc = size(sc,2);
    size_test = size(table_p,2);
    
    if(test_index ==1)
        table_p(1,test_index) = norm(data_ref(1,:)- data_test_row); %������ ���
    end
    
    j = test_index;
    
    %speed-up window
    if bFast ==0
        r_start = 1;
        r_end = size_ref;
    else
        tmp = j-size_test;
        r_start = max(ceil((1/(max_jump_Ref+1))*(j-1))+1, size_ref + (max_jump_Test+1)*tmp);
        r_end = min((max_jump_Test+1)*j-1, ceil((1/(max_jump_Ref+1))*tmp+size_ref));
    end
            
    for i=r_start:r_end
       if(i==1 && j==1)    %1,1 �������� �̸� ����ϰ� ���⼭�� skip �Ѵ�
            continue;
       end

      
        %������ branch�� ���� �Ÿ��� ����Ͽ� �ּҰ� ����
        if bCDP==1 && i == 1   % CDP �̰� �� �Ʒ����� ��� �������� �� �� �ֵ��� min dist�� �����Ͽ� ���´�.
            if bDPW == 0
                if bDataVector==1   %�̺е� ���� ��� �������� 
                    min_dist = 0;
                else
                    min_dist = table_local_dist_p(i, j);
                end
            else
                min_dist = 0;   %DPW�̰� CDP�� ��� �������� �Ÿ��� 0���� �� �־�� �Ѵ�.
                %min_dist = norm(data_ref(1,:)- data_test_row); % DPW �� ��� �������� ���Ͱ� �ƴ� �� �����Ϳ��� �ϹǷ�, ���� �Ÿ� ���
            end
        else                   % �Ϲ����� ��� min_dist �� ���Ѵ�
            min_dist = Inf;
        end
        
        for k = 1: size_sc
            dist = 0;
            size_branch = size(sc{k},2);
            
            %�귣ġ�� leaf�� �������� ũ�⸦ ����Ѵ�
            len_branch_ref = sc{k}{size_branch}(1);
            len_branch_test = sc{k}{size_branch}(2);
            
            %Leaf ����� ���. leaf ����� ��쿡�� DPW�� ���̰� ����
            if(i- len_branch_ref<1 || j-len_branch_test<1 )    %branch�� ���̺� ������ ���������� ���
                dist = Inf;
            else
                dist = dist + table_p(i- len_branch_ref, j-len_branch_test);
            end
            
            % �߰� ����  root�� ��� DPW �� �Ϲ����� ��츦 ������ ó���Ѵ�.
            if bDPW ==0
                for m=1:size_branch-1   % �߰� ����� ���. 
                    branchDist_from_root = sc{k}{m};
                    refID_branchPosition = i - branchDist_from_root(1);
                    testID_branchPosition = j - branchDist_from_root(2);
                
                    if(refID_branchPosition <1 || testID_branchPosition<1 )    %branch�� ���̺� ������ ���������� ���
                        dist = Inf;
                    else
                        dist = dist + table_local_dist_p(refID_branchPosition,  testID_branchPosition);  %�̸� ����� �� local dist �� ����Ѵ�                  
                    end
                end
                
                % root
                dist = dist+table_local_dist_p(i,j);
            else
                for m=0:size_branch-1   % �߰� ����� ���. 
                    if m==0 % root ó��
                        branchDist_from_root = [0 0];
                    else
                        branchDist_from_root = sc{k}{m};
                    end
                    refID_branchPosition = i - branchDist_from_root(1);
                    testID_branchPosition = j - branchDist_from_root(2);
                    if(refID_branchPosition <1 || testID_branchPosition<1 )    %branch�� ���̺� ������ ���������� ���
                        dist = Inf;
                    else
                        data4dpw_ref = v_ref_p(len_branch_ref - branchDist_from_root(1),refID_branchPosition);    %�ش� branch ITEM ���� branchDist_from_leaf ��ŭ ������ �����Ϳ��� ���̸� ���
                        data4dpw_test = v_test_p(len_branch_test - branchDist_from_root(2),testID_branchPosition);    %�ش� branch ITEM ���� branchDist_from_leaf ��ŭ ������ �����Ϳ��� ���̸� ���            
                        dist = dist + norm(data4dpw_ref - data4dpw_test); 
                    end
                end
            end
            
            
               
            if(dist<min_dist)
                min_dist =dist;
            end
            table_p(i, j) = min_dist;
        end
    end
end
