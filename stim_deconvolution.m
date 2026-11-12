%stim deconvolution of flourescent traces in rasters
%used only for illustration not analysis
function stim_deconvolution(obs_fluo, stim)

% This function performs a very simple greedy binary deconvolution
% to infer spike times from observed fluorescence
% INPUTS:
%   obs_fluo : 1 x N vector of observed calcium fluorescence
%   stim     : 1 x N vector of stimulus drive (for plotting comparison)

    % parameters
    samp_freq = 30; %sampling frequency
    tau = 0.2*samp_freq; %0.2 determined empirically

    n = length(obs_fluo);     % Number of time samples
    t = 1:n;                  % Time index (in samples, not seconds)


    %calcium kernel
    %model fluorescence as an exponential decay after each spike

    kernel_duration = 10 * tau;
    %length of calcium kernel (in samples).
    %10*tau should capture most exponential decay

    t_kernel = 0:(kernel_duration - 1);  
    %time axis for kernel, in sample units.

    kernel = exp(-t_kernel / tau);
    %Exponential decay kernel.
    %Assumes:
    %  - Instantaneous rise
    %  - Pure single exponential decay
        kernel = kernel / sum(kernel);  
    %Normalize kernel so total area = 1.

    kernel_len = length(kernel);

    %call to greedy spike inference function (defined at end)
    inferred_spikes = greedy_binary_inference(obs_fluo, kernel);

    %reconstruct fluorescence from inferred spikes
    predicted_fluo = conv(inferred_spikes, kernel, 'full');

    %keep only causal portion
    predicted_fluo = predicted_fluo(1:n);

    %plot
    figure;

    %can look at how well model fits
%     subplot(3,1,1);
%     plot(t, obs_fluo, 'b', 'DisplayName', 'Observed Fluorescence'); hold on;
%     plot(t, predicted_fluo, '--r', 'DisplayName', 'Predicted from Spikes');
%     title('Fluorescence and Model Fit');
%     legend;

    spike_times = t(inferred_spikes > 0);
    stem(spike_times, ones(size(spike_times)), 'Color', [1 0.5 0], 'Marker', 'none');

    title('Inferred Binary Spike Raster');
    xlim([0 n])
    ylim([0 1.5]);
    yticks([]);

    hold on

    plot(t, stim, 'Color', [0.5 0.5 0.5], 'LineWidth', 2);

% greedy binary spike inference
% tries to infer spikes one time point at a time
%   At each time t try placing a spike and see if it reduces squared
%   error
    function inferred_spikes = greedy_binary_inference(observed, kernel)

        n = length(observed);
        inferred_spikes = zeros(1, n);  % Initialize spike train (binary)
        residual = observed;            % Residual signal we try to explain
        kernel_len = length(kernel);

        for t_idx = 1:n

            %skip if the kernel would go out of bounds
            if t_idx + kernel_len - 1 > n
                continue;
            end

            %create spike at time t_idx
            temp_spike = zeros(1, n);
            temp_spike(t_idx) = 1;

            %compute fluorescence caused by this single spike
            temp_fluo = conv(temp_spike, kernel, 'full');

            %keep only first n samples (causal system assumption)
            temp_fluo = temp_fluo(1:n);

            %subtract candidate fluorescence from residual
            new_residual = residual - temp_fluo;

            %compute squared error before and after adding spike
            error_before = sum(residual.^2);
            error_after = sum(new_residual.^2);

            %if adding spike improves fit (reduces error), keep it
            if error_after < error_before
                inferred_spikes(t_idx) = 1;
                residual = new_residual;
            end

        end
    end
end
