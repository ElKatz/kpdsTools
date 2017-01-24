function [PDS ,c ,s]= MemSac_run(PDS ,c ,s)
% run_trial function
% Execution of this m-file accomplishes 1 complete trial
% It is part of the loop controlled by the 'Run' action from the GUI;
% It is preceded by 'next_trial' and followed by 'finish_trial'

% The whole function runs as WHILE loop, checking for changes in eye and
% joystick position. When certain positions are met, the state variable is updated
% 0,0.25(Joy Press),0.5(fixation acquired),1(change time or reward time(no change trial)), 1.5 (reward time for change trial)
% ending in either 3 (broke fixation),3.1(broke joystick press), 3.2 (did not release joystick in time), 3.3(did not press joy stick in time; repeat trial) or 1.5 (joystick release).


% trial-variables and hardware initialization
[PDS, c, s, t]      = trial_init(PDS, c, s);

%%%%% Runtrial While-Loop           %%%%%
while  ~any(t.state == t.endStates)
    
    % get analog voltages (joystick and gaze position)
    [s.EyeX, s.EyeY, t.joy] = getEyeJoy(c);
            
    t.ttime = GetSecs - t.trstart;
    switch t.state
        case 0
            %%%%% STATE 0 = BEFORE fixation-onset
            % If the current time is greater than "c.freeduration" (the amount of
            % time to wait before checking for fixation acquisition), set state 0.1
            % (turn on fixation and start looking for fixation
            % acquisition).
            if  t.ttime > c.ITI
                startrecording; % omniplex
                WaitSecs(0.15);
                start = 1;
                strobe(30001)
                t.state     = 0.1;
                
                % show the fixation ( and fixation-window on exp-disp)
                t.fcolor    = 8;
                t.fwcolor   = 3;
                
                % note the time of fixation-onset
                t.timeFPON  = GetSecs - t.trstart;
            end
            
        case 0.1
            %%%% STATE 0.1 = WAITING for fixation-acquisition
            % If it's past the time to start checking for fixation acquisition,
            % and the fixation has been acquired, set state 0.25.
            if checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                t.state = 0.25;
                strobe(3004)
                t.timeFA = GetSecs - t.trstart; % time of Fix acq
            elseif t.ttime > c.maxFixWait
                t.state = 3.3;
            end
            
        case 0.25
            %%%% STATE 0.25 = MAINTAIN fixation
            if t.ttime < (t.timeFPON + s.preTargDur) && checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation maintained
                
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation broken!
                strobe(3005) 
                t.state                 = 3;
                t.timeBF                = GetSecs - t.trstart; % time broke joy fixation
                             
            elseif t.ttime >= (t.timeFPON + s.preTargDur)
                strobe(4001)
                % Set state 0.5 - maintain fixation during overlap period
                t.state                 = 0.5;
                
                % Turn on target (and fixation-window on exp-disp)
                t.tcolor                = 4;
                t.twcolor               = 1;
                
                % note the time of target onset
                t.timeTFON              = GetSecs - t.trstart;
            end
            
        case 0.5
            %%%% STATE 0.5 = MAINTAIN fixation during target-flash
            if t.ttime < (t.timeTFON + c.targetFlashDur) && checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation maintained
                
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                strobe(3005)
                % Fixation broken during overlap period
                t.state                 = 3.1;
                
                % Note time of fixation-break
                t.timeBF                = GetSecs - t.trstart;
                
            elseif t.ttime >= (t.timeTFON + c.targetFlashDur)
                strobe(4003)
                % Set state 0.75 - waiting for saccade to target
                t.state                 = 0.75;
                
                % extinguish target
                if ~c.vissac
                    t.tcolor = c.backcolor;
                end
                t.twcolor               = 3;
                
                % Note time of fixation offset
                t.timeTFOFF            = GetSecs - t.trstart;
            end
            
        case 0.75
            %%%% STATE 0.75 = MAINTAIN fixation after target-flash prior to
            %%%% fixation offset
            if t.ttime < (t.timeTFOFF + s.postFlashFixDur) && checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation maintained
                
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                strobe(3005)
                % Fixation broken
                t.state                 = 3;
                
                % Note time of fixation-break
                t.timeBF                = GetSecs - t.trstart;
                
            elseif t.ttime >= (t.timeTFOFF + s.postFlashFixDur)
                strobe(3003)
                % Set state = 1 - wait for saccade onset
                t.state         = 1;
                
                % Turn off fixation
                t.fcolor          = c.backcolor;
                t.fwcolor         = 3;

                % Note time of fixation-offset
                t.timeFIXOFF    = GetSecs - t.trstart;
            end
            
        case 1
            %%%% STATE 1 = Wait for SACCADE onset. If we're still in
            %%%% "training" then we'll turn the target on immediately (or
            %%%% after some fixed delay relative to fixation offset),
            %%%% otherwise, target reappearance is contingent on a saccade
            %%%% into the target-window.
            
            if ~c.targOnSacOnly && t.ttime > (t.timeFIXOFF + c.targTrainingDelay)
                % Turn on target (and fixation-window on exp-disp)
                t.tcolor                = 4;
                t.twcolor               = 1;
            end

            if t.ttime > (t.timeFIXOFF + c.minLatency) && t.ttime < (t.timeFIXOFF + c.maxLatency) && (checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH]) && ~c.passEye)
                % No saccade onset yet.

            elseif t.ttime < (t.timeFIXOFF + c.minLatency) && ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Anticipatory saccade!
                t.state                 = 3.1;
                strobe(3005)
                % Note time of fixation-break
                t.timeBF                = GetSecs - t.trstart;
                
            elseif t.ttime > (t.timeFIXOFF + c.maxLatency)
                % Didn't make a saccade within latency window!
                t.state               =  3.2;
                t.tcolor                = 4;
                t.twcolor               = 1;
            elseif t.ttime > (t.timeFIXOFF + c.minLatency) && t.ttime < (t.timeFIXOFF + c.maxLatency) && (~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH]) || c.passEye)
                strobe(7005)
                % fixation-window exit! (presumed saccade onset)
                t.state                 = 1.15;
                
                % note time of saccade onset
                t.timeSACON             = GetSecs - t.trstart;
                
                % display saccade latency
                s.SaccadeLatency        =  t.timeSACON - t.timeFIXOFF;
            end
            
        case 1.15
            
            %%%% STATE 1.15 = check saccade landing position.
            if t.ttime < (t.timeSACON + 0.045)
                % saccade IN-FLIGHT
                
            elseif t.ttime > (t.timeSACON + 0.045) && ~checkEye(c.passEye, t.PtargXY-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                % saccade landed outside target window
                t.state                 =  3.2;
                
                % extinguish target (it might be on because of training)
                t.tcolor                = c.backcolor;
                t.twcolor               = 3;
                
                
            elseif t.ttime > (t.timeSACON + 0.045) && checkEye(c.passEye, t.PtargXY-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                strobe(4004)
                % saccade landed inside target window - set state 1.25 =
                % maintain target fixation
                t.state                 = 1.25;
                
                % Turn on target (and fixation-window on exp-disp)
%                 t.tcolor                = 4;
                t.twcolor               = 3;
                
                % note time of target acquisition
                t.timeTA                = GetSecs - t.trstart;
            end
            
        case 1.25
            
            %%%% STATE 1.25 = MAINTAIN target fixation
            if t.ttime < (t.timeTA + s.targFixDurReq) && checkEye(c.passEye, t.PtargXY-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                % target fixation maintained
                if t.ttime > t.timeTA + c.targetdelay
                    t.tcolor = 4;
                end
            elseif ~checkEye(c.passEye, t.PtargXY-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                strobe(4005)
                % target fixation broken
                t.state                 = 3.3;
                
                % note time of broken target fixation
                t.timeBTF               = GetSecs - t.trstart;
                
            elseif t.ttime >= (t.timeTA + s.targFixDurReq) && checkEye(c.passEye, t.PtargXY-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                % correct trial, delay reward delivery
                t.state                 = 1.35;
                
                % extinguish target
                t.tcolor          = c.backcolor;
                t.twcolor         = 3;

                % note time that target fixation maintenance was completed
                t.timeTFC               = GetSecs - t.trstart;
            end
                
        case 1.35
            %%%% STATE 1.35 = deliver reward after a delay
            if t.ttime > t.timeTFC + c.rewardDelay
                strobe(8000)
                t.state       = 1.5;
                Datapixx('SetDacSchedule', 0, t.Dacrate, t.ndacsamples, t.chnl, t.dacBuffAddr, t.ndacsamples);
                Datapixx('StartDacSchedule');
                Datapixx('RegWrRd');
                t.timeRWD     = GetSecs - t.trstart;
            end
    end
    
    % Do all the drawing, first note what time it is so we can compute what
    % frame we're in, relative to cue-onset (timeCON).
    t.ttime       = GetSecs - t.trstart;
    if t.ttime > t.lastframetime + t.frametimestep - t.magicNumber
        
        % Fill the window with the background color.
        Screen('FillRect', c.window, c.backcolor)
        
        % Draw the grid
        Screen('DrawLines', c.window, t.GridXY,[], t.gridc, c.middleXY)
        
        % Draw the gaze position, MUST DRAW THE GAZE BEFORE THE
        % FIXATION. Otherwise, when the gaze indicator goes over any
        % stimuli it will change the occluded stimulus' color!
        Screen('FillRect', c.window, t.ecolor, [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2))
        
        % Draw the fixation and or target point / window (if desired)
        fixdotframe(c, t)
        
        % Flip (note the time relative to trial-start).
        t.lastframetime = Screen('Flip', c.window, GetSecs + 0.00) - t.trstart;
    end
end

Screen('Flip', c.window);
%%%%% Runtrial While-Loop (end)     %%%%%

%% Send Omniplex stim info and stop recording
if start == 1
    sendOmniPlexStimInfo(c,s);
    strobe(30009)
    stoprecording; % omniplex
end

%% finalize stuff & store data to be saved.
[PDS, c, s]         = trial_end(PDS, c, s, t);

end         % end of run function


%% Helper functions.

function [EyeX, EyeY, joy]  =   getEyeJoy(c)

% update data-pixx registers
Datapixx('RegWrRd')

% read voltages
V       = Datapixx('GetAdcVoltages');

% Convert eye-voltages into screen-pixels.
EyeX    = -sign(V(1))*deg2pix(4*abs(V(1)),c);  % deg to pixx; sign change in X to account for camera invertion.
EyeY    = sign(V(2))*deg2pix(4*abs(V(2)),c);

% read joy-voltage
joy     = V(4);
end

function out                =   checkEye(pass, Eye, WinDim)
% checkEye

out = all(abs(Eye)<WinDim) || pass;

end

function pixels             =   deg2pix(degrees,c)
% deg2pix convert degrees of visual angle into pixels

pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end

function                        fixdotframe(c, t)

Screen('FrameRect',c.window, t.fcolor,repmat(t.PfixXY + c.middleXY,1,2) + [-c.cursorR -c.cursorR c.cursorR c.cursorR],c.fixdotW)
Screen('FrameRect',c.window, t.fwcolor,repmat(t.PfixXY + c.middleXY,1,2) + [-t.PfpWindW -t.PfpWindH t.PfpWindW t.PfpWindH],c.fixwinW)
Screen('FrameRect',c.window, t.tcolor,repmat(t.PtargXY + c.middleXY,1,2) + [-c.cursorR -c.cursorR c.cursorR c.cursorR],c.fixdotW)
Screen('FrameRect',c.window, t.twcolor,repmat(t.PtargXY + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)

end

function [PDS, c, s, t]     =   trial_init(PDS, c, s)

% start of trial time
t.trstart = GetSecs;  
PDS.datapixxtime(c.j) = Datapixx('GetTime');

%%% Start ADC of Eyelink (x,y,pupil) and joystick data; 4 channels
maxDur              = c.maxDur;                     % how many seconds of data do we want to read?
adcRate             = 1000;                         % sampling rate
t.nAdcLocalBuffSpls = adcRate*maxDur;               % number of samples to preallocate for reading 
t.LocalADCbuffer    = zeros(5,t.nAdcLocalBuffSpls);   % We'll acquire 4 ADC channels + 1 time-stamp channel into 5 rows      
t.adcBuffBaseAddr   = 4e6;                          % Datapixx internal buffer address

% set the ADC schedule
Datapixx('SetAdcSchedule', 0, adcRate, t.nAdcLocalBuffSpls, [0 1 2 3], t.adcBuffBaseAddr, t.nAdcLocalBuffSpls);
Datapixx('StartAdcSchedule');
Datapixx('RegWrRd');

%%% Set DAC schedule for reward system
Volt                        = 4.0;
pad                         = 0.01;  % pad 4 volts on either side with zeros
Wave_time                   = c.rewardDur+pad;
t.Dacrate                   = 1000;
reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*c.rewardDur)) zeros(1,round(t.Dacrate*pad/2))];
t.ndacsamples               = floor(t.Dacrate*Wave_time);
t.dacBuffAddr               = 6e6;
t.chnl                      = 0;

% make sure a Dac schedule is not running before setting a new schedule
Datapixx('RegWrRd');
Dacstatus = Datapixx('GetDacStatus');
while Dacstatus.scheduleRunning == 1;
    Datapixx('RegWrRd');
    Dacstatus = Datapixx('GetDacStatus');
end

% Set schedule.
Datapixx('RegWrRd');
Datapixx('WriteDacBuffer', reward_Voltages, t.dacBuffAddr, t.chnl);
Datapixx('RegWrRd');

% Initialize
t.state           = 0;                    %
t.backcolor       = c.backcolor;          % background color CLUT indx
t.fcolor          = c.backcolor;          % fixation pt CLUT indx, initially this should be BG colored.
t.fwcolor         = 3;                    % fixation window CLUT indx
t.tcolor          = c.backcolor;          % target pt CLUT indx, initially this should be BG colored.
t.twcolor         = c.backcolor;          % target window CLUT indx
t.ecolor          = 7;                    % eye position CLUT indx
t.gridc           = 1;                    % grid CLUT indx

% initialize times
t.timeFPON        = -1;                   % time of fixation point onset
t.timeFA          = -1;                   % time of fixation acquisition
t.timeTFON        = -1;                   % time of target flash onset
t.timeTFOFF       = -1;                   % time of target flash offset
t.timeFIXOFF      = -1;                   % time of fixation offset
t.timeSACON       = -1;                   % time of saccade onset (fixation window exit)
t.timeTA          = -1;                   % time of target acquisition / target re-illumination
t.timeTFC         = -1;                   % time of target fixation completion
t.timeBF          = -1;                   % time of broken fixation
t.timeBTF         = -1;                   % time of broken TARGET fixation
t.timeRWD         = -1;                   % time of reward delivery

t.frametimestep   = 1/c.framerate;          % IFI (inter-frame-interval = 1/frame-rate)
t.lastframetime   = 0;                      % time at which last frame was displayed
s.fixXY         = [c.fpX, c.fpY];           % Where will the fixation-point be shown?


% make grid with 2 degree (c.gridW) spacing
minmaxg     = 30;
grid_sp     = deg2pix(-minmaxg:2:minmaxg,c);  % -20 to 20 deg
t.GridXY      = [];
for i = 1:size(grid_sp,2)
    XY=[[-c.middleXY(1);grid_sp(i)] [c.middleXY(1);grid_sp(i)]];
    YX=[[grid_sp(i);-c.middleXY(2)] [grid_sp(i);c.middleXY(2)]];
    t.GridXY = [t.GridXY XY YX];
end

% a logical flag indicating whether the target has been reilluminated or
% not. This is useful for training purposes
t.targReIll   = 0;

% define the "magic number" for stimulus-drawing
t.magicNumber = 0.006;

% fixation-point (and surrounding window) in pixels.
t.PfixXY      = [sign(s.fixXY(1))*deg2pix(abs(s.fixXY(1)),c) -sign(s.fixXY(2))*deg2pix(abs(s.fixXY(2)),c)]; % fixation point xy
t.PtargXY     = [sign(s.targXY(1))*deg2pix(abs(s.targXY(1)),c) -sign(s.targXY(2))*deg2pix(abs(s.targXY(2)),c)]; % target point xy
t.PfpWindW    =  deg2pix(c.fpWindW,c); % fixation point window width
t.PfpWindH    =  deg2pix(c.fpWindH,c); % fixation point window height
t.PtpWindW    =  deg2pix(c.tpWindW,c); % target point window width
t.PtpWindH    =  deg2pix(c.tpWindH,c); % target point window height

% possible trial-ending states
% endStates (state values that stop the trial)
t.endStates   = [   1.5, ...    % correct
                    3, ...      % fixation-break prior to target onset
                    3.1, ...    % fixation-break during overlap or too soon after fixation offset
                    3.2, ...    % miss (didn't reach target in time)
                    3.3, ...    % target fixation-break (didn't maintain target-fixation long enough)
                    3.4]; ...   % non-start (never acquired fixation).
end

function [PDS, c, s]        =   trial_end(PDS, c, s, t)

s.TrialNumber   = c.j;
if t.state == 1.5
    good = 1;
    s.ngood = s.ngood + 1;
    c.repeat = 0;
    if s.repeat20 == 1
        s.repeatcount = s.repeatcount + 1;
    end
    c.repeatcnt = 1;
elseif c.repeatcnt <= c.nrepeats
    c.repeatcnt = c.repeatcnt + 1;
    c.repeat = 1;
    good     = 0;
    pause(c.timeout)
elseif c.repeatcnt > c.nrepeats
    c.repeat = 0;
    c.repeatcnt = 1;
    good     = 0;
    pause(c.timeout)
end


%% OUTPUT behavioral data
PDS.trialnumber(c.j)        = c.j;
PDS.goodtrial(c.j)          = good;
PDS.state(c.j)              = t.state;
PDS.FPpos(c.j,:)            = s.fixXY;
PDS.targAngle(c.j)          = c.targetdir;
PDS.targAmp(c.j)            = c.targetecc;
PDS.targXY(c.j,:)           = s.targXY;
% times
PDS.trialstarttime(c.j,:)   = t.trstart;        % trial start
PDS.timefpon(c.j)           = t.timeFPON;       % fixation on (joypress acquired)
PDS.timetfon(c.j)           = t.timeTFON;       % target flash onset
PDS.timetfoff(c.j)          = t.timeTFOFF;      % target flash offset
PDS.timefpaq(c.j)           = t.timeFA;         % fixation acquired
PDS.timefixoff(c.j)         = t.timeFIXOFF;     % fixation offset
PDS.timesacon(c.j)          = t.timeSACON;      % saccade onset
PDS.timetpaq(c.j)           = t.timeTA;         % target acquired
PDS.timetpfc(c.j)           = t.timeTFC;        % target fixation completed
PDS.fixHoldReqDur(c.j)      = s.targFixDurReq;  % requested fixation-hold duration
PDS.timebrokefix(c.j)       = t.timeBF;         % broke fixation
PDS.timebroketargfix(c.j)   = t.timeBTF;        % broke target fixation
PDS.timereward(c.j)         = t.timeRWD;        % reward delivered
% % eye position
% PDS.EyeXYZ{c.j} = EyeJoy(1:3,:);
% PDS.adcts{c.j} = EyeJoyts;

c.j = c.j + 1;
end

function sendOmniPlexStimInfo(c,s)
% The function sends Omniplex stimuls tag info followed by its value.

sendStimTag(11001)
sendStimValue(c.connectPLX)

sendStimTag(11002)
sendStimValue(s.TrialNumber)

sendStimTag(14001)
sendStimValue(floor(c.targetdir))

sendStimTag(14002)
sendStimValue(floor(c.targetecc*10))

sendStimTag(11099)
sendStimValue(6)

sendStimTag(11098)
sendStimValue(s.repeat20)

sendStimTag(11095)
sendStimValue(c.inactivation)

if c.vissac
    sendStimTag(11097)
    sendStimValue(1)
end

end

function sendStimTag(tag)
% if isinteger(tag)
  strobe(tag)
% else
%     fprintf('tag not an integer.\n');
% end
end

function sendStimValue(value)
%   if isinteger(value)
    strobe(value)
%   else
%     fprintf('stimulus value not an integer.\n');
%   end
end

function strobe(word) 

Datapixx('SetDoutValues',word,hex2dec('007fff'))    % set word in first 15 bits
Datapixx('RegWr');
Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true) 
Datapixx('RegWr');
Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
Datapixx('RegWr');
end











