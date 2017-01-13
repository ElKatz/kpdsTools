% test script for setting up eyelink toolbox and calibration on krauzlis
% pldaps.

% create the c struct from a *_settings file:
addpath(genpath(('/Users/leorkatz/Dropbox/katz_server/pldaps/training1/FST')))

% hacking:
c.screenRect = [0 0 200 100];
c.window    = 1;
[m, s, c] = joypress_settings(c.window, c.screenRect , 60);
close(1)

%%

c.el.customCalibration = 0; % this doesnt work yet

c.el=EyelinkInitDefaults(c.screen_number);

% filename can only be 8 characters long (not including extention
dtstr = datestr(now, 'dHHMM');
if numel(dtstr)>5
    dtstr = dtstr(end-4:end);
end
% dv.el.edfFile = [dv.subj(1:3) dtstr]; %[dv.pref.sfile(1:end-4) '.edf'];
% dv.el.edfFileLocation = dv.pref.datadir;

c.el.edfFile = 'pds.edf'; %[dv.subj(1:3) dtstr]; %[dv.pref.sfile(1:end-4) '.edf'];
c.el.edfFileLocation = pwd; %dv.pref.datadir;
fprintf('EDFFile: %s\n', c.el.edfFile );

c.el.window = c.screen_number; 
% dv.el.backgroundcolour = BlackIndex(dv.disp.ptr);
% dv.el.msgfontcolour    = WhiteIndex(dv.disp.ptr);
% dv.el.imgtitlecolour   = WhiteIndex(dv.disp.ptr);
% dv.el.targetbeep = 0;
% dv.el.calibrationtargetcolour= WhiteIndex(dv.el.window);
% dv.el.calibrationtargetsize= .5;
% dv.el.calibrationtargetwidth=0.5;
c.el.displayCalResults = 1;
c.el.eyeimgsize=50;
EyelinkUpdateDefaults(c.el);

% check if eyelink initializes
if ~EyelinkInit
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown')
    sca
    return
end

% open file to record data to
% res = Eyelink('Openfile', fullfile(dv.el.edfFileLocation,dv.el.edfFile));
res = Eyelink('Openfile', c.el.edfFile);
if res~=0
    fprintf('Cannot create EDF file ''%s'' ', c.el.edfFile);
    Eyelink('Shutdown')
    return;
end

% Eyelink commands to setup the eyelink environment
datestr(now);
Eyelink('command',  ['add_file_preamble_text ''Recorded by PLDAPS'  '''']);
Eyelink('command',  'screen_pixel_coords = %ld, %ld, %ld, %ld', c.disp.winRect(1), c.disp.winRect(2), c.disp.winRect(3)-1, c.disp.winRect(4)-1);
Eyelink('command',  'analog_dac_range = %1d, %1d', -5, 5);
Eyelink('command',  'screen_phys_coords = %1d, %1d, %1d, %1d', 10*-c.disp.widthcm/2, 10*c.disp.heightcm/2, 10*c.disp.widthcm/2, 10*-c.disp.heightcm/2);

[v,vs] = Eyelink('GettrackerVersion');
disp('***************************************************************')
fprintf('\tReading Values from %sEyetracker\r', vs)
disp('***************************************************************')
[result, reply] = Eyelink('ReadFromTracker', 'screen_pixel_coords'); %#ok<*ASGLU>
fprintf(['Screen pixel coordinates are:\t\t' reply '\r'])
[result, reply] = Eyelink('ReadFromTracker', 'screen_phys_coords');
fprintf(['Screen physical coordinates are:\t' reply ' (in mm)\r'])
[result, reply] = Eyelink('ReadFromTracker', 'screen_distance');
fprintf(['Screen distance is:\t\t\t' reply '\r'])
[result, reply] = Eyelink('ReadFromTracker', 'analog_dac_range');
fprintf(['Analog output range is constraiend to:\t' reply ' (volts)\r'])
[result, srate] = Eyelink('ReadFromTracker', 'sample_rate');
fprintf(['Sampling rate is:\t\t\t' srate 'Hz\r'])
c.el.srate = srate; 
pause(.05)


[result,reply]=Eyelink('ReadFromTracker','elcl_select_configuration');
c.el.trackerVersion = vs; 
c.el.trackerMode    = reply;

switch c.el.trackerMode
    case {'RTABLER'}
        fprintf('\rSetting up tracker for remote mode\r')
        % remote mode possible add HTARGET ( head target)
        
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,PUPIL,STATUS,INPUT,HTARGET, HMARKER');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,PUPIL,STATUS,INPUT,HTARGET, HMARKER');
    otherwise
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,PUPIL,STATUS,INPUT');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,PUPIL,STATUS,INPUT');
end


% custom calibration points
if c.el.customCalibration
    width  = c.disp.winRect(3); 
    height = c.disp.winRect(4); 
    disp('setting up custom calibration')
    disp('this is not properly implemented yet')
    Eyelink('command', 'generate_default_targets = NO');
    Eyelink('command','calibration_samples = 5');
    Eyelink('command','calibration_sequence = 1,2,3,4,5');
    Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2,  width/2,height*0.2,  width/2,height - height*0.2,  width*0.2,height/2,  width - width*0.2,height/2 );
    
    fprintf('calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d\r',...
        width/2,height/2,  width/2,height*0.2,  width/2,height - height*0.2,  width*0.2,height/2,  width - width*0.2,height/2);
    
    
    Eyelink('command','validation_samples = 5');
    Eyelink('command','validation_sequence = 0,1,2,3,4,5');
    Eyelink('command','validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2,  width/2,height*0.2,  width/2,height - height*0.2,  width*0.2,height/2,  width - width*0.2,height/2 );
else
    disp('using default calibration points')
    Eyelink('command', 'calibration_type = HV5');
    % you must send this command with value NO for custom calibration
    % you must also reset it to YES for subsequent experiments
    Eyelink('command', 'generate_default_targets = YES');
    
end



% query host to see if automatic calibration sequencing is enabled.
% ReadFromTracker needs to have 2 outputs.
% variables querable are listed in the .ini files in the host
% directories. Note that not all variables are querable.
[result, reply]=Eyelink('ReadFromTracker','enable_automatic_calibration');

if reply % reply = 1
    fprintf('Automatic sequencing ON\r');
else
    fprintf('Automatic sequencing OFF\r');
end

Eyelink('command',  'inputword_is_window = ON');
       
       
pause(.05)

% dv.el.initBool = false;
c.el.maxTrialLength = 9; % in seconds
c.el.bufferSampleLength = 31;  % I'm not sure where to put this variable - I think it may be rig specific
c.el.bufferEventLength = 30;

c.useEyelink = 1;
       
Eyelink('message', 'SETUP');

Eyelink('StartRecording');
