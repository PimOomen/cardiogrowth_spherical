function  Valves = getValveStatus(P)

% Valve status: 1 is open, 0 is closed

% 1) MV
% 2) AV
% 3) TV
% 4) PV
    
%Initialize
Valves = zeros(length(P),4);
Valves(:,1) = logical(P(:,1) > P(:,2));
Valves(:,2) = logical(P(:,2) > P(:,3));
Valves(:,3) = logical(P(:,4) > P(:,5));
Valves(:,4) = logical(P(:,5) > P(:,6));


end
