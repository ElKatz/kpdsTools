function [pds] = convert_PDS(PDS)
%   [pds] = convert_PDS(PDS)
% 
% Convert the standard klapb pds struct into a more user-friedly struct
% names, well, 'pds'.
% The idea is that it is a struct array of length nTrials. 
% Fieldnames will be more verbose (and explanatory), and there will be
% sub-structs.


nTrials = numel(PDS.trialnumber);

for iT = 1:nTrials
    
    pds(iT).trialnumber     = PDS.trialnumber(iT);
    pds(iT).setno           = PDS.setno(iT);
    pds(iT).blockno         = PDS.blockno(iT);
    pds(iT).state           = PDS.state(iT);
    pds(iT).fpon            = PDS.fpon(iT);    % no idea 
    pds(iT).trialcode       = PDS.trialcode(iT);
    pds(iT).voltjoypress    = PDS.voltjoypress(iT);
    pds(iT).dirchangetrial  = PDS.dirchangetrial(iT);
    pds(iT).changeloc       = PDS.changeloc(iT);
    pds(iT).fixchangetrial  = PDS.fixchangetrial(iT);
    pds(iT).dimvalue        = PDS.dimvalue(iT);
    
    % timing:
    pds(iT).timing.datapixxtime = PDS.datapixxtime(iT);
    pds(iT).timing.timestartAdcSchedule = PDS.timestartAdcSchedule(iT);
    pds(iT).timing.timestopAdcSchedule = PDS.timestopAdcSchedule(iT);
    pds(iT).timing.trialstarttime = PDS.trialstarttime(iT);
    pds(iT).timing.timefpon = PDS.timefpon(iT);
    pds(iT).timing.timejoypress = PDS.timejoypress(iT);
    pds(iT).timing.timebrokefix = PDS.timebrokefix(iT);
    pds(iT).timing.timebrokejoy = PDS.timebrokejoy(iT);
    pds(iT).timing.timereward = PDS.timereward(iT);
    pds(iT).timing.timejoyrel = PDS.timejoyrel(iT);
    pds(iT).timing.dirchangetime = PDS.dirchangetime(iT);
    pds(iT).timing.fpchangetime = PDS.fpchangetime(iT);
    
    % geometry:
    pds(iT).geometry.FPpos = PDS.FPpos(iT);
    pds(iT).geometry.loc1loc = PDS.loc1loc(iT);
    pds(iT).geometry.loc1dir = PDS.loc1dir(iT);
    pds(iT).geometry.loc1del = PDS.loc1del(iT);    
    pds(iT).geometry.loc2loc = PDS.loc2loc(iT);
    pds(iT).geometry.loc2dir = PDS.loc2dir(iT);
    pds(iT).geometry.loc2del = PDS.loc2del(iT);
    pds(iT).geometry.locecc = PDS.locecc(iT); 
    
    % datapixx data:
    pds(iT).datapixxData.time       = PDS.adcts{iT};
    pds(iT).datapixxData.eye_x      = PDS.EyeXYZ{iT}(1,:);
    pds(iT).datapixxData.eye_y      = PDS.EyeXYZ{iT}(2,:);
    pds(iT).datapixxData.eye_z      = PDS.EyeXYZ{iT}(3,:);
    pds(iT).datapixxData.joystick_v = PDS.Joy{iT};
end
    