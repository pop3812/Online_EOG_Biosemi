function string_to_keyboard_input(keys)
%STRING_TO_KEYBOARD_INPUT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    disp('Invalid Keyboard Input to string_to_keyboard_input function.');

else
    n_keys = length(keys);
    sound_path = [pwd, '\resources\sound\'];

    for idx = 1:n_keys
        key = keys(idx);

        pause(0.2);
        if str2double(key) < 10 && str2double(key) >= 0
            [calling, callingFs] = eval(['audioread([sound_path, ''phone_', key, '.wav'']);']);
            sound(calling, callingFs);

        elseif strcmp(key, '~')
            [calling, callingFs] = audioread([sound_path, 'phone_connect.wav']);
            sound(calling, callingFs);

    %     elseif strcmp(key, '!')
        else
            [calling, callingFs] = audioread([sound_path, 'phone_backspace.wav']);
            sound(calling, callingFs);

        end

        SendKeys(key);

    end
    
end

end
