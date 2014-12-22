%----------------------------------------------------------------------
% CDP Implementation
%
% [dist, table, match_pair, nPair]=cdp(ref,test, slope_mode, max_slope_length, threshold, bVector, bDPW)
%
% slope_mode = 0: normal mode, 1 : square shape, 2: test-jump, 3: ref_jump
% please read following paper if you want to understand more
% Won-Du Chang, Jungpil Shin, "DPW Approach for Random Forgery Problem in Online Handwritten Signature Verification," Proc.NCM 2008, Gyeongju, Korea Republic, Sep. 2008.
% H. Kameya, S. Mori, R. Oka, "A segmentation-free biometric writer verification method based on continuous dynamic programming," Pattern Recognition Letters, 2006
%
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------

function [dist, table, match_pair, nPair]=cdp(ref,test, slope_mode, max_slope_length, threshold, bVector, bDPW)
    if(nargin<6)
        bVector = 0;
    end
    if(nargin<7)
        bDPW = 0;
    end
    sc = dtw_slope_generation(slope_mode, max_slope_length);        % ������ ����
    nTemplate = size(ref,2); %reference data set�� ����
    nTest= size(test,1); %test data row�� ����
    nWidth = size(test,1);  %DP table�� �ʺ�. �ʹ� �о ������ �Ǵ� ��� circle queue �� ��ȯ�Ͽ��� �Ѵ�.
    table = cell(1,nTemplate);
    match_pair = cell(nTemplate,nTest);  % backtracking data 
    nPair = zeros(nTemplate,nTest);  % backtracking data 
    table_local_dist = cell(1, nTemplate);
    
    bCDP = 1;
    
    %�ʱ�ȭ
    for i=1:nTemplate
        nPoint = size(ref{i},1);
        table{i} = ones(nPoint,nWidth).*Inf;
%        if(slope_mode==1) % square mode �� ���. 
%            table_local_dist{i} = norm(ref{i}(1,:) - test(1,:));
%        else
            table_local_dist{i} = cal_table_local_dist(ref{i},test,0);
%        end
    end
 
    

    %DPW ����� ��� vector���� �ܰ躰�� ����ؾ� �Ѵ�.
    if(bDPW ==1)    
        v_ref = cell(1,nTemplate);
        for i=1:nTemplate
            v_ref{i} = dpw_preprocessing( ref{i}, max_slope_length );
        end
        v_test = dpw_preprocessing( test, max_slope_length );
        
    end
    
    %DP ó��
    for j=1:nTest %��� Test �����Ϳ� ���ؼ�... (���� �¶������� ��ȯ�� �� �κ��� �����ؾ� ��. Online�� �ϳ��� �����Ͱ� �����Ƿ�)
        for i=1:nTemplate
            %DP Table ���
            if bDPW ==0
                tmp = dtw_internal_row(ref{i}, test(j,:),table{i},j, sc, table_local_dist{i}, bCDP,bVector, bDPW);
            else
                tmp = dtw_internal_row(ref{i}, test(j,:),table{i},j, sc, table_local_dist{i}, bCDP,bVector, bDPW, v_ref{i},v_test);
            end
            [table{i}] = tmp;
            dist = table{i}(size(ref{i},1),j);
            
            if dist<threshold
                [match_pair{i,j}, nPair(i,j)] = dtw_backtracking(table{i}, sc,j,bCDP); % backtracking and save track
            end
        end
    end
end



