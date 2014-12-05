function data_processing_main()

global params;
global buffer;
global g_handles;

status = buffer.Calib_or_Acquisition(1);
isLastSec = status > buffer.Calib_or_Acquisition(2);
isFirstSec = status > buffer.Calib_or_Acquisition(end) ...
    || buffer.Calib_or_Acquisition(end) == 2;

isFirstResultShowing = (status - buffer.Calib_or_Acquisition(end) == 2);

if status == 1 % Calibration Mode
    if strcmp(buffer.timer_id_displaying.Running, 'on')
        stop(buffer.timer_id_displaying)
    end
    set(g_handles.system_message, 'String', 'Calibration Mode');
    if isFirstSec
       buffer.n_session = buffer.n_session + 1;
       set(g_handles.console, 'String', ['Session # : ' num2str(buffer.n_session)]);
       if params.DummyMode
           %%%
           number_examples_for_dummy_mode(num2str(buffer.dummy_idx(1)));
           buffer.dummy_idx = circshift(buffer.dummy_idx, -1);
           %%%
       end
    end
    
    if isLastSec
        % Sound Beep
        [beep, Fs] = audioread([pwd, '\resources\sound\beep.wav']);
        sound(beep, Fs); % sound beep
        buffer.calibration_end_idx = buffer.dataqueue.index_end;
    end
    data_calibration(isFirstSec, isLastSec);
    
elseif status == 0 % Data Acquisition Mode
    if strcmp(buffer.timer_id_displaying.Running, 'off')
        start(buffer.timer_id_displaying);
    end
    set(g_handles.system_message, 'String', 'Data Acquisition Mode');
    data_processing();
    
elseif status == 2 % Result Showing
    if isFirstResultShowing
        
        % Sound Beep
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs); % sound beep
        
        if strcmp(buffer.timer_id_displaying.Running, 'on')
            stop(buffer.timer_id_displaying)
        end
        retrieve_session_data();
        draw_touchscreen_trail();

        buffer.recent_n_data = zeros(fix(1/params.DelayTime)*params.DataAcquisitionTime, 1);
    end
%     num_char = number_recognition();
%     string_to_keyboard_input(buffer.selected_key);
end

buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', -1);
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

end

