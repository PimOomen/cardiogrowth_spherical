function H = CompartmentalModel(varargin)
% 
% H = CompartmentalModel('input', 'inputfuncname') simulates a single beat 
% using the input function inputfuncname as string and returns the 
% simulation results in the structure H
%
% H = CompartmentalModel('input', H) simulates a single  heart beat within
% a growth simulation (CardioGrowth.m), the input file is specified and 
% called inside CardioGrowth. The data structure H is used as input and 
% updated to reflect the new heart beat results.


%% Add functions library and input files to path

addpath(genpath('lib'))
addpath(genpath('input'))

%% User input: call user input file if required

if nargin == 0
    error('Specify input');
elseif nargin == 2
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'input'
                if ischar(varargin{2})
                    % When not growing, construct model structure
                    H = eval([varargin{2} '(false)']);
                else
                    % When growing, call model structure to read and update
                    H = varargin{2};
                end
        end
        varargin(1:2) = [];
    end
end

%% Preamble - initialization operations

% Add file path
H.Misc.CMRootDir = fileparts(mfilename('fullpath'));

% Create log file and figure directory
createLogFigDir(H);

% Initialize volumes, pressures and time arrays, and heart
H = setInitialConditions(H);


%% Simulate Heart Beat

% Core of the code: run circulation model until convergence of the
% full circulation
H = justBeatIt(H);


%% Save converged solution

storeConSol(H); 


end


