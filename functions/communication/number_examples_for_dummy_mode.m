function number_examples_for_dummy_mode(num_char)
% NUMBER_EXAMPLES_FOR_DUMMY_MODE
% Generates an examplar eye-dispositions for recognition
% Only works in the dummy mode
% Input Argument
% num_char      : number that you want to generate examplar signal for
%                 e.g. '0', '1', '2', ... '9'

global params;
global buffer;

if strcmp(num_char, '0')
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 -10 -10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 0 -10 -10 0 10]';
elseif strcmp(num_char, '1') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) 10 10 10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 0 -10 -10 0 10]';
elseif strcmp(num_char, '2') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 10 -10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 10 -10 -10 -10 -10]';
elseif strcmp(num_char, '3') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 10 -10 0 10 -10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 10 0 0 -10 -10]';
elseif strcmp(num_char, '4') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 -10 10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 0 0 -10 -10 -10]';
elseif strcmp(num_char, '5')
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) 10 -10 -10 10 10 -10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 0 0 0 0 -10]';
elseif strcmp(num_char, '6') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 -10 -10 -10 10 -10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 0 -10 -10 -10 0]';
elseif strcmp(num_char, '7') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 10 10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 10 0 -10 -10 -10]';
elseif strcmp(num_char, '8') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) -10 10 10 -10 -10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 10 -10 -10 -10 -10 10]';
elseif strcmp(num_char, '9') 
    buffer.X_train = [linspace(0, 0, params.CalibrationTime) 10 10 -10 10 10 10]';
    buffer.Y_train = [linspace(0, 0, params.CalibrationTime) 0 0 10 10 0 -10]';
end

end

