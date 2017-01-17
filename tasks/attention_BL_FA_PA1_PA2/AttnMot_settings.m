function [m, s, c] = AttnMot_settings(window, screenRect, refreshrate)
% for plexon
c.connectPLX = 0;
%% debug params
% pass = 1; simulate correct trials (for debugging)
c.passEye           = 0;
% pass = 1; simulate correct trials (for debugging)
c.passJoy           = 0;
%% params for saving data
%file suffix to be used when saving file
c.filesuffix =1;

%% reward timing params
% time to wait for reward after change if successfully detected
c.rewardwait        = .8;
% reward amount in solenoid duration
c.reward_duration       = 0.32;

%% Joystick params
% joystick press check voltage.
c.joythP            = 0.5;
% joystick release check voltage.
c.joythR            = 2;
% maximum time to wait for joypress release after change.
c.joypressmax_fpdim        = 0.8;
c.joypressmax_stim        = 0.8;
% min time to wait for joypress release after change.
c.joypressmin     = 0.3;



%% fixation params
% fixation point window width in deg
c.fpWindW          = 2;
% fixation point window height in deg
c.fpWindH          = 2;
% Fixation point/window hoirzontal center (in degrees).
c.fpX               = 0;
% Fixation point/window vertical center (in degrees).
c.fpY               = 0;
% fixation point location
c.fixXY=[c.fpX c.fpY];
% cursor (fixation) radius in pixels
c.cursorR           = 6;
% cursor (fixation) outer radius in pixels
c.cuecursorR           = 10;
% fixation-point pen-thickness
c.fixdotW           = 4;
% fixation-point outerborder (Cue) thickness
c.cuedotW           = 2;
% fixation-point outerborder (Cue) thickness
c.fixwinW           = 2;
% Gaze-position indicator radius in pixels
c.EyePtR            = 3;
% grid spacing in degrees
c.gridW             = 2;

% 1 if before injection dataset
c.preinjection = 0;
% 1 if during injection dataset
c.postinjection = 0;


%% The following functions must always be included and defined
% Define the m-files used for this protocol
% "initialization" m-file
m.initialization_file   = 'AttnMot_init.m';

% "next_trial" m-file
m.next_trial_file       = 'AttnMot_next.m';

% "run_trial" m-file
m.run_trial_file        = 'AttnMot_run.m';

% "finish_trial" m-file
m.finish_trial_file     = 'AttnMot_finish.m';

% "savedata" m-file
m.action_1              = 'savedata.m';

% "plotdata" m-file
m.action_2              = 'plotdata_AttnMot.m';

% "plotdata" m-file
m.action_3              = 'reward_give.m';

% "plotdata" m-file
m.action_4              = 'reward_drain.m';

% "plot_prepost_inj" m-file compares performance before and during inactivation
% m.action_3              = 'plot_prepost_inj.m';% used during inactivation to compare before and during

% Define the prefix for the Output File
c.output_prefix         = 'AttnMot';

% Define Banner text to identify the experimental protocol
c.protocol_title        = 'AttnMot_PROTOCOL';

%% TIMING params
% time before checking for joystick press check (s)
c.freeduration      = 0;
% time available to press joystick; repeat trial if not pressed (s)
c.joypresswaitstop  = 10;
% time available to enter fixation window (s)
c.fixwaitstop       = 1;
% max length of the trial (s)
c.trialmax          = 15;
% time between acquiring fixation and cue onset(s)
c.cueonset =0.3;
% cue duration(s)
c.cueduration=0.2;
% time between cue offset and stim onset(s)
c.cuedelay=0.5;
% time between acquiring fixation and stim onset(s)
c.stimwait        = c.cueonset + c.cueduration +c.cuedelay;
% min stim duration (s)
c.stimdur_min    = 1;
% variable stim duration (s)
c.stimdur_max   = 3.5;

%% stim size and location params
% STD of direction distribution in deg
c.dotdirstd = 16;
% change in motion direction when change occurs
c.del=26;
c.dels=[c.del 360-c.del];% CCW and CW changes
% dot life
c.dotslife = 10;
% speed degrees per second
c.dotspeed = 15;
% apertur radius in deg
c.aperture = 3;
% width of each dot in pixels
c.dotwidth = 6;
% density dots/deg^2/seconds
c.dotdensity = 25.0500;
% stim location ON flags:indicates which locations to present stim
c.loc1on = 0;% loc1: RF location
c.loc2on = 0;% loc2: opposite location
% eccetrencity of stimulus
c.RFlocecc = 10; %RF ecc for physiology
% stim location angle
c.RFlocthetas=[30 330]; %possible locations used during training
% RF loc during physiology after RF mapping
c.RFloctheta = 10;%c.RFlocthetas(randi([1 size(c.RFlocthetas,2)]));
% stimulus motion direction in deg (w.r.t horizontal in CCW direction)
c.RFprefdirs=[0 20 45 135 160 180 200 225 315 340]; %possible directions used during training
% RF prefered dir during physiology after dir tuning mapping
c.RFprefdir = 90;%c.RFprefdirs(randi([1 size(c.RFprefdirs,2)]));
% Loc1 dir
c.loc1dir = c.RFprefdir;
% Loc2 dir
c.loc2dir =  mod(180-c.RFprefdir,360);

%% params for computing behavior online
% compute behavior online (used in finish file)
c.updateplot = 0;
% cumulative array to show results for each block used in finish file
c.cumy=[];
% plotting window
c.plotwin           = figure('Position', [1500 100 1000 500]);
%% block, set and trial params
% blocktype/trialtype  (1-B;2-FA;3-PA_S;4-PA))
c.trialtype=1;%initialised to baseline blocks at start; will be randomised in init and run files
% trial counter for all trials
c.j = 1;
% trial counter with in block
c.trinblk = 1;
% block counter
c.blockno = 1;
% set counter
c.setno = 1;
% flag to repeat trial
c.repeattrial = 0;
% reward counter
c.NumRewards = 0;
% fix break counter
c.fixbreaks = 0;
% joy break counter
c.antrels = 0;
%% MISC
% zero for one screen set-up, 1 or 2 for multiscreen
c.screen_number     = 1;
% Joybar edges for the second CLUT
c.joybar            = [1600  800  1700  1100];
% time out duration
c.timeout = 1;
% tasktype % 1 = Visually guided saccades; 2 = Memory guided saccades; 3 = Attention task; 4 = Microstimulation
c.tasktype = 3;
%% COLORS %%%%%%%
c.bc                = 0.32; % background grey val
c.backcolor         = 4; % background index in LUT
c.fixcolor          = 6; % fixation point index in LUT
c.fixwincolor       = 5; % fixation point index in LUT
c.stimcolor         = 6; % motion dots color index in LUT
c.FA_color          = 1; % fixation point border (cue) index in LUT
c.PA_color          = 10;
c.cuecolor          = c.FA_color; % fixation point border (cue) index in LUT
c.ecolor            = 7;  % eye position CLUT indx
c.gridc             = 8;  % grid color
c.jpcolor           = 2; % joy press color
c.jrcolor           = 3; % joy release color
c.jr_iticolor       = 5; % iti waiting for joy release color
c.jprcolor          = 7; % neither press nor release color

c.dimvalue          = 11; %index for dimming
dimval1=0.527;
dimval2=0.529;
dimval3=0.530;

% colors for experimenter's display
% black                     0,1
% green                      2
% red                        3
% background color(grey)     4
% window color    (bright)   5
% fixation dot color(white) 6
% eye position color(blue)  7
% grid color                8
% save data color           9
% PA cue color              10
% fpdim1                    11
% fpdim2                    12
% fpdim3                    13
c.humanColors       = [ 0, 0, 0;                        % 0
    0, 0, 0;                        % 1
    0, 1, 0;                        % 2
    1, 0, 0;                        % 3
    c.bc, c.bc, c.bc;               % 4
    0.4, 0.4, 0.4;                  % 5
    0.54, 0.54, 0.54;               % 6
    0, 0, 1;                        % 7
    0.25, 0.25, 0.25;               % 8
    0, 0.1, 0.2;    % 9
    0.35, 0.2, 0.2; %10
    dimval1, dimval1, dimval1;% 11
    dimval2, dimval2, dimval2;% 12
    dimval3, dimval3, dimval3;];  % 13]

% colors for monkey's display
% black                     0,1
% green                      2
% red                        3
% background color(grey)     4
% window color    (bright)   5
% fixation dot color(white) 6
% eye position color(blue)  7
% grid color                8
% save data color           9
% PA cue color              10
% fpdim1                    11
% fpdim2                    12
% fpdim3                    13


c.monkeyColors = [  0, 0, 0;                        % 0
    0, 0, 0;                        % 1
    c.bc, c.bc, c.bc;               % 2
    c.bc, c.bc, c.bc;               % 3
    c.bc, c.bc, c.bc;               % 4
    c.bc, c.bc, c.bc;               % 5
    0.54, 0.54, 0.54;               % 6
    c.bc, c.bc, c.bc;               % 7
    c.bc, c.bc, c.bc;               % 8
    0, 0.1, 0.2;   % 9
    0.35, 0.2, 0.2;% 10
    dimval1, dimval1, dimval1;% 11
    dimval2, dimval2, dimval2;% 12
    dimval3, dimval3, dimval3;];  % 13]

%%  Status values.
s.TrialNumber = c.j; % What is the current trial number?
s.TrinBlk = c.trinblk;
s.trialtype = c.trialtype;
s.trialcode = 0;
s.fixChangeTrial = 0;
s.stimChangeTrial = 0;
s.Changeloc = 1;
s.blockno = c.blockno;
s.setno = c.setno;
s.NumRewards = c.NumRewards;
s.fixbreaks = c.fixbreaks;
s.antrels = c.antrels;
end
