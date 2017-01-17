function [PDS ,c ,s] = AttnMot_init(PDS ,c ,s)
% initialization function
% this is executed only 1 time, after the settings file is read in,
% as part of the 'Initialize' action from the GUI
% This is where values are defined for the entire experiment

%% Lab configuation parameters
c.viewdist                                      = 410;   % viewing distance (mm)
c.screenhpix                                    = 1200;  % screen height (pixels)
c.screenh                                       = 302.40; % screen height (mm)

%% initialize color lookup tables
% CLUTs may be customized as needed
% CLUTS also need to be defined before initializing DataPixx
c.humanCLUT                                     = c.humanColors;
c.monkeyCLUT                                    = c.monkeyColors;
c.humanCLUT(length(c.humanColors)+1:256,:)      = zeros(256-length(c.humanColors),3);
c.monkeyCLUT(length(c.monkeyColors)+1:256,:)    = zeros(256-length(c.monkeyColors),3);

%% initialize DataPixx
c                                               = init_DataPixx(c);
%% do other one-time initialization steps as desired
c.fixXY = [c.fixXY(1,1) -1*c.fixXY(1,2)]; % invert yaxis- as Psychtoolbox y-axis is positive downwards.
c.middleXY                                      = c.screenRect([3 4])/2; % center of the display
% Loc1 (RF location) X Y
[X,Y] = pol2cart(c.RFloctheta*pi/180,c.RFlocecc);                 %
c.locc1art = [X,-1*Y];
% Loc2 (RF opposite location) X Y
[a, b] = pol2cart(mod(180-c.RFloctheta,360)*pi/180,c.RFlocecc);
c.locc2art = [a;-1*b]';
%% initialize trialists for all trialtypes
% list of pointers to the trial types in trialtypes.m
[c.triallist_B, c.triallist_FA, c.triallist_SPA, c.triallist_PA, c.trialtype_values, c.trialtype_names]=trialcodes_AttnMot;

c.taskseq = randperm(4);
c.trialtype = c.taskseq(1);
if c.trialtype == 1
    c.current = 'B';
    c.triallist = c.triallist_B;
elseif c.trialtype == 2
    c.current = 'FA';
    c.triallist = c.triallist_FA;
elseif c.trialtype == 3
    c.current = 'SPA';
    c.triallist = c.triallist_SPA;
elseif c.trialtype == 4
    c.current = 'PA';
    c.triallist = c.triallist_PA;
end
%% initialize strobe codes
c.strobe=stimcodes_FST;
end

function [c] = init_DataPixx(c)
% INITDATAPIXX is a function that intializes the DATAPIXX, preparing it for
% experiments. Critically, the PSYCHIMAGING calls sets up the dual CLUTS
% (Color Look Up Table) for two screens.  These two CLUTS are in the
% condition file "c".
% Modified from initDataPixx, getting rid of global variables: window,
% screenRect, refreshrate, overlay

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
PsychImaging('AddTask', 'General', 'EnableDataPixxL48Output');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

c.combinedClut = [c.monkeyCLUT;c.humanCLUT];
[c.window, c.screenRect] = PsychImaging('OpenWindow', 1,[c.bc c.bc c.bc]);
Screen('LoadNormalizedGammaTable', c.window, c.combinedClut, 2);

Datapixx('Open');
Datapixx('StopAllSchedules');

%Datapixx('EnableDoutDinLoopback');
Datapixx('DisableDinDebounce');
Datapixx('SetDinLog');
Datapixx('StartDinLog');
Datapixx('SetDoutValues',0);
Datapixx('RegWrRd');

%     Datapixx('EnableAdcFreeRunning');
Datapixx('DisableDacAdcLoopback');
Datapixx('DisableAdcFreeRunning');          % For microsecond-precise sample windows
%     Datapixx('EnableVideoScanningBacklight'); % disable to avoid shadows
Datapixx('DisableVideoScanningBacklight'); %

end
