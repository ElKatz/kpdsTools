%%
%%
clear all
% define your data directory:
dirData = '~/Dropbox/Code/krauzlislab_code/kpds_data';
cd(dirData)
fileList = findFile(dirData, 'AttnMot_');
disp(fileList);
nFiles = numel(fileList);
disp(['totla of ' num2str(nFiles) ' files']);

clrList = cbrewer('div', 'RdYlBu', nFiles);
%% for each file 
iF = 1;
for iF = 1:nFiles
load(fileList{iF})
clr = clrList(iF,:);

%% state defs
% 0     (start), 
% 0.1   (Waiting for Joy Press), 
% 0.2   (Joy pressed; Waiting for fixation)
% 0.5   (fixation acquired),
% 1     (change state; waiting for joy rel), 
% 1.1   no change state-- ???? are these catch trials?
% 2
% 2.1   fix break between fix-acquired & motion onset
% 2.2   fix break between motion onset & change
% 2.3   fix break after a correct joy release (ie witinh joypress window) but before reward was delivered
% 3
% 3.1   joy break between fix-acquired & motion onset
% 3.2   joy break between motion onset & change+joypressmin
% 3.3   late release: joy release beyond the joypress window (i.e. > joypressmax)
% 3.4   misses 
% 3.5   joy release on catch trials (false alarams)
% 3.6   joy release on catch trials (false alarams) but late (i.e. > joypressmax)
% 4
% 4.1   hits 
% 4.2   correct rejects 
% 5     FA distractor false alarms (unused)

%%


%% BL

% changeTrials: 1=change, 0=no change, nan=not a BL trial.
BL.idx.changeTrial = nan(1,numel(PDS.trialnumber));
BL.idx.changeTrial(PDS.trialtype==1 & PDS.fixchangetrial==1) = 1;
BL.idx.changeTrial(PDS.trialtype==1 & PDS.fixchangetrial==0) = 0;
% goodies:
BL.idx.hit          = BL.idx.changeTrial==1 & PDS.state==4.1;
BL.idx.miss         = BL.idx.changeTrial==1 & PDS.state==3.4;
BL.idx.fa           = BL.idx.changeTrial==0 & (PDS.state==3.5 | PDS.state==3.6 | (PDS.state==3.2 & PDS.timebrokejoy>=PDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin));
BL.idx.cr           = BL.idx.changeTrial==0 & PDS.state==4.2;
BL.idx.ar           = (BL.idx.changeTrial==1 | BL.idx.changeTrial==0)  & (PDS.state==3.2 & PDS.timebrokejoy < PDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin);   % anticipatory release
% probability hit:

[BL.pHit, BL.pHitCi] = binofit(sum(BL.idx.hit), sum(BL.idx.hit)+sum(BL.idx.miss));
% probability false alarm:
[BL.pFa, BL.pFaCi] = binofit(sum(BL.idx.fa), sum(BL.idx.fa)+sum(BL.idx.cr));


%% FA:
TBD = 66666; % GOTTA VET FALSE ALARMAS IN FA
% !!! elaborate to account for a foil change

% changeTrials: 1=change, 0=no change, nan=not a FA trial.
FA.idx.changeTrial = nan(1,numel(PDS.trialnumber));
FA.idx.changeTrial(PDS.trialtype==2 & PDS.fixchangetrial==1) = 1;
FA.idx.changeTrial(PDS.trialtype==2 & PDS.fixchangetrial==0) = 0;
% goodies:
FA.idx.hit          = FA.idx.changeTrial==1 & PDS.state==4.1;
FA.idx.miss         = FA.idx.changeTrial==1 & PDS.state==3.4;
FA.idx.fa           = FA.idx.changeTrial==0 &  ((PDS.state==3.2  & PDS.timebrokejoy>=PDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin) | PDS.state==3.5 | PDS.state==3.6);
FA.idx.cr           = FA.idx.changeTrial==0 & PDS.timebrokefix==-1;

% probability hit:
[FA.pHit, FA.pHitCi] = binofit(sum(FA.idx.hit), sum(FA.idx.hit)+sum(FA.idx.miss));
% probability false alarm:
[FA.pFa, FA.pFaCi] = binofit(sum(FA.idx.fa), sum(FA.idx.fa)+sum(FA.idx.cr));

%% SPA:

% changeTrials: 1=change, 0=no change, nan=not a SPA trial.
SPA.idx.changeTrial = nan(1,numel(PDS.trialnumber));
SPA.idx.changeTrial(PDS.trialtype==3 & PDS.stimchangetrial>0) = 1;
SPA.idx.changeTrial(PDS.trialtype==3 & PDS.stimchangetrial==0) = 0;
% goodies:
SPA.idx.hit          = SPA.idx.changeTrial==1 & PDS.state==4.1;
SPA.idx.miss         = SPA.idx.changeTrial==1 & PDS.state==3.4;
SPA.idx.fa           = SPA.idx.changeTrial==0 & (PDS.state==3.3 | PDS.state==3.5 | PDS.state==3.6 | (PDS.state==3.2  & PDS.timebrokejoy>=PDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin));
SPA.idx.cr           = SPA.idx.changeTrial==0 & (PDS.state==4.2);

% probability hit:
[SPA.pHit, SPA.pHitCi] = binofit(sum(SPA.idx.hit), sum(SPA.idx.hit)+sum(SPA.idx.miss));
% probability false alarm:
[SPA.pFa, SPA.pFaCi] = binofit(sum(SPA.idx.fa), sum(SPA.idx.fa)+sum(SPA.idx.cr));

%% PA:

% !!! should elaborate to account for either a change in location 1 or 2.

% changeTrials: 1=change, 0=no change, nan=not a SPA trial.
PA.idx.changeTrial = nan(1,numel(PDS.trialnumber));
PA.idx.changeTrial(PDS.trialtype==4 & PDS.stimchangetrial>0) = 1;
PA.idx.changeTrial(PDS.trialtype==4 & PDS.stimchangetrial==0) = 0;
% goodies:
PA.idx.hit          = PA.idx.changeTrial==1 & PDS.state==4.1;
PA.idx.miss         = PA.idx.changeTrial==1 & PDS.state==3.4;
PA.idx.fa           = PA.idx.changeTrial==0 & (PDS.state==3.3 | PDS.state==3.5 | PDS.state==3.6 | (PDS.state==3.2  & PDS.timebrokejoy>=PDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin));
PA.idx.cr           = PA.idx.changeTrial==0 & (PDS.state==4.2);

% probability hit:
[PA.pHit, PA.pHitCi] = binofit(sum(PA.idx.hit), sum(PA.idx.hit)+sum(PA.idx.miss));
% probability false alarm:
[PA.pFa, PA.pFaCi] = binofit(sum(PA.idx.fa), sum(PA.idx.fa)+sum(PA.idx.cr));

%% Summary fig accross tasks: 
subplot(1, 4, 1)
title('BL')
hold on
% plot(1,BL.pHit, 'o', 'Color', clr);
% plot(2,BL.pFa, 'o', 'Color', clr);
plot([1 2],[BL.pHit BL.pFa], '-o', 'Color', clr, 'LineWidth', 2);
set(gca, 'XTick', [1 2], 'XTickLabel', {'Hit', 'FA'})
xlim([0.5 2.5])
ylim([0 1])

subplot(1, 4, 2)
title('FA')
hold on
% plot(1,FA.pHit, 'o', 'Color', clr);
% plot(2,FA.pFa, 'o', 'Color', clr);
plot([1 2],[FA.pHit FA.pFa], '-o', 'Color', clr, 'LineWidth', 2);
set(gca, 'XTick', [1 2], 'XTickLabel', {'Hit', 'FA'})
xlim([0.5 2.5])
ylim([0 1])

subplot(1, 4, 3)
title('SPA')
hold on
% plot(1,SPA.pHit, 'o', 'Color', clr);
% plot(2,SPA.pFa, 'o', 'Color', clr);
plot([1 2],[SPA.pHit SPA.pFa], '-o', 'Color', clr, 'LineWidth', 2);
set(gca, 'XTick', [1 2], 'XTickLabel', {'Hit', 'FA'})
xlim([0.5 2.5])
ylim([0 1])

subplot(1, 4, 4)
title('PA')
hold on
% plot(1,PA.pHit, 'o', 'Color', clr);
% plot(2,PA.pFa, 'o', 'Color', clr);
plot([1 2],[PA.pHit PA.pFa], '-o', 'Color', clr, 'LineWidth', 2);
set(gca, 'XTick', [1 2], 'XTickLabel', {'Hit', 'FA'})
xlim([0.5 2.5])
ylim([0 1])

end

%% PA timing:

maxTime = 8;
binSize = 0.01;
time    = linspace(0, maxTime, maxTime/binSize);

idx = PDS.trialtype==4 & PDS.timejoyrel>0 & PDS.timejoyrel<maxTime;

tFpEntered      = PDS.fpentered(idx);
tCueOn          = PDS.fpentered(idx) + c.cueonset;
tCueOff         = PDS.fpentered(idx) + c.cueonset + c.cueduration;
tMotionOn       = PDS.fpentered(idx) + c.cueonset + c.cueduration + c.cuedelay;
tMotionChange   = PDS.timech(idx);
tJoyRelease     = PDS.timejoyrel(idx);


figure; hold on
for ii = 1:sum(idx)
    plot(tJoyRelease(ii) - tMotionChange(ii), ii, 'o');
end
%%
bJoyRelease = arrayfun(@(x) find(time > x,1), tJoyRelease); % bin
timeMat = zeros(sum(idx), numel(time));
timeMat(:,bJoyRelease) = 1;

figure(545)
imagesc(timeMat)


%%

c.cueonset =0.3;
% cue duration(s)
c.cueduration=0.2;
% time between cue offset and stim onset(s)
c.cuedelay=0.5;
% time between acquiring fixation and stim onset(s)
c.stimwait        = c.cueonset + c.cueduration +c.cuedelay;
% min stim duration (s)
c.stimdur_min    = 1;
% variable stim duration (s)
c.stimdur_max   = 3.5;




%% PA "threshold"
% in a few sessions I varies the delta so if I average over all of'em, I
% may be able to get a p(Hit) as a fucntion of delta size. Gotta group all
% sessions first.

dirData = '~/Dropbox/Code/krauzlislab_code/kpds_data';
cd(dirData)
fileList = findFile(dirData, 'AttnMot_');
cPDS = combine_pds(fileList);

%%
clear PA
% changeTrials: 1=change, 0=no change, nan=not a PA trial.
PA.idx.changeTrial = nan(numel(cPDS.trialnumber),1);
PA.idx.changeTrial(cPDS.trialtype==4 & cPDS.stimchangetrial>0) = 1;
PA.idx.changeTrial(cPDS.trialtype==4 & cPDS.stimchangetrial==0) = 0;
% goodies:
PA.idx.hit          = PA.idx.changeTrial==1 & cPDS.state==4.1;
PA.idx.miss         = PA.idx.changeTrial==1 & cPDS.state==3.4;
PA.idx.fa           = PA.idx.changeTrial==0 & (cPDS.state==3.3 | cPDS.state==3.5 | cPDS.state==3.6 | (cPDS.state==3.2  & cPDS.timebrokejoy>=cPDS.fpentered+c.stimwait+c.stimdur_min+c.joypressmin));
PA.idx.cr           = PA.idx.changeTrial==0 & (cPDS.state==4.2);

cPDS.delta = mod(cPDS.loc1del + (360-cPDS.loc2del), 360);
    
deltaList = unique(cPDS.delta);
deltaListGood = [];
nDelta = numel(deltaList);
idxD = nan(numel(PA.idx.changeTrial), nDelta);
iG = 1;
for iD = 1:nDelta
    idxD(:,iD) = cPDS.delta==deltaList(iD);
    if sum(idxD(:,iD) & PA.idx.hit) == 0
        continue;
    end
    deltaListGood(iG) = deltaList(iD);
    % probability hit:
    [PA.pHit(iG), PA.pHitCi(iG,:)] = binofit(sum(idxD(:,iD) & PA.idx.hit), sum(idxD(:,iD) & PA.idx.hit)+sum(idxD(:,iD) & PA.idx.miss));
    % probability false alarm:
    [PA.pFa(iG), PA.pFaCi(iG,:)] = binofit(sum(idxD(:,iD) & PA.idx.fa), sum(idxD(:,iD) & PA.idx.fa)+sum(idxD(:,iD) & PA.idx.cr));
    iG = iG+1;
end

figure, hold all; title('poor man''s PMF - Snap')
errorbarFancy(deltaListGood, PA.pHit, abs(PA.pHit'-PA.pHitCi(:,1)), abs(PA.pHit' - PA.pHitCi(:,2)), 'LineStyle', '-')
errorbarFancy(deltaListGood, PA.pFa, abs(PA.pFa'-PA.pFaCi(:,1)), abs(PA.pFa' - PA.pFaCi(:,2)), 'LineStyle', '-');
xlim([min(deltaListGood)-1 max(deltaListGood)+1])
set(gca, 'XTick', deltaListGood, 'XTickLabel', deltaListGood./c.dotdirstd)
ylim([0 1])
xlabel('delta (std)')
ylabel('p(hit)')






