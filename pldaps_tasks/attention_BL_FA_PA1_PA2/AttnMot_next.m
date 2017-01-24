function [PDS ,c ,s]= AttnMot_next(PDS ,c ,s)
% next_trial function
% this is executed once at the beginning of each trial
% as the first step of the 'Run' action from the GUI
% (the other steps are 'run_trial' and 'finish_trial'
% This is where values are loaded as needed for the next trial

%% set up upcoming trial epoch times
c.fixchtime = unifrnd(c.stimdur_min,c.stimdur_max); % fixation change time
c.stimchtime = unifrnd(c.stimdur_min,c.stimdur_max); % time before peripheral stim change
if c.trialtype==1 || c.trialtype==2
    c.fixholdduration = c.fixchtime + c.stimwait ;% fixation time before change happens
    c.stimdur = c.fixchtime+c.rewardwait;% total duration for stim presenation
else
    c.fixholdduration = c.stimchtime + c.stimwait ;% fixation time before change happens
    c.stimdur = c.stimchtime+c.rewardwait;% total duration for stim presenation
end

%% set up trial type info
c.fixChangeTrial       = c.trialtype_values(c.triallist(1),1);%0-no change;1-change
c.stimChangeTrial      = c.trialtype_values(c.triallist(1),2);%0-no change;1:CCW del; 2:CW del
c.Changeloc            = c.trialtype_values(c.triallist(1),3);%0-no change;1: loc1(RF);2: loc2
c.trialtype            = c.trialtype_values(c.triallist(1),5);%trial type
c.trialcode            = c.trialtype_values(c.triallist(1),6);%trial code

if c.trialtype==1
    c.loc1on=0;
    c.loc2on=0;
    c.joypressmax          = c.joypressmax_fpdim;
    c.cuecolor             = c.FA_color;
    
elseif c.trialtype==2
    c.loc1on=1;
    c.loc2on=1;
    c.joypressmax          = c.joypressmax_fpdim;
    c.cuecolor             = c.FA_color;
    
elseif c.trialtype==3
    c.cuecolor           = c.PA_color;
    c.joypressmax        = c.joypressmax_stim;
    
    if c.Changeloc==1
        c.loc1on=1;
        c.loc2on=0;
    elseif c.Changeloc==2
        c.loc1on=0;
        c.loc2on=1;
    end
    
elseif c.trialtype==4
    c.loc1on=1;
    c.loc2on=1;
    c.cuecolor           = c.PA_color;
    c.joypressmax        = c.joypressmax_stim;
end

%% deltas for Loc1 and Loc2
if c.stimChangeTrial>0
    if c.Changeloc==1
        c.loc1del=c.dels(c.stimChangeTrial);
        c.loc2del=0;
    elseif c.Changeloc==2
        c.loc1del=0;
        c.loc2del=c.dels(c.stimChangeTrial);
    end
else
    c.loc1del=0;
    c.loc2del=0;
end

%% update status values
s.TrialNumber   = c.j;
s.TrinBlk   = c.trinblk;
s.trialtype = c.trialtype;
s.trialcode = c.trialcode;
s.fixChangeTrial = c.fixChangeTrial;
s.stimChangeTrial = c.stimChangeTrial;
s.Changeloc = c.Changeloc;
s.blockno = c.blockno;
s.setno = c.setno;
end


