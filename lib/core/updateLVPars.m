function H = updateLVGeoPars(H)
% Update LV parameters (Eq. 12-14) of healthy LV compartment


iG = H.Growth.iG;
Fg = H.Growth.Fg(iG,:);



if iG == 1
    %% If first growth increment, calculate constitutive parameters and geometry

    r0 = (3*H.Heart.LV.V0/(4*pi))^(1/3);
    h0 = (r0^3+H.Growth.LVwallvolume*3/(4*pi)*(1-H.Heart.infarctSize))^(1/3) - r0;

    H.Growth.LV.a   = H.Heart.LV.A*r0/(2*h0);
    H.Growth.LV.b   = H.Heart.LV.B*4/3*pi*r0^3;
    H.Growth.LV.e   = H.Heart.LV.E*2/3*pi*(r0^4/h0);


else
    %% Otherwise, update
    
    % Update Geometry
    r0 = H.Growth.r0(iG-1)*Fg(iG,1);
    h0 = H.Growth.h0(iG-1)*Fg(iG,3);
    
    % Update parameters
    H.Heart.LV.A(1) = 2*H.Growth.LV.a*h0/r0*Fg(3)/Fg(1);
    H.Heart.LV.B(1) = H.Growth.LV.b*3/(4*pi)*(1/(r0*Fg(1)))^3;
    H.Heart.LV.E(1) = 3/(2*pi)*H.Growth.LV.e*h0*Fg(3)/(r0*Fg(1))^4;
    H.Heart.LV.V0(1) = 4/3*pi*(r0*Fg(1))^3;

end    
    
%% Assign

H.Growth.h0(iG) = r0;
H.Growth.r0(iG) = h0;