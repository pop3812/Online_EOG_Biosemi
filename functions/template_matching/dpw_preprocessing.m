%----------------------------------------------------------------------
% [ v_data ] = dpw_preprocessing( data, max_slope_length )
%
% DPW�� ���� Preprocessing
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Post-Doc @  Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [ v_data ] = dpw_preprocessing( data, max_slope_length )
    %array ���� ���
    size_data = size(data,1);
    dim = size(data,2);
   
    %DPW ����� ��� vector���� �ܰ躰�� ����ؾ� �Ѵ�.
    v_data = zeros(max_slope_length,size_data,dim);
    for i=1:max_slope_length
        for j=i+1:size_data
            v_data(i,j,:) = data(j,:) - data(j-i,:);
        end

    end
end

