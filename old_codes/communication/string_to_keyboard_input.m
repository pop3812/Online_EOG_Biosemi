function string_to_keyboard_input(keys)
%STRING_TO_KEYBOARD_INPUT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    disp('Invalid Keyboard Input to string_to_keyboard_input function.');

else
    
sound_path = [pwd, '\resources\sound\'];

key = keys;

pause(0.2);
if str2double(key) < 10 && str2double(key) >= 0
    [calling, callingFs] = eval(['audioread([sound_path, ''phone_', key, '.wav'']);']);
    sound(calling, callingFs);

elseif strcmp(key, 'ENTER')
    [calling, callingFs] = audioread([sound_path, 'phone_connect.wav']);
    sound(calling, callingFs);
    key = '~';
elseif strcmp(key, 'BACKSPACE')
    [calling, callingFs] = audioread([sound_path, 'phone_backspace.wav']);
    sound(calling, callingFs);
    key = '!';
else
%     [calling, callingFs] = audioread([sound_path, 'phone_backspace.wav']);
%     sound(calling, callingFs);
    key = '';
end

SendKeys(key);

end
