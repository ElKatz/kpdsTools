function [m, s, c] = joypress_settings(window, screenRect, refreshrate)                                          
% Joy press + Fixation + Release then reward settings file                                            
% fpon means FP on or Fp off, fixholdduration = duration that the monkey  


% has to press the joystick                                                                           


%% VALUES THAT WILL FIRST SHOW UP IN GUI:                                                              GUI VALUES:
% the gui is hardcoded such that the first 8 c.* values appear as popup
% menus, and the following 4 appear as slidebars.


   c.proportionCueTransient = 0.7;

    
    c.filesuffix =1;
	c.j = 1; % trial counter for all trials
    
    % change in motion direction when change occurs    
    c.del=26;
    
    c.trinblk = 1;  % trial counter with in block    
    
	c.finish  = 5000;% Total number of trials to run  

% maximum time to wait for joypress release after change.                                                         
	c.joypressmax        = 0.8;
% min time to wait for joypress release after change.
	c.joypressmin     = 0.3;
% time to wait for reward afetr joy release on change
    c.rewardwait        = 1; % use for physiology

% reward related vars                                                 
	c.reward_time_init       = 0.3; % lnk: 0.26;% baseline reward
    c.progrewardcount          =0;%counter for progresive reward
    c.progrewardcountflag=0;% flag to use the prog reward
    c.fixbreakflag=0;%flag for fixation break (used to break the prog reward)
       
    
% Approximate ratio of change to no-change trials.
    c.changeratio       = 0.7;
    
% var indicating blocktype  (1-B;2-FA;3-PA))
    c.trialtype=1;%initialised to baseline blocks at start
    c.prevtrialtype=c.trialtype;% to indicate previous block type to alternate between FA and PA blocks

    % fixation point window width in deg
    c.fp1WindW          = 2;

% fixation point window height in deg
    c.fp1WindH          = 2;

% Fixation point/window hoirzontal center (in degrees).
    c.fpX               = 0;
    
% Fixation point/window vertical center (in degrees).
    c.fpY               = 0;
    

%% MANADATORY FILE SPECIFICATIONS:
% User must specify requisite quartet of file in order for pldaps to run:
% the init, next, run, & finish files.

% Define the m-files used for this protocol                                                           
% "initialization" m-file                                                                             
	m.initialization_file   = 'joypress_init.m';
    
% "next_trial" m-file                                                                                 
	m.next_trial_file       = 'joypress_next.m';
    
% "run_trial" m-file                                                                                  
	m.run_trial_file        = 'joypress_run.m';
    
% "finish_trial" m-file                                                                               
	m.finish_trial_file     = 'joypress_finish.m';
    
%% GUI ACTIONS:
% gui is hardcoded to allow up to 9 user-defined actions.
% these action functions have the following input/output:
%   function [PDS ,c ,s] = functionName(PDS ,c ,s)

% "savedata" m-file
    m.action_1              = 'savedata.m';
    
% "plotdata" m-file
    m.action_2              = 'plotdata.m';
    
    m.action_3              = 'plot_prepost_inj.m';    
    
    % lnk: reward give action:
    m.action_4              = 'reward_give.m';  
    % lnk: reward drain action:
    m.action_5              = 'reward_drain.m';  
    

% Define the prefix for the Output File                                                               
	c.output_prefix         = 'joypress';

% Define Banner text to identify the experimental protocol                                            
	c.protocol_title        = 'joypress_PROTOCOL';

%% End of obligatory values section                                                                   


%% Other parameter values
    
 
  c.preinjection = 0;
    c.postinjection = 0;

    c.playAudioBool = 0;

% pass = 1; simulate correct trials (for debugging)                                                   
	c.passEye           = 0;
    
% pass = 1; simulate correct trials (for debugging)                                                   
	c.passJoy           = 0;
    
    
% FP on?
% 
	c.fpon              = 1;
    

% cursor (fixation) radius in pixels
    c.cursorR           = 6;
    
% cursor (fixation) outer radius in pixels
    c.cursorR2           = 10;
% Gaze-position indicator radius in pixels
    c.EyePtR            = 3;
                                                                                                      
% fixation-point pen-thickness
    c.fixdotW           = 4;
    c.fixdotW2           = 2;%outerborder thickness
% fixation-wind width
    c.fixwinW           = 2;

% Voltage joyr press ON
    c.joythP            = 0.5;
    
% joystick release check voltage.                          
	c.joythR            = 2;

% cursor width in pixels
    c.cursorW           = 6;
 
 % location on flags:indicates which locations to show   
    c.loc1on = 1;

	c.loc2on = 1;  
    

% plotting window
     c.plotwin           = figure('Position', [1200 100 1000 500]);

%%% SIZE %%%%%%%%                                                                                     

% eye position width in pixels                                                                        
	c.eyeW              = 6;
% grid spacing in degrees                                                                             
	c.gridW             = 2;


% using datapixx                                                                                      
	c.useDataPixxBool   = 1;

% 0 = continue, 1 = pause, 2 = quit                                                                   
	c.quit              = 0;
    
% zero for one screen set-up, 1 or 2 for multiscreen  
	c.screen_number     = 1;


%%% TIMING  %%%%%%%                                                                                   
% time before checking for joystick press check (s)                                                       
	c.freeduration      = 0;

% time available to press joystick; repeat trial if not pressed (s)                                   
	c.joypresswaitstop  = 10;
    
% time available to enter fixation window (s)                                                         
	c.fixwaitstop       = 1;
    
% variable time to keep press the joystick (s)/ for change of stimulus                                                                 
	c.fixholdrand   = 2.5;%random time after stim onset
	c.fixholdmin    = 1;% min time after stim onset
    
% max length of the trial (s)                                                                         
	c.trialmax          = 15;

% time to release joystick to get reward. (s)                                                         
	c.joyrelwaitstop    = 1;

% time between acquiring fixation and stim onset. (s)                                            
    c.cueonset =0.2;
    % lnk: original:
    c.cueduration=0.3;
    c.cuedelay=0.4;
    % lnk: such that cue overlaps with motion for .3s at first, then
    % doesn't, and gets gradually reduced to a 0.4 cueduration.
%     c.cueduration= 1.2;
%     c.cuedelay= -.3;
    
    
	c.motionwait        = c.cueonset + c.cueduration +c.cuedelay;
%%% LOCATIONS & Sizes  %%%%%                                                                          

% fixation point location                                                                             
	c.fixXY             = [0  0];

% eccetrencity of stimulus                                                                          
	c.RFlocecc            = 10; %RF ecc for physiology
    
% stim location angle                                                                                                      
    c.RFlocthetas=[30 330];
    c.RFloctheta = 30;%c.RFlocthetas(randi([1 size(c.RFlocthetas,2)]));

% stimulus motion direction in deg                                                                                             
       c.RFprefdirs=[0 20 45 135 160 180 200 225 315 340];
%        c.RFprefdir = 45;%c.RFprefdirs(randi([1 size(c.RFprefdirs,2)]));        lnk
       c.RFprefdir = 135;%c.RFprefdirs(randi([1 size(c.RFprefdirs,2)]));  
       
% STD of direction distribution in deg    
    c.dotdirstd = 16;  
    


% dot life    
    c.dotslife = 10;
% speed degrees per second    
    c.dotspeed = 15; 
% apertur radius in deg    
    c.aperture = 3;
% density dots/deg^2/seconds
    c.dotdensity = 25.0500;

% Joybar edges for the second CLUT                                                                    
	c.joybar            = [1600  800  1700  1100];
    
% jitter initial motion direction    
    c.motiondirjitr = [ -0 0 0 ];    

 % flags to save PDS struct and compute behavior online (used in finish file)   
 c.saved=0;
 c.compute=0;
% cumulative array to show results for each block
    c.cumy=[];
% for plexon    
c.connectPLX = 0;
%for nactivation
c.inactivation = 0;
%%% COLORS %%%%%%%      
%background color                                                                                     
	c.bc                = 0.32; % background grey val
    c.backcolor         = 4; % background index in LUT
    c.savecolor         = 9;
    c.fixcolor          = 6; % fixation point index in LUT   
    c.fixbordercolor    = 1; % fixation point border index in LUT   
%      dimval1=0.529;dimval2=0.530;dimval3=0.531;
%      dimval1=0.527;dimval2=0.528;dimval3=0.529;
     dimval1=0.52;  dimval2=0.525;  dimval3=0.527;     


    c.dimvalue=11;%index for dimming

 % define block and sets   (set is collection of 4 blocks)
    c.trialsperblock_init=60;% for FA and PA blocks)
    c.trialsperblock=floor(c.trialsperblock_init/6);% B blocks half the FA and PA blocks
    c.blocksperset=4;
    c.blockno   = 1; % init block no
    c.setno=1; % init set no
    c.repeatblock=0; % repeat block flag to use for PA blocks (see finish file) if fixbrekas >2 in PA blocks (used to repeat PA block)
    c.blockstartflag=1;% flag to avoid repeating of saving data / block start (see finsih file)
    % count for behav params
    c.blocksetflag=0;
    c.repeattrial=0;
    c.fixbreaks=0;
    c.blinks=0;
    c.saccades=0;
    c.antrels=0;
    c.fixvoilations=0;% another fix breaks counter to use for reset blocks separately (used during trianing;see finish file)
% colors for experimenter's display                                                                   
% black                     0,1                                                                          
% cursor (grey)             2                                                                               
% target color              3                                                                               
% background color(grey)    4                                                                          
% window color    (black)   5                                                                          
% fixation dot color(white) 6                                                                          
% eye position color(blue)  7                                                                          
% grid color                8                                                                                   
% save data color           9
% fpdim1                    11
% fpdim2                    12
% fpdim3                    13
	c.humanColors       = [ 0, 0, 0;                        % 0
                            0, 0, 0;                        % 1
                            0, 1, 0;                        % 2
                            1, 0, 0;                        % 3
                            c.bc, c.bc, c.bc;               % 4
                            0.7, 0.7, 0.7;                  % 5
                            0.54, 0.54, 0.54;                        % 6
                            0, 0, 1;                        % 7
                            0.25, 0.25, 0.25;               % 8
                            0, 0.1, 0.2;    % 9
                            0.35, 0.2, 0.2; %10
                            dimval1, dimval1, dimval1;% 11  
                            dimval2, dimval2, dimval2;% 12  
                            dimval3, dimval3, dimval3;];  % 13]    

% colors for monkey's display                                                                         
% black                     0,1                                                                          
% cursor (grey)             2                                                                               
% target color              3                                                                               
% background color(grey)    4                                                                          
% window color    (black)   5                                                                          
% fixation dot color(white) 6                                                                          
% eye position color(blue)  7                                                                          
% grid color                8                                                                                   
% save data color           9
% fpdim1                    11
% fpdim2                    12
% fpdim3                    13

        
        c.monkeyColors = [  0, 0, 0;                        % 0
                            0, 0, 0;                        % 1
                            c.bc, c.bc, c.bc;               % 2
                            c.bc, c.bc, c.bc;               % 3
                            c.bc, c.bc, c.bc;               % 4
                            c.bc, c.bc, c.bc;               % 5
                            0.54, 0.54, 0.54;                        % 6
                            c.bc, c.bc, c.bc;               % 7
                            c.bc, c.bc, c.bc;               % 8
                            0, 0.1, 0.2;   % 9
                            0.35, 0.2, 0.2;% 10  
                            dimval1, dimval1, dimval1;% 11  
                            dimval2, dimval2, dimval2;% 12  
                            dimval3, dimval3, dimval3;];  % 13]

%%  Status values.
%   Not sure what to do with these yet so I'm going to put a dummy value in
%   for now. (jph - 11/26/2012)
    s.TrialNumber   = c.j; % What is the current trial number?
    s.TrinBlk   = c.trinblk;
    s.NumRewards    = 0;
    s.dirChangeTrial   = 0;
    s.Changeloc   = 1;
    s.fixChangeTrial=0;
    s.RewardTime    = c.reward_time_init;
    s.fixgoodblocks4=0;
    s.fixgoodblocks3=0;
    s.fixgoodblocks2=0;
    s.fixgoodblocks1=0;
    s.fixbreaks=c.fixbreaks;
        s.blockno=c.blockno;
        s.setno=c.setno;
        s.repeatblock=c.repeatblock;
    s.FixHoldReq    = 0; % How long must the joystick be held below threshold on the current trial?
    s.JoyPressT     = 0; % What time was the joystick pressed?
    s.JoyReleaseT   = 0; % What time was the joystick released?
    s.trialcode = 0;
    s.antrels=c.antrels;
%% Audio Stuff
% Variables.
c.freq          = 48000;                % Sampling rate.
c.rightFreq     = 300;                  % A low-frequency tone to signal "WRONG" 
c.wrongFreq     = 150;                  % A high-frequency tone to signal "RIGHT"
c.nTF           = round(c.freq/10);     % The tone-duration.
c.lrMode        = 0;                    % Mono sound on both channels.
c.wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.
 
% Make a plateau-ed window with gaussian rise and fall at the beginning and
% end. Start by making the gaussian rise at the beginning. Use somewhat
% arbitrary values of MU and SIGMA to position the rise/fall in a place that
% you like.
risefallProp                    = 1/4;                              % proportion of sound for rise/fall
plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
mu1                             = round(risefallProp*c.nTF);        % Gaussian mean expressed in samples
sigma1                          = round(c.nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.

tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
                                ones(1,round(plateauProp*c.nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
                                fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL
 
% Additively scale the window to ensure that it starts and ends at zero.
tempWindow                      = tempWindow - min(tempWindow);
 
% Multiplicatively scale the window to put the plateau at one.
tempWindow                      = tempWindow/max(tempWindow);
 
% Make the two sounds, one at 150hz ("righttone"), one at 300hz ("wrongtone").
c.wrongtone     = tempWindow.*sin((1:c.nTF)*2*pi*c.wrongFreq/c.freq);
c.righttone     = tempWindow.*sin((1:c.nTF)*2*pi*c.rightFreq/c.freq);
c.noisetone     = tempWindow.*((rand(1,c.nTF)-0.5)*2);

% Normalize the windowed sounds (keep them between -1 and 1.
c.wrongtone     = c.wrongtone/max(abs(c.wrongtone));
c.righttone     = c.righttone/max(abs(c.righttone));
c.noisetone     = c.noisetone/max(abs(c.noisetone));
end
