function Vitals = getVitals(H, export)

% Compute useful clinical metrics

%% Calls

P = H.P;
V = H.V;
t = H.t;


%% 

% Valve opening/closing
Valves = getValveStatus(P);
dValves = diff(Valves);
% AVopens = find(dValves(:,2)==1); 
% AVcloses = find(dValves(:,2)==-1);
% MVopens = find(dValves(:,1)==1, 1, 'first'); 
MVcloses = find(dValves(:,1)==-1, 1, 'first'); 

% Maximum pressure
Vitals.pMax = max(P(:,2));

% ES
[~,Vitals.iES] = max(P(:,2)./V(:,2));
Vitals.ESP = P(Vitals.iES,2);
Vitals.ESV = V(Vitals.iES,2);

% ED Volume (when MV opens)
Vitals.iED = MVcloses;
Vitals.EDP = P(Vitals.iED,2);
Vitals.EDV = V(Vitals.iED,2);

% Stroke volume and EF
% VStroke = Volumes(row_AoV_opens,2) - Volumes(row_AoV_closes,2);
Vitals.VStroke = Vitals.EDV - Vitals.ESV;
Vitals.EF = (Vitals.EDV-Vitals.ESV)/Vitals.EDV;

% Cardiac output (L/min)
Vitals.CO = Vitals.VStroke/t(end)*60/1e3;

% dpdtMax
Vitals.dpdtMax = max(gradient(P(:,2),t));

% Mean arterial pressure (mmHg)
Vitals.MAP = mean(P(:,4));

if export
    Start spreading the news
    s = sprintf(['EDV:\t\t%2.2f\nEDP:\t\t%2.2f\nESV:\t\t%2.2f\nESP:\t\t%2.2f\n'...
                 'pMax:\t\t%2.2f\nStroke volume:\t%2.2f\nCO:\t\t%2.2f\nEF:\t\t%2.2f'...
                 '\nMAP:\t\t%2.2f\ndpdtMax:\t%2.2f\n'],...
                Vitals.EDV, Vitals.EDP, Vitals.ESV, Vitals.ESP,...
                Vitals.pMax, Vitals.VStroke, Vitals.CO, Vitals.EF,...
                Vitals.MAP,Vitals.dpdtMax);
            
    disp(s);
    fid = fopen(fullfile(H.Fig.figDir, 'readouts.txt'),'w');
    fprintf(fid,s);
    fclose(fid);
end

end