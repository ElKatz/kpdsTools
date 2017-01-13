function [PDS, c, s] = reward_drain(PDS, c, s)
%   [PDS, c, s] = reward_drain(PDS, c, s
%
% Delivers long rewards in order to drain the reward system. 
% Intermittant pauses are taken in order to avoid frying the solenoid
% (which may occur if open for too long)

% 20161228 - lnk

%%
nRewards        = 30;
reward_time     = 9.5; % seconds 
pause_time      = .5; % seconds 
playSoundBool   = true;

tic;
total_time = nRewards * (reward_time + pause_time);
disp('---------------------------------------------');
disp(['Draining will take around ' num2str(total_time) ' seconds']);
%
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

hWait = waitbar(0, 'Draining....');
for iR = 1:nRewards
    % give reward:
    Datapixx('SetDacSchedule', 0, Dacrate, ndacsamples, chnl, dacBuffAddr, ndacsamples);
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');
    pause(reward_time + pause_time)
    if mod(iR,(round(nRewards/20)))==0
        waitbar(iR/nRewards, hWait)
    end
end
close(hWait)
disp(['Done! And only took ' num2str(toc) ' seconds']);
disp('---------------------------------------------');

% sound:
if playSoundBool
    load handel
    sound(y(1:round(numel(y)/4)), Fs)
end