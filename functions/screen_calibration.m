function screen_calibration()
%SCREEN_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here

screenNumbers=Screen('Screens');

if(length(screenNumbers) > 2) % Double monitor
    % Initial Preference Setup
    Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'ConserveVRAM', 64);
    
    screenNum = 2; % Use the second monitor
    [window, rect] = Screen('OpenWindow', screenNum, 1);
    [X,Y] = RectCenter(rect);
    FixCross = [X-1,Y-10,X+1,Y+10;X-10,Y-1,X+10,Y+1];
    Screen('FillRect', window, [255, 255, 255], FixCross');
    Screen('Flip', window);
    WaitSecs(2)
    sca
end

end

