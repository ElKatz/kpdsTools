function [PDS, c, s] = reward_give(PDS, c, s)
%   [PDS, c, s] = reward_give(PDS, c, s)

% Function delivers rewards for a duration ('tEnd') or until user
% hits 'esc' key. Rate of reward is given by lambda, rate parameter for
% poisson distribution.
% The function loops through cycles of length 'cycle_time' and either 
% rewards or pauses.
% values are hard coded cause this function is super hacky. Change at will. 
% 20161228 lnk

%% setup:

tEnd        = 180;  % time (sec) to deliver rewards
lambda      = .7;   % rate paramter of 0.3: ~25% of draws will be rewarded, i.e. every ~4 seconds on average. I like that
reward_time = 0.1;  % reward solenoid opening time (sec)
cycletime   = 1;    % cycle time (sec)


%% init reward via datapixx:


Volt        = 4.0;
pad         = 0.01;
wave_time   = reward_time+pad;
Dacrate     = 1000;
reward_Volt = [zeros(1,round(Dacrate*pad/2)) Volt*ones(1,int16(Dacrate*reward_time)) zeros(1,round(Dacrate*pad/2))];
ndacsamples = floor(Dacrate*wave_time);
dacBuffAddr = 6e6;
chnl        = 0;
% init Datapixx:
Datapixx('Open');
Datapixx('RegWrRd');
Datapixx('WriteDacBuffer', reward_Volt,dacBuffAddr,chnl);

%% go reward go:
 
t0       = GetSecs;
tNow     = GetSecs - t0;
hWait    = waitbar(0, 'rewarding your critter. hit ''esc'' to stop');
stopFlag = false;
% start looping:
while tNow < tEnd && ~stopFlag
    k = poissrnd(lambda);
    % give reward with given poisson prbability:
    if k > 0
        Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
        Datapixx('StartDacSchedule');
        Datapixx('RegWrRd');
        pause(cycletime-reward_time);
    else
        pause(cycletime);
    end
    % check if user is hitting the esc key:
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(41) % key 41 = esc key
        stopFlag = true;
    end
    % update waitbar:
    if mod(round(tNow), round(tEnd/20))==0
        waitbar(tNow/tEnd, hWait)
    end
    
    tNow = GetSecs - t0;
end
ListenChar(0)
close(hWait)

%%
