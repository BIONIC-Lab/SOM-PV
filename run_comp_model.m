% clear;
% clc;
%close all;

function [model_time,E_ca,PV_ca,SOM_ca] = run_comp_model(x, freq, amp, useBurst, useBiomimetic, plot_log)

%% =====================================================
%  Canonical E-PV-SOM ICMS Network Model
%
%  Added:
%   - Recurrent excitatory facilitation
%   - SOM facilitation
%   - PV synaptic depression
%   - ICMS synaptic depression
%
%  Canonical interpretation:
%
%   E   = pyramidal neurons
%   PV  = fast depressing inhibition
%   SOM = slower facilitating inhibition
%
%% =====================================================

%% Simulation parameters

dt = 0.001;                 % 1 ms
T  = 30;                    % seconds should add 15 s before and after stim

model_time = -15:dt:T+15;
N = length(model_time);

%% import params

wEE = x(1); %params.wEE;
wPVE = x(2); %params.wPVE;
wSOME = x(3); %params.wSOME;
wSOMPV = x(4); %params.wSOMPV;
wEPV = x(5); %params.wEPV;
wESOM = x(6); %params.wESOM;
facilitation_tau_E = x(7); %params.facilitation_tau_E;
facilitation_strength_E = x(8); %params.facilitation_strength_E;
facilitation_tau_SOM = x(9); %params.facilitation_tau_SOM;
facilitation_strength_SOM = x(10); %params.facilitation_strength_SOM_ratio;
PV_depression_tau = x(11); %params.PV_depression_tau;should tau be impacted by the strength of stim?
PV_depression_strength = x(12); %params.PV_depression_strength;
PV_starting_val = x(13); %params.PV_starting_val;

%added some new parameters to look at applying stimulation to SOM and PV as
%well
stim_on_E = x(14);
stim_on_PV = x(15);
stim_on_SOM = x(16);


%% Time constants (seconds) 
tauE   = 0.5;%0.020;
tauPV  = 0.5;%0.010;
tauSOM = 0.5;%0.030;

%% Connection weights

% Excitatory recurrence
%wEE = 1.2;

% Feedforward PV inhibition onto E
%wPVE = -2.5; %-2.5; 5

% SOM inhibition onto E and PV
%wSOME  = -5;
%wSOMPV = -1;

% Excitatory recruitment of inhibitory neurons
%wEPV  = 5; %at 20 this looked pretty good for 200 Hz 5
%wESOM = 5; %5

%% =====================================================
% ICMS Synaptic Depression - currently excluding this
%% =====================================================

depression_tau = 2.0;
depression_strength = 0.6;

D = ones(1,N);

%% =====================================================
% Excitatory Facilitation
%% =====================================================

%facilitation_tau_E = 1;
%facilitation_strength_E = 1;

F_E = ones(1,N);

%% =====================================================
% SOM Facilitation
%% =====================================================

%facilitation_tau_SOM = 20.0;
%facilitation_strength_SOM = freq*amp*facilitation_strength_SOM_ratio; %strength should depend on parameters

F_SOM = zeros(1,N);
F_SOM = F_SOM+1;

%% =====================================================
% PV Synaptic Depression
%% =====================================================

%PV_depression_tau = 2; %this should be the rate at which it approaches
%PV_depression_strength = 0.2; %this should be the value it approaches

D_PV = zeros(1,N);
starting_val = freq*amp*PV_starting_val; %had freq here before
% a bit of a problem is that we are using this before burst or biomimetic
% implementation
starting_val = min(10,starting_val);
D_PV = D_PV+starting_val;

%% =====================================================
% Stimulation parameters
%% =====================================================
pulse_train = zeros(1,N);

pulse_times = 15:1/freq:T+15;

for k = 1:length(pulse_times)

    idx = round(pulse_times(k)/dt)+1;

    if idx <= N
        pulse_train(idx) = amp;
    end
end

%% =====================================================
% Optional burst stimulation
%% =====================================================
if useBurst

    pulse_train = zeros(1,N);

    burst_freq = 100;
    burst_rate = 1;
    burst_duration = 0.1;

    burst_starts = 15:1/burst_rate:T+15;
    
    %recalculate for bursts
    D_PV = zeros(1,N);
    starting_val = burst_rate*freq*amp*0.05; %had freq here before
    starting_val = min(10,starting_val);
    D_PV = D_PV+starting_val;

    for b = 1:length(burst_starts)

        t0 = burst_starts(b);
        t1 = t0 + burst_duration;

        pulses = t0:1/burst_freq:t1;

        for p = 1:length(pulses)

            idx = round(pulses(p)/dt)+1;

            if idx <= N
                pulse_train(idx) = amp;
            end
        end
    end
end

%% =====================================================
% Optional biomimetic amplitude modulation
%% =====================================================

if useBiomimetic

    pulse_train = zeros(1,N);

    base_amp = 0.8;
    transient_amp = 4.0;

    stim_freq = 100;

    pulses = 15:1/stim_freq:T+15;

    for p = 1:length(pulses)

        t = pulses(p);
        idx = round(t/dt)+1;

        if idx <= N

            if t < 15.1 || t > (T+15-0.1)
                pulse_train(idx) = transient_amp;
            else
                pulse_train(idx) = base_amp;
            end
        end
    end
end

%% =================================================
% Background Poisson-like activity
%% =================================================
%right now this doesn't seem to really do what I want it to do
noise_amp_E   = 0;%0.0002;
noise_amp_PV  = 0;%0.0002;
noise_amp_SOM = 0;%;0.0002;

%% =====================================================
% State variables
%% =====================================================

E   = zeros(1,N);
PV  = zeros(1,N);
SOM = zeros(1,N);

%% Activation function

relu = @(x) max(0,x);

%% =====================================================
% Simulation loop
%% =====================================================
stim_on = 0;
for t = 2:N

    %% =================================================
    % ICMS Synaptic Depression
    %% =================================================

    D(t) = D(t-1) + ...
        dt*(1 - D(t-1))/depression_tau;

    if pulse_train(t) > 0

        D(t) = D(t) - ...
            depression_strength*dt*pulse_train(t);

    end

    D(t) = max(0.1,min(1,D(t)));

%% =================================================
% Excitatory Facilitation - right now this is not facilitating
%% =================================================
if stim_on
    %F_E_target = 1 + facilitation_strength_E * E(t-1);
    F_E_target = facilitation_strength_E;

    dF_E = (F_E_target - F_E(t-1)) / facilitation_tau_E;

    F_E(t) = F_E(t-1) + dt*dF_E;

    F_E(t) = min(2,F_E(t));
end

%% =================================================
% SOM Facilitation
%% =================================================

%F_SOM_target = 1 + facilitation_strength_SOM * E(t-1);
if stim_on
    %F_SOM_target = facilitation_strength_SOM;
    F_SOM_target = facilitation_strength_SOM*E(t-1)^2; %had 10,000 here before

    dF_SOM = (F_SOM_target - F_SOM(t-1)) / facilitation_tau_SOM;

    F_SOM(t) = F_SOM(t-1) + dt*dF_SOM;

    F_SOM(t) = min(40,F_SOM(t));
    F_SOM(t) = max(1, F_SOM(t));
end

%% =================================================
% PV Synaptic Depression
%% =================================================

%D_PV_target = 1 - PV_depression_strength * PV(t-1);
if stim_on
    D_PV_target(t) = starting_val - PV_depression_strength * E(t-1);
    D_PV_target(t) = max(1, D_PV_target(t));%we are just capping the strength at 0.2 here
    
    dD_PV = (D_PV_target(t) - D_PV(t-1)) / PV_depression_tau;

    D_PV(t) = D_PV(t-1) + dt*dD_PV;

    %D_PV(t) = max(0.2,D_PV(t));
end

    %% =================================================
    % ICMS Input
    %% =================================================

    stim = pulse_train(t);% * D(t);
    
    if stim > 0.1
        stim_on = 1; %this will run once once stimulation has started
    end
    
    %% =================================================
    % Random background activity
    %% =================================================
    
    lambda = 100; % Mean or expected number of events

    % Generate random numbers from a Poisson distribution
    noise = poissrnd(lambda);

    noiseE = noise_amp_E * poissrnd(lambda);

    noisePV = noise_amp_PV * poissrnd(lambda);

    noiseSOM = noise_amp_SOM * poissrnd(lambda);

    %% =================================================
    % Inputs
    %% =================================================
    %until there is stim nothing is happening, although technically there
    %should be some random poisson input probably

    inputE = ...
        wEE * F_E(t) * E(t-1) + ...
        wPVE * D_PV(t) * PV(t-1) + ...
        wSOME * F_SOM(t) * SOM(t-1) + ...
        stim_on_E * stim + ...
        noiseE;

    inputPV = ...
        wEPV * E(t-1) + ...
        noisePV  + ...
        wSOMPV * SOM(t-1) + ...
        stim_on_PV * stim;
        %wPVE * D_PV(t) * PV(t-1);

    inputSOM = ...
        wESOM * E(t-1) + ...
        noiseSOM + ...
        stim_on_SOM * stim;
        %wSOME * F_SOM(t) * SOM(t-1) + 1.0 * stim; %(E(t-1).^2)

    %% =================================================
    % Dynamics
    %% =================================================

    dE = ...
        (-E(t-1) + relu(inputE))/tauE;

    dPV = ...
        (-PV(t-1) + relu(inputPV))/tauPV;

    dSOM = ...
        (-SOM(t-1) + relu(inputSOM))/tauSOM;

    %% =================================================
    % Euler Integration
    %% =================================================

    E(t)   = E(t-1)   + dt*dE;
    PV(t)  = PV(t-1)  + dt*dPV;
    SOM(t) = SOM(t-1) + dt*dSOM;

end

%% ============================================
% Calcium-like filtering
%% ============================================

tau_rise  = 0.03;
tau_decay = 0.05;

t_kernel = 0:dt:0.1;

kernel = ...
    (1 - exp(-t_kernel/tau_rise)) .* ...
     exp(-t_kernel/tau_decay);

kernel = kernel / max(kernel);

%% Convolve activity traces

E_ca   = conv(E,   kernel, 'same');
PV_ca  = conv(PV,  kernel, 'same');
SOM_ca = conv(SOM, kernel, 'same');

%% =====================================================
% Plotting
%% =====================================================
if plot_log
    figure;

    subplot(7,1,1)
    plot(model_time,pulse_train,'k')
    ylabel('Stim')
    title(['ICMS Pattern: ' num2str(freq) ' Hz'])

    subplot(7,1,2)
    plot(model_time,E,'LineWidth',2)
    ylabel('E')
    %ylim([-0.1 0.3])

    subplot(7,1,3)
    plot(model_time,PV,'LineWidth',2)
    ylabel('PV')
    %ylim([-0.1 0.3])

    subplot(7,1,4)
    plot(model_time,SOM,'LineWidth',2)
    ylabel('SOM')
    %ylim([-0.1 0.3])

    subplot(7,1,5)
    plot(model_time,F_E,'LineWidth',2)
    ylabel('F_E')

    subplot(7,1,6)
    plot(model_time,F_SOM,'LineWidth',2)
    ylabel('F_{SOM}')

    subplot(7,1,7)
    plot(model_time,D_PV,'LineWidth',2)
    ylabel('D_{PV}')
    xlabel('Time (s)')
end

%% =====================================================
% Change indices
%% =====================================================

early_idx = model_time < 15;
late_idx  = model_time >= 15;

E_change = ...
(mean(E(late_idx)) - mean(E(early_idx))) / ...
(mean(E(late_idx)) + mean(E(early_idx)));

PV_change = ...
(mean(PV(late_idx)) - mean(PV(early_idx))) / ...
(mean(PV(late_idx)) + mean(PV(early_idx)));

SOM_change = ...
(mean(SOM(late_idx)) - mean(SOM(early_idx))) / ...
(mean(SOM(late_idx)) + mean(SOM(early_idx)));

% fprintf('\nChange indices:\n');
% 
% fprintf('E   = %.3f\n',E_change);
% fprintf('PV  = %.3f\n',PV_change);
% fprintf('SOM = %.3f\n',SOM_change);

end