clc; clear; clf;
file_path = 'C:\Users\User\Documents\GitHub\Data\20141223_LeeKR\raw\';
file_name = 'data_2.mat';

global params;
load([file_path file_name]);

%% Parameter
params.rect = File_Header.ExperimentParameters.rect;
params.screen_distance = File_Header.ExperimentParameters.screen_distance;
params.screen_width = File_Header.ExperimentParameters.screen_width;
params.screen_height = File_Header.ExperimentParameters.screen_height;

subplot_n_col = 8;
D_Rate = 64;

deg_bound = 50;
deg_bound_pix_x = screen_degree_to_pixel('X', deg_bound);
deg_bound_pix_y = screen_degree_to_pixel('Y', deg_bound);
deg_bound_pix_x_neg = screen_degree_to_pixel('X', -deg_bound);
deg_bound_pix_y_neg = screen_degree_to_pixel('Y', -deg_bound);

%% Buffer Setting

Data = File_Header.SessionData;
key_rect = File_Header.ExperimentBuffers.key_rect;
N_Session = size(Data, 1);

subplot_n_row = ceil(N_Session/subplot_n_col);

%% Data Retrieve
for i_session = 1:N_Session

    thePoints = Data{i_session}.eye_position_queue;

    [numPoints, two]=size(thePoints);
    
    clear NormalizedPoints;
    thePoints(isnan(thePoints(:, 1)) | isnan(thePoints(:, 2)), :) = [];
    thePoints(thePoints(:, 1)<=deg_bound_pix_x_neg | thePoints(:, 1)>=deg_bound_pix_x, :) = [];
    thePoints(thePoints(:, 2)>=deg_bound_pix_y_neg | thePoints(:, 2)<=deg_bound_pix_y, :) = [];
    
    
    %% Eye Position Normailization
    AbsolutePoints = [thePoints(:,1), thePoints(:,2)];

    % Position Normalization
    NormalizedPoints(:,1) = AbsolutePoints(:,1) - ((max(AbsolutePoints(:,1))+min(AbsolutePoints(:,1)))/2);
    NormalizedPoints(:,2) = AbsolutePoints(:,2) - ((max(AbsolutePoints(:,2))+min(AbsolutePoints(:,2)))/2);

    % Size Normalization
    x_width = max(NormalizedPoints(:,1))-min(NormalizedPoints(:,1));
    y_width = max(NormalizedPoints(:,2))-min(NormalizedPoints(:,2));
    width = max([x_width, y_width]);
    if size(NormalizedPoints, 1) > 0
        NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
        NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);
    end
    
    %% Save Normalized Eye Position
    Normalized_Positions{i_session, 1} = NormalizedPoints;
    
    %% Downsampling for Displaying
    if size(NormalizedPoints, 1) > D_Rate
        DispPoints = [NormalizedPoints(1:D_Rate:end,1), NormalizedPoints(1:D_Rate:end,2)];
    else
        DispPoints = [];
    end
    
    Disp_Positions{i_session, 1} = DispPoints;
end

%% Visualization

figure(1);

for i_session = 1:N_Session
    
    n_color = 256;
    [n_size, two] = size(Disp_Positions{i_session, 1});
    
    if n_size > 1
        
        % Distance Calculation
        Disp_X = Disp_Positions{i_session, 1}(:, 1);
        Disp_Y = Disp_Positions{i_session, 1}(:, 2);

        d_X = diff(Disp_X);
        d_Y = diff(Disp_Y);

        trail_dist = sqrt(d_X.^2 + d_Y.^2);
        trail_dist = cumsum(trail_dist);

        trail_dist = n_color/trail_dist(end) * trail_dist;

        % Displaying Preparation

        cc = jet(n_color);
        cc = flipud(cc);
        [numPoints, two]=size(Disp_X);

        subaxis(subplot_n_row, subplot_n_col, i_session, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
        for i = 1:numPoints-1
            color_idx = ceil(trail_dist(i));

            plot([Disp_X(i), Disp_X(i+1)], ...
                [Disp_Y(i), Disp_Y(i+1)], ...
                '-', 'LineWidth', 3, 'Color', cc(color_idx, :));
            hold on;

        end
        xlim([-0.5 0.5]); ylim([-0.5 0.5]); axis('tight'); axis('off');
        text(0.01, 0.95, num2str(i_session), 'Unit', 'normalized', 'FontSize', 8);
    end
        

    
%     subaxis(subplot_n_row, subplot_n_col, i_session, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
%     plot(Normalized_Positions{i_session}(:, 1), Normalized_Positions{i_session}(:, 2), '-k', 'LineWidth', 2);
%     xlim([-0.5 0.5]); ylim([-0.5 0.5]); axis('tight'); axis('off');
%     set(gca,'xtick',[]); set(gca,'xticklabel',[]);
%     set(gca,'ytick',[]); set(gca,'yticklabel',[]);
end