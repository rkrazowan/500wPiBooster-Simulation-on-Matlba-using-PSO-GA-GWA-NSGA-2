clc
clear

%% 1. System Parameters (From Your Updated Script Image)
P = 500;
Vin = 12;
fs = 10e3;
Vref = 24;

Ioutmax = (P)/Vref;
delIL = 0.01*Ioutmax*(Vref/Vin);
delvout = 0.01*Vref;

% Component calculations from your screenshot
L = (Vin*(Vref-Vin))/(delIL*fs*Vref)
C = (Ioutmax*(1-(Vin/Vref)))/(fs*delvout)
R = Vref/Ioutmax