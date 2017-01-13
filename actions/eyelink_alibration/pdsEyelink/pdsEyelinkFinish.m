function dv = pdsEyelinkFinish(dv)
% dv = pdsEyelinkFinish(dv)
% pdsEyelinkFinish stops recording and closes the currently open edf file. 
% dv [strut]
% Requires Eyelink support from mgl Toolbox (Justin Gardner's lab)

% 12/2013 jly   wrote it



if nargin < 1
    help pdsEyelinkFinish
	return;
end

% edfFile = fullfile(dv.el.edfFileLocation, dv.el.edfFile);
edfFile = dv.el.edfFile;
Eyelink('StopRecording');
Eyelink('CloseFile');
% download data file
try
    fprintf('Receiving data file ''%s''\n', edfFile);
%     status=Eyelink('ReceiveFile', dv.el.edfFile, dv.el.edfFileLocation);
    status=Eyelink('ReceiveFile', edfFile);
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile);
    end
    dv.edfData = mglEyelinkEDFRead(edfFile, 1);
    
catch rdf
    fprintf('Problem receiving data file ''%s''\n', edfFile );
    rdf;
end


    