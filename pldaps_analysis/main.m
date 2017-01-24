%%
%%
clear all
% define your data directory:
dirData = '~/Dropbox/Code/krauzlislab_code/kpds_data';
cd(dirData)
load('R170112_attn_blkdsgn.mat')
%%

get_indices_from_PDS
X = [PDS.dirchangetrial(:) > 0,  PDS.fixchangetrial(:) > 0];
figure, imagesc(X)

%%

taskLabel = {'BL', 'FA', 'PA1', 'PA2'};
taskNumer = 1:numel(taskLabel);

idxLoc1 = PDS.dirchangetrial & ((PDS.changeloc < 90 & PDS.changeloc > -90) |  (PDS.changeloc > 270 & PDS.changeloc <360));
idxLoc2 = PDS.dirchangetrial & ((PDS.changeloc > 90 & PDS.changeloc < 270) |  (PDS.changeloc < -90 & PDS.changeloc > -270));

idxHit  = PDS.state == 4.1;
idxMiss = PDS.state == 3.4;

propHit1 = sum(idxHit & idxLoc1) / sum((idxHit | idxMiss) & idxLoc1);
propHit2 = sum(idxHit & idxLoc2) / sum((idxHit | idxMiss) & idxLoc2);

% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 
% BROKEN 

%%
% baseline, fa, pa single, pa double
for iT = 1:4
        good = PDS.state==3.3 | PDS.state==3.4 | PDS.state==4.1 | PDS.state==4.2 | PDS.state==5;
        idx0 = PDS.trialtype(:)'==iT & PDS.cueTransient(2:end)==0 & good;
        idx1 = PDS.trialtype(:)'==iT & PDS.cueTransient(2:end)==1 & good;
        
        correct0(iT) = mean(PDS.state(idx0)==4.1 | PDS.state(idx0)==4.2);
        correct1(iT) = mean(PDS.state(idx1)==4.1 | PDS.state(idx1)==4.2);
        wrong0(iT) = mean(PDS.state(idx0)==3.3 | PDS.state(idx0)==3.4 | PDS.state(idx0)==5);
        wrong1(iT) = mean(PDS.state(idx1)==3.3 | PDS.state(idx1)==3.4 | PDS.state(idx1)==5);
end

figure; hold all
clr = lines(2);
plot(1:4, correct0, '-o', 'Color', clr(1,:), 'LineWidth', 2)
plot(1:4, correct1, '--o', 'Color', clr(1,:), 'LineWidth', 2)
plot(1:4, wrong0, '-o', 'Color', clr(2,:), 'LineWidth', 2)
plot(1:4, wrong1, '--o', 'Color', clr(2,:), 'LineWidth', 2)
legend({'crct cue-ON', 'crct cue-FLASH', 'wrng cue-ON', 'wrng cue-FLASH'})
set(gca, 'XTick', 1:4, 'XTickLabel', {'BL', 'FA', 'PA1', 'PA2'})    
xlim([.5 4.5])
xlabel('condition')
ylim([0 1])
ylabel('proportion')
title('Does performance depend on cue ON vs. Flash?')
grid on



