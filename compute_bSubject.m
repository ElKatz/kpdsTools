function bSubject = compute_bSubject(bSession, opts)

disp(['---> Running ' mfilename])

global projectName

%% assign defualt options:
if nargin < 2 || ~isfield(opts, 'redoSessionSummary')
    opts.redoSubjectGrouping     = false;
end

%% action time:

fullPath    = fullfile(getpref(projectName, 'dataProcessed'), 'bSubject.mat');

% If bSubject already exists then load:
if exist(fullPath, 'file') && ~opts.redoSubjectGrouping
    disp('bSubject already exists I do declare! loading...')
    load(fullPath);
else
    % get indices for bSession:
    ix = get_indices_from_bSession(bSession);
    jj = 1;
    for iT = 1:ix.temporalWeighting_n
        for iS = 1:ix.subjectName_n
            idx             = ix.temporalWeighting_idx(:,iT) & ix.subjectName_idx(:,iS);
            if sum(idx)==0 
                continue;   
            end
            bSubject(jj)    = combineSessionSummary(bSession(idx));
            jj = jj+1;
        end
    end
    save(fullPath, 'bSubject');
end


disp(['<--- Completed ' mfilename])