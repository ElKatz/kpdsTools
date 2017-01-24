%%
clear all
% define your data directory:
dirData = '~/Dropbox/Code/krauzlislab_code/kpds_data';
cd(dirData)
load('R170105_attn_blkdsgn.mat')
%%

X = [PDS.dirchangetrial(:) > 0,  PDS.fixchangetrial(:) > 0];
figure, imagesc(X)

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



