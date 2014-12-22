function keyboard_examples_for_dummy_mode(num_char)
% NUMBER_EXAMPLES_FOR_DUMMY_MODE
% Generates an examplar eye-dispositions for recognition
% Only works in the dummy mode
% Input Argument
% num_char      : number that you want to generate examplar signal for
%                 e.g. '0', '1', '2', ... '9'

global params;
global buffer;

if strcmp(num_char, '0')
    X_pos = 20;
    Y_pos = 10;
elseif strcmp(num_char, '1') 
    X_pos = -20;
    Y_pos = 10;
elseif strcmp(num_char, '2') 
    X_pos = -10;
    Y_pos = 10;
elseif strcmp(num_char, '3') 
    X_pos = 10;
    Y_pos = 10;
elseif strcmp(num_char, '4') 
    X_pos = -20;
    Y_pos = 0;
elseif strcmp(num_char, '5')
    X_pos = -10;
    Y_pos = 0;
elseif strcmp(num_char, '6') 
    X_pos = 10;
    Y_pos = 0;
elseif strcmp(num_char, '7') 
    X_pos = -20;
    Y_pos = -10;
elseif strcmp(num_char, '8') 
    X_pos = -10;
    Y_pos = -10;
elseif strcmp(num_char, '9') 
    X_pos = 10;
    Y_pos = -10;
end

buffer.X_train = [linspace(0, 0, params.CalibrationTime) X_pos.*linspace(1, 1, params.DataAcquisitionTime)]';
buffer.Y_train = [linspace(0, 0, params.CalibrationTime) Y_pos.*linspace(1, 1, params.DataAcquisitionTime)]';

% disp(['Stimulus Example for Dummy Mode : ', num_char]);

end