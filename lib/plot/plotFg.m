function hFig = plotFg(H)
% Plot Fg


hFig = figure('Visible','off'); hold on; box on
plot(H.Growth.tG, H.Growth.Fg(:,[1 3]), 'LineWidth', H.Fig.lWidth);


xlabel('Time (days)')
ylabel('F_g (-)')
xlim([H.Growth.tG(1) H.Growth.tG(end)])

legend({'F_{g,ff}', 'F_{g,rr}'}, 'Location', 'North', 'Orientation', 'Horizontal', 'Box', 'Off')

set(gca, 'LineWidth', H.Fig.lWidth, 'FontSize', H.Fig.fSize)

fixPaperSize
print(hFig, H.Fig.figType, fullfile(H.Fig.figDir, 'Fg'))


end