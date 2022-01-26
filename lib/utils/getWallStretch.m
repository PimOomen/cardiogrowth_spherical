function labfw = getWallStretch(Heart)

% Get wall stretch from patch stretch

Nw = length(Heart.NPatches);

labfw = zeros(size(Heart.rm));
for iW = 1:Nw
    labfw(:,iW) = mean(Heart.labf(:,Heart.patches==iW),2);
end
