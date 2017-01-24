function [PDS ,c ,s]= AttnMot_run(PDS ,c ,s)
% Execution of this m-file accomplishes 1 complete trial
% It is part of the loop controlled by the 'Run' action from the GUI;
%   it is preceded by 'next_trial' and followed by 'finish_trial'

% The whole function runs as WHILE loop, checking for changes in eye and
% joystick position. When certain positions are met, the state variable is updated
%% state defs
% 0 (start), 0.1(Waiting for Joy Press), 0.2(Joy pressed; Waiting for fixation)
% 0.5(fixation acquired),
% 1(change state; waiting for joy rel), 1.1 (no change state)
% fixation break states starting with 2.something
% joy break states starting with 3.something
% hits 4.1
% misses and late releases 3.4,3.45
% correct rejects 4.2
% FA distractor false alarms 5
% guesses 3.5
endstates=[3 3.1 3.2 3.3 3.4 3.5 3.6 4.1 4.2 5 2 2.1 2.2 2.3];
%%
trstart = GetSecs;  % start of trial time
datapixxstarttime = Datapixx('GetTime');
%% Start ADC of Eyelink (x,y,pupil) and joystick data; 4 channels
adcRate = 1000;                            % Acquire ADC data at 1 kSPS
nAdcLocalBuffSpls = adcRate*c.trialmax;          % Preallocate a local buffer for 15 seconds of data
% EyeXY = zeros(4, nAdcLocalBuffSpls);     % We'll acquire 4 ADC channels into 4 matrix rows
adcBuffBaseAddr = 4e6;                     % Datapixx internal buffer address
Datapixx('SetAdcSchedule', 0, adcRate, nAdcLocalBuffSpls, [0 1 2 3], adcBuffBaseAddr, nAdcLocalBuffSpls);
Datapixx('StartAdcSchedule');
Datapixx('RegWrRd');
timestartAdcSchedule= GetSecs - trstart;
%% Set DAC schedule for reward system
% make sure a Dac schedule is not running before setting a new schedule
Datapixx('RegWrRd');
Dacstatus = Datapixx('GetDacStatus');
while Dacstatus.scheduleRunning == 1
    Datapixx('RegWrRd');
    Dacstatus = Datapixx('GetDacStatus');
    %     display('Dac stepping on itself');
end
%
Volt=4.0;
pad=0.01;  % pad 4 volts on either side with zeros
Wave_time= c.reward_duration+pad;
Dacrate=1000;
reward_Voltages = [zeros(1,round(Dacrate*pad/2)) Volt*ones(1,int16(Dacrate*c.reward_duration)) zeros(1,round(Dacrate*pad/2))];
ndacsamples=floor(Dacrate*Wave_time);
dacBuffAddr = 6e6;
chnl=0;
Datapixx('RegWrRd');
Datapixx('WriteDacBuffer', reward_Voltages,dacBuffAddr,chnl);

%% Initialize
start =0;
state = 0;
strb.bool = 0;

% initialize colors
backcolor   = c.backcolor;  % background color CLUT indx
fcolor      = c.backcolor;  % fixation pt CLUT indx
cuecolor    = c.backcolor;  % cue CLUT indx
loc1color   = c.backcolor;  % cue dots CLUT indx
loc2color   = c.backcolor;  % foil dots CLUT indx
fwcolor     = c.backcolor;  % fixation window CLUT indx


% initialize times
timefpon    = -1;   % time fp on
timefa      = -1;   % acquired fixation
timefpoff   = -1;   % time fp off
timech      = -1;   % time change for change trials;
timeBF      = -1;   % time broken fixation
timeBJ      = -1;   % time broken joystick press
timejp      = -1;   % time joystick press
timejr      = -1;   % time joystick release
timerwd     = -1;   % time rewarded
timecueonset = -1;  % time cue on
timecueoffset = -1; % time cue off
timeloc1onset = -1;  % time stim on at loc1
timeloc2onset = -1;  % time stim on at loc2
timech_foil   = -1;% time peripheral stim (foil/distractor) changed on FA trials

frametimestep = 1/c.refreshrate;    % IFI (inter-frame-interval = 1/frame-rate)
lastframetime = 0;                  % time at which last frame was displayed
k             = 1;                  % cue frame indx
m             = 1;                  % foil frame indx

%% convert degrees into pixels
PfixXY      = [sign(c.fixXY(1))*deg2pix(abs(c.fixXY(1)),c) -sign(c.fixXY(2))*deg2pix(abs(c.fixXY(2)),c)] + c.middleXY; % fixation point xy
PfpWindW    =  deg2pix(c.fpWindW,c); % fixation point window width
PfpWindH    =  deg2pix(c.fpWindH,c); % fixation point window height

%% make grid with 2 degree (c.gridW) spacing
minmaxg     = 30;
grid_sp     = deg2pix(-minmaxg:2:minmaxg,c);  % -20 to 20 deg
GridXY      = [];
for i = 1:size(grid_sp,2)
    XY=[[-c.middleXY(1);grid_sp(i)] [c.middleXY(1);grid_sp(i)]];
    YX=[[grid_sp(i);-c.middleXY(2)] [grid_sp(i);c.middleXY(2)]];
    GridXY = [GridXY XY YX];
end

%% generate all(cue & foil) (Pasternak) dots
if c.loc1on
    [dotX,dotY,dotC,dotW] = gendots_pstnk(c,c.stimdur,c.refreshrate,deg2pix(c.locc1art,c),c.loc1dir,c.loc1del,c.stimchtime);
end
if c.loc2on
    [FdotX1,FdotY1,FdotC1,FdotW1] = gendots_pstnk(c,c.stimdur,c.refreshrate,deg2pix(c.locc2art,c),c.loc2dir,c.loc2del,c.stimchtime);
end

%% Run
while  ~any(state == endstates)
    %%     get joystick and eye positions
    joy = getjoy;               % get instantaneous joystick position
    if joy < c.joythP           % is it pressed ?
        joyfillc = c.jpcolor;               % set the meter green
    elseif joy > c.joythR       % is it released ?
        joyfillc = c.jrcolor;               % set the meter red
    else                        % neither press nor released?
        joyfillc = c.jprcolor;               % set it blue
    end
    
    [s.EyeX,s.EyeY,V]       = geteye(c)     ;  % get instantaneous eye position
    
    %% STATE 0 = BEFORE joystick press check
    % If the current time is greater than "c.freeduration" (the amount of
    % time to wait before checking for joystick press), set state 0.1
    % (start looking for the joystick press).
    ttime = GetSecs-trstart;
    if  state == 0 && ttime > c.freeduration
        state = 0.1;
    end
    
    %% STATE 0.1 = WAITING FOR joystick press
    % If it's past the time to start checking for joystick press, and the
    % joystick is being pressed, set state 0.2 and show the fixation dot (and the window on the
    % experimenter display), and make a note of the time that the
    % fixation-dot was turned on.
    ttime = GetSecs-trstart;
    if  state == 0.1 && checkJoy(c.passJoy,joy,c.joythP,0)
        % omniplex start recording
        startrecording;
        WaitSecs(0.15);
        start =1;
        strobe(c.strobe.trialBegin)
        %
        state = 0.2;% joy pressed
        timejp = GetSecs - trstart; % time of joy press
        strobe(c.strobe.joypress)
        strb.value = c.strobe.fixdoton;
        strb.bool = 1;
        fcolor= c.fixcolor;   % show fixation dot
        fwcolor = c.fixwincolor;  % show fix window on 2nd clut
        timefpon= GetSecs - trstart;
        
        % Otherwise, if it's past the time to start checking for joystick
        % press, and it's also past time to wait for a joystick press, set
        % state = 3 (trial finished).
    elseif state == 0.1 && ttime > c.joypresswaitstop
        state = 3;    % did not press joystick; repeat trial number
    end
    
    %% STATE 0.2 = WAITING FOR SUBJECT FIXATION (F) while maintaining joystick (J) press
    % If the joystick is being held, and the maximum period to wait for
    % fixation being acquired has not elapsed, and eye enter fixation window,
    % set state 0.5, and make a note of that time ("timefa").
    ttime = GetSecs-trstart;
    if  state == 0.2 && ttime < (timejp + c.fixwaitstop) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
        state = 0.5;    % fixation acquired
        timefa = GetSecs - trstart;  % time fixation acquired
        strobe(c.strobe.fixacqd)
        
    elseif state == 0.2 && ~checkJoy(c.passJoy,joy,c.joythP,0)
        state = 3.1;     % broke joy press
        timeBJ = GetSecs - trstart; % time broke joy press
        strobe(c.strobe.joybreak)
        fcolor= backcolor;
        fwcolor = backcolor;
        timefpoff= GetSecs - trstart;
        
    elseif state == 0.2 && ttime > timejp + c.fixwaitstop
        state = 2;       % did not acquire fixation
        fcolor= backcolor;
        fwcolor = backcolor;
        timefpoff= GetSecs - trstart;
    end
    %% STATE 0.5 = MAINTAIN FIXATION (F) and joy press
    ttime = GetSecs-trstart;
    if state == 0.5
        if ttime < (timefa + c.fixholdduration) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
            % check time elapsed for cue on
            if ttime > timefa + c.cueonset && timecueonset ==-1
                cuecolor=c.cuecolor;     % cue clut indx
                timecueonset = GetSecs - trstart; % time of cue onset
                strb.value = c.strobe.cueon;%% cue on strobe value
                strb.bool = 1;
            end
            % check time elapsed for cue off
%             if ttime > timefa + c.cueonset + c.cuedelay && timecueonset ~=-1 && timecueoffset ==-1
            if ttime > timefa + c.cueonset + c.cueduration && timecueonset ~=-1 && timecueoffset ==-1
                cuecolor=c.backcolor;     % cue clut indx
                timecueoffset = GetSecs - trstart; % time of cue offset
                strb.value = c.strobe.cueoff;%% cue off strobe value
                strb.bool = 1;
            end
            % check time elapsed for loc1 stim on
            if ttime > timefa + c.stimwait && timeloc1onset ==-1 && c.loc1on ==1
                loc1color=c.stimcolor;     % dots clut indx
                timeloc1onset = GetSecs - trstart; % time of loc1 onset
                strb.value = c.strobe.stimon;
                strb.bool = 1;
            end
            % check time elapsed for loc2 stim on
            if ttime > timefa + c.stimwait && timeloc2onset ==-1 && c.loc2on ==1
                loc2color=c.stimcolor;     % dots clut indx
                timeloc2onset = GetSecs - trstart; % time of loc2 onset
                strb.value = c.strobe.stimon;
                strb.bool = 1;
            end
            
        elseif  ttime < (timefa + c.fixholdduration)  && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && ~checkJoy(c.passJoy,joy,c.joythP,0)
            state = 3.2; % broke joy
            timeBJ = GetSecs - trstart;
            
            strobe(c.strobe.joybreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            joyfillc = c.jrcolor;
            fcolor= backcolor;
            cuecolor= backcolor;
            fwcolor = backcolor;
            timefpoff= GetSecs - trstart;
            
        elseif ttime < (timefa + c.fixholdduration)  && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
            state = 2.1;  % broke fixation
            timeBF = GetSecs - trstart;
            
            strobe(c.strobe.fixbreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            cuecolor= backcolor;
            fwcolor = backcolor;
            timefpoff= GetSecs - trstart;
            
        elseif ttime > (timefa + c.fixholdduration) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0) % neither broke fixation nor joypress.
            timech      = GetSecs - trstart;
            if c.trialtype==2 || c.trialtype==1
                if c.fixChangeTrial
                    state   = 1;
                    strb.value = c.strobe.fixdotdim;
                    strb.bool = 1;
                    fcolor=c.dimvalue;
                else
                    state=1.1;
                    strb.value = c.strobe.nochange;
                    strb.bool = 1;
                end
            else
                if c.stimChangeTrial
                    state   = 1;
                    strb.value = c.strobe.cuechange;
                    strb.bool = 1;
                else
                    state=1.1;
                    strb.value = c.strobe.nochange;
                    strb.bool = 1;
                end
            end
        end
    end
    
    ttime = GetSecs-trstart;
    %% get stim change times on FA trials
    if c.trialtype==2  && c.stimChangeTrial>0 && ttime>(timefa+c.stimwait+c.stimchtime) && timeloc1onset ~=-1 && timeloc2onset ~=-1 && timech_foil~=-1
        timech_foil      = GetSecs - trstart;
        strb.value = c.strobe.foilchange;
        strb.bool = 1;
    end
    
    %% check for joy rel on change
    ttime = GetSecs-trstart;
    if state == 1
        % If the joystick-release window hasn't passed and the joystick has
        % been released
        if (ttime <= (timech + c.joypressmax) && ttime > (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state  = 4;
            timejr   = GetSecs - trstart;
            
            strobe(c.strobe.joyrelease)
            joyfillc = c.jrcolor;
            % If he released the joystick but at too
            % short a latency, this is an anticipatory release.
        elseif ttime <= (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)
            state = 3.2;% broke joy
            timeBJ   = GetSecs - trstart;
            
            strobe(c.strobe.joybreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            joyfillc = c.jrcolor;
            % if fixation broken
        elseif ttime <= (timech + c.rewardwait) && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 2.2;% broke fixation
            timeBF = GetSecs - trstart;
            
            strobe(c.strobe.fixbreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            % If the joystick-release window has passed,
            % long-latency error.
        elseif ttime <= (timech + c.rewardwait) && ttime > (timech + c.joypressmax) && ~checkJoy(c.passJoy,joy,c.joythP,0) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 3.3;% late release
            timejr   = GetSecs - trstart;
            
            strobe(c.strobe.joyrelease)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            joyfillc = c.jrcolor;
        elseif ttime > (timech + c.rewardwait)
            state = 3.4;% miss
            
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
        end
        
    end
    
    %% give reward
    ttime = GetSecs-trstart;
    if state == 4
        if ttime>=timech+c.rewardwait % hits
            Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
            Datapixx('StartDacSchedule');
            Datapixx('RegWrRd');
            state = 4.1; %  Deliver Reward
            timerwd     = GetSecs - trstart;
            
            strobe(c.strobe.reward)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
        elseif ttime <= timech+c.rewardwait && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 2.3;% broke fixation
            timeBF = GetSecs - trstart;
            
            strobe(c.strobe.fixbreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
        end
    end
    
    %% after no change
    ttime = GetSecs-trstart;
    if state == 1.1
        if ttime <= (timech + c.rewardwait) && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 2.2;% broke fixation
            timeBF = GetSecs - trstart;
            
            strobe(c.strobe.fixbreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
        elseif ttime <= (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)
            state = 3.2; % broke joy
            timeBJ   = GetSecs - trstart;
            
            strobe(c.strobe.joybreak)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            joyfillc = c.jrcolor;
        elseif (ttime <= (timech + c.joypressmax) && ttime > (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 3.5;% false alarms on catch trials
            timejr   = GetSecs - trstart;
            
            strobe(c.strobe.joyrelease)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            joyfillc = c.jrcolor;
        elseif ttime <= (timech + c.rewardwait) && ttime > (timech + c.joypressmax) && ~checkJoy(c.passJoy,joy,c.joythP,0) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            state = 3.6; % false alarms on catch trials but late
            timejr   = GetSecs - trstart;
            strobe(c.strobe.joyrelease)
            
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
            joyfillc = c.jrcolor;
        elseif ttime >= (timech + c.rewardwait)
            % Deliver Reward
            Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
            Datapixx('StartDacSchedule');
            Datapixx('RegWrRd');
            state = 4.2;%correct rejects
            timerwd     = GetSecs - trstart;
            
            strobe(c.strobe.reward)
            strb.value = c.strobe.fixdotoff;
            strb.bool = 1;
            
            fcolor= backcolor;
            fwcolor = backcolor;
            timefpoff   = GetSecs - trstart;
        end
    end
    %%    update display
    ttime = GetSecs-trstart;
    if ttime > lastframetime + frametimestep-0.006
        Screen('FillRect', c.window,backcolor)   % draw background color; when using overlay window.
        Screen('DrawLines', c.window, GridXY,[],c.gridc,c.middleXY)   % draw grid lines on 2nd display
        Screen('FillRect', c.window, c.ecolor, [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR) % Draw the gaze position.
        Screen('FillRect',c.window, joyfillc,[1600 800 1700 800+300*abs((2.5-joy)/2.5)]) % draw joy bar fill
        Screen('FrameRect',c.window, joyfillc,c.joybar) % draw joybar frame
        Screen('FrameRect',c.window,fcolor,[PfixXY PfixXY] + [-c.cursorR -c.cursorR c.cursorR c.cursorR],c.fixdotW) % fixation
        Screen('FrameRect',c.window,fwcolor,[PfixXY PfixXY] + [-PfpWindW -PfpWindH PfpWindW PfpWindH],c.fixwinW) % fixation window
        Screen('FrameRect',c.window,cuecolor,[PfixXY PfixXY] + [-c.cuecursorR -c.cuecursorR c.cuecursorR c.cuecursorR],c.cuedotW)  % cue
        
        if c.loc1on == 1 && timeloc1onset ~= -1
            Screen('Drawdots',c.window,[dotX{k} dotY{k}]',dotW{k},[1 1 1]'*loc1color,c.middleXY,1) % draw cue dots
            if k < size(dotX,2)
                k=k+1;     % update cue dots frame indx
            end
        end
        
        if c.loc2on == 1 && timeloc2onset ~= -1
            Screen('Drawdots',c.window,[FdotX1{m} FdotY1{m}]',FdotW1{m},[1 1 1]'*loc2color,c.middleXY,1)  % draw foil dots
            if m < size(FdotX1,2)
                m=m+1;     % update cue dots frame indx
            end
        end
        
        temptime = Screen('Flip', c.window,GetSecs + 0.00); % flip frame
        lastframetime = temptime-trstart;
        
        % strobe the values after updating the display
        if strb.bool
            strobe(strb.value)
            strb.bool = 0;
        end
    end
        
end
% End of Runtrial While-Loop
%% Clear the display
Screen('FillRect', c.window,backcolor)
Screen('Flip', c.window);

% determine false alarms on trialtype2 (FA trials);
% if joy released in the window after stim change
if c.trialtype==2 && timech_foil~=-1 && state~=4.1 && timejr>(timech_foil+c.joypressmin) && timejr<=(timech_foil+c.joypressmax_stim)
    state=5; % false alarm state
end

%% send stim info to omniplex
if start == 1
    sendOmniPlexStimInfo(c,state);
    strobe(c.strobe.trialEnd)
    stoprecording; % omniplex
end

%% wait for joystick release before next trial
if any(state == endstates)
    ttime = GetSecs-trstart;
    while ~checkJoy(c.passJoy,joy,c.joythR,1)
        Datapixx('RegWrRd');                    % Update registers for GetAdcStatus
        status = Datapixx('GetAdcStatus');
        if status.scheduleRunning == 0 && status.freeRunning == 0
            Datapixx('EnableAdcFreeRunning');   % enable free running mode if ADC schedule stopped
        end
        joy = getjoy;                           % get joy position
        joyfillc = c.jr_iticolor;
        if ttime > lastframetime + frametimestep-0.006
            Screen('FillRect',c.window, joyfillc,[1600 800 1700 800+300*abs((2.5-joy)/2.5)]) % draw joy bar fill
            Screen('FrameRect',c.window, joyfillc,c.joybar);
            temptime = Screen('Flip', c.window,GetSecs + 0.00); % flip frame
            lastframetime = temptime-trstart;
        end
        ttime = GetSecs-trstart;
    end
    
    Screen('FillRect', c.window,backcolor)
    Screen('Flip', c.window);
    Datapixx('DisableAdcFreeRunning');
end

%% Read continuously sampled Eye data
Datapixx('RegWrRd');                    % Update registers for GetAdcStatus
status = Datapixx('GetAdcStatus');
nReadSpls = status.newBufferFrames;      % How many Spls can we read?
[EyeJoy, EyeJoyts] = Datapixx('ReadAdcBuffer', nReadSpls, adcBuffBaseAddr);
Datapixx('StopAdcSchedule');
timestopAdcSchedule= GetSecs - trstart;

%% update counters based on trial result
if (state == 4.1 || state ==4.2) % rewards (hits and correct rejects)
    c.repeattrial=0;
    c.NumRewards    = c.NumRewards+1;
elseif state == 5 %fas
    c.repeattrial=0;
    WaitSecs(c.timeout+rand);
elseif state == 3.4 % misses
    c.repeattrial=0;
elseif state>2 && state<3 %fix breaks
    c.fixbreaks=c.fixbreaks+1;
    c.repeattrial=1;
    WaitSecs(c.timeout+rand);
elseif (state == 3.2 || state ==3.5 || state ==3.6)
    c.antrels=c.antrels+1;%ant rels
    c.repeattrial=1;
    WaitSecs(c.timeout+rand);
else
    c.repeattrial=1;
end

%% OUTPUT behavioral data for the current trial

if  timejp~=-1 % trials where joy stick pressed
    % trial and block counters; trial end state
    PDS.trialnumber(c.j)        = c.j;
    PDS.trinblk(c.j)            = c.trinblk;
    PDS.setno(c.j)              = c.setno;
    PDS.blockno(c.j)            = c.blockno;
    PDS.state(c.j)              = state;
    PDS.repeattrial(c.j)        = c.repeattrial;
    
    % stim location and deltas
    PDS.FPpos(c.j,:)             = c.fixXY;
    PDS.cuecolor(c.j)            = c.cuecolor;
    PDS.RFlocecc(c.j)            = c.RFlocecc;
    PDS.RFloctheta(c.j)          = c.RFloctheta;
    PDS.loc1dir(c.j)             = c.loc1dir;
    PDS.loc2dir(c.j)             = c.loc2dir;
    PDS.loc1del(c.j)             = c.loc1del;
    PDS.loc2del(c.j)             = c.loc2del;
    PDS.dimvalue(c.j)            = c.dimvalue;
    
    % trial types
    PDS.trialcode(c.j)          = c.trialcode;
    PDS.trialtype(c.j)          = c.trialtype;
    PDS.fixchangetrial(c.j)      = c.fixChangeTrial;
    PDS.stimchangetrial(c.j)     = c.stimChangeTrial;
    PDS.changeloc(c.j)           = c.Changeloc;
    
    % times
    PDS.datapixxtime(c.j)         = datapixxstarttime;
    PDS.timestartAdcSchedule(c.j) = timestartAdcSchedule;
    PDS.timestopAdcSchedule(c.j) = timestopAdcSchedule;
    PDS.trialstarttime(c.j)      = trstart;
    PDS.timejoypress(c.j)       = timejp;
    PDS.timefpon(c.j)           = timefpon;
    PDS.fpentered(c.j)          = timefa;
    PDS.cueonset(c.j)           = timecueonset;
    PDS.cueoffset(c.j)          = timecueoffset;
    PDS.timeloc2onset(c.j)      = timeloc2onset;
    PDS.timeloc1onset(c.j)      = timeloc1onset;
    PDS.timebrokefix(c.j)       = timeBF;   % broke fix
    PDS.timebrokejoy(c.j)       = timeBJ;   % broke joy press
    PDS.timereward(c.j)         = timerwd;  % Reward
    PDS.timejoyrel(c.j)         = timejr;   % joy release
    PDS.timefpoff(c.j)          = timefpoff;
    PDS.timech(c.j)             = timech;% relevant stim change time
    PDS.foilchangetime(c.j)     = timech_foil;% stim change time in FA trials
    PDS.stimchangetime(c.j)     = timefa + c.stimwait + c.stimchtime;
    PDS.fpchangetime(c.j)       = timefa + c.stimwait + c.fixchtime;
    PDS.fixholdduration(c.j)    = c.fixholdduration;%duration before change
    PDS.stimduration(c.j)       = c.stimdur;%duration of peripheral stimuli
    PDS.reward(c.j)             = c.reward_duration;
    
    % eye & joy position
    PDS.EyeXYZ{c.j} = EyeJoy(1:3,:);
    PDS.Joy{c.j} = EyeJoy(4,:);       % Joypos;
    PDS.adcts{c.j} = EyeJoyts;
    
    c.j=c.j+1;% increase tr no everytime joy pressed
end

%% update trial list
c=updatetriallist(c);
end         % end of run function

%%
function out = checkJoy(pass,joy,th,pos)
% checkJoy is a boolean that is true if joy is less(pos=0; press) or greater(pos=1; greater) than th
% If PASS is on, it always returns TRUE.


if pass == 0
    if pos == 0
        out = joy < th;
    else
        out = joy > th;
    end
else
    out = 1;
end
end

%%
function joy = getjoy()

Datapixx RegWrRd
V       = Datapixx('GetAdcVoltages');
joy     = V(4); % joystick is on the 4th analog channel; first 3 are EyeX,Y and pupil size
if joy<0
    joy=0;
end
end

%%
function [dotX,dotY,dotC,dotW] = gendots_pstnk(c,dduration,refreshrate,dotoffset,theta,thetadel,chtime)
%
% INPUTS
%   coh: coherence expressed as a percentage
%   dduration: duration of the dots in seconds
%   refreshrate: refresh rate in Hz
%   dotoffset: offset in pixels from the CENTER of the screen
%   LR: 0 = left, 1= right
%
% OUTPUTS
%   dotX & dotY: coordinates for dots indexed by frame
%   dotC: color values (by frame)
%   dotW: width values to give to DRAWDOTS (by frame)

% some the parameters below can be transferred to the c structure
dotparam = c.dotdensity; %dots/deg^2/seconds  [DENSITY]
apertradius = c.aperture; % degrees radius
ndots = round(dotparam*(pi*apertradius.^2)/refreshrate);
speed = c.dotspeed;   % degrees per second
dotwidth = c.dotwidth; % dot width in pixels
dotlife = c.dotslife; % frames
dirvar = c.dotdirstd; % STD of direction distribution in deg

apertpixels = round(deg2pix(apertradius,c))*2;  % apertradius in pixels (MUST BE EVEN!)
speedpixels = deg2pix(speed,c);   % speed in pixels
location = dotoffset - [apertpixels/2 apertpixels/2]; % in pixels

% initialize a group of dots
dots = ceil(rand(ndots,2)*(apertpixels-1));
age = randi(dotlife,[ndots,1]);
dir1 = theta + dirvar*randn(ndots,1);
dir2 = theta + thetadel + dirvar*randn(ndots,1);

j=1;dir=dir1;
while j <= round(dduration*refreshrate)
    
    [tempv(:,2),tempv(:,1)] = pol2cart(-dir*pi/180,ones(ndots,1)*speedpixels/refreshrate);
    dots = dots + tempv;     % move dots
    dots = mod(dots-1,apertpixels-1)+1;    % wrap
    
    % put dots into pixel list
    impixels = dots;
    
    % round the edges
    edges = sqrt((impixels(:,1)-apertpixels/2).^2 + (impixels(:,2)-apertpixels/2).^2)  > (apertpixels/2);
    impixels(edges,:) = [];
    
    if sum(edges)~= ndots
        dotY{j} = impixels(:,1)+location(2);
        dotX{j} = impixels(:,2)+location(1);
        dotC{j} = ones(size(dotY{j}));
        dotW{j} = ones(size(dotY{j}))*dotwidth;
        j=j+1;
        %     else
        %         j=j-1;
    end
    
    age=age+1;
    old = find(age > dotlife);
    age(old) = 1;
    dots(old,:) = ceil(rand(size(old,1),2)*(apertpixels-1));
    dir1(old) = theta + dirvar*randn(size(old,1),1);
    dir2(old) = theta + thetadel + dirvar*randn(size(old,1),1);
    if j >= round(chtime*refreshrate) && chtime ~= -1
        dir(old)=dir2(old);
    else
        dir(old)=dir1(old);
    end
end
end

%%
function pixels = deg2pix(degrees,c)
% DEG2PIX convert degrees of visual angle into pixels

pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end

%%
function out = squarewindow(pass,a,w,h)
% SQUAREWINDOW is a boolean that is true if 1 coordinates a(x,y) within a
% square window given by W (width) and H (height). "a" is specified from
% the center of the window.
%
% If PASS is on, it always returns TRUE.

if pass == 0
    out = abs(a(1)) < w & abs(a(2)) < h;
else
    out = 1;
end
end

function [EyeX,EyeY,V] = geteye(c)

Datapixx RegWrRd

% Read voltages from the ViewPIXX and transform [-10 10] Volts to [-40 40] degrees
V       = 4*Datapixx('GetAdcVoltages');

% Convert voltages into screen-pixels.
EyeX    = 960 - sign(V(1))*deg2pix(abs(V(1)),c);  % deg to pixx; sign change in X to account for camera invertion.
EyeY    = 600 + sign(V(2))*deg2pix(abs(V(2)),c);
end

%%
function c = updatetriallist(c)
if c.repeattrial == 0; % if its a good finished trial update the tr list
    c.triallist = c.triallist(2:end);% update trial list
    c.trinblk = c.trinblk + 1;% increment trial counter
    
    % if trail list empty (block done)
    if isempty(c.triallist)
        c.blockno = c.blockno + 1;%increment block no
        c.trinblk = 1;%initialize the trial no in the block
        c.taskseq = c.taskseq(2:end);% update the trialtype list
        
        % if trail type list empty (set done)
        if isempty(c.taskseq)
            c.setno = c.setno + 1;%increment block no
            c.taskseq = randperm(4);%randomize trialtypes
            c.updateplot = 1; %update plot every set; see finish file
        end
        
        c.trialtype = c.taskseq(1);%current trial type
        % load the trial list for that trial type
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
    end
elseif c.repeattrial == 1; % if its a trial to be repeated, move the trial to the end in the list
    c.triallist=[c.triallist(2:end) c.triallist(1)];
end

end

%% Starts saving data on Omniplex
function startrecording

Datapixx('SetDoutValues',2^17,hex2dec('020000'))     % set RSTART to 1
Datapixx('RegWrRd');
end

%% Stops saving data on Omniplex
function stoprecording

Datapixx('SetDoutValues',0,hex2dec('020000'))       % set RSTART to 0
Datapixx('RegWrRd');
end

%% The function sends Omniplex stimulus tag info followed by its value.
function sendOmniPlexStimInfo(c,state)
% trial,block and set info
sendStimTag(c.strobe.connectPLX)
sendStimValue(c.connectPLX)

sendStimTag(c.strobe.trialcount)
sendStimValue(c.j)

sendStimTag(c.strobe.blocknumber)
sendStimValue(c.blockno)

sendStimTag(c.strobe.trinblk)
sendStimValue(c.trinblk)

sendStimTag(c.strobe.setnumber)
sendStimValue(c.setno)

%trial type info
sendStimTag(c.strobe.trialcode)
sendStimValue(c.trialcode)

sendStimTag(c.strobe.trialtype)
sendStimValue(c.trialtype)

%trial result
sendStimTag(c.strobe.state)
sendStimValue(state*10)

% dim info
sendStimTag(c.strobe.fixchangetrial)
sendStimValue(c.fixChangeTrial)

sendStimTag(c.strobe.fixdotdimvalue)
sendStimValue(c.dimvalue)

% stimulus info
sendStimTag(c.strobe.RFlocecc)
sendStimValue(c.RFlocecc*10)

sendStimTag(c.strobe.RFlocTH)
sendStimValue(c.RFloctheta*10)

sendStimTag(c.strobe.stimchangetrial)
sendStimValue(c.stimChangeTrial)

sendStimTag(c.strobe.changeloc)
sendStimValue(c.Changeloc)

sendStimTag(c.strobe.loc1dir)
sendStimValue(c.loc1dir)

sendStimTag(c.strobe.loc2dir)
sendStimValue(c.loc2dir)

sendStimTag(c.strobe.loc1del)
sendStimValue(c.loc1del)

sendStimTag(c.strobe.loc2del)
sendStimValue(c.loc2del)

%reward info
sendStimTag(c.strobe.rewardduration)
sendStimValue(floor(100*c.reward_duration))

% tasktype : Ask ANil about this
sendStimTag(c.strobe.tasktype)
sendStimValue(c.tasktype)

end

%% Tag of a stimulus attribute
function sendStimTag(tag)
% if isinteger(tag)
strobe(tag)
% else
%     fprintf('tag not an integer.\n');
% end
end

%% Value of a stimulus attribute
function sendStimValue(value)
%   if isinteger(value)
strobe(value)
%   else
%     fprintf('stimulus value not an integer.\n');
%   end
end

%% Strobe an integer
function strobe(word)

Datapixx('SetDoutValues',word,hex2dec('007fff'))    % set word in first 15 bits
Datapixx('RegWr');
Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
Datapixx('RegWr');
Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
Datapixx('RegWr');
end