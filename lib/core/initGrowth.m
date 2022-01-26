function H = initGrowth(H)

Ng = length(H.Growth.tG);

% Initialize time arrays for growth variable storage
H.Growth.labfMax = zeros(Ng, 1);
H.Growth.labrMax = zeros(Ng, 1);
H.Growth.Fg = ones(Ng, 3);  % Fg11 - Fg22 - Fg33

% Initialize history storage field
H.Hist = [];

% Initialize wall thickness and radius
H.Growth.h0 = zeros(Ng,1);
H.Growth.r0 = zeros(Ng,1);

% Change in LV cavity volume due to growth
H.Growth.dCavity = 0;

end