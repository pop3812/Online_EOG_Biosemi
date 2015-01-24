function [feature_matrix, slopes_x, slopes_y] = signal_feature_analysis(signal, min_n_points, x_slope_threshold, y_slope_threshold)
%SIGNAL_PLATEAU_FIND : finds plateau-like regions in the signal
% INPUT ARGUMENTS
% signal : [n_data x 2] Matrix containing EOG signal
% min_n_points : minimum length of feature to be classified not a noise
% slope_threshold : slope threshold
%
% OUTPUT
% feature_matrix : [n_data x 2] structure that contains the flag of
%           signal features (increasing, decreasing, flat, noise, blink)
%           0: flat, 1: increasing, -1: decreasing, 2: blink

min_step = 5; % in degree

[n_data, two] = size(signal);
feature_matrix = nan(n_data, 2);

%% Signal feature finding for horizontal

[dData, minmax, stats] = AnalyzeEdges(signal(:,1));
slopes_x = dData(:,end);
[dData, minmax, stats] = AnalyzeEdges(signal(:,2));
slopes_y = dData(:,end);

% Horizontal features
feature_matrix(isnan(signal(:,2)), 1) = 2; % blink
feature_matrix(slopes_x>x_slope_threshold, 1) = 1; % increasing
feature_matrix(slopes_x<-x_slope_threshold, 1) = -1; % decreasing
feature_matrix(slopes_x<=x_slope_threshold & slopes_x>=-x_slope_threshold, 1) = 0; % flat

% Vertical features 
feature_matrix(isnan(signal(:,2)), 2) = 2; % blink
feature_matrix(slopes_y>y_slope_threshold, 2) = 1; % increasing
feature_matrix(slopes_y<-y_slope_threshold, 2) = -1; % decreasing
feature_matrix(slopes_y<=y_slope_threshold & slopes_y>=-y_slope_threshold, 2) = 0; % flat

%% Eye blink vicinity check
% Check blink detected regions' vicinity

% if the left side of blink region is increasing, the increasing region
% is classified as blink (to discriminate it from upward eye gazing)

% if the right side of blink region is decreasing, the decreasing region
% is classified as blink (to discriminate it from downward eye gazing)

unknown_regions = zeros(n_data, 1);
unknown_regions(isnan(feature_matrix(:,1))) = 1;
df = diff([0; unknown_regions; 0]);

unknown_regions = struct('on',num2cell(find(df==1)), ...
    'off',num2cell(find(df==-1)-1));

[n_regions, dim] = size(unknown_regions);

for i = 1:n_regions
    % boundary check
    if unknown_regions(i).off < n_data && unknown_regions(i).on > 1
        % the leftside of the blink
        if feature_matrix(unknown_regions(i).off+1, 1) == 2
                x_flag = feature_matrix(unknown_regions(i).on-1, 1);
                y_flag = feature_matrix(unknown_regions(i).on-1, 2);
                if y_flag == 1 && abs(x_flag) ~= 1
                   x_flag = 0;
                   y_flag = 1;
                end
        
        % the rightside of the blink
        elseif feature_matrix(unknown_regions(i).on-1, 1) == 2
                x_flag = feature_matrix(unknown_regions(i).off+1, 1);
                y_flag = feature_matrix(unknown_regions(i).off+1, 2);
                if y_flag == -1  && abs(x_flag) ~= 1
                   x_flag = 2;
                   y_flag = 2;
                end
        end
        
    % out of bound blink
    else
        x_flag = 0;
        y_flag = 0;
    end

    feature_matrix(unknown_regions(i).on:unknown_regions(i).off, 1) = x_flag;
    feature_matrix(unknown_regions(i).on:unknown_regions(i).off, 2) = y_flag;
end

%% Feature extraction

% Horizontal
[xf_start_idx, xf_length, xf_end_idx, xfeatures, xn_feature] = signal_feature_info_extractor(feature_matrix(:, 1));
% Vertical
[f_start_idx, f_length, f_end_idx, features, n_feature] = signal_feature_info_extractor(feature_matrix(:, 2));


%% False increase and decrease removal (Noise)
%  noise is classified with -2: noise flag

% too short increasing or decreasing regions are classified as noise
% features (will be removed later by looking vicinity of the noise region)

% Horizontal
for i = 1:xn_feature
    sig_length = xf_length(i);
    if sig_length < min_n_points && abs(xfeatures(i)) ~= 2
        feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = -2;
    end
end

% Vertical

for i = 1:n_feature
    sig_length = f_length(i);
    if sig_length < min_n_points && abs(features(i)) ~= 2
        feature_matrix(f_start_idx(i):f_end_idx(i), 2) = -2;
    end
end

%% Feature update

% Horizontal
[xf_start_idx, xf_length, xf_end_idx, xfeatures, xn_feature] = signal_feature_info_extractor(feature_matrix(:, 1));
% Vertical
[f_start_idx, f_length, f_end_idx, features, n_feature] = signal_feature_info_extractor(feature_matrix(:, 2));

%% Eye blink vicinity re-check with noises and Vertical Noise Removal

% if the leftside of eye blink region is increasing and the rightside is
% decreasing, the whole region is classified as eye blink region.

% the regions classified as noises are re-classifed by looking the vicinity
% of them. for example, if noise region is in between increasing regions,
% it is re-classified as increasing

% Noise removal
if n_feature > 1
    if features(1)==-2
        if features(2) == 2
            feature_matrix(f_start_idx(1):f_end_idx(1), 2) = 2;
            features(1) = 2;
        else
            feature_matrix(f_start_idx(1):f_end_idx(1), 2) = 0;
            features(1) = 0;
        end
    end
    if features(end)==-2
        if features(end-1) == 2
            feature_matrix(f_start_idx(end):f_end_idx(end), 2) = 2;
            features(1) = 2;
        else
            feature_matrix(f_start_idx(end):f_end_idx(end), 2) = 0;
            features(1) = 0;
        end
    end
end

if n_feature > 3
    for i = 2:n_feature-1
        
        % Eye blink check
        if features(i) == 2
           % if left and right side remnents exist
           if (features(i-1)==1 || features(i-1)==-2) && ...
                   (features(i+1)==-1 || features(i+1)==-2)
               if isempty(find(abs(feature_matrix(f_start_idx(i-1):f_end_idx(i+1), 1)) == 1, 1))
                  feature_matrix(f_start_idx(i-1):f_end_idx(i+1), 1) = 2;
                  feature_matrix(f_start_idx(i-1):f_end_idx(i+1), 2) = 2;
                  features(i-1) = 2;
                  features(i+1) = 2;
               end
           % if leftside remnent exists
           elseif (features(i-1)==1 || features(i-1)==-2) && ...
                   (features(i+1)~=1 && features(i+1)~=-1)
               if isempty(find(abs(feature_matrix(f_start_idx(i-1):f_end_idx(i-1), 1)) == 1, 1)) && ...
                       min_step > max(signal(f_start_idx(i-1):f_end_idx(i-1), 2)) - min(signal(f_start_idx(i-1):f_end_idx(i-1), 2))
                  feature_matrix(f_start_idx(i-1):f_end_idx(i-1), 1) = 2;
                  feature_matrix(f_start_idx(i-1):f_end_idx(i-1), 2) = 2;
                  features(i-1) = 2;
               end
          % if rightside remnent exists
           elseif (features(i-1)~=1 && features(i-1)~=-1) && ...
                   (features(i+1)==-1 || features(i+1)==-2)
               if isempty(find(abs(feature_matrix(f_start_idx(i+1):f_end_idx(i+1), 1)) == 1, 1)) && ...
                       min_step > max(signal(f_start_idx(i+1):f_end_idx(i+1), 2)) - min(signal(f_start_idx(i+1):f_end_idx(i+1), 2))
                  feature_matrix(f_start_idx(i+1):f_end_idx(i+1), 1) = 2;
                  feature_matrix(f_start_idx(i+1):f_end_idx(i+1), 2) = 2;
                  features(i+1) = 2;
               end
           end
        end
        
        % Noise removal
        if features(i) == -2
           if (abs(features(i-1))==1) 
               feature_matrix(f_start_idx(i):f_end_idx(i), 2) = features(i-1);
               features(i) = features(i-1);
           elseif (abs(features(i+1))==1)
               feature_matrix(f_start_idx(i):f_end_idx(i), 2) = features(i+1);
               features(i) = features(i+1);
           elseif (features(i-1)==0 && features(i+1)==0)
               % if noise is in btw flat but changing signal (increasing)
               if min_step <= nanmean(signal(f_start_idx(i+1):f_end_idx(i+1),2)) ...
                       - nanmean(signal(f_start_idx(i+1):f_end_idx(i+1),2))
                   feature_matrix(f_start_idx(i):f_end_idx(i), 2) = 1;
                   features(i) = 1;
                   
               % if noise is in btw flat but changing signal (decreasing)  
               elseif -min_step >= nanmean(signal(f_start_idx(i+1):f_end_idx(i+1),2)) ...
                       - nanmean(signal(f_start_idx(i+1):f_end_idx(i+1),2))
                   feature_matrix(f_start_idx(i):f_end_idx(i), 2) = -1;
                   features(i) = -1;
               else
                   feature_matrix(f_start_idx(i):f_end_idx(i), 2) = 0;
                   features(i) = 0;
               end
           else
               feature_matrix(f_start_idx(i):f_end_idx(i), 2) = 2;
               features(i) = 2; 
           end
        end
        
    end
end

%% Horizontal Noise Removal (Average out)

% the regions classified as noises are re-classifed by looking the vicinity
% of them. for example, if noise region is in between increasing regions,
% it is re-classified as increasing

% Noise removal

        
if xn_feature > 1
    if xfeatures(1)==-2
        if xfeatures(2) == 2
            feature_matrix(xf_start_idx(1):xf_end_idx(1), 1) = 2;
            xfeatures(1) = 2;
        else
            feature_matrix(xf_start_idx(1):xf_end_idx(1), 1) = 0;
            xfeatures(1) = 0;
        end
    end
    if xfeatures(end)==-2
        if xfeatures(end-1) == 2
            feature_matrix(xf_start_idx(end):xf_end_idx(end), 1) = 2;
            xfeatures(end) = 2;
        else
            feature_matrix(xf_start_idx(end):xf_end_idx(end), 1) = 0;
            xfeatures(end) = 0;
        end 
    end
end
    
if xn_feature > 3
    for i = 2:xn_feature-1

        % Noise removal
        if xfeatures(i) == -2
           if (abs(xfeatures(i-1))==1) 
               feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = xfeatures(i-1);
               xfeatures(i) = xfeatures(i-1);
           elseif (abs(xfeatures(i+1))==1)
               feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = xfeatures(i+1);
               xfeatures(i) = xfeatures(i+1);
           elseif (xfeatures(i-1)==0 && xfeatures(i+1)==0)
               
               % if noise is in btw flat but changing signal (increasing)
               if min_step <= nanmean(signal(xf_start_idx(i+1):xf_end_idx(i+1),1)) ...
                       - nanmean(signal(xf_start_idx(i+1):xf_end_idx(i+1),1))
                   feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = 1;
                   xfeatures(i) = 1;
                   
               % if noise is in btw flat but changing signal (decreasing)  
               elseif -min_step >= nanmean(signal(xf_start_idx(i+1):xf_end_idx(i+1),1)) ...
                       - nanmean(signal(xf_start_idx(i+1):xf_end_idx(i+1),1))
                   feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = -1;
                   xfeatures(i) = -1;
               else
                   feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = 0;
                   xfeatures(i) = 0;
               end
               
           else
               feature_matrix(xf_start_idx(i):xf_end_idx(i), 1) = 2;
               xfeatures(i) = 2; 

           end
        end
        
    end
end

%% Feature update

% Horizontal
[xf_start_idx, xf_length, xf_end_idx, xfeatures, xn_feature] = signal_feature_info_extractor(feature_matrix(:, 1));
% Vertical
[f_start_idx, f_length, f_end_idx, features, n_feature] = signal_feature_info_extractor(feature_matrix(:, 2));

%% End point blink removal

% the blink is not detected well at the end of the signal as only
% increasing part of blink signal is recorded. thus, if vertical signal is
% abruptly increasing after long period of gaze fixation, the region should be
% classified as blink region.

if n_feature > 1
   if features(n_feature) == 1 && (features(n_feature-1) == 0 || features(n_feature-1) == 2) && xn_feature > 1
      cut_min_idx =  f_start_idx(n_feature-1);
      cut_idx = n_data;
      
      
      for i = xn_feature-1:-1:1
          % if x is changing
          if abs(xfeatures(i)) == 1
             cut_idx = xf_start_idx(i+1);
             break;
          end
              
          % if x is all flat
          if xf_start_idx(i) < cut_min_idx
              cut_idx = cut_min_idx;
              break; 
          end
      end
      
        % judge if the gaze fixation period is long enough
        if cut_idx <= f_start_idx(n_feature)

            fixation_length = f_start_idx(n_feature) - cut_idx + 1;
            if fixation_length > 128 % minimum : 1 sec
                feature_matrix(f_start_idx(n_feature):n_data, 1) = 2;
                feature_matrix(f_start_idx(n_feature):n_data, 2) = 2;
            end
        end
   end
end

end


