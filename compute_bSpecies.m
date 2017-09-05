function bSpecies = compute_bSpecies(bSession, opts)

disp(['---> Running ' mfilename])

global projectName

%% assign defualt options:
if nargin < 2 || ~isfield(opts, 'redoSessionSummary')
    opts.redoSpeciesGrouping     = false;
end

%% action time:

fullPath    = fullfile(getpref(projectName, 'dataProcessed'), 'bSpecies.mat');

% If bSpecies already exists then load:
if exist(fullPath, 'file') && ~opts.redoSpeciesGrouping
    disp('bSpecies already exists I do declare! loading...')
    load(fullPath);
else
    % get indices for bSession:
    ix = get_indices_from_bSession(bSession);
    jj = 1;
    for iT = 1:ix.temporalWeighting_n
        for iS = 1:ix.species_n
            idx             = ix.temporalWeighting_idx(:,iT) & ix.species_idx(:,iS);
            if sum(idx)==0; 
                continue;   
            end
            bSpecies(jj)    = combineSessionSummary(bSession(idx));
            jj = jj+1;
        end
    end
    save(fullPath, 'bSpecies');
end


disp(['<--- Completed ' mfilename])