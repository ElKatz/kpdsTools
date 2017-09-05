%% compute_motion_std_for_each_subject.m
% ot zScore the the mean motion coherence (for pmf) I need to take each
% sessions' stimulus values and divie them by the std of all motion
% strengths ovre ALL sessions. 
% This is the approach I took in LIP inactivaion project.
% I did it for each subject separately so that each subject's motion
% strengths are normalized to the range of motion he was exposed to. 

% I compute the std here and then hardcode it in the sessionSummary
% function.

cd('~/Dropbox/Code/gaborPulseStimulus/code')

global projectName
projectName = 'gaborPulseStimulus';
setup_preferences

% load bSession:
load './dataProcessed/bSession.mat';

ix = get_indices_from_bSession(bSession);

clear subject_allSessions
jj = 1;
for iS = 1:ix.subjectName_n
    idx             = ix.subjectName_idx(:,iS);
    if sum(idx)==0
        continue;
    end
    subject_allSessions(jj)    = combineSessionSummary(bSession(idx));
    jj = jj+1;
end

% this is it:
subStd = arrayfun(@(x) std(x.stimulus.mean), subject_allSessions)