function H = V2P(H)

%% Preallocate output

P = zeros(1, size(H.V,2));
V = H.V(H.Solver.inc,:);

%% Calculate pressure in blood vessel compartments

P(1) = V(1)/H.Circ.C.vp;      %P_Cvp
P(3) = V(3)/H.Circ.C.as;      %P_Cas
P(4) = V(4)/H.Circ.C.vs;      %P_Cvs
P(6) = V(6)/H.Circ.C.ap;      %P_Cap   


%% Calculate pressure in ventricles

LV = H.Heart.LV;
RV = H.Heart.RV;
VLV = V([2 7:end]);

% LV (healthy and ischemic compartments)
P([2 7:end]) = LV.et(:,H.Solver.inc) .* LV.E.*(VLV - LV.V0) + ...
       (1-LV.et(:,H.Solver.inc)).*LV.A.*( exp(LV.B*(VLV - LV.V0)) - 1 );

% RV
P(5) = RV.et(H.Solver.inc) * RV.E*(V(5) - RV.V0) + ...
       (1-RV.et(H.Solver.inc))*RV.A*( exp(RV.B*(V(5)-RV.V0)) - 1 );


%% Assign

H.P(H.Solver.inc,:) = P;