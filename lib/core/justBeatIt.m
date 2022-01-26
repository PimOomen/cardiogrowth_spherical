function H = justBeatIt(H)

%% Initiate

% Initial estimate: set final volumes equal to initial volumes
H.V(end,:) = H.V(1,:);

% Initiate RK4 loop
iter = 0;
isTransientState = true;

% RK4 Solver loop
while isTransientState

    %% Initialize iteration

    % First solver iteration and cardiac cycle time increment
    iter = iter + 1;
    H.Solver.inc = 1;   
    
    % Determining initial volumes from ending volumes in order to 
    % reach steady-state (i.e. volumes at beginning of  cardiac 
    % cycle should be the same as those at the end of the cycle for
    % every compartment if we're at stady state) 
    % Fix "Volume leakage" by ensuring sum is equal to SBV
    H.V(1,:) = H.V(end,:).*H.Circ.SBV./sum(H.V(end,:));

    % Calculate initial pressures
    H = V2P(H);


    %% Cardiac cycle
    
    % Main part of the solver, estimate compartmental pressures and volumes
    % for each time point throughout the cardiac cycle
    for inc = 2:H.Solver.NInc
        H.Solver.inc = inc;
        H = rk4(H);
    end


    %% Calculate if Steady-State has Occured

    % Absolute errors for each compartment
    E = abs(H.V(end,:) - H.V(1,:));

    % Ensure at least two solver iterations
    if iter > 1
        % Check if all compartment errors are below tolerance
        isTransientState = sum(E > H.Solver.cutoff) > 0;
    end

    % Convergence diagnostics
    if ~H.Growth.isGrowth
        printRK4(E, iter, H.Fig.figDir)
    end

    % Emergency brake, if too many iterations have occurred
    if iter > H.Solver.iterMax 
        warning('Maximum allowed number of iterations has been reached')
        isTransientState = 0;
    end

end


if ~H.Growth.isGrowth
    disp('Steady-state circulation established');
end

H.Solver.iter = iter;
H.Solver.errors = E;

end