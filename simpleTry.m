function varargout = simpleTry(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simpleTry_OpeningFcn, ...
                   'gui_OutputFcn',  @simpleTry_OutputFcn, ...
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


% --- Executes just before simpleTry is made visible.
function simpleTry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simpleTry (see VARARGIN)

handles.videoFileName = '';

% Choose default command line output for simpleTry
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.videoDisplay,'xtick',[],'ytick',[]);


% UIWAIT makes simpleTry wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simpleTry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[baseFileName, folder] = uigetfile('*.*', 'Specify an image file');

% Create the full file name.
fullVideoFileName = fullfile(folder, baseFileName);
handles.videoFileName = fullVideoFileName;
v = VideoReader(fullVideoFileName);
vidFrame = readFrame(v);
image(vidFrame, 'Parent', handles.videoDisplay);
handles.videoDisplay.Visible = 'off';
pause(1/v.FrameRate);
% Save the handles structure.
guidata(hObject,handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
v = VideoReader(handles.videoFileName);
while hasFrame(v)
    vidFrame = readFrame(v);
    image(vidFrame, 'Parent', handles.videoDisplay);
    handles.videoDisplay.Visible = 'off';
    pause(1/v.FrameRate);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[STI1,STI1_hough, edgeCounter1] = generateSTI(handles.videoFileName, 1, 'column');
image(STI1, 'Parent', handles.STI_column);
image(STI1_hough, 'Parent', handles.STI_column_hough);
set(handles.Result, 'String', '');
resultStr = get(handles.Result, 'String');
if edgeCounter1 == 0
    resultStr = strcat(resultStr, '  Find no edge in STI from column.');
    set(handles.Result, 'String', resultStr);
else
    resultStr = strcat(resultStr, '  Find 1 edge in STI from column.');
    set(handles.Result, 'String', resultStr);
end

[STI1,STI1_hough, edgeCounter2] = generateSTI(handles.videoFileName, 1, 'row');
image(STI1, 'Parent', handles.STI_row);
image(STI1_hough, 'Parent', handles.STI_row_hough);
if edgeCounter2 == 0
    resultStr = strcat(resultStr, '  Find no edge in STI from row.');
    set(handles.Result, 'String', resultStr);
else
    resultStr = strcat(resultStr, '  Find 1 edge in STI from row.');
    set(handles.Result, 'String', resultStr);
end

if(edgeCounter1 ~= 0 && edgeCounter2 == 0)
    resultStr = strcat(resultStr, ...
        '    Conclustion: Video transition is more likely to be a horizontal wiping.');
    set(handles.Result, 'String', resultStr);
elseif(edgeCounter1 == 0 && edgeCounter2 ~= 0)
    resultStr = strcat(resultStr, ...
        '    Conclustion: Video transition is more likely to be a vertical wiping.');
    set(handles.Result, 'String', resultStr);   
end


function Result_Callback(hObject, eventdata, handles)
% hObject    handle to Result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Result as text
%        str2double(get(hObject,'String')) returns contents of Result as a double


% --- Executes during object creation, after setting all properties.
function Result_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
