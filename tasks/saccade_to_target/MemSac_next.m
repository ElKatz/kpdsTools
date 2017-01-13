function [PDS ,c ,s]= MemSac_next(PDS ,c ,s)
%% next_trial function
% this is executed once at the beginning of each trial
% as the first step of the 'Run' action from the GUI
% (the other steps are 'run_trial' and 'finish_trial'
% This is where values are set as needed for the next trial

%% Next trial parameters
if s.repeat20 == 0
    [c, s]                  = nextparams(c, s);
end
end



%% Helper functions
function [c, s]         = nextparams(c, s)

if ~c.repeat
    
    % where will the target be placed on the next trial?
    if ~isempty(c.userlocs)
        s.targXY                = [c.userlocs(1,1),c.userlocs(1,2)];
        [c.targetdir, c.targetecc] = cart2pol(c.userlocs(1,1),c.userlocs(1,2));
        c.targetdir = mod(c.targetdir*180/pi,360);
        c.userlocs(1,:) = [];
    else
        s.targXY                = [c.targX(c.stdcnt),c.targY(c.stdcnt)];
        [c.targetdir, c.targetecc] = cart2pol(c.targX(c.stdcnt),c.targY(c.stdcnt));
        c.targetdir = mod(c.targetdir*180/pi,360);
        c.stdcnt = mod(c.stdcnt,size(c.targX,1)) + 1;
    end
    
    % what will the temporal parameters of the next trial be?
    s.preTargDur            = unifrnd(c.preTargMin, c.preTargMax);
    s.postFlashFixDur       = unifrnd(c.postFlashFixMin, c.postFlashFixMax);
    s.targFixDurReq         = unifrnd(c.minTargFix, c.maxTargFix);
    
end
end