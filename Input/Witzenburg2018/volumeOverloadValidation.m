function H = volumeOverloadValidation(isGrowth)
%% User input for the compartmental model
%
%//////////////////////////////////////////////////////////////////////////
% Input file desciption
%//////////////////////////////////////////////////////////////////////////

% Replication of Witzenberg 2018 Volume Overload
% Validation Study w/ Nakano Data 

%//////////////////////////////////////////////////////////////////////////
%% 0. GENERAL
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Figure export directory to store figure, workspace, and some functional 
% readouts. If non-existent, it will be created for you.
Fig.figDir = 'Output/VOValidation';


%//////////////////////////////////////////////////////////////////////////
%% 1. COMPARTMENTAL MODEL
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.1 Hemodynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Circ.HR = 62;            % Heart Rate [beats/min] 
Circ.SBV = 338;

% Capacitances [ml/mmHg] 
Circ.C.vp = 3; 
Circ.C.as = 1.02;
Circ.C.vs = 17;
Circ.C.ap = 2;

% Resistances (from Santamore) [mmHg * s/mL]
Circ.R.vp = 0.015;
Circ.R.cs = 0.023;
Circ.R.as = 2.38;
Circ.R.vs = 0.015;
Circ.R.cp = 0.060;
Circ.R.ap = 0.300;
Circ.R.mvbr = inf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.2 Heart properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start time of systole, onset of contraction [s]
Heart.t0 = 0.0;                      

% EDPVR & ESPVR parameters (note A & B are switched from Colleen's paper)
Heart.A = 0.145;                % Linear ED component [mmHg]
Heart.B = 0.089;                % Exponential ED component [1/mL] 
Heart.E = 26.6;                  % End-systolic elastance of LV [mmHg/mL]
Heart.V0 = 26.4;                 % Unloaded ventricular volume [mL]

% Scaling factor of maximum contraction of RV compared to LV
Heart.RVScale = 3/7;

% LV infarction size (LV fraction), set 0 for healthy
Heart.infarctSize = 0.0;
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.3 Solver controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Solver settings
Solver.cutoff = 0.14;      % Convergence criterium
Solver.iterMax = 50;       % Maximum number of iterationsclear all
Solver.NInc = 5000;      % Number of time steps during heart beat
                                   % (will be over-written if
                                   % time-varying elastance is chosen)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.4 Plotting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Will be ignored when using growth simulation
Fig.isKill = false;                      % Plot?
Fig.cMapName = 'plasma';                    % Color map
Fig.fSize = 18;                            % Font size
Fig.lWidth = 3;                            % Line width
Fig.mSize = 10;                             % Marker size
Fig.figType = '-dpdf';                     % Figure export type


if ~isGrowth

    Growth.isGrowth = false;

else
    Growth.isGrowth = true;

%//////////////////////////////////////////////////////////////////////////
%% 2. GROWTH
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.1 General
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LV wall volume, determined such that the acute change in LV wall 
% thickness in the normal compartment matched reported values
Growth.LVwallvolume = 25000;           % [mL?]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.2 Growth time course
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Growth timing, always preceded by acute, control (and drug perturbation)
Growth.tTotal = 90;              % Total simulation time [days]
Growth.dt = 1;                 % Number of days per growth step [days]

% Do not change this block, construct growth time vector, growth always 
% starts at t = 1, preceded by:
%   o No drugs: control is -1, acute is 0
%   o Drugs: control is -2, acute is -1, drug perturbation is 0
Growth.tG = [-1 0 1:Growth.dt:Growth.tTotal]';   
Growth.iRef = 1;                      % Control time step for growth
Ng = length(Growth.tG);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.3 Hemodynamics and mechanical activation during growth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Assign the values of SBV, Ras, HR, etc at each time step of the growth 
% simulation. This will overwrite the overlapping parameters of the CM.
% Any change in V0 due to growth will be added/substracted to SBV during 
% the growth simulation.

% Hemodynamics
load("Nakano_Data.mat");
Growth.Circ.SBV = [338; repmat(390, [Ng-1 1])];
Growth.Circ.Ras = [2.38; repmat(2.2733, [Ng-1 1])];
Growth.Circ.MVBR = [inf linspace(0.1479, 0.1479*1.4, 91)];
Growth.Circ.HR = [62, HR_vector]; %HR_vector from Nakano_Data.mat. It is experimental data

Growth.infarctSizeg = zeros(Ng,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.4 Modified KOM model growth parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choice of growth curve: modified KOM fitted by CMW (false) or true
% sigmoid fitted to modified KOM by Vignesh (true)
Growth.sigmoidSwitch = false;

% Growth parameters (from CMW et al. 2018)
if ~Growth.sigmoidSwitch
    Growth.pars.f_ff_max = 0.1*Growth.dt;
    Growth.pars.f_cc_max = 0.1*Growth.dt;
    Growth.pars.f_f = 31;
    Growth.pars.sl_50 = 0.215;
    Growth.pars.r_f_neg = 576;
    Growth.pars.st_50_neg = 0.034;
    Growth.pars.r_f_pos = 36.42;  
    Growth.pars.st_50_pos = 0.0971;
else
    % Growth parameters for a true sigmoid growth curve fitted by Vignesh
    Growth.pars.n = 5;
    Growth.pars.sl_50 = 0.21;
    Growth.pars.Ffgmax = 0.05*tScale;
    Growth.pars.mp = 4.0827;
    Growth.pars.mn = 11;
    Growth.pars.st_50_pos = .5*0.0909;
    Growth.pars.st_50_neg = 0.0366; 
    Growth.pars.Frgmax = 0.1*Growth.dt; 
end

end


%% Assign to model structure

H.Circ = Circ;
H.Heart = Heart;
H.Solver = Solver;
H.Fig = Fig;
H.Growth = Growth;

end


