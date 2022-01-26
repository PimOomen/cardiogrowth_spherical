
function H = storeGrowth(H)

% Calls
iG = H.Growth.iG;

% Vitals
H.Hist(iG).Vitals = getVitals(H, false);

% Dimensions
[H.Hist(iG).r, H.Hist(iG).h] = sphereDimensions(H.V(:,2), H.Growth.r0(iG), H.Growth.h0(iG));

% Stretch
H.Hist(iG).labr = H.Hist(iG).h/H.Growth.h0(iG);
H.Hist(iG).labf = H.Hist(iG).r/H.Growth.r0(iG);

% Max LV stretch - for growth
H.Growth.labfMax(iG) = max(H.Hist(iG).labf);
H.Growth.labrMax(iG) = max(H.Hist(iG).labr);

% LV Pressure and volume
H.Hist(iG).P = H.P;
H.Hist(iG).V = H.V;

end