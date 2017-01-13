function [PDS ,c ,s]= joypress_next(PDS ,c ,s)
% next_trial function
% this is executed once at the beginning of each trial
% as the first step of the 'Run' action from the GUI
% (the other steps are 'run_trial' and 'finish_trial'
% This is where values are block as needed for the next trial

%% dimming and attention task blocks interaleaved
if rem(c.trinblk-1,c.trialsperblock)==0 && c.blocksetflag==0
    if rem(c.blockno,4)==1
        c.trialtype=1;
        c.progrewardcount =0;
        c.fixbreakflag=0;
        c.fixvoilations=0;
        c.trinblk=1;
        c.blocksetflag=1;
        c.progrewardcountflag =0;% no prog reward on baseline blocks
    elseif rem(c.blockno,4)==2 && c.repeatblock==0
        c.trialtype=2;
        c.progrewardcount =0;
        c.fixbreakflag=0;
        c.trinblk=1;
        c.blocksetflag=1;
        c.progrewardcountflag=0;
        c.fixvoilations=0;
    elseif rem(c.blockno,4)==3 && c.repeatblock==0
        c.trialtype=3;
        c.progrewardcount =0;
        c.fixbreakflag=0;
        c.trinblk=1;
        c.blocksetflag=1;
        c.progrewardcountflag=0;
        c.fixvoilations=0;
    elseif rem(c.blockno,4)==0 && c.repeatblock==0
        c.trialtype=4;
        c.progrewardcount =0;
        c.fixbreakflag=0;
        c.trinblk=1;
        c.blocksetflag=1;
        c.progrewardcountflag=0;
        c.fixvoilations=0;
    elseif c.repeatblock==1
        c.fixvoilations=0;
        c.trinblk=1;
        c.blocksetflag=1;
        c.progrewardcountflag=0;
    end
end


% c.trialsperblock determines the end of block (see finish file):
if c.trialtype==1
    c.trialsperblock=floor(c.trialsperblock_init/6);%baseline blocks
elseif c.trialtype==2
    c.trialsperblock=c.trialsperblock_init;% FA blocks
elseif c.trialtype==3
    c.trialsperblock=c.trialsperblock_init/2;% pA blocks
elseif c.trialtype==4
    c.trialsperblock=c.trialsperblock_init;% pA blocks
end

% set up upcoming trial epoch times
if c.trialtype==1 || c.trialtype==2
    c.fixdimchtime = c.fixholdmin + c.fixholdrand*rand; % fixdm time
    c.motiondirchtime1 = c.fixholdmin + c.fixholdrand*rand; %% Uniform distribution; time before motion direction change
    c.motiondirchtime2 = c.rewardwait;%c.joypressmax+c.rewardwait;  %% Uniform distribution; time after motion direction change (untill reward)
    c.motiondirchtime =c.fixdimchtime+c.motiondirchtime2;%  total duration for motion presenation
    c.fixholdduration   = c.fixdimchtime + c.motionwait ;%fixation time before change happens
else
    c.motiondirchtime1 = c.fixholdmin + c.fixholdrand*rand;  %% Uniform distribution; time before motion direction change
    c.motiondirchtime2 = c.rewardwait;%c.joypressmax+c.rewardwait;  %% Uniform distribution; time after motion direction change
    c.motiondirchtime =c.motiondirchtime1+c.motiondirchtime2;% total duration for motion presenation
    c.fixholdduration   = c.motiondirchtime1 + c.motionwait ;%fixation time before change happens
end

%%
c.middleXY = c.screenRect([3 4])/2; % center of the display

c.fixXY = [c.fixXY(1,1) -1*c.fixXY(1,2)]; % invert yaxis- as Psychtoolbox y-axis is positive downwards.

s.FixHoldReq            = c.fixholdduration;

c.fixXY=[c.fpX c.fpY];

c.locations = [c.RFloctheta, mod(180-c.RFloctheta,360)];
c.loc1deg = c.locations(1);
[X,Y] = pol2cart(c.loc1deg*pi/180,c.RFlocecc);                 % first location
c.locc1art = [X,-1*Y];

c.loc2deg = c.locations(2);                      % 2nd locations
[a, b] = pol2cart(c.loc2deg*pi/180,c.RFlocecc);
c.locc2art = [a;-1*b]';


c.loc1dir = c.RFprefdir;
c.loc2dir =  mod(180-c.RFprefdir,360);

c.dels   = [c.del 360-c.del];
%%
if c.trialtype==1
    c.loc2on=0;
    c.loc1on=0;
    s.fixChangeTrial       = c.trialtype_values(c.triallist1_tbd(1),1);%0-no change;1-change
    s.dirChangeTrial       = c.trialtype_values(c.triallist1_tbd(1),2);%0-no change;1: +del;2: -del
    s.Changeloc            = c.trialtype_values(c.triallist1_tbd(1),3);%0-no change;1: loc1(RF);2: loc2
    if s.dirChangeTrial>0
        if s.Changeloc==1
            c.loc1changetime = c.motiondirchtime1;
            c.loc2changetime = c.motiondirchtime;
        elseif s.Changeloc==2
            c.loc1changetime = c.motiondirchtime;
            c.loc2changetime = c.motiondirchtime1;
        end
        c.loc1del=c.dels(s.dirChangeTrial);
        c.loc2del=c.dels(s.dirChangeTrial);
    else
        c.loc1changetime = c.motiondirchtime;
        c.loc2changetime = c.motiondirchtime;
        c.loc1del=c.del;
        c.loc2del=c.del;
    end
    c.fixcolor=6;
    c.fixbordercolor=1;
    c.dotscolor=6;
    c.dimvalue=13;
    c.trialcode=c.trialtype_values(c.triallist1_tbd(1),5);
    c.joypressmax        = 0.6;
    
elseif c.trialtype==2
    c.loc2on=1;
    c.loc1on=1;
    s.fixChangeTrial       = c.trialtype_values(c.triallist2_tbd(1),1);%always pick the first in the pointer list
    s.dirChangeTrial       = c.trialtype_values(c.triallist2_tbd(1),2);
    s.Changeloc            = c.trialtype_values(c.triallist2_tbd(1),3);
    if s.dirChangeTrial>0
        if s.Changeloc==1
            c.loc1changetime = c.motiondirchtime1;
            c.loc2changetime = c.motiondirchtime;
            
        elseif s.Changeloc==2
            c.loc1changetime = c.motiondirchtime;
            c.loc2changetime = c.motiondirchtime1;
        end
        c.loc1del=c.dels(s.dirChangeTrial);
        c.loc2del=c.dels(s.dirChangeTrial);
    else
        c.loc1changetime = c.motiondirchtime;
        c.loc2changetime = c.motiondirchtime;
        c.loc1del=c.del;
        c.loc2del=c.del;
    end
    c.fixcolor=6;
    c.fixbordercolor=1;
    c.dotscolor=6;
    c.dimvalue=13;
    c.trialcode=c.trialtype_values(c.triallist2_tbd(1),5);
    c.joypressmax        = 0.6;
elseif c.trialtype==3
    
    s.fixChangeTrial       = 0;%c.trialtype_values(c.triallist3_tbd(1),1);
    s.dirChangeTrial       = binornd(1,0.75);%c.trialtype_values(c.triallist3_tbd(1),2);
    s.Changeloc            = 1+binornd(1,0.5);%c.trialtype_values(c.triallist3_tbd(1),3);
    if s.dirChangeTrial>0
        if s.Changeloc==1
            c.loc1changetime = c.motiondirchtime1;
            c.loc2changetime = c.motiondirchtime;
            c.loc1on=1;
            c.loc2on=0;
        elseif s.Changeloc==2
            c.loc1changetime = c.motiondirchtime;
            c.loc2changetime = c.motiondirchtime1;
            c.loc1on=0;
            c.loc2on=1;
            
        end
        c.loc1del=c.dels(1+binornd(1,0.5));
        c.loc2del=c.dels(1+binornd(1,0.5));
        
    else
        c.loc1changetime = c.motiondirchtime;
        c.loc2changetime = c.motiondirchtime;
        c.loc1del=c.del;
        c.loc2del=c.del;
        c.loc1on=binornd(1,0.5);
        c.loc2on=1-c.loc1on;

    end
    c.fixcolor=6;
    c.fixbordercolor=10;
    c.dotscolor=6;
    c.trialcode=c.trialtype_values(c.triallist3_tbd(1),5);
    c.joypressmax        = 0.75;
elseif c.trialtype==4
    c.loc2on=1;
    c.loc1on=1;
    s.fixChangeTrial       = 0;%c.trialtype_values(c.triallist3_tbd(1),1);
    s.dirChangeTrial       = binornd(1,0.75);%c.trialtype_values(c.triallist3_tbd(1),2);
    s.Changeloc            = 1+binornd(1,0.5);%c.trialtype_values(c.triallist3_tbd(1),3);
    if s.dirChangeTrial>0
        if s.Changeloc==1
            c.loc1changetime = c.motiondirchtime1;
            c.loc2changetime = c.motiondirchtime;
            
        elseif s.Changeloc==2
            c.loc1changetime = c.motiondirchtime;
            c.loc2changetime = c.motiondirchtime1;
        end
        c.loc1del=c.dels(1+binornd(1,0.5));
        c.loc2del=c.dels(1+binornd(1,0.5));
    else
        c.loc1changetime = c.motiondirchtime;
        c.loc2changetime = c.motiondirchtime;
        c.loc1del=c.del;
        c.loc2del=c.del;
    end
    c.fixcolor=6;
    c.fixbordercolor=10;
    c.dotscolor=6;
    c.trialcode=c.trialtype_values(c.triallist3_tbd(1),5);
    c.joypressmax        = 0.75;
    
end
c.loc1duration = c.motiondirchtime;
c.loc2duration = c.motiondirchtime;

% determine reward before setting up the dac schedule (progressive reward)
if c.progrewardcountflag==1
    increment=0.14;
    c.reward_time=c.reward_time_init+(increment*c.progrewardcount*c.reward_time_init*(1-c.fixbreakflag));
else
    c.reward_time=c.reward_time_init;
end

% show these vars before start of trial
s.TrinBlk   = c.trinblk;
s.TrialNumber   = c.j;
s.RewardTime = c.reward_time ;
s.trialcode = c.trialcode;
end


