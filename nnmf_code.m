%code to perform non-negative matrix factorization for removal of non-stim
%components
function [fixed_data] = nnmf_code(input_data, stim_vectors_1, stim_vectors_2, train_type, onset_start)

%% Ensure data is non-negative
neural_data_filled = fillmissing(input_data, 'previous',1);
nan_idx = isnan(neural_data_filled(1,:));
neural_data_clean = neural_data_filled(:,~nan_idx);
%neural_data_filled= max(0, neural_data_filled);  % Force non-negativity if needed
neural_data_clean = neural_data_clean - min(min(neural_data_clean));

%% this first bit is to look at the number of components impacts
%reconstruction error, from analysis we found 3-4 tends to work best
% max_k = 20; 
% recon_errors = zeros(1, max_k);
% 
% for k = 1:max_k
%     [~, H, err] = nnmf(neural_data_clean', k, 'replicates', 3, 'options', statset('MaxIter', 1000));
%     recon_errors(k) = err;  % final residual norm
% end
% 
% figure;
% plot(1:max_k, recon_errors, '-o');
% xlabel('Number of Components (k)');
% ylabel('Reconstruction Error');
% title('NMF Reconstruction Error Curve');

%% here we use 3 components if the ICMS vector is constant or 2 if it chanes
%throughout
if all(stim_vectors_1 == stim_vectors_2)
    nComponents = 3;%input('select the number of components');
else
    nComponents = 4;
end
nComponents = 4;

%this is the manual check, if yes it will separate out noise, otherwise it
%will not make any adjustments
figure
plot(nanmean(neural_data_clean,2))
title(train_type)
user_input = input('is there sensory noise (1 for yes, 0 for no)');
close all

% Apply NMF using MATLAB's built-in function
if ~all(all(isnan(neural_data_clean))) && logical(user_input)

    %Step 1: Seed H0 with known stimulus pattern for one component
    H0 = rand(nComponents, size(neural_data_clean, 1));  % Initialize randoml

    if all(stim_vectors_1 == stim_vectors_2)
        H0(1, :) = stim_vectors_1;  % Seed first component with stimulus shape
    else
        H0(1, :) = stim_vectors_1;  % Seed first component with stimulus shape
        H0(2, :) = stim_vectors_2;  % Seed first component with stimulus shape
    end

    [W, H] = nnmf(neural_data_clean', nComponents, 'replicates', 10, 'options', statset('MaxIter', 1000), 'H0', H0);

    % W: neurons × components
    % H: components × time

    % Plot temporal components (H)
    figure
    for i = 1:nComponents
        subplot(nComponents,1,i);
        plot(H(i,:));
        hold on
        plot(stim_vectors_1*max(max(H(i,:))), '--')
        title(['NMF Component ', num2str(i), ' Corr: ', num2str(corr(H(i,:)', stim_vectors_2', 'rows', 'complete'))]);
        xlabel('Time');
        ylabel('Activity');
    end
    %the user will type in which components look to be stimulation evoked
    %by typing in the number of the plot
    selected_factors = input('Choose the best ones');

    %% do reconstruction and adjust for baseline trends
    %Initialize reconstruction
    X_reconstructed = zeros(size(neural_data_clean));

    %reconstruct the signal with only the stim components
    for curr_fac = 1:length(selected_factors)
         X_reconstructed = X_reconstructed + (W(:, selected_factors(curr_fac)) * H(selected_factors(curr_fac), :))';
    end

    % Subtract baseline (pre-stim onset)
    X_reconstructed = X_reconstructed - nanmean(X_reconstructed(1:onset_start, :));

    % Get logical index of non-stimulation timepoints
    nonstim_idx = stim_vectors_1 == 0;

    %don't want to use the pre-stim or post-stim period per se
    nonstim_idx(5296:end) = 0;

    % Compute the average trace across all neurons
    avg_trace = mean(X_reconstructed, 2);  % [time x 1]

    % Fit a linear trend to the non-stim points in the average trace
    t = (1:length(avg_trace))';  % Time vector
    p = polyfit(t(nonstim_idx'), avg_trace(nonstim_idx), 1);  % Linear fit

    % Evaluate the fitted baseline over all timepoints
    baseline_trend = polyval(p, t);

    % Subtract the trend from all neurons' signals
    X_detrended = X_reconstructed - baseline_trend;

    figure
    plot(nanmean(X_detrended,2))
    hold on
    plot(nanmean(input_data,2), '--')
    title(train_type)

    %after seeing the reconstructed signal give the user the opportunity to
    %reject
    accept = input('accept changes? (1 for yes, 0 for no)');
    close all

    if logical(accept)
        input_data(:,~nan_idx) = X_detrended;
    end
end
fixed_data = input_data;



            