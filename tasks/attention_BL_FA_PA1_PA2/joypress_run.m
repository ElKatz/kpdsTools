function [PDS ,c ,s]= joypress_run(PDS ,c ,s)
% step 10: three different trials: 1-single patc trials (both locations ramdomised); 2- central dimming
% task with patche son; 3- motion change detetcion in both patches
% run_trial function
% Execution of this m-file accomplishes 1 complete trial
% It is part of the loop controlled by the 'Run' action from the GUI;
%   it is preceded by 'next_trial' and followed by 'finish_trial'

% The whole function runs as WHILE loop, checking for changes in eye and
% joystick position. When certain positions are met, the state variable is updated
% 0,0.25(Joy Press),0.5(fixation acquired),1(change time or reward time(no change trial)), 1.5 (reward time for change trial)
% ending in either 3 (broke fixation),3.1(broke joystick press), 3.2 (did not release joystick in time), 3.3(did not press joy stick in time; repeat trial) or 1.5 (joystick release).
global overlay %#ok<NUSED>

trstart = GetSecs;  % start of trial time

ttime = GetSecs-trstart; %  current time after start of trail

    PDS.datapixxtime(c.j) = Datapixx('GetTime');

    %%% Start ADC of Eyelink (x,y,pupil) and joystick data; 4 channels
    adcRate = 1000;                            % Acquire ADC data at 1 kSPS
    nAdcLocalBuffSpls = adcRate*c.trialmax;          % Preallocate a local buffer for 15 seconds of data

    % EyeXY = zeros(4, nAdcLocalBuffSpls);     % We'll acquire 4 ADC channels into 4 matrix rows
    adcBuffBaseAddr = 4e6;                     % Datapixx internal buffer address
    Datapixx('SetAdcSchedule', 0, adcRate, nAdcLocalBuffSpls, [0 1 2 3], adcBuffBaseAddr, nAdcLocalBuffSpls);
    Datapixx('StartAdcSchedule');
    Datapixx('RegWrRd');
    timestartAdcSchedule= GetSecs - trstart;
    % make sure a Dac schedule is not running before setting a new schedule
    Datapixx('RegWrRd');
    Dacstatus = Datapixx('GetDacStatus');
    while Dacstatus.scheduleRunning == 1
        Datapixx('RegWrRd');
        Dacstatus = Datapixx('GetDacStatus');
        % display('Dac stepping on itself')
    end
        
    %%% Set DAC schedule for reward system
    Volt=4.0;
    pad=0.01;  % pad 4 volts on either side with zeros
    Wave_time= c.reward_time+pad;
    Dacrate=1000;
    reward_Voltages = [zeros(1,round(Dacrate*pad/2)) Volt*ones(1,int16(Dacrate*c.reward_time)) zeros(1,round(Dacrate*pad/2))];
    ndacsamples=floor(Dacrate*Wave_time);
    dacBuffAddr = 6e6;
    chnl=0;
    Datapixx('RegWrRd');
    Datapixx('WriteDacBuffer', reward_Voltages,dacBuffAddr,chnl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize
start =0;
strb.bool = 0;
state       = 0;            %
dirchangestrobed = 0;
loc1on      = 0;            % loc 1 on (1)
loc2on      = 0;            % loc 2 on (1)
backcolor   = c.backcolor;  % background color CLUT indx
fcolor      = 4;            % fixation pt CLUT indx
fcolor2      = 4;            % fixation pt CLUT indx
loc1color      = c.backcolor;  % cue dots CLUT indx
loc2color   = c.backcolor;  % foil dots CLUT indx
fwcolor     = 4;            % fixation window CLUT indx
ecolor      = 7;            % eye position CLUT indx. (11/28/2012 - jph) Making this WHITE for now.
gridc       = 8;            % grid CLUT indx

% initialize times
timefa      = -1;   % acquired fixation
timefpon    = -1;
timefpoff   = -1;
timech      = -1;   % time change for change trials; time rwd for nochange trials
timeBF      = -1;   % time broken fixation
timeBJ      = -1;   % time broken joystick press
timejp      = -1;   % time joystick press
timejr      = -1;   % time joystick release for reward
timerwd     = -1;   % time rewarded
timeloc1onset =-1;
timeloc2onset=-1;

frametimestep = 1/c.refreshrate;    % IFI (inter-frame-interval = 1/frame-rate)
lastframetime = 0;                  % time at which last frame was displayed
k             = 1;                  % cue frame indx
m             = 1;                  % foil frame indx
s.fixXY       = [c.fpX, c.fpY];     % Where will the fixation-point be shown?

% convert degrees into pixels
PfixXY      = [sign(s.fixXY(1))*deg2pix(abs(s.fixXY(1)),c) -sign(s.fixXY(2))*deg2pix(abs(s.fixXY(2)),c)] + c.middleXY; % fixation point xy
PfpWindW    =  deg2pix(c.fp1WindW,c); % fixation point window width
PfpWindH    =  deg2pix(c.fp1WindH,c); % fixation point window height

% make grid with 2 degree (c.gridW) spacing
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
[dotX,dotY,dotC,dotW] = gendots_pstnk(c,c.loc1duration,c.refreshrate,deg2pix(c.locc1art,c),c.loc1dir,c.loc1del,c.loc1changetime);
end
if c.loc2on
[FdotX1,FdotY1,FdotC1,FdotW1] = gendots_pstnk(c,c.loc2duration,c.refreshrate,deg2pix(c.locc2art,c),c.loc2dir,c.loc2del,c.loc2changetime);
end

%% lnk: determine if cue is transient or not:
if ~isfield(c, 'proportionCueTransient')
    c.proportionCueTransient = 0.3;
end
if rand < c.proportionCueTransient
    cueTransient = 1;
else
    cueTransient = 0;
end

%% Run

while  state ~= 2 && state ~= 2.1 && state ~= 2.2 && state ~= 2.3 && state ~= 2.4 && ...
        state ~= 3 && state ~= 3.1 && state ~= 3.2 && state ~= 3.3 && state ~= 3.4 && ...
        state ~= 4.1 && state ~= 4.2 && ...
        c.quit == 0

    if c.useDataPixxBool            % Are we using the ViewPIXX / DataPIXX, or simulating?
        % If so...
        joy = getjoy;               % get instantaneous joystick position
        if joy < c.joythP           % is it pressed ?
            joyfillc = 2;               % set the meter green
        elseif joy > c.joythR       % is it released ?
            joyfillc = 3;               % set the meter red
        else                        % neither press nor released?
            joyfillc = 7;               % set it blue
        end

       [s.EyeX,s.EyeY,V]       = geteye(c)     ;  % get instantaneous eye position
        s.EyeVoltsX             = V(1);
        s.EyeVoltsY             = V(2);
        [cursorX,cursorY]       = GetMouse;     % mouse position
        cursorX                 = cursorX-2560; % 2560 is mac pro display's xdim.

    else
        % Otherwise, use the mouse...
        joy                 = GetMouse;
        [cursorX,cursorY]   = GetMouse;
        cursorX             = cursorX-2560;
        [s.EyeX,s.EyeY]     = GetMouse;
    end

    %%%%% STATE 0 = BEFORE joystick press check
    % If the current time is greater than "c.freeduration" (the amount of
    % time to wait before checking for joystick press), set state 0.1
    % (start looking for the joystick press). Make a note of when this
    % occured ("timefa").
    ttime = GetSecs-trstart;
    if  state == 0 && ttime > c.freeduration
        state = 0.1;
        %flipDataPixxBit(c.useDataPixxBool,1)
    end

    %%%% STATE 0 = WAITING FOR joystick press
    % If it's past the time to start checking for joystick press, and the
    % joystick is being pressed, set state 0.25. If showing the fixation
    % dot is desirable, show the fixation dot (and the window on the
    % experimenter display), and make a note of the time that the
    % fixation-dot was turned on.
    if  state == 0.1 && checkJoy(c.passJoy,joy,c.joythP,0)
        startrecording; % omniplex
        WaitSecs(0.15);
        start =1;
        strobe(30001)
        timejp = GetSecs - trstart; % time of joy press
        state = 0.2;
        strobe(2001)
        strb.value = 3001;
        strb.bool = 1;
            fcolor= c.fixcolor;              % show fixation dot
            fcolor2= c.fixbordercolor;
            fwcolor = 5;            % show fix window on 2nd clut
            timefpon= GetSecs - trstart;
        
    % Otherwise, if it's past the time to start checking for joystick
    % press, and it's also past time to wait for a joystick press, set
    % state = 3.3 (trial over).
    elseif state == 0.1 && ttime > c.joypresswaitstop
        state = 3;    % did not press joy; repeat trial number
    end

    %%%% STATE 0.25 = WAITING FOR SUBJECT FIXATION (F) while maintaining joystick (J) press
    % If the joystick is being held, and the maximum period to wait for
    % fixation being acquired has not elapsed, and fixation is being held,
    % set state 0.5, and make a note of that time ("timefa").
    ttime = GetSecs-trstart;
    if  state == 0.2 && ttime < (timejp + c.fixwaitstop) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
        state = 0.5;    % fixation acquired
        timefa = GetSecs - trstart;  % time fixation acquired
        strobe(3004)

    elseif state == 0.2 && ~checkJoy(c.passJoy,joy,c.joythP,0)
        timeBJ = GetSecs - trstart; % time broke joy press
        fcolor= backcolor;
        fcolor2= backcolor;
        fwcolor = backcolor;
         timefpoff= GetSecs - trstart;
        state = 3.1;     % broke joy press
        strobe(2005)
        
    elseif state == 0.2 && ttime > timejp + c.fixwaitstop
        state = 2;       % did not acquire fixation
        fcolor= backcolor;
        fcolor2= backcolor;
        fwcolor = backcolor;
        timefpoff= GetSecs - trstart;
    end


    %%%% STATE 0.5 = MAINTAIN FIXATION (F) and joy press
    ttime = GetSecs-trstart;
    if state == 0.5
        if ttime < (timefa + c.fixholdduration) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
                        
            if ttime > timefa + c.motionwait && timeloc1onset ==-1 && c.loc1on ==1 
                
                loc1on=1;     % loc1 on
                loc1color=c.dotscolor;     % dots clut indx
                timeloc1onset = GetSecs - trstart; % time of dots onset

                strb.value = 6001;
                strb.bool = 1;
            end
            if ttime > timefa + c.motionwait && timeloc2onset ==-1 && c.loc2on ==1

                loc2on=1;     % loc2 on
                loc2color=c.dotscolor;     % dots clut indx
                timeloc2onset = GetSecs - trstart; % time of dots onset
                
                strb.value = 6001;
                strb.bool = 1;
            end
            
        elseif ttime < (timefa + c.motionwait)  && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && ~checkJoy(c.passJoy,joy,c.joythP,0)
            fcolor= backcolor;
            fcolor2= backcolor;
            fwcolor = backcolor;
            timefpoff= GetSecs - trstart;
            strb.value = 3003;
            strb.bool = 1;
            
            timeBJ = GetSecs - trstart;                 % time broke joy press
            joyfillc=3;
            state = 3.2;                                % broke joy press
            strobe(2005)
        elseif  ttime > (timefa + c.motionwait) && ttime < (timefa + c.fixholdduration)  && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && ~checkJoy(c.passJoy,joy,c.joythP,0)
             fcolor= backcolor;
             fcolor2= backcolor;
            fwcolor = backcolor;
            timefpoff= GetSecs - trstart;
            strb.value = 3003;
            strb.bool = 1;
            
             timejr = GetSecs - trstart; 
            joyfillc=3;
            state = 3.3;   
            strobe(2005)
        elseif ttime < (timefa + c.fixholdduration)  && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0)
            fcolor= backcolor;
            fcolor2= backcolor;
            fwcolor = backcolor;
            timeBF = GetSecs - trstart;
            timefpoff= GetSecs - trstart;
            strb.value = 3003;
            strb.bool = 1;
            
            strobe(3005)
            if ttime < timefa + c.motionwait
            state = 2.1;                                  % broke fixation
            else
                state=2.2;
            end            
        elseif ttime > (timefa + c.fixholdduration) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) && checkJoy(c.passJoy,joy,c.joythP,0) % neither broke fixation nor joypress.
            timech      = GetSecs - trstart;
            if c.trialtype==2 || c.trialtype==1
                 if s.fixChangeTrial
                 fcolor=c.dimvalue;
                 strb.value = 3002;
                 strb.bool = 1;
                 state   = 1;
                 else
                state=1.1;
                 end
            else
                 if s.dirChangeTrial
                 strb.value = 6004;
                 strb.bool = 1;
                 state   = 1;
                 else
                 state=1.1;
                 end
            end
        end
    end
        ttime = GetSecs-trstart;
           
    % get dirchange times on FA trials
    if c.trialtype==2  && s.dirChangeTrial && ttime>(timefa+c.motionwait+c.motiondirchtime1) && loc1on==1 && loc2on==1 && dirchangestrobed==0
                 strb.value = 6005;
                 strb.bool = 1;
                 dirchangestrobed=1;
    end
        ttime = GetSecs-trstart;
    %%%% after no change
    if state == 1.1
        if ttime <= (timech + c.rewardwait) && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) 
            strobe(3005)         
         timefpoff   = GetSecs - trstart;
         strb.value = 3003;
            strb.bool = 1;
         timeBF = GetSecs - trstart;
            state = 2.3;
            
         elseif ttime <= (timech + c.rewardwait) && ~checkJoy(c.passJoy,joy,c.joythP,0)
         strobe(2005)
         timejr   = GetSecs - trstart;
         joyfillc=3;
         timefpoff   = GetSecs - trstart;
         strb.value = 3003;
            strb.bool = 1;
         state = 3.3;
         
        elseif ttime >= (timech + c.rewardwait)
                            %               Deliver Reward
                Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
                Datapixx('StartDacSchedule');
                Datapixx('RegWrRd');
                strobe(8000)
                timerwd     = GetSecs - trstart;
                timefpoff   = GetSecs - trstart;
                strb.value = 3003;
                strb.bool = 1;
                state = 4.2;  
        end
    end
    

    % Give reward to joy rel on change
    ttime = GetSecs-trstart;
    if state == 1
        % If the joystick-release window hasn't passed and the joystick has
        % been released, deliver the reward and set state 1.5.
        if (ttime <= (timech + c.joypressmax) && ttime > (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            strobe(2002)
            timejr   = GetSecs - trstart;
                joyfillc=3;
                state  = 4;
        % If he released the joystick after the FP went off but at too
        % short a latency, this is an anticipatory release.
        elseif ttime <= (timech + c.joypressmin) && ~checkJoy(c.passJoy,joy,c.joythP,0)
            strobe(2005)
            timejr   = GetSecs - trstart;
            timefpoff   = GetSecs - trstart;
            strb.value = 3003;
            strb.bool = 1;
            joyfillc=3;
            state = 3.3;
                    % if fixation broken before joypressmin       
        elseif ttime <= (timech + c.joypressmax) && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
           strobe(3005)
           timefpoff   = GetSecs - trstart;
           strb.value = 3003;
            strb.bool = 1;
           timeBF = GetSecs - trstart;
            state = 2.3;
                     % If the joystick-release window has passed, 
        % long-latency error.
        elseif ttime <= (timech + c.rewardwait) && ttime > (timech + c.joypressmax) 
            if ~checkJoy(c.passJoy,joy,c.joythP,0) && squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH) 
               timefpoff   = GetSecs - trstart;
               timejr   = GetSecs - trstart;
                joyfillc=3;
               strb.value = 3003;
                strb.bool = 1;
                state = 3.4;
            else
                timefpoff   = GetSecs - trstart;
               strb.value = 3003;
                strb.bool = 1;
                state = 3.4;
            end
        
        end
    end
    
    if state == 4
        if ttime>=timech+c.rewardwait % hits
         %               Deliver Reward
                Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
                Datapixx('StartDacSchedule');
                Datapixx('RegWrRd');
                strobe(8000)
                timerwd     = GetSecs - trstart;
                timefpoff   = GetSecs - trstart;
                strb.value = 3003;
                strb.bool = 1;
                state = 4.1;
        elseif ttime <= timech+c.rewardwait && ~squarewindow(c.passEye,PfixXY-[s.EyeX s.EyeY],PfpWindW,PfpWindH)
            strobe(3005)
            timeBF = GetSecs - trstart;
            timefpoff   = GetSecs - trstart;
            strb.value = 3003;
            strb.bool = 1;
            state = 2.4;
        end
    end
    
    ttime = GetSecs-trstart;
    if ttime > lastframetime + frametimestep-0.006
        if c.useDataPixxBool
            Screen('FillRect', c.window,backcolor)   % draw background color; when using overlay window.
            Screen('DrawLines', c.window, GridXY,[],gridc,c.middleXY)   % draw grid lines on 2nd display
            % Draw the gaze position.
            Screen('FillRect', c.window, ecolor, [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR)
            Screen('FillRect',c.window, joyfillc,[1600 800 1700 800+300*abs((2.5-joy)/2.5)]) % draw joy bar fill

            Screen('FrameRect',c.window, joyfillc,c.joybar) % draw joybar frame
            
            
            % lnk
          
            if cueTransient==1
                if ttime>=timefa+c.cueonset && ttime<=timefa+c.cueonset+c.cueduration && timefa~=-1
                    fixdotframe(c,PfixXY,c.fixdotW,fcolor,c.fixdotW2,fcolor2,fwcolor,PfpWindW,PfpWindH)   % draw outerborder
                else
                    fixdotframe2(c,PfixXY,c.fixdotW,fcolor,fwcolor,PfpWindW,PfpWindH)   % draw fixation point
                end
            else
                fixdotframe(c,PfixXY,c.fixdotW,fcolor,c.fixdotW2,fcolor2,fwcolor,PfpWindW,PfpWindH)   % draw fixation point and outerborder
            end
            
           
            
            
           
            if loc2on ==1
                Screen('Drawdots',c.window,[FdotX1{m} FdotY1{m}]',FdotW1{m},[1 1 1]'*loc2color,c.middleXY,1)  % draw foil dots
                if m < size(FdotX1,2)
                    m=m+1;     % update cue dots frame indx
                end
            end
            
            if loc1on == 1
                Screen('Drawdots',c.window,[dotX{k} dotY{k}]',dotW{k},[1 1 1]'*loc1color,c.middleXY,1) % draw cue dots
                if k < size(dotX,2)
                    k=k+1;     % update cue dots frame indx
                end
            end
            temptime = Screen('Flip', c.window,GetSecs + 0.00); % flip frame
            
            if strb.bool
                strobe(strb.value)
                strb.bool = 0;
            end
            
            lastframetime = temptime-trstart;
        end
        
        
    end
    
    ttime = GetSecs-trstart;
    
end
% Clear the display
    Screen('FillRect', c.window,backcolor)
    Screen('Flip', c.window);
    
% determine false alarms on trialtype2 (FA trials); more simpler because of
% the state 3.3 (3.3 indicates joy releeases on no fix change trials and joyreleases before fix change time on fixchange trials,just need to see if RT is after dirchange)
if c.trialtype==2  && s.dirChangeTrial && state==3.3 && timejr>(timefa+c.motionwait+c.motiondirchtime1+c.joypressmin)
                        state=5; % false alarm state
end
   
%%%%% End of Runtrial While-Loop
if start == 1
    sendOmniPlexStimInfo(c,s,state);
    strobe(30009)
    stoprecording; % omniplex
end



% wait for joystick release before next trial
if state == 2 || state == 2.1 || state == 2.2 || state == 2.3 || state ==2.4 || state == 3 || state == 3.1 || state==3.2 || state ==3.3 || state ==3.4 || state ==4.1 || state == 4.2 || state == 5
    while ~checkJoy(c.passJoy,joy,c.joythR,1) && c.quit == 0
        Datapixx('RegWrRd');                    % Update registers for GetAdcStatus
        status = Datapixx('GetAdcStatus');
        if status.scheduleRunning == 0 && status.freeRunning == 0
            Datapixx('EnableAdcFreeRunning');   % enable free running mode if ADC schedule stopped
        end
        joy = getjoy;                           % get joy position
        joyfillc =5;
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

%%% Read continuously sampled Eye data
if c.useDataPixxBool
    Datapixx('RegWrRd');                    % Update registers for GetAdcStatus
    status = Datapixx('GetAdcStatus');
    nReadSpls = status.newBufferFrames;      % How many Spls can we read?
    [EyeJoy, EyeJoyts] = Datapixx('ReadAdcBuffer', nReadSpls, adcBuffBaseAddr);
    Datapixx('StopAdcSchedule');
    timestopAdcSchedule= GetSecs - trstart;
end


% update counters based on trial result
if (state == 4.1 || state ==4.2) %rewards(hits and correct rejects)
    if c.playAudioBool==1
        sound(c.righttone, c.freq)
    end
    c.trinblk         = c.trinblk + 1; %c.j counter increment only when trial is finished without fix break or ant rel
    c.progrewardcount = c.progrewardcount + 1;
    c.repeattrial=0;
    s.NumRewards    = s.NumRewards+1;
    
elseif state == 3.3         %
    if c.playAudioBool==1
        sound(c.noisetone, c.freq) % lnk: tricky. somewhere between "break" and FA....
    end
    c.antrels=c.antrels+1;
    c.repeattrial=1;
    WaitSecs (0.5+1*rand);
    
elseif state == 5 %false alram
    if c.playAudioBool==1
        sound(c.wrongtone, c.freq)
    end
    c.trinblk         = c.trinblk + 1;
    c.repeattrial=0;
    WaitSecs (2.5+1*rand);
    
elseif state == 3.4 % misses
    if c.playAudioBool==1
        sound(c.wrongtone, c.freq)
    end
    c.trinblk         = c.trinblk + 1;
    c.repeattrial=0;
    
elseif state>2 && state<3
    if c.playAudioBool==1
        sound(c.noisetone, c.freq)
    end
    c.progrewardcountflag =0;
    c.fixbreakflag=1;
    WaitSecs (0.5+1*rand);
    c.progrewardcount =0;
    c.fixbreaks=c.fixbreaks+1;
    c.fixvoilations=c.fixvoilations+1;
    c.repeattrial=1;
else
    c.repeattrial=1;        % lnk: probably broken...
    if c.playAudioBool==1
        sound(c.noisetone, c.freq)
    end
end

s.fixbreaks=c.fixbreaks;
s.antrels=c.antrels;

% update trial list
c=updatetriallist(c);
    
    
%% OUTPUT behavioral data

if  timejp~=-1 % trials where joy stick pressed
   
    PDS.trialnumber(c.j) = c.j;
    PDS.setno(c.j) = c.setno;
    PDS.blockno(c.j) = c.blockno;
    PDS.state(c.j) = state;
    PDS.FPpos(c.j,:) = s.fixXY;
    PDS.fpon(c.j) = c.fpon;
    PDS.trialcode(c.j) = c.trialcode;
    % times
   PDS.timestartAdcSchedule(c.j) = timestartAdcSchedule;
   PDS.timestopAdcSchedule(c.j) = timestopAdcSchedule;
    PDS.trialstarttime(c.j)      = trstart;
    PDS.timefpon(c.j)           = timefpon;     % Joy press & FP on
    PDS.fpentered(c.j)          = timefa;      % Fix Win entered
    PDS.trialtype(c.j)          = c.trialtype;
    PDS.timeloc2onset(c.j)      = timeloc2onset;
    PDS.timeloc1onset(c.j)      = timeloc1onset;
    PDS.reward(c.j)             = c.reward_time;
    PDS.fixholdduration(c.j)    = c.fixholdduration;%duration before change
    PDS.timefpoff(c.j)          = timefpoff;
    PDS.voltjoypress(c.j)       = c.joythP;
    PDS.timejoypress(c.j)       = timejp;
    PDS.timebrokefix(c.j)       = timeBF;   % broke fix
    PDS.timebrokejoy(c.j)       = timeBJ;   % broke joy press
    PDS.timereward(c.j)         = timerwd;  % Reward
    PDS.timejoyrel(c.j)         = timejr;   % joy release
    
    PDS.dirchangetrial(c.j)      = s.dirChangeTrial;
    if s.Changeloc>0
    PDS.changeloc(c.j)           = c.locations(s.Changeloc);  
    else
    PDS.changeloc(c.j)           = -1;     
    end
    PDS.dirchangetime(c.j)       = c.motiondirchtime1 + c.motionwait +timefa;
    PDS.fixchangetrial(c.j)      = s.fixChangeTrial;
    PDS.fpchangetime(c.j)        = c.fixdimchtime + c.motionwait +timefa;
    PDS.dimvalue(c.j)            = c.dimvalue;
    PDS.loc1loc(c.j)             = c.loc1deg;
    PDS.loc1dir(c.j)             = c.loc1dir;
    PDS.loc1del(c.j)             = c.loc1del;
    PDS.loc2loc(c.j)             = c.loc2deg;
    PDS.loc2dir(c.j)             = c.loc2dir;
    PDS.loc2del(c.j)             = c.loc2del;
    PDS.locecc(c.j)              =c.RFlocecc;
    % eye & joy position
    PDS.EyeXYZ{c.j} = EyeJoy(1:3,:);
    PDS.Joy{c.j} = EyeJoy(4,:);       % Joypos;
    PDS.adcts{c.j} = EyeJoyts;

    s.JoyPressT                 = timejp;   % What time was the joystick pressed?
    s.JoyReleaseT               = timejr;  % What time was the joystick released?

    c.j=c.j+1;% increase tr no everytime joy pressed
    
    PDS.cueTransient(c.j) = cueTransient;
end

end         % end of run function


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

function joy = getjoy()

Datapixx RegWrRd
V       = Datapixx('GetAdcVoltages');
joy     = V(4); % joystick is on the 4th analog channel; first 3 are EyeX,Y and pupil size
if joy<0
    joy=0;
end
end




function fixdotframe(c,PfixXY,fixdotW,fixcolor,fixdotW2,fixcolor2,fixWincolor,PfpWindW,PfpWindH)

Screen('FrameRect',c.window,fixcolor,[PfixXY PfixXY] + [-c.cursorR -c.cursorR c.cursorR c.cursorR],fixdotW)
Screen('FrameRect',c.window,fixWincolor,[PfixXY PfixXY] + [-PfpWindW -PfpWindH PfpWindW PfpWindH],c.fixwinW)
Screen('FrameRect',c.window,fixcolor2,[PfixXY PfixXY] + [-c.cursorR2 -c.cursorR2 c.cursorR2 c.cursorR2],fixdotW2)

end

function fixdotframe2(c,PfixXY,fixdotW,fixcolor,fixWincolor,PfpWindW,PfpWindH)

Screen('FrameRect',c.window,fixcolor,[PfixXY PfixXY] + [-c.cursorR -c.cursorR c.cursorR c.cursorR],fixdotW)
Screen('FrameRect',c.window,fixWincolor,[PfixXY PfixXY] + [-PfpWindW -PfpWindH PfpWindW PfpWindH],c.fixwinW)

end

function [dotX,dotY,dotC,dotW] = gendots_pstnk(c,dduration,refreshrate,dotoffset,theta,thetadel,chtime)
%
% GENDOTS generates "Sekuler" dots for use in PsychToolBox Experiments,
%  using (default) 3 tiers and partially hidden by a round aperture. 
% - use with DRAWDOTS (PTB3)
% - requires DEGTOPIX
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
dotwidth = 6; % dot width in pixels
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

function pixels = deg2pix(degrees,c)
% DEG2PIX convert degrees of visual angle into pixels

pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end



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
% eyex=V(1)
% eyey=V(1)
end

function c = updatetriallist(c)
% trialtype baseline
if c.trialtype==1 && c.repeattrial==0;%if its a good finished trial update the ptr list
c.triallist1_tbd=c.triallist1_tbd(2:end);
    if isempty(c.triallist1_tbd)
        c.triallist1_tbd=Shuffle(c.triallist1_init);
    end
elseif c.trialtype==1 && c.repeattrial==1;%if its a trial to be repeated:move the trialtype ptr to the end in the list and shuffle
c.triallist1_tbd=[c.triallist1_tbd(2:end) c.triallist1_tbd(1)];    
% c.triallist1_tbd=Shuffle(c.triallist1_tbd);
end

% trialtype FA
if c.trialtype==2 && c.repeattrial==0
c.triallist2_tbd=c.triallist2_tbd(2:end);
    if isempty(c.triallist2_tbd)
        c.triallist2_tbd=Shuffle(c.triallist2_init);
    end
elseif c.trialtype==2 && c.repeattrial==1
c.triallist2_tbd=[c.triallist2_tbd(2:end) c.triallist2_tbd(1)];  
% c.triallist2_tbd=Shuffle(c.triallist2_tbd);
end

% trialtype PA
if c.trialtype==3 && c.repeattrial==0
c.triallist3_tbd=c.triallist3_tbd(2:end);
    if isempty(c.triallist3_tbd)
        c.triallist3_tbd=Shuffle(c.triallist3_init);
    end
elseif c.trialtype==3 && c.repeattrial==1
c.triallist3_tbd=[c.triallist3_tbd(2:end) c.triallist3_tbd(1)];
% c.triallist3_tbd=Shuffle(c.triallist3_tbd);
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
%% The function sends Omniplex stimuls tag info followed by its value.
function sendOmniPlexStimInfo(c,s,state)
% trial,block and set info
sendStimTag(11001)
sendStimValue(c.connectPLX)

sendStimTag(11002)
sendStimValue(c.j)

sendStimTag(11003)
sendStimValue(c.blockno)

sendStimTag(11004)
sendStimValue(c.trinblk)

sendStimTag(11005)
sendStimValue(c.setno)

%trial type info
sendStimTag(11010)
sendStimValue(c.trialcode)

sendStimTag(11009)
sendStimValue(c.trialtype)

%trial result
sendStimTag(11008)
sendStimValue(state*10)

% if c.trialtype~=3
% % dim info
% sendStimTag(13002)
% sendStimValue(s.fixChangeTrial)
% end

if c.trialtype~=1

% motion stim info
% sendStimTag(16010)
% sendStimValue(s.Changeloc)
% 
% sendStimTag(16010)
% sendStimValue(s.dirChangeTrial)

sendStimTag(16001)
sendStimValue(floor(c.loc1deg*10))

sendStimTag(16002) %;%loc1 ecc
sendStimValue(c.RFlocecc*10)

sendStimTag(16003)
sendStimValue(floor(c.loc2deg*10))

sendStimTag(16004) ;%loc2 ecc same as loc 1
sendStimValue(c.RFlocecc*10)

sendStimTag(16012)
sendStimValue(c.loc1dir)

sendStimTag(16013)
sendStimValue(c.loc2dir)

sendStimTag(16010)
sendStimValue(c.loc1del)

sendStimTag(16011)
sendStimValue(c.loc2del)

end

%reward info
sendStimTag(18001)
sendStimValue(c.progrewardcountflag)

sendStimTag(18000)
sendStimValue(floor(100*c.reward_time))

%
sendStimTag(11099)
sendStimValue(3)

sendStimTag(11095)
sendStimValue(c.inactivation)

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