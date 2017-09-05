function [bSession, listBadGaborRecovery] = compute_bSession(opts)

disp(['---> Running ' mfilename])

global projectName

%% assign defualt options:
if nargin < 1 || ~isfield(opts, 'redoSessionSummary')
    opts.redoSessionSummary     = false;
end
if nargin < 1 || ~isfield(opts, 'redoImportAllDataFiles')
    opts.redoImportAllDataFiles = false;
end

%% action time:

% if a bSession.mat already exists, just load it:
fullPath = fullfile(getpref(projectName, 'dataProcessed'), 'bSession.mat');

if exist(fullPath, 'file') && ~opts.redoSessionSummary
    disp('bSession already exists I do declare! loading...')
    load(fullPath);
else
    dataDir = getpref(projectName, 'data');
    % find all processed files from 'data' folder:
    exfiles=findFile(dataDir, {'.mat'});
    % if there are no processed files, process them:
    if isempty(exfiles) || opts.redoImportAllDataFiles
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% cmdImportAllDataFiles %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('doing cmdImportAllDataFiles!')
        listBadGaborRecovery = cmdImportAllDataFiles;
        exfiles=findFile(dataDir, {'.mat'}); 
    end
    % for each processed datafile, run sessionSummary to get behavior strcut:
    nSessions = numel(exfiles);
    disp(['loading ' num2str(nSessions) ' files...'])
    for kEx=1:nSessions
        stim = load(fullfile(dataDir, exfiles{kEx}));
        disp(['Running sessionSummary ' num2str(kEx) ' of ' num2str(nSessions), ' on:    ' exfiles{kEx}]);
        bSession(kEx) = sessionSummary(stim);
    end
    save(fullPath, 'bSession');
end

disp(['<--- Completed ' mfilename])