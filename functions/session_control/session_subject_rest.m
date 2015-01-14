function session_subject_rest(resting_sec)
% function for the session when subject takes a rest

global params;
global g_handles;

if nargin < 1
   resting_sec = 5; % default 5 sec
end

if resting_sec == 5
    voice_name = '5sec_rest';
elseif resting_sec == 20
    voice_name = '20sec_rest';
elseif resting_sec == 60
    voice_name = '60sec_rest';
end

if params.window ~= -1
    window = params.window;
    
    [X_center,Y_center] = RectCenter(params.rect);

    if params.default_fixation_y > 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y-3);
    elseif params.default_fixation_y <= 0
        Y = screen_degree_to_pixel('Y', params.default_fixation_y+3);
    else
        Y = Y_center;
    end

    set(g_handles.console, 'String', 'Resting');
    DrawFormattedText(window, 'Take a rest.', 'center', ...
        Y, [255, 255, 255]);
    Screen('Flip', window);
    
    [beep, Fs] = audioread([pwd, '\resources\sound\voice\' voice_name '.wav']);
    [ready_beep, Fs] = audioread([pwd, '\resources\sound\voice\beep_start_center.wav']);
    Snd('Play', beep', Fs); WaitSecs(length(beep)/Fs);
    
    WaitSecs(resting_sec);

    DrawFormattedText(window, 'Get ready.', 'center', ...
        Y, [255, 255, 255]);
    Screen('Flip', window);

    Snd('Play', ready_beep', Fs); WaitSecs(length(ready_beep)/Fs);
        
    clear biosemix;
else
    set(g_handles.console, 'String', 'Resting');
    
    [beep, Fs] = audioread([pwd, '\resources\sound\voice\' voice_name '.wav']);
    Snd('Play', beep', Fs); 
    
    WaitSecs(resting_sec);

    clear biosemix;
end
end

