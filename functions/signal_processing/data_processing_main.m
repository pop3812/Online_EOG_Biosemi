function data_processing_main()

global params;
global buffer;
global g_handles;

status = buffer.Calib_or_Acquisition(1);
isLastSec = status > buffer.Calib_or_Acquisition(2);
isFirstSec = status > buffer.Calib_or_Acquisition(end) ...
    || buffer.Calib_or_Acquisition(end) == 2;

% isLastAcquisition = status < buffer.Calib_or_Acquisition(2);

if status == 1 % Calibration Mode
    if strcmp(buffer.timer_id_displaying.Running, 'on')
        stop(buffer.timer_id_displaying)
    end
    set(g_handles.system_message, 'String', 'Calibration Mode');
    if isFirstSec && params.DummyMode
       %%%
       number_examples_for_dummy_mode(num2str(buffer.dummy_idx(1)));
       buffer.dummy_idx = circshift(buffer.dummy_idx, -1);
       %%%
    end
    data_calibration(isFirstSec, isLastSec);
    
elseif status == 0 % Data Acquisition Mode
    if strcmp(buffer.timer_id_displaying.Running, 'off')
        start(buffer.timer_id_displaying);
    end
    set(g_handles.system_message, 'String', 'Data Acquisition Mode');
    data_processing();
elseif status == 2 % Result Showing
    num_char = number_recognition();
    string_to_keyboard_input(num_char);
end

buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', -1);
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

end

