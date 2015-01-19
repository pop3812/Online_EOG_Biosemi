function draw_alphabet_set(handles)
%DRAW_ALPHABET_SET Summary of this function goes here
%   Detailed explanation goes here

global params;
global buffer;
global g_handles;

if isfield(buffer, 'session_data') && ~isempty(buffer.session_data{1})
set(handles.system_message, 'String', 'Visualizing the Data ... Wait.');

subplot_n_col = 8;
D_Rate = 8;

%% Buffer Setting

Data = buffer.session_data;
key_rect = buffer.key_rect;
N_Session = size(Data, 1);

subplot_n_row = ceil(N_Session/subplot_n_col);

%% Data Retrieve
for i_session = 1:N_Session

    %% Normalized Eye Position
    NormalizedPoints = Data{i_session}.normalized_eye_position;
    
    %% Downsampling for Displaying
    if size(NormalizedPoints, 1) > D_Rate
        DispPoints = [NormalizedPoints(1:D_Rate:end,1), NormalizedPoints(1:D_Rate:end,2)];
    else
        DispPoints = [];
    end
    
    Disp_Positions{i_session, 1} = DispPoints;
end

%% Visualization

if isfield(g_handles, 'alphabet_plot') && ishandle(g_handles.alphabet_plot)
    figure(g_handles.alphabet_plot);
    clf(g_handles.alphabet_plot);
else
g_handles.alphabet_plot = figure('name', 'Alphabet Set Visualization', 'NumberTitle', 'off');
end

% set(g_handles.alphabet_plot, 'Color', [1, 1, 1]);

for i_session = 1:N_Session
    
    [n_size, two] = size(Disp_Positions{i_session, 1});
    
    if n_size > 1
        
        % Distance Calculation
        Disp_X = Disp_Positions{i_session, 1}(:, 1);
        Disp_Y = Disp_Positions{i_session, 1}(:, 2);

        subaxis(subplot_n_row, subplot_n_col, i_session, 'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05);
        draw_alphabet_on_plot([Disp_X Disp_Y]);
        text(-0.5, 0.95, num2str(i_session), 'Unit', 'normalized', 'FontSize', 10, 'FontWeight', 'bold');
    end

end

[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
sound(beep, Fs);

set(handles.system_message, 'String', 'Alphabet set visualization has been done.')

else
    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);

    set(handles.system_message, 'String', 'There is no data to plot.')
end

end
