function [ cPDS ] = combine_pds(fileList)
%   [ cPDS ] = combine_pds(fileList)
%
% function loads PDS files in 'fileList' and combines them into one big ass
% struct 'cPDS'


% % init:
iF = 1;
% for iF = 1:nFiles
load(fileList{iF})
flds = fieldnames(PDS);
cPDS = struct;
cPDS.fileName = [];
for iF = 1:numel(flds)
    cPDS.(flds{iF}) = [];
end

disp('--> making a combo PDS');
%%

nFiles = numel(fileList);

for iF = 1:nFiles
    disp(['Loading file:    ' fileList{iF}])
    load(fileList{iF})
    % init:
    if iF==1
        flds = fieldnames(PDS);
        cPDS = struct;
        cPDS.fileName = [];
        for iFld = 1:numel(flds)
            cPDS.(flds{iFld}) = []; 
        end
    end
    
    cPDS.fileName               = {cPDS.fileName, fileList{iF}};
    cPDS.trialnumber            = [cPDS.trialnumber; PDS.trialnumber(:)];
    cPDS.trinblk            = [cPDS.trinblk; PDS.trinblk(:)];
    cPDS.setno            =  [cPDS.setno; PDS.setno(:)];
    cPDS.blockno            =  [cPDS.blockno; PDS.blockno(:)];
    cPDS.state            =  [cPDS.state; PDS.state(:)];
    cPDS.repeattrial            =  [cPDS.repeattrial; PDS.repeattrial(:)];
    cPDS.FPpos            =  [cPDS.FPpos; PDS.FPpos];
    cPDS.cuecolor            =  [cPDS.cuecolor; PDS.cuecolor(:)];
    cPDS.RFlocecc            =  [cPDS.RFlocecc; PDS.RFlocecc(:)];
    cPDS.RFloctheta            =  [cPDS.RFloctheta; PDS.RFloctheta(:)];
    cPDS.loc1dir            =  [cPDS.loc1dir; PDS.loc1dir(:)];
    cPDS.loc2dir            =  [cPDS.loc2dir; PDS.loc2dir(:)];
    cPDS.loc1del            =  [cPDS.loc1del; PDS.loc1del(:)];
    cPDS.loc2del            =  [cPDS.loc2del; PDS.loc2del(:)];
    cPDS.dimvalue            =  [cPDS.dimvalue; PDS.dimvalue(:)];
    cPDS.trialcode            =  [cPDS.trialcode; PDS.trialcode(:)];
    cPDS.trialtype            =  [cPDS.trialtype; PDS.trialtype(:)];
    cPDS.fixchangetrial            = [cPDS.fixchangetrial; PDS.fixchangetrial(:)]; 
    cPDS.stimchangetrial            =  [cPDS.stimchangetrial; PDS.stimchangetrial(:)];
    cPDS.changeloc            =  [cPDS.changeloc; PDS.changeloc(:)];
    % cPDS.datapixxtime            =  [cPDS.datapixxtime; PDS.datapixxtime];
    % cPDS.timestartAdcSchedule            =  [cPDS.timestartAdcSchedule; PDS.timestartAdcSchedule];
    % cPDS.timestopAdcSchedule            =  [cPDS.timestopAdcSchedule; PDS.timestopAdcSchedule];
    cPDS.trialstarttime            =  [cPDS.trialstarttime; PDS.trialstarttime(:)];
    cPDS.timejoypress            =  [cPDS.timejoypress; PDS.timejoypress(:)];
    cPDS.timefpon            =  [cPDS.timefpon; PDS.timefpon(:)];
    cPDS.fpentered            =  [cPDS.fpentered; PDS.fpentered(:)];
    cPDS.cueonset            =  [cPDS.cueonset; PDS.cueonset(:)];
    cPDS.cueoffset            =  [cPDS.cueoffset; PDS.cueoffset(:)];
    cPDS.timeloc2onset            =  [cPDS.timeloc2onset; PDS.timeloc2onset(:)];
    cPDS.timeloc1onset            =  [cPDS.timeloc1onset; PDS.timeloc1onset(:)];
    cPDS.timebrokefix            =  [cPDS.timebrokefix; PDS.timebrokefix(:)];
    cPDS.timebrokejoy            =  [cPDS.timebrokejoy; PDS.timebrokejoy(:)];
    cPDS.timereward            =  [cPDS.timereward; PDS.timereward(:)];
    cPDS.timejoyrel            =  [cPDS.timejoyrel; PDS.timejoyrel(:)];
    cPDS.timefpoff            =  [cPDS.timefpoff; PDS.timefpoff(:)];
    cPDS.timech            =  [cPDS.timech; PDS.timech(:)];
    cPDS.foilchangetime            =  [cPDS.foilchangetime; PDS.foilchangetime(:)];
    cPDS.stimchangetime            =  [cPDS.stimchangetime; PDS.stimchangetime(:)];
    cPDS.fpchangetime            =  [cPDS.fpchangetime; PDS.fpchangetime(:)];
    cPDS.fixholdduration            =  [cPDS.fixholdduration; PDS.fixholdduration(:)];
    cPDS.stimduration            =  [cPDS.stimduration; PDS.stimduration(:)];
    cPDS.reward            =  [cPDS.reward; PDS.reward(:)];
    % cPDS.EyeXYZ            =  [cPDS.EyeXYZ; PDS.EyeXYZ];
    % cPDS.Joy            =  [cPDS.Joy; PDS.Joy];
    % cPDS.adcts            =  [cPDS.adcts; PDS.adcts];
end

disp('--> combo PDS complete!');
end

