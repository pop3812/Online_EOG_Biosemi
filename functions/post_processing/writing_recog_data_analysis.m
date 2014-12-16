clc; clear;
file_path = 'C:\Users\User\Documents\GitHub\Data\';
file_name = 'char_4.mat';

global params;
load([file_path file_name]);

%% Parameter
params.rect = File_Header.ExperimentParameters.rect;
params.screen_distance = File_Header.ExperimentParameters.screen_distance;
params.screen_width = File_Header.ExperimentParameters.screen_width;
params.screen_height = File_Header.ExperimentParameters.screen_height;

subplot_n_col = 8;

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
    NormalizedPoints(:,1) = NormalizedPoints(:, 1)./(width);
    NormalizedPoints(:,2) = NormalizedPoints(:, 2)./(width);

    %% Save Normalized Eye Position
    Normalized_Positions{i_session, 1} = NormalizedPoints;
    
end

%% Visualization

figure(1);

for i_session = 1:N_Session
    subaxis(subplot_n_row, subplot_n_col, i_session, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0);
    plot(Normalized_Positions{i_session}(:, 1), Normalized_Positions{i_session}(:, 2), '-k', 'LineWidth', 2);
    xlim([-0.5 0.5]); ylim([-0.5 0.5]); axis('tight'); axis('off');
%     set(gca,'xtick',[]); set(gca,'xticklabel',[]);
%     set(gca,'ytick',[]); set(gca,'yticklabel',[]);
end