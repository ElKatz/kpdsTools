function varargout = pldaps_gui2(varargin)
% TEST_MENU3 M-file for test_menu3.fig
%      TEST_MENU3, by itself, creates a new TEST_MENU3 or raises the existing
%      singleton*.
%
%      H = TEST_MENU3 returns the handle to a new TEST_MENU3 or the handle to
%      the existing singleton*.
%
%      TEST_MENU3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_MENU3.M with the given input arguments.
%
%      TEST_MENU3('Property','Value',...) creates a new TEST_MENU3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_menu3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_menu3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_menu3

% Last Modified by GUIDE v2.5 25-Sep-2012 14:40:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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
end


% --- Executes just before GUI is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_menu3 (see VARARGIN)

% % clear Screen and Datapixx before starting up
% Screen('CloseAll'); Datapixx('close');
% 
% % Get rid of the Psychtoolbox welcome screen
% Screen('Preference','VisualDebuglevel',3) 
% 
% % Get values for Psychtoolbox
% handles.screen_number = 1;
% [handles.window handles.screenRect] = Screen('OpenWindow',handles.screen_number,0);
% handles.priorityLevel=MaxPriority(handles.window);
% handles.run_status = 0;
% handles.task = 1;


% Get values for files and paths
%   paths assume that 'Settings' and 'Output' subdirectories exist 
handles.Settings_path_text = sprintf('%s/Settings/',pwd);
handles.Output_path_text = sprintf('%s/Output/',pwd);

    
% accept settings file as input argument
if numel(varargin)>0    % user has provided settings file as argument
    handles.Settings_file_text = varargin{1};
    %   update text for output file name
    set(handles.Settings_file,'String',handles.Settings_file_text);
    % provide message to user on gui about status
    tstring = sprintf('Ready to Initialize');
    set(handles.Message_text,'String',tstring);
    % make Initialize button visible
    set(handles.Initialize_pushbutton,'Visible','on');
else
    % provide message to user on gui about status
    tstring = sprintf('Ready to a select a Settings File');
    set(handles.Message_text,'String',tstring);
end




% Choose default command line output for test_menu3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

end


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


%   SETTINGS FILE PUSHBUTTON
% --- Executes on button press in Settings_Browse_pushbutton.
function Settings_Browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Settings directory, necessary for eval function...
    eval(['cd ' handles.Settings_path_text]);
    % prompt user to select conditions file
    [handles.Settings_file_text,handles.Settings_path_text] = uigetfile('*.m','choose settings file')
    % update text for Settings file name
    set(handles.Settings_file,'String',handles.Settings_file_text);
    % go back to original working directory
    eval(['cd ' pwd_orig]);
    
    % provide message to user on gui about status
    tstring = sprintf('Ready to Initialize');
    set(handles.Message_text,'String',tstring);
    % make Initialize button visible
    set(handles.Initialize_pushbutton,'Visible','on');
    % Update handles structure
    guidata(hObject, handles);
    
    
end


%   SETTINGS SAVEAS PUSHBUTTON    
% --- Executes on button press in Settings_SaveAs_pushbutton.
function Settings_SaveAs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_SaveAs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % Update handles structure
    guidata(hObject, handles);
    % get original name of settings file
    handles.Settings_file_orig = get(handles.Settings_file,'String');
    
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Settings directory for users convenience...
    eval(['cd ' handles.Settings_path_text]);
    
    % prompt user to select new name for saved settings file
    [handles.Settings_file_text,handles.Settings_path_text] = uiputfile('','save settings file as','Location',[100 100])

    % construct file name strings and make call to save new settings file
    input_file = sprintf('%s%s',handles.Settings_path_text,handles.Settings_file_orig);
    output_file = sprintf('%s%s',handles.Settings_path_text,handles.Settings_file_text);
    save_settingsfile(input_file, handles.c1, output_file);
    
    % go back to original working directory
    eval(['cd ' pwd_orig]);
    
    % update text for Settings file name
    set(handles.Settings_file,'String',handles.Settings_file_text);
    
    % provide message to user on gui about status
    tstring = sprintf('%s: Settings saved to file %s', handles.c1.protocol_title, handles.Settings_file_text);
    set(handles.Message_text,'String',tstring);
    
    % Update handles structure
    guidata(hObject, handles);
    
end



%   OUTPUT FILE "BROWSE" PUSHBUTTON
% --- Executes on button press in Output_file_pushbutton.
function Output_file_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Output_file_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % launch browser gui for use to select new file and path
    [handles.Output_file_text,handles.Output_path_text] = uigetfile('.PDS','initialize output file','nameyourfile.PDS');

    % update text for output file name
    set(handles.Output_file,'String',handles.Output_file_text);
    
    % Update handles structure
    guidata(hObject, handles);
end


% OUTPUTFILE SLIDER FOR UPDATING FILE NAME
% --- Executes on slider movement.
function Output_file_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Output_file_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    raw = get(handles.Output_file_slider,'Value');
    count = round(raw);         % round to integer value
    suffix = get(handles.Output_file_suffix,'String');
    
    if(count && isempty(suffix)==0)         % if counter is greater than zero & suffix string is not empty
                                            %   make output file name including count and suffix
        handles.Output_file_text = sprintf('at1_%s_%d_%s',datestr(now,'dd.mm.yyyy'),count,suffix);
    elseif(count && isempty(suffix)==1)     % if counter is greater than zero & suffix string is empty
                                            %   make output file name including count 
        handles.Output_file_text = sprintf('at1_%s_%d',datestr(now,'dd.mm.yyyy'),count);
    elseif(count==0 && isempty(suffix)==0)  % if count is not greater than zero but suffix string is not empty
                                            %   make output file name including suffix
        handles.Output_file_text = sprintf('at1_%s_%s',datestr(now,'dd.mm.yyyy'),suffix);
    else                                    % if count is zero and suffix string is empty
                                            %   make output file name
                                            %   without count or suffix
        handles.Output_file_text = sprintf('at1_%s',datestr(now,'dd.mm.yyyy'));
    end
    
    %   update text for output file name
    set(handles.Output_file,'String',handles.Output_file_text);
    % Update handles structure
    guidata(hObject, handles);
    
end

        
% OUTPUTFILE SUFFIX OPTION
function Output_file_suffix_Callback(hObject, eventdata, handles)
% hObject    handle to Output_file_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Output_file_suffix as text
%        str2double(get(hObject,'String')) returns contents of Output_file_suffix as a double

    raw = get(handles.Output_file_slider,'Value');
    count = round(raw);         % round to integer value
    suffix = get(handles.Output_file_suffix,'String');
    
    if(count && isempty(suffix)==0)         % if counter is greater than zero & suffix string is not empty
                                            %   make output file name including count and suffix
        handles.Output_file_text = sprintf('at1_%s_%d_%s',datestr(now,'dd.mm.yyyy'),count,suffix);
    elseif(count && isempty(suffix)==1)     % if counter is greater than zero & suffix string is empty
                                            %   make output file name including count 
        handles.Output_file_text = sprintf('at1_%s_%d',datestr(now,'dd.mm.yyyy'),count);
    elseif(count==0 && isempty(suffix)==0)  % if count is not greater than zero but suffix string is not empty
                                            %   make output file name including suffix
        handles.Output_file_text = sprintf('at1_%s_%s',datestr(now,'dd.mm.yyyy'),suffix);
    else                                    % if count is zero and suffix string is empty
                                            %   make output file name
                                            %   without count or suffix
        handles.Output_file_text = sprintf('at1_%s',datestr(now,'dd.mm.yyyy'));
    end
    
    %   update text for output file name
    set(handles.Output_file,'String',handles.Output_file_text);
    % Update handles structure
    guidata(hObject, handles);
    
end


%   INITIALIZE PUSHBUTTON
% --- Executes on button press in Initialize_pushbutton.
function Initialize_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Initialize_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    % provide message to user on gui about status
    tstring = sprintf('Initializing...');
    set(handles.Message_text,'String',tstring);

    % Update handles structure
    guidata(hObject, handles);
    drawnow;        % so that text message appears during initializing
    
    % clear Screen and Datapixx before starting up
    Screen('CloseAll'); Datapixx('close');

    % Get rid of the Psychtoolbox welcome screen
    Screen('Preference','VisualDebuglevel',3); 

    % Get values for Psychtoolbox
    handles.screen_number = 1;
    [handles.window handles.screenRect] = Screen('OpenWindow',handles.screen_number,0);
    handles.priorityLevel=MaxPriority(handles.window);
   

    % get starting directory so we can return
    pwd_orig = pwd;
 
            
    % change into Settings directory, necessary for eval function...
    eval(['cd ' handles.Settings_path_text]);

    
    % set these values so they can be passed to settings file function
    handles.c1.window = handles.window;
    handles.c1.screenRect = handles.screenRect;
    handles.c1.refreshrate = FrameRate(handles.c1.window);
    
    %get name of settings file
    handles.Settings_file_text = get(handles.Settings_file,'String');
    
    % evaluate settings file function, values returned to 
    %       m1 (m-file text values)
    %       s1 (status values)
    %       c1 (control parameters)
    eval(['[m1 s1 c1] = ' handles.Settings_file_text(1:end-2) '(handles.c1.window,handles.c1.screenRect,handles.c1.refreshrate)'])
    
    % pass structure values to handles so they can be passed to functions
    handles.m1 = m1;
    handles.s1 = s1;
    handles.c1 = c1;


    
    % Now we set up GUI options for the Control Parameters
    clear string_list;
    Cnames = fieldnames(handles.c1);     % get field names from structure

    % put the structure field names in a list for the popup menu
    for i=1:1:length(Cnames)
    string_list{i} = Cnames{i};
    end
    
    for j=1:1:12
        if(j<=length(Cnames))  % error trap if number of #names < #menus
            % set values for the popup menu
            set(eval(sprintf('handles.par_popupmenu%d',j)),'String',string_list);
            set(eval(sprintf('handles.par_popupmenu%d',j)),'Value',j);
            set(eval(sprintf('handles.par_popupmenu%d',j)),'Visible','on');

            % get contents of the field
            field = c1.(Cnames{j});        
            if(length(field)==1)    % only do this if variable is single-valued
                set(eval(sprintf('handles.par_value%d',j)),'String',num2str(field));
                set(eval(sprintf('handles.par_value%d',j)),'Visible','on');
                if(j>8)             % parameters 8 to 12 have sliders, too
                   if(field)   % if value is non-zero
                        max_value = abs(round(field * 2));
                        if(field>0) min_value = 0; else min_value = round(field * 2); end;
                    else        % if value is zero
                        max_value = 1;
                        min_value = -1;
                   end
                    set(eval(sprintf('handles.par_slider%d',j)),'Value',field);
                    set(eval(sprintf('handles.par_slider%d',j)),'Min',min_value);
                    set(eval(sprintf('handles.par_slider%d',j)),'Max',max_value);
                    set(eval(sprintf('handles.par_slider%d',j)),'Visible','on');
                end
            end
        end
    end
    
    % Now we set up GUI options for the Status Values
    clear string_list;
    Snames = fieldnames(handles.s1);     % get field names from structure

    % put the structure field names in a list for the popup menu
    for i=1:1:length(Snames)
    string_list{i} = Snames{i};
    end
    
    for j=1:1:12
        if(j<=length(Snames)) % error trap if #names < #menus
            % set values for the popup menu
            set(eval(sprintf('handles.val_popupmenu%d',j)),'String',string_list);
            set(eval(sprintf('handles.val_popupmenu%d',j)),'Value',j);
            set(eval(sprintf('handles.val_popupmenu%d',j)),'Visible','on');

            % get contents of the field
            field = s1.(Snames{j});        
            if(length(field)==1)    % only do this if variable is single-valued
                set(eval(sprintf('handles.val_text%d',j)),'String',num2str(field));
                set(eval(sprintf('handles.val_text%d',j)),'Visible','on');
            end
        end
    end
    
    % Now we set up GUI options for the User-defined Actions
    clear string_list;
    Mnames = fieldnames(handles.m1);     % get field names from structure
    
     for j=1:1:9     % 9 possible User-defined Actions
         for i=1:1:length(Mnames)     % error trap if #names < #buttons, subtract 4 'trial-related' m files    
             if(strcmp(Mnames{i},sprintf('action_%d',j)))   % if Mname is named action_j
                 
                % here we name the button
                %   the syntax here is a bit twisted
                %   we use eval on the names of the m1 fields to return the name of the m-file 
                set(eval(sprintf('handles.User_action_%d',j)),'String',eval(sprintf('handles.m1.action_%d(1:end-2)',j)));   % name the button
                set(eval(sprintf('handles.User_action_%d',j)),'Visible','on');  % make that button visible
             end
         end
     end
    

    
    %   make output file name
    handles.Output_file_text = sprintf('%s_%s',handles.c1.output_prefix,datestr(now,'dd.mm.yyyy'))
    
    %   update text for output file name
    set(handles.Output_file,'String',handles.Output_file_text);
    
    
    % initialize data output structure
    PDS = {};
    handles.PDS = PDS;
 
    handles.c1.screen_number = handles.screen_number;
    % need to add back values that were overwritten
    handles.c1.window = handles.window;
    handles.c1.screenRect = handles.screenRect;
    handles.c1.refreshrate = FrameRate(handles.c1.window);
    handles.c1.runflag = 0;
    
    % go back to original working directory
    eval(['cd ' pwd_orig]);
    
    % User-define initialization
    % use content of initialization m-file to setup values
    [handles.PDS,handles.c1] = eval([handles.m1.initialization_file(1:end-2) '(handles.PDS,handles.c1)']);

    
    % now that settings are initialized, it is ok for them to be saved, so
    % make SaveAs button visible
    set(handles.Settings_SaveAs_pushbutton,'Visible','on');
    
    % make other Action buttons visible
    set(handles.Clear_pushbutton,'Visible','on');
    set(handles.Run_togglebutton,'Visible','on');
    set(handles.Pause_togglebutton,'Visible','on');
    
    % provide message to user on gui about status
    tstring = sprintf('%s: Initialized with file %s', handles.c1.protocol_title, handles.Settings_file_text);
    set(handles.Message_text,'String',tstring);
    
    % Update handles structure so data are shared
    guidata(hObject, handles);

end

    
%   RUN TOGGLEBUTTON    
% --- Executes on button press in Run_togglebutton.
function Run_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Run_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
                
   % Update handles structure
        guidata(hObject, handles);
        drawnow;
        handles = guidata(hObject); % get the newest GUI data
        
    % Here we toggle the state of the runflag to match the button 
    if handles.c1.runflag == 0      % if run flag is currently not true
        % then set runflag true (i.e., run the trial)
        handles.c1.runflag = 1; 
        % unpress "Pause" button
        set(handles.Pause_togglebutton,'Value',0);
    elseif handles.c1.runflag == 1      % if run flag is currently true
        % then set runflag false (i.e., stop running the trial)
        handles.c1.runflag = 0; 
    end
    
                
        while 1
                
             % runflag = 1 means run the trial
             if handles.c1.runflag == 1         
               
                set(handles.Run_togglebutton,'Value',1);        % show button pressed
                % provide message to user on gui about status
                tstring = sprintf('%s: Running', handles.c1.protocol_title);
                set(handles.Message_text,'String',tstring);
                drawnow;
                
                % run the next trial
                % use content of next_trial m-file to setup values
                [handles.PDS,handles.c1,handles.s1] = eval([handles.m1.next_trial_file(1:end-2) '(handles.PDS,handles.c1,handles.s1)']);
                
                % Update handles structure and menu display
                guidata(hObject, handles);
                update_Status_Values(hObject);
                drawnow;
                handles = guidata(hObject); % get the newest GUI data

                % use content of run_trial m-file to run the trial
                [handles.PDS,handles.c1,handles.s1] = eval([handles.m1.run_trial_file(1:end-2) '(handles.PDS,handles.c1,handles.s1)']);
                                
                % Update handles structure and menu display
                guidata(hObject, handles);
                update_Status_Values(hObject);
                drawnow;
                handles = guidata(hObject); % get the newest GUI data
                
                % use content of next_trial m-file to run the trial
                [handles.PDS,handles.c1,handles.s1] = eval([handles.m1.finish_trial_file(1:end-2) '(handles.PDS,handles.c1,handles.s1)']);
                                
                % Update handles structure and menu display
                guidata(hObject, handles);
                update_Status_Values(hObject);
                drawnow;
                handles = guidata(hObject); % get the newest GUI data
                                             
                
             % runflag = 0 means stop
             elseif handles.c1.runflag == 0               
                % keyboard
                % unpress "Pause" button
                set(handles.Run_togglebutton,'Value',0);        % show button not pressed
                set(handles.Pause_togglebutton,'Value',0);      % show button not pressed
                % provide message to user on gui about status
                tstring = sprintf('%s: Paused', handles.c1.protocol_title);
                set(handles.Message_text,'String',tstring);
                drawnow;
                % Update handles structure
                guidata(hObject, handles);
                break;      % exit the loop
             end   
          
        end
        
        % Update handles structure and menu display
        guidata(hObject, handles);
        update_Status_Values(hObject);
        drawnow;
        handles = guidata(hObject); % get the newest GUI data
                   
               
end


% update Status Values panel
function update_Status_Values(hObject)

    handles = guidata(hObject);
    Snames = fieldnames(handles.s1);     % get field names from structure

    for j=1:1:12        % loop over the 12 possible Status Values
        if(j<=length(Snames))
            % get index to value of popup menu
            i = get(eval(sprintf('handles.val_popupmenu%d',j)),'Value');
            % get value of field for that index
            field = handles.s1.(Snames{i});        
            if(length(field)==1)    % only do this if variable is single-valued
                set(eval(sprintf('handles.val_text%d',j)),'String',num2str(field));
                set(eval(sprintf('handles.val_text%d',j)),'Visible','on');
            else
                set(eval(sprintf('handles.val_text%d',j)),'Visible','off');
            end
        end
    end
        
    drawnow;  


end



%   PAUSE TOGGLEBUTTON
% --- Executes on button press in pushbutton4.
function Pause_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Screen('FillRect', handles.window,0)
    Screen('Flip', handles.window);
        % set runflag tp "pause" value
        handles.c1.runflag = 0; 
        % Update handles structure
        guidata(hObject, handles);
end


%   CLEAR PUSHBUTTON
% --- Executes on button press in Clear_pushbutton.
function Clear_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    Screen('closeall');
    Datapixx('close');

    % Update handles structure
    guidata(hObject, handles);
end




%% PARAMETER VALUES


%% PARAMETER POPUP MENU CALLBACK FUNCTIONS

% --- Executes on selection change in par_popupmenu1.
function par_popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu1

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value1,'String',num2str(field));
        set(handles.par_value1,'Visible','on');
    else
        set(handles.par_value1,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% --- Executes on selection change in par_popupmenu2.
function par_popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu2

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value2,'String',num2str(field));
        set(handles.par_value2,'Visible','on');
    else
        set(handles.par_value2,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% --- Executes on selection change in par_popupmenu3.
function par_popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu3

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value3,'String',num2str(field));
        set(handles.par_value3,'Visible','on');
    else
        set(handles.par_value3,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
end

% --- Executes on selection change in par_popupmenu4.
function par_popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu4

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value4,'String',num2str(field));
        set(handles.par_value4,'Visible','on');
    else
        set(handles.par_value4,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu5.
function par_popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu5

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value5,'String',num2str(field));
        set(handles.par_value5,'Visible','on');
    else
        set(handles.par_value5,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu6.
function par_popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu6

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value6,'String',num2str(field));
        set(handles.par_value6,'Visible','on');
    else
        set(handles.par_value6,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu6.
function par_popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu6

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value7,'String',num2str(field));
        set(handles.par_value7,'Visible','on');
    else
        set(handles.par_value7,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu6.
function par_popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu6

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value8,'String',num2str(field));
        set(handles.par_value8,'Visible','on');
    else
        set(handles.par_value8,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu11.
function par_popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu11

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value9,'String',num2str(field));
        set(handles.par_value9,'Visible','on');
        set(handles.par_slider9,'Visible','on');
        % set corresponding slider
        if(field)   % if value is non-zero
        max_value = abs(round(field * 2));
        if(field>0) min_value = 0; else min_value = round(field * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        
        set(handles.par_slider9,'Min',min_value);
        set(handles.par_slider9,'Max',max_value);
        set(handles.par_slider9,'Value',field);  
    else
        set(handles.par_value9,'Visible','off');
        set(handles.par_slider9,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu12.
function par_popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu12

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value10,'String',num2str(field));
        set(handles.par_value10,'Visible','on');
        set(handles.par_slider10,'Visible','on');
        % set corresponding slider
        if(field)   % if value is non-zero
        max_value = abs(round(field * 2));
        if(field>0) min_value = 0; else min_value = round(field * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        
        set(handles.par_slider10,'Min',min_value);
        set(handles.par_slider10,'Max',max_value);
        set(handles.par_slider10,'Value',field);  
    else
        set(handles.par_value10,'Visible','off');
        set(handles.par_slider10,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu11.
function par_popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu11

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value11,'String',num2str(field));
        set(handles.par_value11,'Visible','on');
        set(handles.par_slider11,'Visible','on');
        % set corresponding slider
        if(field)   % if value is non-zero
        max_value = abs(round(field * 2));
        if(field>0) min_value = 0; else min_value = round(field * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        
        set(handles.par_slider11,'Min',min_value);
        set(handles.par_slider11,'Max',max_value);
        set(handles.par_slider11,'Value',field);  
    else
        set(handles.par_value11,'Visible','off');
        set(handles.par_slider11,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end

% --- Executes on selection change in par_popupmenu12.
function par_popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu12

    i = get(hObject,'Value');
    % get contents of the field
    Cnames = fieldnames(handles.c1);     % get field names from structure
    field = handles.c1.(Cnames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.par_value12,'String',num2str(field));
        set(handles.par_value12,'Visible','on');
        set(handles.par_slider12,'Visible','on');
        % set corresponding slider
        if(field)   % if value is non-zero
        max_value = abs(round(field * 2));
        if(field>0) min_value = 0; else min_value = round(field * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        
        set(handles.par_slider12,'Min',min_value);
        set(handles.par_slider12,'Max',max_value);
        set(handles.par_slider12,'Value',field);  
        
    else
        set(handles.par_value12,'Visible','off');
        set(handles.par_slider12,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;    
end




%% PARAMETER VALUE CALLBACK FUNCTIONS

% Value 1
function par_value1_Callback(hObject, eventdata, handles)
% hObject    handle to par_value1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value1 as text
%        str2double(get(hObject,'String')) returns contents of par_value1 as a double

    
    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value1,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu1,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Value 2
function par_value2_Callback(hObject, eventdata, handles)
% hObject    handle to par_value2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value2 as text
%        str2double(get(hObject,'String')) returns contents of par_value2 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value2,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu2,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
    

end

% Value 3
function par_value3_Callback(hObject, eventdata, handles)
% hObject    handle to par_value3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value3 as text
%        str2double(get(hObject,'String')) returns contents of par_value3 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value3,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu3,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
end

% Value 4
function par_value4_Callback(hObject, eventdata, handles)
% hObject    handle to par_value4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value4 as text
%        str2double(get(hObject,'String')) returns contents of par_value4 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value4,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu4,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Value 5
function par_value5_Callback(hObject, eventdata, handles)
% hObject    handle to par_value5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value5 as text
%        str2double(get(hObject,'String')) returns contents of par_value5 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value5,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu5,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Value 6
function par_value6_Callback(hObject, eventdata, handles)
% hObject    handle to par_value6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value6 as text
%        str2double(get(hObject,'String')) returns contents of par_value6 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value6,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu6,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Value 7
function par_value7_Callback(hObject, eventdata, handles)
% hObject    handle to par_value6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value6 as text
%        str2double(get(hObject,'String')) returns contents of par_value6 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value7,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu7,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end


% Value 8
function par_value8_Callback(hObject, eventdata, handles)
% hObject    handle to par_value8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value6 as text
%        str2double(get(hObject,'String')) returns contents of par_value6 as a double

    value = str2double(get(hObject,'String'));
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value8,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu8,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end


% Value 9
function par_value9_Callback(hObject, eventdata, handles)
% hObject    handle to par_value18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    value = str2double(get(hObject,'String'));
    
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value9,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu9,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
        
            % set values for slider
        if(value)   % if value is non-zero
            max_value = abs(round(value * 2));
            if(value>0) min_value = 0; else min_value = round(value * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        set(handles.par_slider9,'Min',min_value);
        set(handles.par_slider9,'Max',max_value);
        set(handles.par_slider9,'Value',value);  
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Value 10
function par_value10_Callback(hObject, eventdata, handles)
% hObject    handle to par_value10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value12 as text
%        str2double(get(hObject,'String')) returns contents of par_value12 as a double

    value = str2double(get(hObject,'String'));
    
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value10,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu10,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
        
            % set values for slider
        if(value)   % if value is non-zero
            max_value = abs(round(value * 2));
            if(value>0) min_value = 0; else min_value = round(value * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        set(handles.par_slider10,'Min',min_value);
        set(handles.par_slider10,'Max',max_value);
        set(handles.par_slider10,'Value',value);  
    end
     
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
    

end

% Value 11
function par_value11_Callback(hObject, eventdata, handles)
% hObject    handle to par_value11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value11 as text
%        str2double(get(hObject,'String')) returns contents of par_value11 as a double

    value = str2double(get(hObject,'String'));
    
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value11,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu11,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
        
            % set values for slider
        if(value)   % if value is non-zero
            max_value = abs(round(value * 2));
            if(value>0) min_value = 0; else min_value = round(value * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        set(handles.par_slider11,'Min',min_value);
        set(handles.par_slider11,'Max',max_value);
        set(handles.par_slider11,'Value',value);  
    end
    
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
    
end

% Value 12
function par_value12_Callback(hObject, eventdata, handles)
% hObject    handle to par_value12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value12 as text
%        str2double(get(hObject,'String')) returns contents of par_value12 as a double

    value = str2double(get(hObject,'String'));
    
    % conditional to catch possible user input errors
    if(isnan(value))    % if value entered is not a number
        set(handles.par_value12,'String','error');
    else                % if value entered is a number
        index = get(handles.par_popupmenu12,'Value');
        Cnames = fieldnames(handles.c1);     % get field names from structure
        tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
        handles.c1 = setfield(handles.c1,tstring,value);
        
            % set values for slider
        if(value)   % if value is non-zero
            max_value = abs(round(value * 2));
            if(value>0) min_value = 0; else min_value = round(value * 2); end;
        else        % if value is zero
            max_value = 1;
            min_value = -1;
        end
        set(handles.par_slider12,'Min',min_value);
        set(handles.par_slider12,'Max',max_value);
        set(handles.par_slider12,'Value',value);  
    end
         
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
    
end



%% PARAMETER SLIDERS

% Slider 9
% --- Executes on slider movement.
function par_slider9_Callback(hObject, eventdata, handles)
% hObject    handle to par_slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
   
    raw = get(hObject,'Value');
    % value = raw;
    value = round(raw*10)/10;                     % round value to nearest 10th
        
    % determine which structure variable this is, and set its value
    index = get(handles.par_popupmenu9,'Value');
    Cnames = fieldnames(handles.c1);     % get field names from structure
    tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
    handles.c1 = setfield(handles.c1,tstring,value);
    
    % set value in corresponding text field
    set(handles.par_value9,'String',num2str(value));  
    
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Slider 10
% --- Executes on slider movement.
function par_slider10_Callback(hObject, eventdata, handles)
% hObject    handle to par_slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    raw = get(hObject,'Value');
    % value = raw;
    value = round(raw*10)/10;                     % round value to nearest 10th
        
    % determine which structure variable this is, and set its value
    index = get(handles.par_popupmenu10,'Value');
    Cnames = fieldnames(handles.c1);     % get field names from structure
    tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
    handles.c1 = setfield(handles.c1,tstring,value);
    
    % set value in corresponding text field
    set(handles.par_value10,'String',num2str(value));  
    
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end

% Slider 11
% --- Executes on slider movement.
function par_slider11_Callback(hObject, eventdata, handles)
% hObject    handle to par_slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

    raw = get(hObject,'Value');
    % value = raw;
    value = round(raw*10)/10;                     % round value to nearest 10th
        
    % determine which structure variable this is, and set its value
    index = get(handles.par_popupmenu11,'Value');
    Cnames = fieldnames(handles.c1);     % get field names from structure
    tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
    handles.c1 = setfield(handles.c1,tstring,value);
    
    % set value in corresponding text field
    set(handles.par_value11,'String',num2str(value));  
    
    % Update handles structure
    guidata(hObject, handles);
    drawnow;
    
    
end

% Slider 12
% --- Executes on slider movement.
function par_slider12_Callback(hObject, eventdata, handles)
% hObject    handle to par_slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


    raw = get(hObject,'Value');
    % value = raw;
    value = round(raw*10)/10;                     % round value to nearest 10th
        
    % determine which structure variable this is, and set its value
    index = get(handles.par_popupmenu12,'Value');
    Cnames = fieldnames(handles.c1);     % get field names from structure
    tstring = eval([sprintf('Cnames{%d}',index)]);   % get field name based on index
    handles.c1 = setfield(handles.c1,tstring,value);
    
    % set value in corresponding text field
    set(handles.par_value12,'String',num2str(value));  
    
    % Update handles structure
    guidata(hObject, handles);
    drawnow;

end
    

%% OTHER GUI FUNCTIONS




% --- Executes during object creation, after setting all properties.
function Output_file_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Output_file_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes during object creation, after setting all properties.
function Output_file_suffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Output_file_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes during object creation, after setting all properties.
function par_value1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes during object creation, after setting all properties.
function par_value2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes during object creation, after setting all properties.
function par_value3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes during object creation, after setting all properties.
function par_value4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes during object creation, after setting all properties.
function par_value5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes during object creation, after setting all properties.
function par_value6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function par_value12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes during object creation, after setting all properties.
function par_popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes during object creation, after setting all properties.
function par_popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes during object creation, after setting all properties.
function par_popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function par_slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function par_slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function par_slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes during object creation, after setting all properties.
function par_slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end






function save_settingsfile(input, S, output)
% find byte positions of structure field names in S in filename

n_names = 1;
names_bytes = 1;

Snames = fieldnames(S);     % get field names from structure

fid_in = fopen(input,'r');      % open settings file

comments_bytes(1) = 0;      % always grab first line, which contains function name
comments_lines(1) = 1;      % function name is always the first line

i = 2;      % initialize counter for comments, allowing that first index points to first line


% grab first field name
index = 1;
tname = sprintf('c.%s',Snames{index}); 

tline_num = 0;          % initialize line counter
% Loop through the original settings file
    while 1
        
        file_position = ftell(fid_in);     % get current position in file
        tline = fgetl(fid_in);             % grab the current line
        tline_num = tline_num + 1;
        if ~ischar(tline), break, end;   % exit if at end of file
        x = size(strtrim(tline),2);      % size of char spaces
        if x,              % if line has characters on it
            a = strtrim(tline);         % eliminate white spaces
                    % get byte position of any comment lines
            if(a(1)=='%')              % if first non-space chars are %!, this is a comment line
                comments_bytes(i) = file_position;  % grab byte position of comment line
                comments_lines(i) = tline_num;      % grab line position of comment line
                i = i + 1;
            end
        
        
            % grab any lines matching fieldnames
            if(numel(a)>=length(tname))    % first check if a is long enough to be a match
                if(a(1:length(tname))== tname)             
                names_bytes(index) = file_position;  % grab byte position of field name
                names_lines(index) = tline_num;
                % now, get next field name
                index = index + 1;
                if(index<=numel(Snames))
                    tname = sprintf('c.%s',Snames{index});
                end
                end  
            end
        end
    end


% We go back and grab those comment strings
n_comments = size(comments_bytes,2);             % how many comments are there?
comments = '';                               % initialize comments
for i = 1:1:n_comments
    fseek(fid_in, comments_bytes(i), -1);      % move into position
    tline = fgetl(fid_in);                     % get the line
    a = strtrim(tline);                     % eliminate white spaces
    %b = strtrim(a(3:size(a,2)));            % eliminate '%' and any white space after that
    comments = strvcat(comments, a);        % collect comment strings
end

fclose(fid_in);

% Make index arrays for sorting
% Each array contains byte position, incremented index, and a flag
%       flag is 1 for field names, -1 for comments
names_index = [names_bytes; names_lines; 1:1:(length(names_bytes)); ones(1,length(names_bytes))]';
comments_index = [comments_bytes; comments_lines; 1:1:(length(comments_bytes)); ones(1,length(comments_bytes)).*-1]';

temp_index = [names_index; comments_index];
[values, order] = sort(temp_index(:,1));
sorted_index = temp_index(order,:);

% Print the sorted values to the output file

fid_out = fopen(output,'w');
%initialize newlines indicator
    % these are used to reproduce the line spacing from the original file
newlines = 0;  
extralines = 0;
Text_Comments = {'initialization_file','next_trial_file','run_trial_file','finish_trial_file','output_prefix','protocol_title'};
    
    for j = 1:length(sorted_index)
        % comments
        if(sorted_index(j,4) < 0)
            % any extra newlines needed?
            if(j>1) 
                newlines = sorted_index(j,2) - sorted_index(j-1,2) - 1 - extralines;
                extralines = 0;
            end
            while(newlines) 
                fprintf(fid_out, '\n');
                newlines = newlines-1;
            end
            % print comment
            fprintf(fid_out, '%s\n', comments(sorted_index(j,3),:));
        end
        
        % values from structure
        if(sorted_index(j,4)>0)
            % get contents of the field
            field = S.(Snames{sorted_index(j,3)});
            % print out a formatted version of the structure, separated by tabs
        
            %   starting with the field names, plus '='
            Nstring = Snames{sorted_index(j,3)};
            fprintf(fid_out,'\tc.%s = ', Nstring);
            
            % if the Field name matches any of the Text Comments
            %   the values should be printed as string
            if(sum(strcmp(Nstring,Text_Comments)))  
                %print values out as string
                fprintf(fid_out,'''%s'';\n', field);
            else
                %   print out the numeric values in the field
                [rows cols] = size(field);
                % single-value case
                if(cols==1 && rows==1)
                    if(abs(round(field)-field)) <= eps('double')  fprintf(fid_out,'%d;\n', field); % check if number is integer
                    else fprintf(fid_out,'%f;\n', field); 
                    end
                % vector case
                elseif(cols>1 && rows==1)
                    fprintf(fid_out,'[');       % add open bracket before printing values
                    for n = 1:cols               % print each value
                        if(abs(round(field(n))-field(n))) <= eps('double')  fprintf(fid_out,'%d', field(n)); % check if number is integer
                        else fprintf(fid_out,'%f', field(n)); 
                        end 
                        if(n<cols) fprintf(fid_out,'  ');   end  % add spaces between values
                    end
                    fprintf(fid_out,'];\n');       % add close bracket after printing values
                % array case
                elseif(cols>1 && rows>1)
                    fprintf(fid_out,'[');       % add open bracket before printing values
                    extralines = rows-1;          % we need to take into account that newlines are added here for each row
                    for m = 1:rows
                        for n = 1:cols               % print each value
                            if(abs(round(field(m,n))-field(m,n))) <= eps('double')  fprintf(fid_out,'%d', field(m,n)); % check if number is integer
                            else fprintf(fid_out,'%f', field(m,n)); 
                            end 
                            if(n<cols) fprintf(fid_out,',  ');   end  % add comma and spaces between values
                        end
                        if(m<rows) fprintf(fid_out,';\n\t\t\t'); end    % add semicolon and newline between rows, tabs to indent next row
                    end
                    fprintf(fid_out,'];\n');       % add close bracket after printing values

                end         % end of printing out numeric values
            end
            
            
        end
        
    end

fprintf(fid_out,'\nend\n');
fclose(fid_out);


end




% --- Executes on selection change in val_popupmenu1.
function val_popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        val_popupmenu1

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text1,'String',num2str(field));
        set(handles.val_text1,'Visible','on');
    else
        set(handles.val_text1,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   


end


% --- Executes during object creation, after setting all properties.
function val_popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu2.
function val_popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu2

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text2,'String',num2str(field));
        set(handles.val_text2,'Visible','on');
    else
        set(handles.val_text2,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   

    
end


% --- Executes during object creation, after setting all properties.
function val_popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu3.
function val_popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu3

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text3,'String',num2str(field));
        set(handles.val_text3,'Visible','on');
    else
        set(handles.val_text3,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   


end


% --- Executes during object creation, after setting all properties.
function val_popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu4.
function val_popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu4

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text4,'String',num2str(field));
        set(handles.val_text4,'Visible','on');
    else
        set(handles.val_text4,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   


end


% --- Executes during object creation, after setting all properties.
function val_popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu5.
function val_popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu5

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text5,'String',num2str(field));
        set(handles.val_text5,'Visible','on');
    else
        set(handles.val_text5,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   

end


% --- Executes during object creation, after setting all properties.
function val_popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu6.
function val_popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu6

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text6,'String',num2str(field));
        set(handles.val_text6,'Visible','on');
    else
        set(handles.val_text6,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   

end


% --- Executes during object creation, after setting all properties.
function val_popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu7.
function val_popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu7

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text7,'String',num2str(field));
        set(handles.val_text7,'Visible','on');
    else
        set(handles.val_text7,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   

end


% --- Executes during object creation, after setting all properties.
function val_popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu8.
function val_popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu8

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text8,'String',num2str(field));
        set(handles.val_text8,'Visible','on');
    else
        set(handles.val_text8,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;   


end


% --- Executes during object creation, after setting all properties.
function val_popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




% --- Executes on selection change in val_popupmenu9.
function val_popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu9


    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text9,'String',num2str(field));
        set(handles.val_text9,'Visible','on');
    else
        set(handles.val_text9,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;  

end



% --- Executes during object creation, after setting all properties.
function val_popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in val_popupmenu10.
function val_popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu10


    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text10,'String',num2str(field));
        set(handles.val_text10,'Visible','on');
    else
        set(handles.val_text10,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;  

end



% --- Executes during object creation, after setting all properties.
function val_popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




% --- Executes on selection change in val_popupmenu11.
function val_popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu11

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text11,'String',num2str(field));
        set(handles.val_text11,'Visible','on');
    else
        set(handles.val_text11,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;  

end



% --- Executes during object creation, after setting all properties.
function val_popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in val_popupmenu12.
function val_popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to val_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns val_popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val_popupmenu12

    i = get(hObject,'Value');
    % get contents of the field
    Snames = fieldnames(handles.s1);     % get field names from structure
    field = handles.s1.(Snames{i});        
    if(length(field)==1)    % only do this if variable is single-valued
        set(handles.val_text12,'String',num2str(field));
        set(handles.val_text12,'Visible','on');
    else
        set(handles.val_text12,'Visible','off');
    end
    % Update handles structure
    guidata(hObject, handles);
    drawnow;  

end



% --- Executes during object creation, after setting all properties.
function val_popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val_popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



           
                


% --- Executes on selection change in par_popupmenu7.
function popupmenu33_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu7
end




% --- Executes during object creation, after setting all properties.
function popupmenu33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to par_value7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_value7 as text
%        str2double(get(hObject,'String')) returns contents of par_value7 as a double
end

% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_value7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in par_popupmenu8.
function popupmenu35_Callback(hObject, eventdata, handles)
% hObject    handle to par_popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns par_popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_popupmenu8
end


% --- Executes during object creation, after setting all properties.
function popupmenu35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




% --- Executes on button press in User_action_1.
function User_action_1_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_1,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data           
     

end


% --- Executes on button press in User_action_2.
function User_action_2_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_2,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  


end


% --- Executes on button press in User_action_3.
function User_action_3_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_3,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end


% --- Executes on button press in User_action_4.
function User_action_4_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_4,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end


% --- Executes on button press in User_action_5.
function User_action_5_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_5,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end


% --- Executes on button press in User_action_6.
function User_action_6_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_6,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end

% --- Executes on button press in User_action_7.
function User_action_7_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_7,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end


% --- Executes on button press in User_action_8.
function User_action_8_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_8,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end


% --- Executes on button press in User_action_9.
function User_action_9_Callback(hObject, eventdata, handles)
% hObject    handle to User_action_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name of m-file defined for this action
astring = get(handles.User_action_9,'String');

if(astring)     % error check just in case string is not defined
    % get starting directory so we can return
    pwd_orig = pwd;
    % change into Actions directory, necessary for eval function...
    pstring = sprintf('%s/Actions',pwd_orig);
    eval(['cd ' pstring]);
    % use content of m-file to execute user-defined action
    [handles.PDS,handles.c1,handles.s1] = eval([astring '(handles.PDS,handles.c1,handles.s1)']);
    % then return to original working directory
    eval(['cd ' pwd_orig]);
end

% Update handles structure and menu display
guidata(hObject, handles);
update_Status_Values(hObject);
drawnow;
handles = guidata(hObject); % get the newest GUI data  

end



     

