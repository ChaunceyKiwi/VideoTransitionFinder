function varargout = videoWipeFinder(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @videoWipeFinder_OpeningFcn, ...
                   'gui_OutputFcn',  @videoWipeFinder_OutputFcn, ...
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

% --- Executes just before videoWipeFinder is made visible.
function videoWipeFinder_OpeningFcn(hObject, eventdata, handles, varargin)
handles.videoFileName = '';

% Choose default command line output for videoWipeFinder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.videoDisplay,'xtick',[],'ytick',[]);

% --- Outputs from this function are returned to the command line.
function varargout = videoWipeFinder_OutputFcn(hObject, eventdata, handles) 
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

contents = cellstr(get(handles.chooseMethod,'String'));
method = contents{get(handles.chooseMethod,'Value')};
scale = 1/8;
% load matrix from video file
[video, frameNumber] = getMatrixFromVideo(handles.videoFileName, scale);

[STI1,STI1_hough,STI_colour1,edgeCounter1] = generateSTI(video, ...
    frameNumber, 'column', method);
[STI2,STI2_hough,STI_colour2,edgeCounter2] = generateSTI(video, ...
    frameNumber, 'row', method);

% Add image generate to GUI
image(STI_colour1, 'Parent', handles.STI_column);
image(STI1, 'Parent', handles.STI_intersection_column);
image(STI1_hough, 'Parent', handles.STI_column_hough);
image(STI_colour2, 'Parent', handles.STI_row);
image(STI2, 'Parent', handles.STI_intersection_row);
image(STI2_hough, 'Parent', handles.STI_row_hough);

% Show result in editText box
set(handles.Result, 'String', '');
resultStr = get(handles.Result, 'String');
if edgeCounter1 == 0
    resultStr = strcat(resultStr,sprintf('Find no edge in STI from column.\n'));
    set(handles.Result, 'String', resultStr);
else
    resultStr = strcat(resultStr,sprintf('Find 1 edge in STI from column.\n'));
    set(handles.Result, 'String', resultStr);
end
if edgeCounter2 == 0
    resultStr = strcat(resultStr,sprintf('  Find no edge in STI from row.\n'));
    set(handles.Result, 'String', resultStr);
else
    resultStr = strcat(resultStr,sprintf('  Find 1 edge in STI from row.\n'));
    set(handles.Result, 'String', resultStr);
end
if(edgeCounter1 ~= 0 && edgeCounter2 == 0)
    resultStr = strcat(resultStr, ...
        '        Conclusion: Video transition is more likely to be a horizontal wipe.');
    set(handles.Result, 'String', resultStr);
elseif(edgeCounter1 == 0 && edgeCounter2 ~= 0)
    resultStr = strcat(resultStr, ...
        '        Conclusion: Video transition is more likely to be a vertical wipe.');
    set(handles.Result, 'String', resultStr); 
else
     resultStr = strcat(resultStr, ...
        '        Conclusion: Video transition might not be a wipe.');
    set(handles.Result, 'String', resultStr);    
end

function Result_Callback(hObject, eventdata, handles)

function Result_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
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


% --- Executes on selection change in chooseMethod.
function chooseMethod_Callback(hObject, eventdata, handles)
% hObject    handle to chooseMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: contents = cellstr(get(hObject,'String')) returns chooseMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseMethod


% --- Executes during object creation, after setting all properties.
function chooseMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
