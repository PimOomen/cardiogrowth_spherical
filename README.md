# CardiacGrowth

## Description
Rapid computational model to simulate a cardiac mechanics and hemodynamics, and growth & remodeling

            
            .:::.   .:::.
           :::::::.:::::::
           :::::::::::::::
           ':::::::::::::'
             ':::::::::'
               ':::::'              
                 ':'

MATLAB code of the rapid computational model developed by Colleen Witzenburg (Witzenburg et al., J. Cardiovasc Transl Res 2018) and Pim Oomen at the University of Virginia to predict cardiac growth and remodeling using changes in strain. The main code is CardioGrowth, there one can choose one of the following input files calibrated to experimental data:

- PressureOverloadFitting: calibrated to Sasayama et al., 1976
- PressureOverloadValidation: calibrated to Nagatomo et al. 1999
- VolumeOverloadFitting: calibrated to Kleaveland et al., 1988
- VolumeOverloadValidation: calibrated to Nakano et lal., 1991

You are encouraged to develop your own input file based on the included ones, and share them with others (contact us to have them included here). Note that the current version of the model is capable of simulating an cardiac cycle with an infarcted left ventricle, but not yet growth, to be updated soon.

For simulations including dyssynchrony and a more realistic cardiac geometry, please be refered to Oomen et al., BMMB 2021 and the corresponding repository on GitHub.

## How to run
To simulate a single heart beat using the input function inputfuncname as string, and return the simulation results in the structure H:
```
H = CompartmentalModel('input', 'inputfuncname') 
```

To simulate growth as specified in the input function 'inputfuncname' as string, and return the simulation results in the structure H:
```
H = CardioGrowth('input', 'inputfuncname') 
```

Several plot functions are included in the lib/plot directory, including plotting pressure-volume loop in the most recent steady-state heart beat of the LV
```
plotPV(H)
```
or any other compartment
```
plotPV(H, compartmentnumber)
```
, history of PV loops during growth 
```
plotPV(H)
```
or
```
plotPVHist(H, compartmentnumnber)
```
and growth (total, fiber, and radial direction)
```
plotGrowt(H)
```
. All figures will be saved in the directory specified in the input file Plot graphical settings and 