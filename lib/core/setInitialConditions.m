function H = setInitialConditions(H)
         
% Calculate initial circulation and ventricle compartments' volumes and set
% time array

%% Initialize Timing

H.t = linspace(0, 60/H.Circ.HR, H.Solver.NInc)';            % Time vector [ms]
H.Solver.dt = mean(diff(H.t));


%% Initialize volumes and pressures

% Add infarct compartment if set
infarctComp = H.Heart.infarctSize > 0;

H.V = zeros(H.Solver.NInc,6+infarctComp);
H.P = zeros(H.Solver.NInc,6+infarctComp);

% Set compartment names
if infarctComp
    H.Compartments = {'VP', 'LV', 'AS', ' VS', 'RA', 'RV', 'LVInfact'};
else
    H.Compartments = {'VP', 'LV', 'AS', ' VS', 'RA', 'RV'};
end


%% Ventricular parameters

H.Heart.LV.A = H.Heart.A;           H.Heart.RV.A = H.Heart.A;
H.Heart.LV.B = H.Heart.B;           H.Heart.RV.B = H.Heart.B;
H.Heart.LV.E = H.Heart.E;           H.Heart.RV.E = H.Heart.E;
H.Heart.LV.V0 = H.Heart.V0;         H.Heart.RV.V0 = H.Heart.V0;

% Change RV elastance
H.Heart.RV.E = H.Heart.E*H.Heart.RVScale;

% Construct sinoid activation functions
Tes = 0.2*(60/H.Circ.HR)*(80/60);
et = zeros(1,H.Solver.NInc);
et(H.t<=2*Tes) = 1/2*(1 - cos(pi * H.t(H.t<=2*Tes)/Tes));

% Assign and shift to start position
H.Heart.LV.et = circshift(et, round(H.Heart.t0*H.Solver.NInc/H.t(end)));
H.Heart.LV.det = gradient(H.Heart.LV.et, H.t);
H.Heart.RV.et = H.Heart.LV.et;
H.Heart.RV.det = H.Heart.LV.det;

% Make infarct updates if applicable
if infarctComp
    H.Heart.LV.A = repmat(H.Heart.LV.A, [2,1]);
    H.Heart.LV.B = repmat(H.Heart.LV.B, [2,1]);
    H.Heart.LV.E = repmat(H.Heart.LV.E, [2,1]);
    H.Heart.LV.V0 = repmat(H.Heart.LV.V0, [2,1]);

    % Adjust unloaded volumes
    H.Heart.LV.V0 = H.Heart.LV.V0.*[(1-H.Heart.infarctSize), H.Heart.infarctSize];

    % Adjust B and E to maintain global EDPVR and ESPVR despite the 
    % compartment volume changes
    H.Heart.LV.B = H.Heart.LV.B.*sum(H.Heart.LV.V0)./H.Heart.LV.V0(:,4);
    H.Heart.LV.E = H.Heart.LV.E.*sum(H.Heart.LV.V0)./H.Heart.LV.V0(:,4);

    % Set et to 0 for infarct
    H.Heart.LV.et = [H.Heart.LV.et; zeros(size(H.Heart.LV.et))];
    H.Heart.LV.det = [H.Heart.LV.det; zeros(size(H.Heart.LV.det))];
end


%% Initial solver estimates

% Load previous simulation values if existing...
fConSol = fullfile(H.Misc.CMRootDir,'convergedSols/ConSol.mat');
if exist(fConSol, 'file') == 2
    if ~H.Growth.isGrowth
        disp('Volumes initialized using previous simulation outcome')
    end
    % Load previously converged solution
    load(fConSol, 'ConSol')
    % Initial guess for volumes from converged solution
    if numel(ConSol.k) == numel(H.V(1,:))
        H.V(1,:) = ConSol.k.*H.Circ.SBV;
    else
        % If sizes are inconsistent because if e.g. ischemia, do not use
        H.V(1,:) = H.Circ.k.*H.Circ.SBV;
    end
else
    % ... or guess
    H.V(1,:) = H.Circ.k.*H.Circ.SBV; 
end


end