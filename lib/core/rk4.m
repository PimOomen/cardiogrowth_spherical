function H = rk4(H)

% Code engine: Runge-Kutta differential equation solver to calculate 
% volumes and pressures at the current time point
%
% Compartments:
% VP  LV  AS  VS  RV  AP   (LV ischemic)
% 1   2   3   4   5   6    (7)


%% Calls

inc = H.Solver.inc;
dt = H.Solver.dt;
R = H.Circ.R;

% Current pressures
P = H.P(inc-1,:);
V = H.V(inc-1,:);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RK4 solver components k1-k4, used to update compartment volumes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% k1
[DV2, DV2ischemic] = dv2(P, R, V, H.Heart.infarctSize);
k1 = [dv1(P, R) DV2 dv3(P, R) dv4(P, R) ...
         dv5(P, R) dv6(P, R) DV2ischemic];    
    
% k2
Pk2 = P + 0.5*dt*k1;
[DV2, DV2ischemic] = dv2(Pk2, R, V, H.Heart.infarctSize);
k2 = [dv1(Pk2, R) DV2 dv3(Pk2, R) dv4(Pk2, R), ...  
            dv5(Pk2, R) dv6(Pk2, R) DV2ischemic]; 
    
% k3
Pk3 = P + 0.5*dt*k2;
[DV2, DV2ischemic] = dv2(Pk3, R, V, H.Heart.infarctSize);
k3 = [dv1(Pk3, R) DV2 dv3(Pk3, R) dv4(Pk3, R), ...  
            dv5(Pk3, R) dv6(Pk3, R) DV2ischemic]; 

% k4
Pk4 = P  + dt*k3;
[DV2, DV2ischemic] = dv2(Pk3, R, V, H.Heart.infarctSize);
k4 = [dv1(Pk4, R) DV2 dv3(Pk4, R) dv4(Pk4, R), ...  
            dv5(Pk4, R) dv6(Pk4, R) DV2ischemic]; 
        
    
%% Compute new volumes 

H.V(inc,:) = H.V(inc-1,:) + 1/6*dt*(k1 + 2*k2 + 2*k3 + k4);

    
%% Compute new pressures

%Calculate circulation Pressures
H = V2P(H);                
    
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to compute volume changes in all compartments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dV1: Pulmonary veins
function dV = dv1(P, R)
    dV = (P(6) - P(1)) / R.ap...
       - (P(1) - P(2)) / R.vp * (P(1) > P(2))...
       + (P(2) - P(1)) / R.mvbr * (P(2) > P(1));
end

% dV2: Left ventricle
function [dV, dVischemic] = dv2(P, R, V, ischemic)

    dV = (P(1) - P(2)) / R.vp * (P(1) > P(2))...
       - (P(2) - P(3)) / R.cs * (P(2) > P(3))...
       - (P(2) - P(1)) / R.mvbr * (P(2) > P(1));
    
    if ischemic == 0
        dVischemic = [];
    else
        % If ischemic, determine healthy and ischemic compartments dV
        % Note, this works for any number of any number of compartments
        NCompartments = 2;
        
        %% Compute compartments x and y to solve linear system
        % Components are dependent on the chosen active contraction model
        % and should thus correspond to the function used to calculate
        % pressure in the LV and RV based on their volumes
        x = H.Heart.det(:,H.Solver.inc) .*( H.Heart.LV.E.*(V([2 7:end])-V0) - ...
                      H.Heart.LV.A.*(exp(H.Heart.LV.B.*(V([2 7:end]) - H.Heart.LV.V0)) - 1) );
        y = H.Heart.LV.et(:,H.Solver.inc).*H.Heart.E + (1-H.Heart.LV.et(:,H.Solver.inc)) .* H.Heart.LV.A.*H.Heart.LV.B.*...
                exp(H.Heart.LV.B.*(V([2 7:end])-H.Heart.LV.V0));
            
        %% Solve linear system to compute volume change in all compartments
        
        % Building A
        A = zeros(NCompartments);
        A(end,:) = 1;
        A(1:end-1, 1) = y(1);
        for j = 2:NCompartments
            A(j-1,j) = -y(j);
        end

        % Solve linear system to compute volume changes, given in array s
        dVLV = A\[x(2:NCompartments) - x(1); dV];

        dV = dVLV(1);              % Healthy compartment
        dVischemic = dVLV(2);      % dV in all other compartments

    end
end

% dV3: Systemic arterial
function dV = dv3(P, R) 
    dV = (P(2) - P(3)) / R.cs * (P(2) > P(3)) ...
       - (P(3) - P(4)) / R.as;
end

% dV4: Systemic veins
function dV = dv4(P, R) 
    dV = (P(3) - P(4)) / R.as ...
       - (P(4) - P(5)) / R.vs * (P(4) > P(5));
end

% dV5: Right ventricle
function dV = dv5(P, R)
    dV = (P(4) - P(5)) / R.vs * (P(4) > P(5)) ...
       - (P(5) - P(6)) / R.cp * (P(5) > P(6));
end

% dV6: Pulmonary arteries
function dV = dv6(P, R) 
    dV = (P(5) - P(6)) / R.cp * (P(5) > P(6)) ...
       - (P(6) - P(1)) / R.ap;
end

