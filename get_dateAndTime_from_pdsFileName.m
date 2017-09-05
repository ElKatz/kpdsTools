function [yyyymmdd, hhmm] = get_dateAndTime_from_pdsFileName(fileName)

idx = false(1, numel(fileName));
idx(regexp(fileName, '\d')) = true;

idxNumStart = find([0, diff(idx)]==1);
idxNumEnd  = find([0, diff(idx)]==-1);


try
    
    % get date:
    idxNum1 = idxNumStart(1):idxNumEnd(1)-1;
    if numel(idxNum1)== 8
        yyyymmdd = fileName(idxNum1);
    elseif numel(idxNum1)== 6
        tmp = fileName(idxNum1);
        yyyymmdd = ['20' tmp(5:6) tmp(1:4)];
    else
        warning('danger steve sebastian, danger!')
        keyboard;
    end
    
    % get time:
    idxNum2 = idxNumStart(2):idxNumEnd(2)-1;
    if numel(idxNum2)==4
        hhmm = fileName(idxNum2);
    else
        warning('danger steve sebastian, danger!')
        keyboard;
    end
    
catch
    
    warning('couldn''t get time of PDS file. assigning it a default of 0000')
    hhmm = '0000';
end


