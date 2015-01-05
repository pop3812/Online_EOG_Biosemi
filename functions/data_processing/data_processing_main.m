function data_processing_main()

global params;
global buffer;
global g_handles;
global timer_id_data;

status = buffer.Calib_or_Acquisition(1);
isLastSec = status > buffer.Calib_or_Acquisition(2);
isFirstSec = status > buffer.Calib_or_Acquisition(end) ...
    || buffer.Calib_or_Acquisition(end) == 2;

isFirstResultShowing = (status - buffer.Calib_or_Acquisition(end) == 2);
isLastResultShowing = (status == 2 && buffer.Calib_or_Acquisition(2) == 1);

if status == 1 % Calibration Mode
    if strcmp(buffer.timer_id_displaying.Running, 'on')
        stop(buffer.timer_id_displaying)
    end
    
    if isFirstSec && ~buffer.Recalibration_status
        set(g_handles.system_message, 'String', 'Calibration Mode');
        buffer.n_session = buffer.n_session + 1;
        set(g_handles.console, 'String', ['Session # : ' num2str(buffer.n_session)]);
        if params.DummyMode
           %%%
           number_examples_for_dummy_mode(num2str(buffer.dummy_idx(1)));
           buffer.dummy_idx = circshift(buffer.dummy_idx, -1);
           %%%
        end
    elseif isFirstSec && buffer.Recalibration_status
        set(g_handles.system_message, 'String', 'Re-do Calibration Mode');
    end

    session_calibration(isFirstSec, isLastSec);
    
elseif status == 0 % Data Acquisition Mode
    if strcmp(buffer.timer_id_displaying.Running, 'off')
        start(buffer.timer_id_displaying);
    end
    set(g_handles.system_message, 'String', 'Data Acquisition Mode');
    session_data_acquisition();
    
elseif status == 2 % Result Showing
    if isFirstResultShowing
        set(g_handles.system_message, 'String', 'Result Showing Mode');
        
        % Sound Beep
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs); % sound beep
        
        if strcmp(buffer.timer_id_displaying.Running, 'on')
            stop(buffer.timer_id_displaying)
        end
        
        session_retrieve_data();
        draw_touchscreen_trail();
        
    end
    
    % Check User's Feedback
    if isLastResultShowing
        stop(timer_id_data);
        
        FlushEvents('keyDown');
        ListenChar(2);
        str_input = GetChar;
        disp(['User Input : ', str_input]);
        ListenChar(0);
        
        % Reject
        if strcmp(str_input, 'X') || strcmp(str_input, 'x') 
            buffer.n_session = buffer.n_session - 1;
            str_show = 'The previous session was rejected.';
            disp(str_show);
            screen_init_psy(str_show);
            WaitSecs(1.0);
        end
        
        start(timer_id_data);
    end

%     num_char = number_recognition();
%     string_to_keyboard_input(buffer.selected_key);
end

buffer.Calib_or_Acquisition = circshift(buffer.Calib_or_Acquisition', -1);
buffer.Calib_or_Acquisition = buffer.Calib_or_Acquisition';

end

