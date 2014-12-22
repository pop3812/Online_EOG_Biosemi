%----------------------------------------------------------------------
% [dist, table, slope] = dtw(data_ref, data_test, slope_mode, max_slope_length, bDPW)
%
% Implementation of Dynamic Timew Warping
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
% slope_mode = 0: normal mode, 1 : square shape, 2: test-jump, 3: ref_jump
% please read following paper if you want to understand more
% Won-Du Chang, Jungpil Shin, "DPW Approach for Random Forgery Problem in Online Handwritten Signature Verification," Proc.NCM 2008, Gyeongju, Korea Republic, Sep. 2008.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------

function [dist, table, slope] = dtw(data_ref, data_test, slope_mode, max_slope_length, bDPW)
    if nargin<5
        bDPW = 0;
    end
    bCDP = 0;   %CDP �� ���� ����
    bDataVector = 0;    %CDP �� �ƴ� ��� data �� vector�̵� �ƴϵ� ����� ����.
    sc = dtw_slope_generation(slope_mode, max_slope_length);        % ������ ����
    %Speed Up �� ���� �ʿ��� ���� ���
    if slope_mode==0 || slope_mode ==1
        max_jump_Test = max_slope_length-1;
        max_jump_Ref = max_slope_length-1;
    elseif slope_mode ==2
        max_jump_Test = max_slope_length-1;
        max_jump_Ref = Inf;
    elseif slope_mode ==3
        max_jump_Test = Inf;
        max_jump_Ref = max_slope_length-1;
    else
    end
    
    %array ���� ���
    size_test = size(data_test,1);
    size_ref  = size(data_ref,1);
    
    
    table = ones(size_ref, size_test);                          % DP Table ����
    table = table.*Inf;                                         % �ʱ�ȭ
    
   
    %DPW ����� ��� vector���� �ܰ躰�� ����ؾ� �Ѵ�.
    if(bDPW ==1)    
        v_ref = dpw_preprocessing( data_ref, max_slope_length );
        v_test = dpw_preprocessing( data_test, max_slope_length );
    end
    
     % �ð� ������ ���� local distance ���̺� ���
     table_local_dist = cal_table_local_dist(data_ref,data_test);

    
            
    %DP Table ���
    table(1,1) = table_local_dist(1, 1);
    for j=1:size_test
        if(bDPW ==1)
            [table] = dtw_internal_row(data_ref,data_test(j,:), table, j, sc, table_local_dist, bCDP, bDataVector, bDPW, v_ref,v_test,max_jump_Test, max_jump_Ref);
        else
            [table] = dtw_internal_row(data_ref,data_test(j,:), table, j, sc, table_local_dist, bCDP, bDataVector, bDPW,[],[],max_jump_Test, max_jump_Ref);
        end
    end
    
    slope = sc;
   
    dist = table(size_ref, size_test);
  
end
%------------------------------------------------------------------------------------










