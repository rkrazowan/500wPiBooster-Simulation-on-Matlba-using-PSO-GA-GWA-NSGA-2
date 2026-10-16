clc; clear; close all;

%% 1. Fixed parameters (your physical circuit)
Vin  = 8.9;          % V
Vref = 15;          % V
fs   = 62.5e3;        % Hz
L    = 400e-6;      % H  (actual)
C    = 1000e-6;     % F  (actual)
D    = 1 - Vin/Vref;   % ideal duty = 0.5

%% 2. Choose the load (edit Pload only)
Pload = 15;                  % W  <-- design load
R     = Vref^2/Pload;        % ohm
Iout  = Vref/R;              % A
IL    = Iout/(1-D);          % average inductor current

%% 3. Ripple and mode checks
dIL   = Vin*D/(L*fs);                 % inductor ripple (pk-pk), A
dVo   = Iout*D/(fs*C);                % output ripple (pk-pk), V
ripIL = 100*dIL/IL;                   % % of average IL
ripVo = 100*dVo/Vref;                 % % of Vout

Rcrit = 2*L*fs/(D*(1-D)^2);           % CCM if R < Rcrit
Pmin_CCM = Vref^2/Rcrit;              % minimum power for CCM

% Load range that suits this L and C
R_ccm_max     = Rcrit;                          % DCM boundary
R_ripple30    = Vref*(1-D)/(Vin*D/(L*fs)/0.3);  % dIL = 30% of IL
P_ripple30    = Vref^2/R_ripple30;

fprintf('--- Design with L=%.0f uH, C=%.0f uF ---\n', L*1e6, C*1e6);
fprintf('Duty D            = %.3f\n', D);
fprintf('Load R            = %.2f ohm (%.1f W, %.2f A)\n', R, Pload, Iout);
fprintf('Avg inductor I    = %.2f A\n', IL);
fprintf('Inductor ripple   = %.2f A pp (%.1f %% of IL)\n', dIL, ripIL);
fprintf('Output ripple     = %.3f V pp (%.2f %%)\n', dVo, ripVo);
fprintf('CCM boundary      : R < %.1f ohm  (P > %.1f W)\n', Rcrit, Pmin_CCM);
fprintf('Ripple<=30%% of IL : P >= %.1f W\n', P_ripple30);
if R < Rcrit
    disp('Mode: CCM  (OK)');
else
    disp('Mode: DCM  (averaged model below NOT valid)');
end

%% 4. Small-signal model (valid in CCM)
s   = tf('s');
den = 1 + s*L/(R*(1-D)^2) + s^2*L*C/(1-D)^2;
Gvd = (Vref/(1-D)) * (1 - s*L/(R*(1-D)^2)) / den;   % duty -> Vout
Gvg = (1/(1-D)) / den;                              % Vin  -> Vout

fRHPZ = R*(1-D)^2/(2*pi*L);
f0    = (1-D)/(2*pi*sqrt(L*C));
fprintf('RHP zero          = %.0f Hz\n', fRHPZ);
fprintf('LC resonance      = %.0f Hz\n', f0);
fprintf('Suggested loop crossover < %.0f Hz (about fRHPZ/5)\n', fRHPZ/5);

figure; bode(Gvd); grid on; title('Gvd(s): duty to output voltage');
figure; step(Gvd*0.01); grid on; title('Open-loop response to 1% duty step');

%% 5. Values to use in Simulink
% Vin=12 V, L=400e-6, C=1000e-6, R=R (above), fs=10e3, Vref=24,
% initial duty D=0.5, diode drop ~0.7 V, add C ESR ~ 20-50 mOhm if known