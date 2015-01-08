function varargout = online_gui(varargin)
% ONLINE_GUI MATLAB code for online_gui.fig
%      ONLINE_GUI, by itself, creates a new ONLINE_GUI or raises the existing
%      singleton*.
%
%      H = ONLINE_GUI returns the handle to a new ONLINE_GUI or the handle to
%      the existing singleton*.
%
%      ONLINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONLINE_GUI.M with the given input arguments.
%
%      ONLINE_GUI('Property','Value',...) creates a new ONLINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before online_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to online_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help online_gui

% Last Modified by GUIDE v2.5 08-Jan-2015 17:38:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @online_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @online_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT

% --- Executes just before online_gui is made visible.
function online_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to online_gui (see VARARGIN)

% Choose default command line output for online_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using online_gui.
if strcmp(get(hObject,'Visible'),'off')
    axes(handles.current_signal);
    plot([0 10], [0 0], 'color', 'black');
    
    set(handles.current_position, 'XTick', []);
    set(handles.current_position, 'YTick', []);
    box(handles.current_position, 'on');
    
    set(handles.current_calibration, 'XTick', []);
    set(handles.current_calibration, 'YTick', []);
    box(handles.current_calibration, 'on');
end

% UIWAIT makes online_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = online_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in initialize_button.
function initialize_button_Callback(hObject, eventdata, handles)
% hObject    handle to initialize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear params buffer File_Header;

global program_name;
global params;
global buffer;
global File_Header;

params.DummyMode = 0; % 0 : biosemi, 1 : Dummy
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

%% Dump if exist
try
	dummy = biosemix([1 0]); %실행될때마다 버퍼에서 데이터 가져오기, 일단 한번 실행하는 것.
catch me
	if strfind(me.message,'BIOSEMI device')
        params.DummyMode = 1; % 0 : biosemi, 1 : Dummy
        
        sound(beep, Fs); % sound beep
        set(handles.system_message, 'String', ...
            strrep([me.message 'The program will be run in dummy mode.'], sprintf('\n'),'. '));
        set(handles.console, 'String', 'Dummy Mode');
        clear biosemix;
    else
        rethrow(me);
	end
end

%% Basic Parameter Initialization

% Experiment Parameter Settings
set_experiment_parameters();
set_blink_detection_parameters();

if (params.DummyMode == 0)
    sound(beep, Fs); % sound beep
    set(handles.system_message, 'String', ...
        'BIOSEMI has been detected. Initialization has been done successfully.');
    set(handles.console, 'String', 'Biosemi Mode');
elseif(params.DummyMode == 1)
    if (params.use_real_dummy == 1)
    % Get dummy sample data
    load([pwd, '\resources\sample_signal\sample_128hz_90sec.mat']);
    buffer.dummy_signal = data;
    clear data data_header;
    end
end

%% Preparing for signal acquisition

% downsampling setting for online data acquisition
params.DecimateFactor = 2048/params.SamplingFrequency2Use;
% decimation factor (sampling rate) ,1 = 2048, 2 = 1024, ...., 8 = 256 etc.
if(params.DecimateFactor==1)
    params.DownSample = 0;
    % 1 = downsample, 0 = none, Downsampleing according to Biosemi_Initialize
elseif(params.DecimateFactor>1)
    params.DownSample = 1;
end

% buffer setting for online data acquisition
params.BufferLength_Biosemi = params.SamplingFrequency2Use * params.DelayTime;
params.QueueLength = params.SamplingFrequency2Use * params.BufferTime;
params.DriftRemovalLength = params.SamplingFrequency2Use * params.CalibrationTime;

% buffers
if ~isempty(timerfind)
    stop(timerfind);
    delete(timerfind);
end
initial_buffer_initiation()

%% Initialize Biosemi

File_Header = file_initialize_Biosemi();

%% GUI Control
set(handles.calib_button, 'Enable', 'on');
set(handles.start_button, 'Enable', 'off');
set(handles.stop_button, 'Enable', 'off');

%% Initialize the Screen
screen_init_psy();

% --- Executes on button press in calib_button.
function calib_button_Callback(hObject, eventdata, handles)
% hObject    handle to calib_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global program_name;
global g_handles;

g_handles = handles;
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

set(handles.system_message, 'String', 'Calibration');

% Stop the current session
clear biosemix;

if ~isempty(timerfind)
    stop(timerfind);
    delete(timerfind);
end

% GUI Control
set(handles.initialize_button, 'Enable', 'off');
set(handles.start_button, 'Enable', 'off');
set(handles.stop_button, 'Enable', 'on');

% Data Calibration
clear biosemix;
initial_calibration();

% GUI Control
set(handles.initialize_button, 'Enable', 'on');
set(handles.calib_button, 'Enable', 'on');
set(handles.start_button, 'Enable', 'on');
set(handles.stop_button, 'Enable', 'off');

sound(beep, Fs); % sound beep
set(handles.system_message, 'String', 'Calibration has been done successfully.');


% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global program_name;
global g_handles;
global timer_id_data;
global params;
global buffer;

g_handles = handles;
[beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);

timer_id_data= timer('TimerFcn','session_control_main', ...
        'StartDelay', 0, 'Period', params.DelayTime, 'ExecutionMode', 'FixedRate');

screen_refresh_period = fix(1.0 / params.screen_refresh_frequency * 10^3)/10^3;
buffer.timer_id_displaying = timer('TimerFcn','screen_draw_trail()', ...
        'StartDelay', 0, 'Period', screen_refresh_period, 'ExecutionMode', 'FixedRate');

choice = questdlg('Do you want to start data acquisition?', program_name, ...
    'Yes', 'No', 'Yes');

switch choice
    case 'Yes'        
        start(timer_id_data);
        sound(beep, Fs); % sound beep
        
        % GUI Control
        set(handles.start_button, 'Enable', 'off');
        set(handles.stop_button, 'Enable', 'on');
        set(handles.initialize_button, 'Enable', 'off');
        set(handles.calib_button, 'Enable', 'off');
    case 'No'
        return;
end


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;
global timer_id_data;
global buffer;

choice = questdlg('Do you want to stop data acquisition?', program_name, ...
    'Yes', 'No', 'No');

switch choice
    case 'Yes'
        
        session_stop();

    case 'No'
        return;
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;
global File_Header;
global buffer;
global params;

verbose_time = strjoin(strsplit((mat2str(fix(clock))), ' '), '_');
verbose_time = strrep(verbose_time, '[', '');
verbose_time = strrep(verbose_time, ']', '');

[file, path] = uiputfile('*.mat', 'Save Current Experiment Results As', ...
                ['Online_EOG_', verbose_time]);
save_path = fullfile(path, file);

if ~isequal(file, 0)
    try
        File_Header = file_initialize_Biosemi();
        save(save_path, 'File_Header');
        set(handles.system_message, 'String', 'Data has been saved successfully.');
    catch me
        set(handles.system_message, 'String', me.message);

%         errordlg(me.message, program_name);
    end
end

% --------------------------------------------------------------------
function EmergencySaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to EmergencySaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global File_Header;
global params;

verbose_time = strjoin(strsplit((mat2str(fix(clock))), ' '), '_');
verbose_time = strrep(verbose_time, '[', '');
verbose_time = strrep(verbose_time, ']', '');

save_path = [params.emergency_save_path, 'Online_EOG_', verbose_time, '.mat'];

try
    File_Header = file_initialize_Biosemi();
    save(save_path, 'File_Header');
    set(handles.system_message, 'String', 'Data has been saved successfully.');
catch me
    set(handles.system_message, 'String', me.message);

%         errordlg(me.message, program_name);
end

% --------------------------------------------------------------------
function OpenParameterMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenParameterMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat', 'Open from a file');
save_path = fullfile(path, file);

if ~isequal(file, 0)
    try
        loaded_struct = load(save_path);
        file_retrieve_parameters(loaded_struct.File_Header);
        set(handles.system_message, 'String', ['Parameter Setting has been loaded successfully from ' file ' file.']);
        clear loaded_struct;
        
        % GUI Control
        set(handles.initialize_button, 'Enable', 'on');
        set(handles.calib_button, 'Enable', 'on');
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        
    catch me
        set(handles.system_message, 'String', me.message);

%         errordlg(me.message, program_name);
    end
end

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global program_name;

selection = questdlg(['Do you want to exit?'],...
                     program_name,...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --------------------------------------------------------------------
function SessionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SessionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function NewSetMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to NewSetMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global program_name;
    selection = questdlg(['Do you want to record a new set?'; ...
                    'You might lose the current data.'], program_name,...
                    'Yes','No','No');
    if strcmp(selection,'Yes')
        session_initialize();
        set(handles.system_message, 'String', ...
            'All session data has been reset. Prepared for new set recording.');
        
        [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
        sound(beep, Fs);
    end

% --------------------------------------------------------------------
function PrevMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrevMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    message = session_go_prev();
    set(handles.system_message, 'String', message);

    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);

% --------------------------------------------------------------------
function SessionMoveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SessionMoveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    input_num = -1;
    while ~(input_num > 0 && input_num < 30)
    x = inputdlg('Enter the number :',...
             'Move to specific session', [1 50]);
    input_num = str2num(x{:});
    end
    message = session_go_prev(input_num);
    set(handles.system_message, 'String', message);

    [beep, Fs] = audioread([pwd, '\resources\sound\alert.wav']);
    sound(beep, Fs);
   

% --------------------------------------------------------------------
function VisualizationMenu_Callback(hObject, eventdata, handles)
% hObject    handle to VisualizationMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function CalibResultsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CalibResultsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function AlphabetPlotMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to AlphabetPlotMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    draw_alphabet_set(handles);
    
%%%%%%%%%%%%%%%%%%%% Do not touch Below Here %%%%%%%%%%%%%%%%%%%%


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


function console_Callback(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of console as text
%        str2double(get(hObject,'String')) returns contents of console as a double


% --- Executes during object creation, after setting all properties.
function console_CreateFcn(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
clear biosemix;

global program_name;
program_name = 'Online EOG GUI';

global params;
global buffer;
global File_Header;

% Add function path
addpath(genpath([pwd, '\functions']));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function system_message_Callback(hObject, eventdata, handles)
% hObject    handle to system_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of system_message as text
%        str2double(get(hObject,'String')) returns contents of system_message as a double


% --- Executes during object creation, after setting all properties.
function system_message_CreateFcn(hObject, eventdata, handles)
% hObject    handle to system_message (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
