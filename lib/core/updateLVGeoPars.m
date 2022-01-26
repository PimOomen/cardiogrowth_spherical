function H = updateLVGeoPars(H)
% Update LV parameters (Eq. 12-14) of healthy LV compartment

iG = H.Growth.iG;
    
if iG == 1
% Initialize wall geometry and constitutive parameters
    r0 = (3*H.Heart.V0/(4*pi))^(1/3);
    h0 = (r0^3+H.Growth.LVwallvolume*3/(4*pi)*(1-H.Heart.infarctSize))^(1/3) - r0;
    
    H.Growth.LV.a   = H.Heart.A*r0/(2*h0);
    H.Growth.LV.b   = H.Heart.B*4/3*pi*r0^3;
    H.Growth.LV.e   = H.Heart.E*2/3*pi*(r0^4/h0);
else
    r0 = H.Growth.r0(1)*H.Growth.Fg(iG,1);
    h0 = H.Growth.h0(1)*H.Growth.Fg(iG,3);
end

% Update parameters
H.Heart.LV.A(1) = 2*H.Growth.LV.a*h0/r0;
H.Heart.LV.B(1) = H.Growth.LV.b*3/(4*pi)*(1/r0)^3;
H.Heart.LV.E(1) = 3/(2*pi)*H.Growth.LV.e*h0/(r0)^4;
H.Heart.LV.V0(1) = 4/3*pi*r0^3;

    
%% Assign

H.Growth.r0(iG) = r0;
H.Growth.h0(iG) = h0;

end