function number_examples_for_dummy_mode(num_char)
% NUMBER_EXAMPLES_FOR_DUMMY_MODE
% Generates an examplar eye-dispositions for recognition
% Only works in the dummy mode
% Input Argument
% num_char      : number that you want to generate examplar signal for
%                 e.g. '0', '1', '2', ... '9'

global params;
global buffer;

ExtendFactor = 1/params.DelayTime;
calib_space = linspace(0, 0, ExtendFactor * params.CalibrationTime);
calib_space_y = linspace(params.default_fixation_y, params.default_fixation_y, ExtendFactor * params.CalibrationTime);
packed_space = linspace(0, 0, ExtendFactor * params.DataAcquisitionTime - 6);

if strcmp(num_char, '0')
    buffer.X_train = [calib_space -10 -10 -10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 0 -10 -10 0 10 packed_space]';
elseif strcmp(num_char, '1') 
    buffer.X_train = [calib_space 10 10 10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 0 -10 -10 0 10 packed_space]';
elseif strcmp(num_char, '2') 
    buffer.X_train = [calib_space -10 10 -10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 10 -10 -10 -10 -10 packed_space]';
elseif strcmp(num_char, '3') 
    buffer.X_train = [calib_space -10 10 -10 0 10 -10 packed_space]';
    buffer.Y_train = [calib_space_y 10 10 0 0 -10 -10 packed_space]';
elseif strcmp(num_char, '4') 
    buffer.X_train = [calib_space -10 -10 10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 0 0 -10 -10 -10 packed_space]';
elseif strcmp(num_char, '5')
    buffer.X_train = [calib_space 10 -10 -10 10 10 -10 packed_space]';
    buffer.Y_train = [calib_space_y 10 0 0 0 0 -10 packed_space]';
elseif strcmp(num_char, '6') 
    buffer.X_train = [calib_space -10 -10 -10 -10 10 -10 packed_space]';
    buffer.Y_train = [calib_space_y 10 0 -10 -10 -10 0 packed_space]';
elseif strcmp(num_char, '7') 
    buffer.X_train = [calib_space -10 10 10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 10 0 -10 -10 -10 packed_space]';
elseif strcmp(num_char, '8') 
    buffer.X_train = [calib_space -10 10 -10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 10 -10 -10 10 10 10 packed_space]';
elseif strcmp(num_char, '9') 
    buffer.X_train = [calib_space 10 10 -10 10 10 10 packed_space]';
    buffer.Y_train = [calib_space_y 0 0 10 10 0 -10 packed_space]';
end

% disp(['Stimulus Example for Dummy Mode : ', num_char]);

end

