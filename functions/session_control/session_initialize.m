function session_initialize()

global buffer;
global params;

buffer.n_session = 1;
buffer.session_data = cell(1, 1);

ExtendFactor = fix(1/params.DelayTime);
buffer.Calib_or_Acquisition = [ones(1, ExtendFactor*params.CalibrationTime), zeros(1, ExtendFactor*params.DataAcquisitionTime), 2.* ones(1, ExtendFactor*params.ResultShowTime)];

end

