function createLogFigDir(H)

% Create figure directory and log file

% Create figure directory if non-existent (and required)
if ~H.Fig.isKill
    if ~isfolder(H.Fig.figDir); mkdir(H.Fig.figDir); end
end

% Remove log file if existing from previous run
if exist(fullfile(H.Fig.figDir,'solver.log'), 'file') == 2
    delete(fullfile(H.Fig.figDir,'solver.log')); 
end

end