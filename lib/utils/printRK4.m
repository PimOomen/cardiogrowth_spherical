function printRK4(E, iter, printDir)

% Start spreading the news
str = sprintf('Iter %i: %1.1e %1.1e %1.1e %1.1e %1.1e %1.1e %1.1e %1.1e', iter, E);

% Display in command window
disp(str);

% Store errors in text file if desired
if ~isempty(printDir)
    fid = fopen(fullfile(printDir,'solver.log'), 'a');
    fprintf(fid, [str ,'\n']);
    fclose(fid);
end