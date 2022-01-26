function hFig = plotPVHist(H, iC)
% Plot PV loops during growth
% plotPVHist(H):    plot LV loops
% plotPVHist(H,iC): plot specific compartment iC


Ng = length(H.Hist);

% Load colormap
cMap = [zeros(2,3); eval([H.Fig.cMapName '(' num2str(Ng-2) ');'])];

% Default compartment to plot is LV
if nargin < 2
    iC = 2;
end     

hFig = figure('Visible','off'); hold on; box on

for iG = 1:Ng
    p(iG) = plot(H.Hist(iG).V(:,iC), H.Hist(iG).P(:,iC),...
        'Color', cMap(iG,:));
end

xlabel('Volume (mL)')
ylabel('Pressure (mmHg)')

set(p, 'LineWidth', H.Fig.lWidth)
set(p(1), 'LineStyle', '--')
set(p(2), 'LineStyle', ':')
set(gca, 'LineWidth', H.Fig.lWidth, 'FontSize', H.Fig.fSize)


fixPaperSize
print(hFig, H.Fig.figType, fullfile(H.Fig.figDir, 'PVHist'))