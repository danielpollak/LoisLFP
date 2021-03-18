%---------------------------------------------------------------------------------------
%   Song Preview ver 2.02
%   Aug 2020
%   Aug 20 2020: global variable 'new_destination' added, to remember the folder path to
%       store newly cut song bouts.
%   Aug 26 2020: new 'expand' button added. it locates and visilizes the parent song file 
%       where the current selected song bout was cut, so that user can change the current 
%       bout by re-select mannually in the sonogram.
%---------------------------------------------------------------------------------------

function varargout = SongPreview_202(varargin)
% SONGPREVIEW_202 MATLAB code for SongPreview_202.fig
%      SONGPREVIEW_202, by itself, creates a new SONGPREVIEW_202 or raises the existing
%      singleton*.
%
%      H = SONGPREVIEW_202 returns the handle to a new SONGPREVIEW_202 or the handle to
%      the existing singleton*.
%
%      SONGPREVIEW_202('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONGPREVIEW_202.M with the given input arguments.
%
%      SONGPREVIEW_202('Property','Value',...) creates a new SONGPREVIEW_202 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SongPreview_202_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SongPreview_202_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SongPreview_202

% Last Modified by GUIDE v2.5 26-Aug-2020 11:35:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SongPreview_202_OpeningFcn, ...
                   'gui_OutputFcn',  @SongPreview_202_OutputFcn, ...
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


% --- Executes just before SongPreview_202 is made visible.
function SongPreview_202_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SongPreview_202 (see VARARGIN)

% Choose default command line output for SongPreview_202
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'toolbar','figure');
% set(hObject,'menubar','figure');
%initialize parameters
global fileList fileList_select current_select sampleRate
fileList = {};
fileList_select = {};
current_select = {};
sampleRate = 44100; %sampling rate of .wav files

% UIWAIT makes SongPreview_202 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SongPreview_202_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global current_select;
contents = cellstr(get(hObject, 'String'));
filename = contents{get(hObject, 'Value')};
if (filename)
    current_select = filename;
    [soundData,fs] = audioread(filename);
    [s,f,t]=spectrogram(soundData,fix(fs/100),fix(fs/130),512,fs,'yaxis');
    sonogram_im=abs(s(f<12000&f>300,:));
    imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
    colormap(flip(gray));
    xticks([0:3.5/(length(soundData)/fs*2):3.5]);
    yticks([]);
    xticklabels([]);
    xlabel('500ms / tick')
    axis on;
end


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_dir.
function button_dir_Callback(hObject, eventdata, handles)
% hObject    handle to button_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileList fileList_select current_select new_destination
pathName = uigetdir;
if (pathName)
    new_destination=pathName;
    cd(pathName);
    fileList_select={};
    fileDIR = dir([pathName '/*.wav']);
    fileList = {fileDIR.name};
    set(handles.text3,'String',pathName);
    set(handles.listbox1,'String',fileList);
    set(handles.listbox2,'String',fileList_select);
    set(handles.listbox1,'Value',1);
    set(handles.listbox2,'Value',1);
    current_select = {};
end

% --- Executes on button press in button_move.
function button_move_Callback(hObject, eventdata, handles)
% hObject    handle to button_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileList_select
if ~isempty(fileList_select)
    pathName = uigetdir('move selected files to folder');
    if (pathName)
        for i=1:length(fileList_select)
            movefile(fileList_select{i},pathName);
        end
        fileList_select = {};
        set(handles.listbox2,'String',fileList_select);
        set(handles.listbox2,'value',1);
    end
end


% --- Executes on button press in button_del.
function button_del_Callback(hObject, eventdata, handles)
% hObject    handle to button_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileList_select
if ~isempty(fileList_select)
    selection = questdlg('Confirm to delete these files?','Confirm Delete',...
        'Confirm','Cancel','Cancel');
    switch selection
        case 'Confirm'
            recycle('on');
            for i=1:length(fileList_select)
                delete(fileList_select{i});
            end
            fileList_select = {};
            set(handles.listbox2,'String',fileList_select);
            set(handles.listbox2,'value',1);
        case 'Cancel'
    end
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
global current_select;
contents = cellstr(get(hObject, 'String'));
if length(contents)>0
    filename = contents{get(hObject, 'Value')};
    current_select = filename;
    [soundData,fs] = audioread(filename);
    [s,f,t]=spectrogram(soundData,fix(fs/100),fix(fs/125),512,fs,'yaxis');
    sonogram_im=abs(s(f<12000&f>300,:));
    imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
    colormap(flip(gray));
    xticks([0:3.5/(length(soundData)/fs*2):3.5]);
    yticks([]);
    xticklabels([]);
    xlabel('500ms / tick')
    axis on;
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_add.
function button_add_Callback(hObject, eventdata, handles)
% hObject    handle to button_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global current_select fileList fileList_select
% if isempty(current_select)
%     return;
% end
% idx_l = get(handles.listbox1,'value');
% if idx_l == length(fileList) && length(fileList)>1
%     idx_l=idx_l-1;
% end
% idx_r = get(handles.listbox2,'value');
% if idx_r == length(fileList_select) && length(fileList_select)>1
%     idx_r = idx_r-1;
% end
% if isempty(find(ismember(fileList_select,current_select)));
%     fileList_select{end+1}= current_select;
%     fileList = fileList(find(~ismember(fileList,current_select)));
%     set(handles.listbox1,'Value',idx_l);
% else
%     fileList_select = fileList_select(find(~ismember(fileList_select,current_select)));
%     if isempty(find(ismember(fileList,current_select)))
%         fileList{end+1} = current_select;
%     end
%     set(handles.listbox2,'Value',idx_r);
% end
% fileList = sort(fileList);
% fileList_select = sort(fileList_select);
% 
% set(handles.listbox1,'String',fileList);
% set(handles.listbox2,'String',fileList_select);
% 
% current_select = {};

% --- Executes on button press in button_playsound.
function button_playsound_Callback(hObject, eventdata, handles)
% hObject    handle to button_playsound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_select;
if (current_select)
    [soundData,fs] = audioread(current_select);
    sound(soundData,fs);
end


% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global current_select fileList fileList_select
switch eventdata.Key 
    case 'm' 
        if ~isempty(current_select)
            idx = get(hObject,'Value');
            fileList_select{end+1} = fileList{idx};
            fileList(idx) = [];
            if idx>1 && length(fileList)<idx
                set(hObject,'Value',idx-1)
            end
            set(hObject,'String',fileList);
            fileList_select = sort(fileList_select);
            set(handles.listbox2,'String',fileList_select);
            if length(fileList)>0
                current_select = fileList{get(hObject,'Value')};
                [soundData,fs] = audioread(current_select);
                [s,f,t]=spectrogram(soundData,fix(fs/100),fix(fs/125),512,fs,'yaxis');
                sonogram_im=abs(s(f<12000&f>300,:));
                imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
                colormap(flip(gray));
                xticks([0:3.5/(length(soundData)/fs*2):3.5]);
                yticks([]);
                xticklabels([]);
                xlabel('500ms / tick')
                axis on;
            else
                current_select = {};
            end
        end
end


% --- Executes on key press with focus on listbox2 and none of its controls.
function listbox2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global current_select fileList fileList_select
switch eventdata.Key 
    case 'm' 
        if ~isempty(current_select)
            idx = get(hObject,'Value');
            fileList{end+1} = fileList_select{idx};
            fileList_select(idx) = [];
            if idx>1 && length(fileList_select)<idx
                set(hObject,'Value',idx-1)
            end
            set(hObject,'String',fileList_select);
            fileList = sort(fileList);
            set(handles.listbox1,'String',fileList);
            if length(fileList_select)>0
                current_select = fileList_select{get(hObject,'Value')};
                [soundData,fs] = audioread(current_select);
                [s,f,t]=spectrogram(soundData,fix(fs/100),fix(fs/125),512,fs,'yaxis');
                sonogram_im=abs(s(f<12000&f>300,:));
                imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
                colormap(flip(gray));
                xticks([0:3.5/(length(soundData)/fs*2):3.5]);
                yticks([]);
                xticklabels([]);
                xlabel('500ms / tick')
                axis on;
            else
                current_select = {};
            end
        end
end


% --- Executes on button press in pushbutton_cut.
function pushbutton_cut_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_select
if ~isempty(current_select)
    h_select=drawrectangle(handles.axes1);
    if isvalid(h_select)
         selection = questdlg('Confirm to trim this song?','Confirm',...
        'Confirm','Cancel','Cancel');
        switch selection
            case 'Confirm'
            [songdata,fs]=audioread(current_select);
            newxlim=h_select.Position([1,3]);
            cache=fix(max(length(songdata)*newxlim(1)/3.5,1)):fix(min(length(songdata),(newxlim(1)+newxlim(2))*length(songdata)/3.5));
            delete(current_select);
            audiowrite(current_select,songdata(cache),fs);
            [s,f,t]=spectrogram(songdata(cache),fix(fs/100),fix(fs/125),512,fs,'yaxis');
            sonogram_im=abs(s(f<12000&f>300,:));
            imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
            colormap(flip(gray));
            xticks([0:3.5/(length(songdata(cache))/fs*2):3.5]);
            yticks([]);
            xticklabels([]);
            xlabel('500ms / tick')
            axis on;
            case 'Cancel'
        end
    end
    delete(h_select);
end
        


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_select
global new_destination
if ~isempty(current_select)
    h_select=drawrectangle(handles.axes1);
    if isvalid(h_select)
         selection = questdlg('Confirm to make new bout file?','Confirm',...
        'Confirm','Cancel','Cancel');
        switch selection
            case 'Confirm'
            [songdata,fs]=audioread(current_select);
            newxlim=h_select.Position([1,3]);
            cache=fix(max(length(songdata)*newxlim(1)/3.5,1)):fix(min(length(songdata),(newxlim(1)+newxlim(2))*length(songdata)/3.5));
            selpath=uigetdir(new_destination,'where to put the new file?');
            if selpath
                newFile=[selpath '\' erase(current_select,'.wav') '_' num2str(fix(cache(1)*2/fs)/2) '.wav'];
                audiowrite(newFile,songdata(cache),fs);
                new_destination=selpath;
            end
            case 'Cancel'
        end
    end
    delete(h_select);
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global current_select
if ~isempty(current_select)
    [boutdata,fs]=audioread(current_select);
    currentpath=pwd;
    splits=strsplit(current_select,'_');
    if length(splits)==8
        parentFile=[splits{1} '_' splits{2} '_' splits{3} '_' splits{4} '_' splits{5} '_' splits{6} '_' splits{7} '.wav'];
        if isfile(['..\' parentFile])
            newFigure=figure();
            newAx=axes(newFigure,'box','off');
            [songdata,fs]=audioread(['..\' parentFile]);
            [r,lags]=xcorr(boutdata,songdata);
            [M,I]=max(r);
            [s,f,t]=spectrogram(songdata,fix(fs/100),fix(fs/125),512,fs,'yaxis');
            sonogram_im=abs(s(f<12000&f>300,:));
            imshow(flip(sonogram_im),'Parent',newAx,'XData',[0 10],'YData',[0 1]);
            colormap(flip(gray));
            xticks([0:10/(length(songdata)/fs*2):10]);
            yticks([]);
            xticklabels([]);
            xlabel('500ms / tick')
            axis on;
            newFigure.WindowState='maximized';
            drawrectangle(newAx,'color',[0.5 0 0],'position',[10/length(songdata)*abs(lags(I)) 0 10/length(songdata)*length(boutdata) 1]);
            h_select=drawrectangle(newAx);
            if isvalid(h_select)
                selection = questdlg('Confirm to change bout file?','Confirm',...
            'Confirm','Cancel','Cancel');
                switch selection
                    case 'Confirm'
                        newxlim=h_select.Position([1,3]);
                        cache=fix(max(length(songdata)*newxlim(1)/10,1)):fix(min(length(songdata),(newxlim(1)+newxlim(2))*length(songdata)/10));
                        delete(current_select);
                        audiowrite(current_select,songdata(cache),fs);
                        close(newFigure);
                        [s,f,t]=spectrogram(songdata(cache),fix(fs/100),fix(fs/125),512,fs,'yaxis');
                        sonogram_im=abs(s(f<12000&f>300,:));
                        imshow(flip(sonogram_im),'Parent',handles.axes1,'XData',[0 3.5],'YData',[0 1]);
                        colormap(flip(gray));
                        xticks([0:3.5/(length(songdata(cache))/fs*2):3.5]);
                        yticks([]);
                        xticklabels([]);
                        xlabel('500ms / tick')
                        axis on;
                    case 'Cancel'
                        close(newFigure);
                end
            end
        end
    end
end
