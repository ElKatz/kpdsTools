function summary = compute_summary_from_bSession(bSession)
%   summary = compute_summary_from_bSession(bSession)
%
% restructure all the individual sessions into a summary structarray that 
% is indexed by the temporal weighting signal condition (early/flat/late)



% get all sessions per temporal weighting:
tempWeights_perSesssion = arrayfun(@(x) x.temporalWeighting, bSession, 'UniformOutput', 0);
tempWeights             = unique(tempWeights_perSesssion);
% for iT = 1:numel(tempWeights)

summary = struct( ...
    'temporalWeighting', [],...
    'wMean', [], ...
    'wNormMean', [],...
    'wIndex', [],...
    'wSlope', [], ...
    'wEnergy', [], ...
    'pmfThresh', [], ...
    'pmfSlope', [], ...
    'pc', [], ...
    'rt', []);

for iT = 1:3
    tempWeightIdx = strcmp(tempWeights_perSesssion, tempWeights{iT});
    summary(iT).temporalWeighting = tempWeights{iT};
    % wMean:
    summary(iT).wMean.dist = arrayfun(@(x) mean(x.ppkRidge.w), bSession(tempWeightIdx))';
    [summary(iT).wMean.mean,    summary(iT).wMean.error] = bootMeanAndErr(summary(iT).wMean.dist);
    % wMeanNorm:
    summary(iT).wNormMean.dist = arrayfun(@(x) mean(x.ppkRidge.w_norm), bSession(tempWeightIdx))';
    [summary(iT).wNormMean.mean,    summary(iT).wNormMean.error] = bootMeanAndErr(summary(iT).wNormMean.dist);
    % wIndex:
    summary(iT).wIndex.dist = arrayfun(@(x) mean(x.ppkRidge.w_index), bSession(tempWeightIdx))';
    [summary(iT).wIndex.mean, summary(iT).wIndex.error] = bootMeanAndErr(summary(iT).wIndex.dist);
    % wSlope:
    summary(iT).wSlope.dist = arrayfun(@(x) table2array(x.ppkRidge.w_lm.Coefficients(2,1)), bSession(tempWeightIdx))';
    [summary(iT).wSlope.mean, summary(iT).wSlope.error] = bootMeanAndErr(summary(iT).wSlope.dist);
    % wEnergy:
    summary(iT).wEnergy.dist = arrayfun(@(x) sum(x.ppkRidge.w_energy), bSession(tempWeightIdx))';
    [summary(iT).wEnergy.mean, summary(iT).wEnergy.error] = bootMeanAndErr(summary(iT).wEnergy.dist);
    % wCom:
    summary(iT).wCom.dist = arrayfun(@(x) sum(x.ppkRidge.w_com), bSession(tempWeightIdx))';
    [summary(iT).wCom.mean, summary(iT).wCom.error] = bootMeanAndErr(summary(iT).wCom.dist);
    % pmfThresh:
    summary(iT).pmfThresh.dist = arrayfun(@(x) x.pmf.threshValue, bSession(tempWeightIdx))';
    [summary(iT).pmfThresh.mean, summary(iT).pmfThresh.error] = bootMeanAndErr(summary(iT).pmfThresh.dist);
    % pmfSlope:
    summary(iT).pmfSlope.dist = arrayfun(@(x) x.pmf.theta(2), bSession(tempWeightIdx))';
    [summary(iT).pmfSlope.mean, summary(iT).pmfSlope.error] = bootMeanAndErr(summary(iT).pmfSlope.dist);
    % pc:
    summary(iT).pc.dist = arrayfun(@(x) mean(x.correct), bSession(tempWeightIdx))';
    [summary(iT).pc.mean, summary(iT).pc.error] = bootMeanAndErr(summary(iT).pc.dist);
    % rt:
    summary(iT).rt.dist = arrayfun(@(x) mean(x.correct), bSession(tempWeightIdx))';       
    [summary(iT).rt.mean, summary(iT).rt.error] = bootMeanAndErr(summary(iT).rt.dist);

end
