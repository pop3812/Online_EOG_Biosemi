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

% Last Modified by GUIDE v2.5 04-Nov-2014 13:57:06

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
global program_name;
global params;
global buffer;
global GDF_Header;

params.DummyMode = 0; % 0 : biosemi, 1 : Dummy
%% Dump if exist
try
	dummy = biosemix([1 0]); %실행될때마다 버퍼에서 데이터 가져오기, 일단 한번 실행하는 것.
catch me
	if strfind(me.message,'BIOSEMI device')
        params.DummyMode = 1; % 0 : biosemi, 1 : Dummy
        warndlg([me.message 'The program will be run in dummy mode.'], program_name);
        set(handles.console, 'String', 'Dummy Mode');
        clear biosemix;
    else
        rethrow(me);
	end
end

if (params.DummyMode ==0)
    params.DummyMode = 0; % 0 : biosemi, 1 : Dummy
    set(handles.console, 'String', 'Biosemi Mode');
end

%% Basic Parameter Initialization

% Experiment Parameter Settings
set_experiment_parameters();

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

% buffers
buffer.DM = online_downsample_init(params.DecimateFactor); % Online downsample buffer
buffer.buffer_4medianfilter = circlequeue(params.medianfilter_size, params.CompNum);

buffer.dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.dataqueue.data(:,:) = NaN;

buffer.raw_dataqueue   = circlequeue(params.QueueLength, params.CompNum);
buffer.raw_dataqueue.data(:,:) = NaN;

%% Initialize Biosemi
if(params.DummyMode~=1)
    warndlg('Biosemi detected. Successfully done.', program_name);
end

GDF_Header = signal_initialize_Biosemi();

%% GUI Control
set(handles.calib_button, 'Enable', 'on');
set(handles.start_button, 'Enable', 'off');
set(handles.stop_button, 'Enable', 'off');

% --- Executes on button press in calib_button.
function calib_button_Callback(hObject, eventdata, handles)
% hObject    handle to calib_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global program_name;
global g_handles;

g_handles = handles;

% GUI Control
set(handles.initialize_button, 'Enable', 'off');
set(handles.start_button, 'Enable', 'off');
set(handles.stop_button, 'Enable', 'off');

data_calibration();

% GUI Control
set(handles.initialize_button, 'Enable', 'on');
set(handles.calib_button, 'Enable', 'on');
set(handles.start_button, 'Enable', 'on');
set(handles.stop_button, 'Enable', 'off');
warndlg('Calibration has been successfully done.', program_name);


% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global program_name;
global g_handles;
global timer_id_data;
global params;

g_handles = handles;

timer_id_data= timer('TimerFcn','data_processing', ...
        'StartDelay', 0, 'Period', params.DelayTime, 'ExecutionMode', 'FixedRate');

choice = questdlg('Do you want to start data acquisition?', program_name, ...
    'Yes', 'No', 'Yes');

switch choice
    case 'Yes'        
        start(timer_id_data);
        
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

choice = questdlg('Do you want to stop data acquisition?', program_name, ...
    'Yes', 'No', 'No');

switch choice
    case 'Yes'
        clear biosemix;
        stop(timer_id_data);
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        set(handles.initialize_button, 'Enable', 'on');
        set(handles.calib_button, 'Enable', 'on');
        warndlg('Data acquisition has been stopped.', program_name);

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
global GDF_Header;

[file, path] = uiputfile('*.mat', 'Save Current Experiment Parameters and Results As');
save_path = fullfile(path, file);

if ~isequal(file, 0)
    try
        save(save_path, 'GDF_Header');
    catch me
        errordlg(me.message, program_name);
    end
    
%     axes(handles.current_signal);
%     img  = getframe(gca);
%     try
%         imwrite(img.cdata,save_path, 'png');
%     catch me
%         errordlg(me.message, program_name);
%     end
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
global GDF_Header;

% Add function path
addpath([pwd, '\functions']);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
