clc
clear

%% 1. System Parameters & Component Calculations
P = 500;
Vin = 12;
fs = 10e3;
Vref = 24;

Ioutmax = P / Vref;
delIL = 0.01 * Ioutmax * (Vref / Vin);
delvout = 0.01 * Vref;

% Component calculations
L = (Vin * (Vref - Vin)) / (delIL * fs * Vref);
C = (Ioutmax * (1 - (Vin / Vref))) / (fs * delvout);
R = Vref / Ioutmax;

% Duty ratio calculation for Boost Converter
D = (Vref - Vin) / Vref;

%% 2. Transfer Function Coefficient Setup (YouTuber Method)
a = Vin / (1 - D)^2;
b = L / (R * (1 - D)^2);
c = (L * C) / (1 - D)^2;

% Open-loop Transfer Function Numerator and Denominator
num = [-a*b  a];
den = [c  b  1];

%% 3. Open-Loop Control-to-Output Transfer Function
Gs = tf(num, den);
fprintf('--- Open Loop Transfer Function Gs(s) ---\n');
display(Gs);