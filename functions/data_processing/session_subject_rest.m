function session_subject_rest()
% function for the session when subject takes a rest

global params;
global g_handles;

if params.window ~= -1
    window = params.window;
    [cdn_beep, cdn_Fs] = audioread([pwd, '\resources\sound\count_down.wav']);
    [X_center,Y_center] = RectCenter(params.rect);

    if params.default_fixation_y > 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y-3);
    elseif params.default_fixation_y <= 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y+3);
    else
        Y = Y_center;
    end

    set(g_handles.console, 'String', 'Resting');
    DrawFormattedText(window, 'Take a rest for 10 secs.', 'center', ...
        Y, [255, 255, 255]);
    Screen('Flip', window);
    pause(10.0);

    sound(cdn_beep, cdn_Fs); % sound count down
    for remain_sec = 4:-1:1
        screen_init_psy(['Get Ready.' char(10) char(10) num2str(remain_sec) '.0 secs remaining.']);
        WaitSecs(1.0);
    end

    clear biosemix;
else
    [cdn_beep, cdn_Fs] = audioread([pwd, '\resources\sound\count_down.wav']);
    set(g_handles.console, 'String', 'Resting');
    pause(10.0);
    
    sound(cdn_beep, cdn_Fs); % sound count down
    for remain_sec = 4:-1:1
        pause(1.0);
    end
end
end

