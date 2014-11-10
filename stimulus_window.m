function varargout = stimulus_window(varargin)
% STIMULUS_WINDOW MATLAB code for stimulus_window.fig
%      STIMULUS_WINDOW, by itself, creates a new STIMULUS_WINDOW or raises the existing
%      singleton*.
%
%      H = STIMULUS_WINDOW returns the handle to a new STIMULUS_WINDOW or the handle to
%      the existing singleton*.
%
%      STIMULUS_WINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMULUS_WINDOW.M with the given input arguments.
%
%      STIMULUS_WINDOW('Property','Value',...) creates a new STIMULUS_WINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimulus_window_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimulus_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimulus_window

% Last Modified by GUIDE v2.5 10-Nov-2014 15:33:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimulus_window_OpeningFcn, ...
                   'gui_OutputFcn',  @stimulus_window_OutputFcn, ...
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


% --- Executes just before stimulus_window is made visible.
function stimulus_window_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimulus_window (see VARARGIN)

% Choose default command line output for stimulus_window
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stimulus_window wait for user response (see UIRESUME)
% uiwait(handles.window);


% --- Outputs from this function are returned to the command line.
function varargout = stimulus_window_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
