function S=comparePulseModels(stim)
% compare different models

S=struct('nTrials',[],...
    'exname',[],...
    'isNancy',[],...
    'xvfolds',[],...
    'Xs',[],...
    'Xc',[],...
    'z',[],...
    'X',[],...
    'Y',[],...
    'Yhcho',[],...
    'Yhcor',[],...
    'coh',[],...
    'corr',[],...
    'isrevco',[],...
    'abspmf',[],...
    'llr',[],...
    'yhatSum',[],...
    'yhatPulse',[],...
    'yhatEarly',[],...
    'yhatLate',[],...
    'ytrue',[],...
    'pulseModel',[],...
    'lls',[],...
    'llp',[],...
    'llstrain',[],...
    'llptrain',[],...
    'sumMI',[],...
    'pulseMI',[],...
    'earlyMI',[],...
    'lateMI',[],...
    'llratiotest',[]);
   
validTrials = find(stim.goodtrial & ~stim.frozentrials & stim.trialCnt(stim.trialId) < 5 & (1:numel(stim.goodtrial))' > 50);
nTrials=numel(validTrials);
S.nTrials=nTrials;
% cross validation folds
S.exname=stim.exname;
S.isNancy=strcmp(S.exname(1:2), 'n2');
S.xvfolds = xvalidationIdx(nTrials, 5, false);

% % pulse stimulus averaged across space
% S.Xs  = sum(stim.pulses(validTrials,:,:),3);
S.Xs = stim.pulses;

% S.X=S.X/max(S.X(:));
S.Xc = S.Xs/size(stim.pulses,3);
S.z=std(S.Xs(:));
S.X = S.Xs/S.z;
S.Y = stim.targchosen(validTrials)==1;
S.corr=stim.targcorrect(validTrials)==stim.targchosen(validTrials);
S.Yhcho=[stim.targchosen(validTrials-1) stim.targchosen(validTrials-2)];
S.Yhcho=sign(S.Yhcho-1.5);
S.Yhcho(isnan(S.Yhcho))=0;
S.Yhcor=stim.targcorrect(validTrials-1)==stim.targchosen(validTrials-1);
S.coh=mean(S.Xc,2);
S.isrevco=stim.dirprob(validTrials)==0;

if sum(S.isrevco)<60
    disp('Not enough revco trials')
    return
end

%
% fit psychometric function, get threshold
clf
S.abspmf=fitWeibullPmf(abs(S.coh), S.corr);



% run some pulse model comparison
S.X=S.Xc;
D=dataset(S.coh, S.X(:,1), S.X(:,2), S.X(:,3), S.X(:,4), S.X(:,5), S.X(:,6), S.X(:,7), S.Yhcho(:,1), S.Y, 'VarNames', {'Sum', 'Pulse1', 'Pulse2', 'Pulse3', 'Pulse4', 'Pulse5', 'Pulse6', 'Pulse7', 'ChoHist', 'Y'});
% use only revco trials (the others are too correlated)
D=D(S.isrevco,:);

% build model specs
modelspecs={'Y~Sum', ... % model is a function of the trial coherence
    'Y~Pulse1+Pulse2+Pulse3+Pulse4+Pulse5+Pulse6+Pulse7', ... % 7 pulse model
    'Y~Pulse1+Pulse2+Pulse3', ... % first 3 pulses
    'Y~Pulse5+Pulse6+Pulse7'}; % last 3 pulses
rng(12345) % fix random seed
cv=cvpartition(size(D,1), 'KFold', 10); % partition the data

figure(2); clf
S.llr=nan(cv.NumTestSets,1);
S.yhatSum=nan(cv.NumObservations,1);
S.yhatPulse=nan(cv.NumObservations,1);
S.yhatEarly=nan(cv.NumObservations,1);
S.yhatLate=nan(cv.NumObservations,1);
S.ytrue=nan(cv.NumObservations,1);

S.pulseModel.Coefficients.Estimate=nan(8,cv.NumTestSets);
S.pulseModel.Coefficients.SE=nan(8,cv.NumTestSets);

for k=1:cv.NumTestSets
    % you can't concetenate models, which is annoying. So, just fit each
    % one separately and then we can extract what we need
    sumModel=fitglm(D(cv.training(k),:), modelspecs{1}, 'distr', 'binomial');
    pulseModel=fitglm(D(cv.training(k),:), modelspecs{2}, 'distr', 'binomial');
    earlyOnly=fitglm(D(cv.training(k),:), modelspecs{3}, 'distr', 'binomial');
    lateOnly=fitglm(D(cv.training(k),:), modelspecs{4}, 'distr', 'binomial');
    
    
    S.pulseModel.Coefficients.Estimate(:,k)=pulseModel.Coefficients.Estimate;
    S.pulseModel.Coefficients.SE(:,k)=pulseModel.Coefficients.SE;
    
    errorbar(pulseModel.Coefficients.Estimate(2:end),pulseModel.Coefficients.SE(2:end)); hold on
    xs=sumModel.predict(D(cv.test(k),:));
    xp=pulseModel.predict(D(cv.test(k),:));
    xe=earlyOnly.predict(D(cv.test(k),:));
    xl=lateOnly.predict(D(cv.test(k),:));
    
    S.yhatSum(cv.test(k))=xs;
    S.yhatPulse(cv.test(k))=xp;
    S.yhatEarly(cv.test(k))=xe;
    S.yhatLate(cv.test(k))=xl;
    
    y=D.Y(cv.test(k));
    S.ytrue(cv.test(k))=y;
    
    % compute the likelihood of test data (bernoulli log likelihood)
    S.lls=sum(log(xs(y==1))) + sum(log(1-xs(y==0)));
    S.llp=sum(log(xp(y==1))) + sum(log(1-xp(y==0)));
    S.llstrain=sumModel.LogLikelihood;
    S.llptrain=pulseModel.LogLikelihood;
    
    S.llr(k)=S.llp-S.lls;
    %fprintf('%d) %02.2f\n', k,S.llr(k))
end


S.sumMI=corr(S.yhatSum, S.ytrue);
S.pulseMI=corr(S.yhatPulse, S.ytrue);
S.earlyMI=corr(S.yhatEarly, S.ytrue);
S.lateMI=corr(S.yhatLate, S.ytrue);

S.llratiotest=1-chi2cdf(2*(S.llptrain-S.llstrain), 6);