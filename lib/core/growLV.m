function H = growLV(H)

% Strain-driven anisotropic growth of LV, as in Witzenburg 2018

%% Calls

Growth = H.Growth;
pars = H.Growth.pars;
iG = Growth.iG;

%% Calculate Green-Lagrange strain

% At set point
EfMaxSet = 0.5*(Growth.labfMax(Growth.iRef).^2 - 1);
ErMaxSet = 0.5*(Growth.labrMax(Growth.iRef).^2 - 1);

% At current time point
EfMax = 0.5*(Growth.labfMax(Growth.iG-1).^2 - 1);
ErMax = 0.5*(Growth.labrMax(Growth.iG-1).^2 - 1);


%% Stimulus functions

sl = max(EfMax) - EfMaxSet;
st = -max(ErMax) + ErMaxSet;


%% Growth tensor

Fgi = zeros(1,3);

% Modified KOM, fit to PO and VO fitting simulations by CMW
if ~Growth.sigmoidSwitch

    % Fiber direction, eq 8
    Fgi(1) = (sl>0).*sqrt(   pars.f_ff_max ./ (1+exp(-pars.f_f.*(sl-pars.sl_50)) )+1 ) + ...
                 (sl<0).*sqrt(  -pars.f_ff_max ./ (1+exp( pars.f_f.*(sl+pars.sl_50)) )+1 ) + ...
                 (sl==0);         

    % radial direction        
    Fgi(3)= (st>0).*(  pars.f_cc_max ./ (1+exp(-pars.r_f_pos.*(st-pars.st_50_pos)) )+1 ) + ...
                (st<0).*( -pars.f_cc_max ./ (1+exp( pars.r_f_neg.*(st+pars.st_50_neg)) )+1 ) + ...
                (st==0);  %eqn 9     
          
% Modified modified KOM: true sigmoid curve fitted by Vignesh to the 
% modified KOM growth curve that CMW fitted to PO and VO         
else
    
    % If n is odd, s50 is to be subtracted rather than added in the
    % denominator of the sigmoid in the reversal part (s<0)
    isodd = 1 - (rem(pars.n,2)==1)*2;
    
    % Circumferential direction
    Fgi(1) = (sl>0) .* (sl.pars.n ./  (sl.pars.n + pars.sl_50.pars.n) .* pars.Ffgmax + 1) +...
                 (sl<0) .* (-sl.pars.n ./ (sl.pars.n + isodd*pars.sl_50.pars.n) .* pars.Ffgmax + 1) +...
                 (sl==0);

    % Radial direciton 
    Fgi(3) = (st>0) .* (st.pars.mp ./ (st.pars.mp + pars.st_50pos.pars.mp) .* pars.rgmax + 1) +...
                 (st<0) .* (-st.pars.mn ./ (st.pars.mn + isodd*pars.st_50neg.pars.mn) .* pars.Frgmax + 1) +...
                 (st==0);

end    

% Eq 10 modified - cross-fiber and fiber growth stretches are the same and 
% radial growth stretch is different
Fgi(2) = Fgi(1); 

% Update growth tensor
Growth.Fg(iG,:) = Growth.Fg(iG-1,:).*Fgi;


%% Assign to structure

H.Growth = Growth;


