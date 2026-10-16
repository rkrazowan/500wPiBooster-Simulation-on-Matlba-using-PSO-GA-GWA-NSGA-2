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

% Boost Converter Component Values
L = (Vin * (Vref - Vin)) / (delIL * fs * Vref);
C = (Ioutmax * (1 - (Vin / Vref))) / (fs * delvout);
R = Vref / Ioutmax;

D = 1 - Vin / Vref; 
Dp = 1 - D;

fprintf('--- Component Values ---\n');
fprintf('L = %.6f H\n', L);
fprintf('C = %.6f F\n', C);
fprintf('R = %.4f Ohm\n\n', R);

%% 2. Control Plant Transfer Function (G)
% G(s) = (Vin/Dp^2) * (-L/(R*Dp^2)*s + 1) / (L*C/Dp^2*s^2 + L/(R*Dp^2)*s + 1)
num = (Vin / Dp^2) * [-L / (R * Dp^2), 1];
den = [(L * C / Dp^2), L / (R * Dp^2), 1];
G = tf(num, den);

% Right-Half Plane (RHP) Zero Calculation
fz = (R * Dp^2) / (2 * pi * L);
fprintf('Right-Half Plane Zero (fz) = %.2f Hz\n\n', fz);

%% 3. Mathematical Tuning - Method 1 (Crossover below RHP Zero)
fc1 = fz / 5;              % Crossover frequency
wc1 = 2 * pi * fc1;        
wz1 = wc1 / 10;            % Controller zero placed 10x below crossover

Cn1 = tf([1 wz1], [1 0]);  % Proportional-Integral filter structural form
Kp1 = 1 / abs(evalfr(Cn1 * G, 1i * wc1));
Ki1 = Kp1 * wz1;

fprintf('--- Method 1 Mathematical Values (fc = fz/5) ---\n');
fprintf('Kp = %.4f\n', Kp1);
fprintf('Ki = %.4f\n', Ki1);
[Gm1, Pm1] = margin(tf([Kp1 Ki1], [1 0]) * G);
fprintf('Phase Margin = %.2f deg\n\n', Pm1);

%% 4. Mathematical Tuning - Method 2 (Integral-Dominant)
fc2 = fz / 10;             % Lower crossover frequency
wc2 = 2 * pi * fc2;
wz2 = 5 * wc2;             % Controller zero placed ABOVE crossover

Cn2 = tf([1/wz2 1], [1 0]);
Ki2 = 1 / abs(evalfr(Cn2 * G, 1i * wc2));
Kp2 = Ki2 / wz2;

fprintf('--- Method 2 Mathematical Values (Integral-Dominant) ---\n');
fprintf('Kp = %.4f\n', Kp2);
fprintf('Ki = %.4f\n', Ki2);
[Gm2, Pm2] = margin(tf([Kp2 Ki2], [1 0]) * G);
fprintf('Phase Margin = %.2f deg\n\n', Pm2);

%% 5. Launch Interactive Autotuner App
fprintf('Opening PID Tuner for Plant G...\n');
pidTuner(G, 'PI'); 
