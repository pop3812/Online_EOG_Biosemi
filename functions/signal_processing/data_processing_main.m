function data_processing_main()

global params;
global buffer;
global g_handles;

status = buffer.Calib_or_Acquisition(1);
isLastSec = status > buffer.Calib_or_Acquisition(2);
isFirstSec = status > buffer.Calib_or_Acquisition(end);

if status == 1 % Calibration Mode
    set(g_handles.system_message, 'String', 'Calibration Mode');
    data_calibration(isFirstSec, isLastSec);
elseif status == 0 % Data Acquisition Mode
    set(g_handles.system_message, 'String', 'Data Acquisition Mode');
    data_processing();
end

buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', -1);
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

end

