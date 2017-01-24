function [pds] = convert_PDS(PDS)
%   [pds] = convert_PDS(PDS)
% 
% Convert the standard klapb pds struct into a more user-friedly struct
% names, well, 'pds'.
% The idea is that it is a struct array of length nTrials. 
% Fieldnames will be more verbose (and explanatory), and there will be
% sub-structs.

pds     = struct;
nTrials = numel(PDS.trialnumber);


for iT = 1:nTrials
    % the general stuff:
    pds(iT).trialNumber     = PDS.trialnumber(iT);
    pds(iT).blockNumber     = PDS.blockno(iT);
    pds(iT).setNumber       = PDS.setno(iT);
    pds(iT).endState        = PDS.state(iT);
    pds(iT).code            = PDS.trialcode(iT);    
    
    % made these more "general" so that they fit orientation stimuli too
    pds(iT).isChangeFA      = PDS.fixchangetrial(iT); % 0-no change;1-change
    pds(iT).isChangePA      = PDS.dirchangetrial(iT); % 0-no change; 1: +del; 2: -del
    % break up into:
    % 1. isChangePA
    % 2. deltaValue
    % 3. isCW
  
    % fa stuff:
    pds(iT).fa.delta            = PDS.dimvalue(iT); % in theroy, this can be in settings ('c') vars, but lets keep it here anyway
    pds(iT).fa.positionXY       = PDS.FPpos(iT,:);
    % pa stuff:
    pds(iT).pa.changeLocation   = PDS.changeloc(iT);    %0-no change;1: loc1;  2: loc2  
    pds(iT).pa.direction1        = PDS.loc1dir(iT); % this is motion direction
    pds(iT).pa.delta1           = PDS.loc1del(iT); % this tells us if ther delta was CW or CCW (AND IN FACT, is reduntant with PDS.dirchangetrial for +del/-del)
    pds(iT).pa.positionPolar1    = [PDS.loc1loc(iT), PDS.locecc(iT)]; % angle and radius, in polar coords.
    pds(iT).pa.direction2        = PDS.loc2dir(iT); % this is motion direction
    pds(iT).pa.delta2           = PDS.loc2del(iT); % shouldn't this be in status?
    pds(iT).pa.positionPolar2    = [PDS.loc2loc(iT), PDS.locecc(iT)]; % angle and radius, in polar coords.
     
    % timing:
    pds(iT).timing.datapixxTime     = PDS.datapixxtime(iT);
    pds(iT).timing.startAdcSchedule = PDS.timestartAdcSchedule(iT);
    pds(iT).timing.stopAdcSchedule  = PDS.timestopAdcSchedule(iT);
    pds(iT).timing.trialStart       = PDS.trialstarttime(iT);
    pds(iT).timing.fixationOn       = PDS.timefpon(iT);
    pds(iT).timing.joyPress         = PDS.timejoypress(iT);
    pds(iT).timing.breakFix         = PDS.timebrokefix(iT);
    pds(iT).timing.breakeJoy        = PDS.timebrokejoy(iT);
    pds(iT).timing.reward           = PDS.timereward(iT);
    pds(iT).timing.joyRelease       = PDS.timejoyrel(iT);
    pds(iT).timing.paChange         = PDS.dirchangetime(iT);
    pds(iT).timing.faChange         = PDS.fpchangetime(iT);
    
    % adcData from datapixx:
    pds(iT).adcData.time        = PDS.adcts{iT};
    pds(iT).adcData.eyeX        = PDS.EyeXYZ{iT}(1,:);
    pds(iT).adcData.eyeY        = PDS.EyeXYZ{iT}(2,:);
    pds(iT).adcData.pupil       = PDS.EyeXYZ{iT}(3,:);
    pds(iT).adcData.joyVolt     = PDS.Joy{iT};
end


%%





    