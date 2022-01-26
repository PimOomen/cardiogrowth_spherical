function H = CardioGrowth(varargin)

% H = CardioGrowth('input', 'inputfuncname') simulates growth as 
% specified in the input function 'inputfuncname' as string and 
% returns the simulation results in the structure H.




%% Add functions library and input files to path

addpath(genpath('lib'));
addpath(genpath('input'));


%% User input: call user input file if required

if nargin == 0
    error('Specify input');
elseif nargin == 2
    while ~isempty(varargin)
        switch lower(varargin{1})
            % When not growing, construct model structure
            case 'input'
                H = eval([varargin{2} '(true)']);
        end
        varargin(1:2) = [];
    end
end


%% Preamble

Ng = length(H.Growth.tG);
H = initGrowth(H);


%% Growth simulation

pBar = textprogressbar(Ng,'startmsg', 'Growing... ', 'endmsg', ' Done');

for iG = 1:Ng
    
    % Grow after acute time step
    H.Growth.iG = iG;
    if iG > 2
        H = growLV(H);
    end

    % Update circulation and heart parameters
    H = updateCircHeartGrowth(H);

    % Run heart beat
    H = CompartmentalModel('input', H);

    % Store growth history
    H = storeGrowth(H);

    % Update progress bar
    pBar(iG);
end


end