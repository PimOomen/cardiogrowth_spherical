function H = updateCircHeartGrowth(H)

% If using within growth environment, update circulation parameters
Growth = H.Growth;
    
iG = Growth.iG; 

%% Circulation
H.Circ.HR = Growth.Circ.HR(iG);
H.Circ.SBV = Growth.Circ.SBV(iG);
H.Circ.R.as = Growth.Circ.Ras(iG);
H.Circ.R.mvbr = Growth.Circ.MVBR(iG);


%% Heart

% Ischemia
H.Heart.infarctSize = H.Growth.infarctSizeg(iG);

if iG == 1
    % Initialize wall geometry and constitutive parameters
    r0 = (3*H.Heart.V0/(4*pi))^(1/3);
    h0 = (r0^3+H.Growth.LVwallvolume*3/(4*pi)*(1-H.Heart.infarctSize))^(1/3) - r0;
    
    H.Growth.LV.a   = H.Heart.A*r0/(2*h0);
    H.Growth.LV.b   = H.Heart.B*4/3*pi*r0^3;
    H.Growth.LV.e   = H.Heart.E*2/3*pi*(r0^4/h0);
else
    % Otherwise update from initial using growth tensor
    r0 = H.Growth.r0(1)*H.Growth.Fg(iG,1);
    h0 = H.Growth.h0(1)*H.Growth.Fg(iG,3);
end

% Update parameters
H.Heart.A = 2*H.Growth.LV.a*h0/r0;
H.Heart.B = H.Growth.LV.b*3/(4*pi)*(1/r0)^3;
H.Heart.E = 3/(2*pi)*H.Growth.LV.e*h0/(r0)^4;
H.Heart.V0 = 4/3*pi*r0^3;

    
%% Assign

H.Growth.r0(iG) = r0;
H.Growth.h0(iG) = h0;


end


