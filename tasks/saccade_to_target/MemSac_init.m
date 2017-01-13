function [PDS ,c ,s] = MemSac_init(PDS ,c ,s)
% initialization function
% this is executed only 1 time, after the settings file is read in,
% as part of the 'Initialize' action from the GUI
% This is where values are defined for the entire experiment

%% Reposition GUI window
allobj = findall(0);

for i = 1:length(allobj)
    if isfield(get(allobj(i)),'Name')
        if strfind(get(allobj(i),'Name'),'pldaps_gui2_beta')
            set(allobj(i),'Position',[5 5 133.8333   43.4167]);
            break;
        end
    end
end
%% Geometry
c.viewdist                      = 410;      % viewing distance (mm)
c.screenhpix                    = 1200;     % screen height (pixels)
c.screenh                       = 302.40;   % screen height (mm)

%% Initialize LUT
c                               = lutinit(c);

%% Initialize DataPixx
c                               = init_DataPixx(c);
%% user defined locations
c.userlocs = zeros(0,2);

%   [c.targX,c.targY] = meshgrid(-5:5:20,-10:5:10);  % RF mapping
[c.targX,c.targY] = meshgrid(-20:5:20,-10:5:10); % Velocity deficit mapping


c.targX = c.targX(:);
c.targY = c.targY(:);
centr = find(c.targX==0 & c.targY==0);
c.targX(centr) =[];
c.targY(centr)=[];
shuffle = randperm(size(c.targX,1));
c.targX = c.targX(shuffle);
c.targY = c.targY(shuffle);
[c.gridX,c.gridY] = meshgrid((-25:0.5:25),(-10:0.5:10));

temp = load ('control_sac_vel_barnum');

c.X=temp.X;%X,Y eye h,v pos
c.Y=temp.Y;
c.EV = temp.V;
c.A=temp.A;% A,B target h, v pos
c.B=temp.B;
end

%% Helper functions

function c                      = init_DataPixx(c)
% INITDATAPIXX is a function that intializes the DATAPIXX, preparing it for
% experiments. Critically, the PSYCHIMAGING calls sets up the dual CLUTS
% (Color Look Up Table) for two screens.  These two CLUTS are in the
% condition file "c".
% Modified from initDataPixx, getting rid of global variables: window,
% screenRect, refreshrate, overlay

if c.useDataPixxBool
    AssertOpenGL;
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'EnableDataPixxL48Output');
    
    c.combinedClut = [c.monkeyCLUT;c.humanCLUT];
    [c.window, c.screenRect] = PsychImaging('OpenWindow', 1, [0 0 0]);
    c.middleXY = [c.screenRect(3)/2 c.screenRect(4)/2];
    Screen('LoadNormalizedGammaTable', c.window, c.combinedClut, 2);
    
    % load an identity CLUT into the graphics-card hardware to make sure that
    % it doesn't transform our pixel colors at all. DON'T use the 2-flag for
    % this so that it gets loaded into the graphics-card hardware and not the
    % ViewPIXX.
    Screen('LoadNormalizedGammaTable', c.window, repmat(linspace(0,1,256)',1,3));
    %PsychTweak('UseGPUIndex', 1);
    %Screen('Preference', 'ScreenToHead', 1, 1, 0);
    
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    
    %     Datapixx('EnableAdcFreeRunning');
    Datapixx('DisableDacAdcLoopback');
    Datapixx('DisableAdcFreeRunning');          % For microsecond-precise sample windows
    Datapixx('EnableVideoScanningBacklight');
    
else
end
end

function c                      = lutinit(c)
% initialize color lookup tables
% CLUTs may be customized as needed
% CLUTS also need to be defined before initializing DataPixx

bgRGB                                           = [0.45 0.45 0.45];

fixColor                                        = [0.45, 0.65, 0.45];

c.backcolor         = 2;

% colors for EXPERIMENTER's display
% black                     0
% grey-1 (grid-lines)       1
% grey-2 (background)       2
% grey-3 (fix-window)       3
% white  (target-point)     4
% red                       5
% green                     6
% blue                      7
% dimmed Target             8
% fixation                  9

c.humanColors       = [ 0, 0, 0;                        % 0
    0.35, 0.35, 0.35;               % 1
    bgRGB;                          % 2
    0.2, 0.2, 0.2;                  % 3
    0.82, 0.82, 0.82;               % 4
    0.47,0.47,0.47;                 % 5
    0, 1, 0;                        % 6
    0, 0, 1;                        % 7
    0.65,0.65,0.65;                    % 8
    fixColor];                      % 9

% colors for MONKEY's display
% black                     0
% grey-2 (grid-lines)       2
% grey-2 (background)       2
% grey-2 (fix-window)       3
% white  (target-point)     4
% grey-2 (red)              2
% grey-2 (green)            2
% grey-2 (blue)             2
% dimmed Target             8
% fixation                  9

c.monkeyColors       = [ 0, 0, 0;                       % 0
    bgRGB;                          % 1
    bgRGB;                          % 2
    bgRGB;                          % 3
    0.82, 0.82, 0.82;               % 4
    0.465,0.465,0.465;                 % 5
    bgRGB;                          % 6
    bgRGB;                          % 7
    0.65,0.65,0.65;                    % 8
    fixColor];                      % 9

c.ffc                                           = size(c.humanColors,1)+1;
c.humanCLUT                                     = c.humanColors;
c.monkeyCLUT                                    = c.monkeyColors;
c.humanCLUT(length(c.humanColors)+1:256,:)      = zeros(256-length(c.humanColors),3);
c.monkeyCLUT(length(c.monkeyColors)+1:256,:)    = zeros(256-length(c.monkeyColors),3);
end