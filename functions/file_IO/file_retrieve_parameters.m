function file_retrieve_parameters(File_Header)
%SIGNAL_INITIALIZE_BIOSEMI Summary of this function goes here
%   Detailed explanation goes here
global params;
global buffer;

param_names = fieldnames(File_Header.ExperimentParameters);
buffer_names = fieldnames(File_Header.ExperimentBuffers);

n_params = length(param_names);
n_buffer = length(buffer_names);

%% Parameter Setting

disp(['Loading parameter settings from a file ...' char(10)]);

if n_params > 0
    for i = 1:n_params

            params.(param_names{i}) = File_Header.ExperimentParameters.(param_names{i});

    end
end

disp(params);

%% Buffer Setting

disp(['Loading buffer settings from a file ...' char(10)]);

if n_buffer > 0
    for i = 1:n_buffer

            buffer.(buffer_names{i}) = File_Header.ExperimentBuffers.(buffer_names{i});

    end
end

disp(buffer);

%% Reset Session Data

buffer.n_session = 0;
buffer.session_data = cell(1, 1);

end