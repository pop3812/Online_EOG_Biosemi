function num_char = number_recognition()
% NUMBER_RECOGNITION
% Recognizes the number from eye position information
% Code from Im and Jeon

global buffer;
global params;

%% 시작부분

%find state : 1=가로 2=왼쪽 3오른쪽

%% Parameter for the Recognition
threshold_value = 5;
VR_threshold_value = 5;

num_char = '';

%% Data Allocation from the Buffer

n_character_per_session = 1; % get this number of characters per each data acquisition session
eye_position_queue = circshift(buffer.eye_position_queue.data, -buffer.eye_position_queue.index_start+1);

n_data_sum = nansum(buffer.recent_n_data);
n_data_per_character = floor(n_data_sum / n_character_per_session);

end_idx = buffer.eye_position_queue.datasize;
eye_position_queue = eye_position_queue(end_idx-n_data_sum+1:end_idx, :);

test_Hor_Data = cell(n_character_per_session, 1);
test_VR_Data = cell(n_character_per_session, 1);

find_test_hor_point = cell(n_character_per_session, 1);
find_test_state = cell(n_character_per_session, 1);
VR_test_slope = cell(n_character_per_session, 1);

%% Eye Position Data Transfer
for i = 1:n_character_per_session
    eye_pos_Hor = eye_position_queue(n_data_per_character*(i-1)+1:n_data_per_character*i, 1)';
    eye_pos_VR = eye_position_queue(n_data_per_character*(i-1)+1:n_data_per_character*i, 2)';   
    
    % Remove NaN values
    eye_pos_Hor(isnan(eye_pos_Hor(1,:)))=[];
    eye_pos_VR(isnan(eye_pos_VR(1,:)))=[];
    
    test_Hor_Data{i} = eye_pos_Hor;
    test_VR_Data{i} = eye_pos_VR;
end

%% Horizontal Component Movement Recognition
% 1:Right 2:Left
% state=0 : Horizontal Eye-position 값이 중간인 부분 (Middle)
% state=1 : Horizontal Eye-position 값이 threshold_value 이상인 부분 (Right)
% state=2 : Horizontal Eye-position 값이 -threshold_value 이하인 부분 (Left)

for i=1:n_character_per_session
    k=1;
    state=0;
    for  j=1:length(test_Hor_Data{i}(1,:))  
       %% threshold_value 이하 지점 포인트 잡는 부분
        % -threshold_value 보다 작아지는 시점을 잡는 부분 
        if (test_Hor_Data{i}(1,j)<=-threshold_value && state==0)
           state=2;
           find_test_hor_point{i}(1,k)=j;
           find_test_hor_point{i}(2,k)=state;
           find_test_hor_point{i}(3,k)=test_Hor_Data{i}(1,j);
           k=k+1;
        end
        % -threshold_value 보다 커지는 시점을 잡는 부분 
        if(state==2 && test_Hor_Data{i}(1,j)>=-threshold_value)
          state=0;
          find_test_hor_point{i}(1,k)=j-1;
          find_test_hor_point{i}(2,k)=state;
          find_test_hor_point{i}(3,k)=test_Hor_Data{i}(1,j);
          k=k+1;
        end

       %% threshold_value 이상 지점 포인트 잡는 부분
        % threshold_value보다 커지는 시점을 잡는 부분
        if (test_Hor_Data{i}(1,j)>=threshold_value && state==0)
           state=1;
           find_test_hor_point{i}(1,k)=j;
           find_test_hor_point{i}(2,k)=state;
           find_test_hor_point{i}(3,k)=test_Hor_Data{i}(1,j);
           k=k+1;
        end
        % threshold_value보다 작아지는 시점을 잡는 부분 
        if(state==1 && test_Hor_Data{i}(1,j)<=threshold_value)
          state=0;
          find_test_hor_point{i}(1,k)=j-1;
          find_test_hor_point{i}(2,k)=state;
          find_test_hor_point{i}(3,k)=test_Hor_Data{i}(1,j);
          k=k+1;
        end
        
       %% -threshold_value ~ threshold_value 사이
        %(-threshold_value ~ threshold_value 사이 값을 찾는부분)
        if (test_Hor_Data{i}(1,j)>=-threshold_value && test_Hor_Data{i}(1,j)<=threshold_value && state==0)
           state=3;
        end
        %(-threshold_value ~ threshold_value 사이 값을 찾는부분을 벗어 난 경우
        if(state==3 && (test_Hor_Data{i}(1,j)<=-threshold_value ||test_Hor_Data{i}(1,j)>=threshold_value))
          state=0;
        end
        
    end
end
  

%% R, L Decision Making
  for i=1:n_character_per_session
      k=1;
      for j=1:2:length(find_test_hor_point{i}(2,:))
          if(j==1)
              find_test_state{i}(1,k)=find_test_hor_point{i}(2,j);
%               find_test_state{i}(2,k)=find_test_hor_point{i}(1,j);
          end
          if(find_test_state{i}(1,k)~=find_test_hor_point{i}(2,j))
%               k=k+1;
%               find_test_state{i}(1,k)=find_test_hor_point{i}(2,(j-1));
%               find_test_state{i}(2,k)=find_test_hor_point{i}(1,(j-1));
              k=k+1;
              find_test_state{i}(1,k)=find_test_hor_point{i}(2,j);
%               find_test_state{i}(2,k)=find_test_hor_point{i}(1,j);
          end
      end
  end
  
%% Vertical Component Movement Recognition 
% 0 - Not changed 1 - Upward 2 - Downward

  % length가 홀수 인 경우 보정하는 부분
  for i=1:n_character_per_session
      if(mod(length(find_test_hor_point{i}(1,:)),2)==1)
          find_test_hor_point{i}(1,length(find_test_hor_point{i}(1,:))+1)=length(test_Hor_Data{i}(1,:));
      end
  end
          
   % slope값 구하는 부분
  for i=1:n_character_per_session
      k=1;
      for j=1:2:length(find_test_hor_point{i}(1,:))
          if j == length(find_test_hor_point{i}(1,:))-1
              VR_test_slope{i}(1,k) = ...
                  test_VR_Data{i}(find_test_hor_point{i}(1,j+1)) - ...
                  test_VR_Data{i}(find_test_hor_point{i}(1,j));
          else
              VR_test_slope{i}(1,k) = ...
                  test_VR_Data{i}(find_test_hor_point{i}(1,j+2)) - ...
                  test_VR_Data{i}(find_test_hor_point{i}(1,j));
          end
          k=k+1;
      end
  end
               
   % VR Slope Categorization
   % 0 - Not changed 1 - Upward 2 - Downward
   % is categorized as 'not changed' if the disposition is smaller than threshold
   
   for i=1:n_character_per_session
       for j=1:length(VR_test_slope{i}(1,:))
           if(VR_test_slope{i}(1,j)>=VR_threshold_value) % Upward
               VR_test_slope{i}(2,j)=1;
           elseif(VR_test_slope{i}(1,j)<=-VR_threshold_value) % Downward
               VR_test_slope{i}(2,j)=2;
           else % Non-changing
               VR_test_slope{i}(2,j)=0;
           end
       end
   end

%% Pattern Recognition
% Output as a number character 

for z=1:n_character_per_session
    if (length(find_test_state{1,z}(1,:))==1) % if the legnth is 1
        % in case of 1
        num_char = '1';
    elseif (length(find_test_state{1,z}(1,:))==2) % if the legnth is 2
        if(VR_test_slope{1,z}(2,1)==2 && VR_test_slope{1,z}(2,2)==1)
            % in case of 0
            num_char = '0';
        elseif(VR_test_slope{1,z}(2,1)==2 && VR_test_slope{1,z}(2,2)==2)
            % in case of 4
            num_char = '4';
        elseif(VR_test_slope{1,z}(2,1)==0 && VR_test_slope{1,z}(2,2)==2)
            % in case of 7
            num_char = '7';         
        end
    elseif (length(find_test_state{1,z}(1,:))==3) % if the length is 3
        if(find_test_state{1,z}(1,1)==2)
            % in case of 6
            num_char = '6';
        elseif(find_test_state{1,z}(1,1)==1)
            % in case of 9
            num_char = '9';
        end  
    elseif (length(find_test_state{1,z}(1,:))==4) % if the length is 4
        if(find_test_state{1,z}(1,1)==1)
            % in case of 5 % which starts from 'R'
            num_char = '5';
        elseif(find_test_state{1,z}(1,1)==2)
            if(VR_test_slope{1,z}(2,1)==2)
                % in case of 8 % which starts from 'L'
                num_char = '8';
            elseif (VR_test_slope{1,z}(2,1)==0)
                % in case of 2
                num_char = '2';
            end
        end
       
    elseif (length(find_test_state{1,z}(1,:))==5)
        % in case of 3
        num_char = '3';
    end
        
end

disp(['Recognized number : ', num_char]);

end

