function message = session_go_prev(input_num)

global buffer;
global params;
global g_handles;

if nargin < 1
   input_num = buffer.n_session - 1;
end

if input_num > 0 && input_num <= 29
    buffer.n_session = input_num;
    message = ['Moved to the designated session. Current session # : ', num2str(buffer.n_session)];
elseif input_num <= 0
    message = ['This is the first session. Current session # : ', num2str(buffer.n_session)];
elseif input_num > 29
    message = ['You can only move to 1-29 sessions. Current session # : ', num2str(buffer.n_session)];
end

ExtendFactor = fix(1/params.DelayTime);
buffer.Calib_or_Acquisition = [ones(1, ExtendFactor*params.CalibrationTime), zeros(1, ExtendFactor*params.DataAcquisitionTime), 2.* ones(1, ExtendFactor*params.ResultShowTime)];

end

