clc
clear

Vin = 15;
D = 0.6; 
fs = 25e3; 
R = 100; % Matched to video's actual simulation script parameter

% Proper Boost steady state output voltage
Vout = Vin / (1 - D); 
Ioutmax = Vout / R;               

% Exact ripple parameters targeted by the YouTuber 
delIL = 0.008;       % Tight ripple current of 8 mA
delVout = 0.06;      % Tight ripple voltage of 60 mV (0.16%)

% Exact Boost Converter design formulas
L = (Vin * D) / (delIL * fs)   % Outputs exactly 0.045 H (45 mH)
C = (Ioutmax * D) / (fs * delVout) % Outputs exactly 150 uF

%% 2. Transfer Function Coefficient Setup (As shown in image)
a = Vin / (1 - D)^2;
b = L / (R * (1 - D)^2);
c = (L * C) / (1 - D)^2;

% Numerator and Denominator matrices for tf()
num = [a*(-b) a];   % Models the Right-Half-Plane (RHP) zero: a*(-b)*s + a
den = [c b 1];       % Standard second-order denominator: c*s^2 + b*s + 1

%% 3. Open-Loop Control-to-Output Transfer Function
Gs = tf(num, den); 
fprintf('--- Open Loop Transfer Function Gs(s) ---\n');
display(Gs);

%% 4. PI Controller Implementation
Kp = 0.005;
Ki = 0.087;
PIs = tf([Kp Ki], [1 0]);  % Generates the PI function: (Kp*s + Ki) / s
Gs_CL=feedback(Gs,1)

%% 5. Closed-Loop System Function (Unity Feedback)
Gs_PI = feedback(Gs * PIs, 1);
fprintf('--- Closed-Loop Transfer Function Gs_PI(s) ---\n');
display(Gs_PI);