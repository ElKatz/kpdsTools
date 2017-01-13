function [m, s, c] = memsacsettings(window, screenRect, refreshrate)
% Joy press + Fixation + Release then reward settings file
% fpon means FP on or Fp off, fixholdduration = duration that the monkey
% has to press the joystick


%% VALUES THAT WILL FIRST SHOW UP IN MENU

% 1
c.vissac = 1;

% 2
% reward magnitude (solenoid opening time in seconds)
c.rewardDur         = 0.1;%0.19 for memsac

% 3
% Target point window height in deg
c.tpWindH          = 4;

% 4
% Target point window width in deg
c.tpWindW          = 4;

% 5
% pass = 1; simulate correct trials (for debugging)
c.passEye           = 0;

% 6
%
c.filesufix = 1;

% 7
% connect to Plexon to get data
c.connectPLX = 0;

% 8
c.mapeyevelocity = 0;

% 9
% maximum post-saccade fixation duration
c.maxTargFix        = 0.5;

% 10
% duration of target-flash
c.targetFlashDur    = 0.2;

% 11
% minimum post-flash fixation-duration
c.postFlashFixMin   = 1;

% 12
% maximum post-flash fixation-duration
c.postFlashFixMax   = 1.5;

%% The following values must always be included and defined
%% These two values are always shown in menu

% Define the m-files used for this protocol
% "initialization" m-file
m.initialization_file   = 'MemSac_init.m';

% "next_trial" m-file
m.next_trial_file       = 'MemSac_next.m';

% "run_trial" m-file
m.run_trial_file        = 'MemSac_run.m';

% "finish_trial" m-file
m.finish_trial_file     = 'MemSac_finish.m';

% "savedata" m-file
m.action_1              = 'save_data.m';

% "savedata" m-file
m.action_2              = 'saveplot.m';

% "user-defined action #5' m-file
m.action_3              = 'repeat.m';

% "user-defined action #5' m-file
m.action_4              = 'repeat20.m';

% "savedata" m-file
m.action_5              = 'quit_repeating.m';

% "savedata" m-file
m.action_6              = 'toggleVisMem.m';

% "savedata" m-file
m.action_7              = 'show_sparks.m';

% "user-defined action #5' m-file
m.action_8              = 'mapEyeVelocity.m';

% "user-defined action #5' m-file
m.action_9              = 'Inactivation_ON.m';


% Define the prefix for the Output File
c.output_prefix         = 'MemSac';

% Define Banner text to identify the experimental protocol
c.protocol_title        = 'MemSac_protocol';

%% End of obligatory values section


%% Other parameter values
%
c.Rrepeat = 0;
%
c.inactivation = 0;
%
c.showsparks = 0;
% minimum post-saccade fixation duration
c.minTargFix        = 0.5;
% minimum saccade-latency criterion
c.minLatency        = 0.1;
% minimum fixation-only time before target onset
c.preTargMin        = 0.75;
% maximum fixation-only time before target onset
c.preTargMax        = 1;
% maximum saccade-latency criterion
c.maxLatency        = 0.5;
% maximum time to wait for fixation-acquisition
c.maxFixWait        = 5;
% condition target reappearance on saccade?
c.targOnSacOnly     = 1;
% repeat trial if true
c.repeat = 0;
%
c.targetdelay = 0.25;
% if we're training the animal to make memory guided sacacdes, we'll delay
% the onset of the target after fixation offset without making it saccade
% contingent. What should this delay be?
c.targTrainingDelay     = 0;

% how long to time-out after an error-trial (in seconds)?
c.timeoutdur        = 0.275;

% minimum target amplitude
c.minTargAmp        = 4;

% maximum target amplitude
c.maxTargAmp        = 15;

% delay reward delivery after a correctly performed trial
c.rewardDelay       = 0;

% do we want there to be a time-out penalty following incorrect trials?
c.timeout       = 0;

% ITERATOR for current trial count
c.j                 = 1;
%
c.finish           = 500;

% current trial number (excluding fixation breaks and non-starts)
c.trialnumber       = 1;

% fixation point/window hoirzontal center (in degrees).
c.fpX               = 0;

% fixation point/window vertical center (in degrees).
c.fpY               = 0;

% fixation point window height in deg
c.fpWindH          = 1.5;

% fixation point window width in deg
c.fpWindW          = 1.5;


% Total number of trials to run
c.finish            = 10000;

% FP dimming (or going off).
c.fpdimflag         = 0;

% cursor (fixation) radius in pixels
c.cursorR           = 6;

% Gaze-position indicator radius in pixels
c.EyePtR            = 3;

% fixation-point pen-thickness
c.fixdotW           = 4;

% fixation-point pen-thickness
c.fixwinW           = 1;

% flag variable controls trial-randomization stuff...
c.flag              = 2;

% Voltage joyr press ON
c.joythP            = 0.5;

% joystick release check voltage. (press is < joythP; release is >= joythR)
c.joythR            = 2;

% cursor width in pixels
c.cursorW           = 6;

% framerate
c.framerate         = 100;

% using datapixx
c.useDataPixxBool   = 1;

% ITERATOR for # of good trials
c.goodtrial         = 0;


% zero for one screen set-up, 1 or 2 for multiscreen
c.screen_number     = 1;

% time before start of fix point (s)
c.ITI      = 0.1;

% max length of the trial (s)
c.maxDur            = 10;

% Joybar edges for the second CLUT
c.joyBarCoords      = [1600  800  1700  1100];
% 
c.stdcnt = 1;
%
c.nrepeats = 2;
%
c.repeatcnt = 1;


%%  Status values.
s.TrialNumber       = 1; % What is the current trial number?
s.ngood             = 0;
s.TrialType         = 0;
s.preTargDur        = 0;
s.overlapDur        = 0;
s.targFixDurReq     = 0;
s.SaccadeLatency    = 0;
s.repeat20          = 0;
s.repeatcount       = 0;
s.fixXY             = [0 0];
s.targXY            = [0 0];
s.X=[];
s.Y=[];
s.sacV=[];
s.chV = [];
s.sact = [];

end
