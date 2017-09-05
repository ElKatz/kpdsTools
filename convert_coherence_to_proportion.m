function [coherence_p, coherence_originalForm] = convert_coherence_to_proportion(coherence, nGabors)
%   coherence_p = convert_coherence_to_proportion(coherence, nGabors)
%
% The function converts coherence values [nTrials, 7] into a proportion, 
% i.e. to a range between -1 and 1. 
% It idnetifies the current format and performs the appropriate conversion. 
% Identification is a bit hacky. I look at the range to identify original
% coherence form.
% 
% INPUT:
%   coherence - [nTrials, 7] matrix of coherence values in an y form
% OUTPUT:
%   coherence_p - [nTrials, 7] matrix of coherence proportion, ie [-1 1]
%   values.
%   coherence_originalForm - string describing the original form in which
%   the coherence values were.


%% 

flag = 0;
% if coherence is in nGabors, then range should be smaller or equal to 
% nGabors*2, larger than 2, and in round numbers:
if range(coherence(:))<=nGabors*2 && range(coherence(:))>2 && all(mod(coherence(:),1)==0)
    coherence_originalForm = 'nGabors';
    coherence_p = coherence ./ nGabors;
    flag = flag+1;
end

% if coherence is in nGabors/100, check the same as above but for
% coherence*100:
if range(coherence(:).*100)<=nGabors*2 && range(coherence(:).*100)>2 && all(mod(coherence(:).*100,1)==0)
    % then coherence is in #gabors / 100.
    coherence_originalForm = 'nGabors_divided_by100';
    coherence_p = (coherence.*100) ./ nGabors;
    flag = flag+1;
end
    
% if coherence is in percent gabors, then range should be smaller or equal
% to 200, larger than 2, and not in round numbers (as in case 1):
if range(coherence(:))<=200 && range(coherence(:))>2 && ~all(mod(coherence(:),1)==0)
    % then coherence is in % Gabors
    coherence_originalForm = 'percentGabors';
    coherence_p = coherence ./ 100;
    flag = flag+1;
end

% if coherence is already in proportion gabors, then th range should be
% smaller or equal to 2, and to discriminate from case 2, must makes sure
% that coherence is not(!) in nGabors/100:
if range(coherence(:))<=2 && ~all(mod(coherence(:).*100,1)==0)
    % then coherence is already 'proportion gabors'
    coherence_originalForm = 'proportionGabors';
    coherence_p = coherence;
    flag = flag+1;
end

assert(flag==1, 'ERROR: flag should be set to 1. looks like coherence matched more than 1 condition')
assert(range(coherence_p(:))<=2, 'ERROR: conversion of coherence to proportion got messed up')



