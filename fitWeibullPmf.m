function S=fitWeibullPmf(X,Y,nBins,base)
% fit a weibull pmf to percent correct data with MLE
% S=fitWeibCdf(X,Y,nBins,base)
% inputs:
%   X     [n x 1] signal strength
%   Y     [n x 1] binary vector
%   nBins [1 x 1] number of bins
%   base  [1 x 1] 0 or .5 (is this full or percent correct) default: .5
% outputs:
%   S [struct]
%       .bins
%       .pc
%       .nt
%       .alpha
%       .beta
%       .lapse
%       .xx
%       .yy
%
% (c) 2016 JLY wrote it
if nargin<4
    base=.5;
    if nargin<3
        nBins=10;
    end
end

% linear binning
bins=linspace(0, max(abs(X(:))), nBins);
bidx=cell2mat(arrayfun(@(i,j) X>i & X<j, bins(1:end-1), bins(2:end), 'UniformOutput', false));

nBins=size(bidx,2);
   
S.bc=nan(nBins,1);
S.nt=nan(nBins,1);
S.pc=nan(nBins,1);
            
for kBin=1:nBins
    iix=bidx(:,kBin);
    S.nt(kBin)=sum(iix);
    S.bc(kBin)=mean(X(iix));
    S.pc(kBin)=mean(Y(iix));
end
            
% throw out bins that have no data        
S.bc(S.nt<7)=nan;
goodbins=~isnan(S.bc);
S.bc=S.bc(goodbins);
S.nt=S.nt(goodbins);
S.pc=S.pc(goodbins);

h=plot(S.bc, S.pc, '-o'); hold on

% fit Weibull PMF with lapse parameter
weibullCdf=@(param,x) base+(base-param(3))*(1-exp(-(x./param(2)).^param(1)));
logli=@(beta, x,y,nt) nansum(round(y.*nt).*log(weibullCdf(beta, x))) + nansum( round((1-y).*nt).*log(1-weibullCdf(beta, x)));

beta0=[1 1 .5];
warning('off', 'optim:fminunc:SwitchingMethod')

% fit psychometric function
nlogli=@(beta) -logli(beta, S.bc, S.pc, S.nt);
opts=optimset('gradobj', 'off', 'display', 'none');
[betaHat,fval]=fminunc(nlogli, beta0, opts);
% try again with no lapse
weibullCdfNoLapse=@(param,x) (1-base*exp(-(x./param(2)).^param(1)));
logli=@(beta, x,y,nt) nansum(round(y.*nt).*log(weibullCdfNoLapse(beta, x))) + nansum( round((1-y).*nt).*log(1-weibullCdfNoLapse(beta, x)));
nlogli=@(beta) -logli(beta, S.bc, S.pc, S.nt);
[betaHat0,fval0]=fminunc(nlogli, beta0(1:2), opts);



S.alpha=betaHat(2);
S.beta=betaHat(1);

S.xx=0:.05:S.bc(end);

plot(S.xx,weibullCdf(betaHat,S.xx), 'Color', get(h, 'Color'))
plot(S.xx,weibullCdfNoLapse(betaHat0,S.xx), 'Color', 'r')


% likelihood ratio test to include lapse or not
if chi2cdf(2*(-fval+fval0),1)<.95
    betaHat=betaHat0;
    lapse=0;
    weibullCdf=weibullCdfNoLapse;
else
    lapse=betaHat(3);
end
S.lapse=lapse;

S.yy=weibullCdf(betaHat,S.xx);


