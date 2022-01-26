function V = getVitalHist(H, vital)

% Growth time
t = H.Growth.tG;
Nt = length(t);

% Loop through time history
V = zeros(Nt,1);
for i = 1:Nt
    Vi = getfield(H.Hist(i).Vitals, vital);
    if ~isempty(Vi)
        V(i) = Vi;
    end
end

