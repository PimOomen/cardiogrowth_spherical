function hFig = plotPV(H, iC, EDESPVR)
% Plot PV loop
% plotPVHist(H):    plot LV loop
% plotPVHist(H,iC): plot specific compartment iC
% plotPVHist(H,iC,EDPVR): plot specific compartment iC, with (EDESPVR=true) 
% or without(EDESPVR = false) including EDPVR and ESPVR


% Default compartment to plot is LV
if nargin < 2
    iC = 2;
    EDESPVR = false;
end
if nargin < 3
    EDESPVR = false;
end

hFig = figure('Visible','off'); hold on; box on

p = plot(H.V(:,iC), H.P(:,iC), '-');

% Add EDPR and ESPVR if plotting LV or RV
if EDESPVR
    if (iC == 2)
        Ventricle = H.Heart.LV;
    elseif (iC == 5)
        Ventricle = H.Heart.LV;
    end

    VLim = get(gca,'XLim');
    PLim = get(gca,'YLim');

    VEDES = linspace(Ventricle.V0, 1.2*max(H.V(:,iC)), 100);
    p(2) = plot(VEDES, Ventricle.A.*( exp(Ventricle.B*(VEDES - Ventricle.V0)) - 1 ), '--k');
    p(3) = plot(VEDES, Ventricle.E.*(VEDES - Ventricle.V0), '--k');
    
    xlim([0.8*Ventricle.V0 1.2*max(H.V(:,iC))])
    ylim(PLim)
end

xlabel('Volume (mL)')
ylabel('Pressure (mmHg)')

set(p, 'LineWidth', H.Fig.lWidth)
set(gca, 'LineWidth', H.Fig.lWidth, 'FontSize', H.Fig.fSize)

fixPaperSize
print(hFig, H.Fig.figType, fullfile(H.Fig.figDir, 'PV'))

end