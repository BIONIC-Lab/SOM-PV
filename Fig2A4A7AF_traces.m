%% Neuron traces - Figs 2A, 4A, 7A,F
%depends on two functions: spline_fit and 
%can also plot average across trials - changed fitting to not include fits
%right now to double check, might be introducing some weird stuff
frate = 0.034; %frame rate
x_label = [1:7200]*frate; %time axis
onset_start = 437; %approximate frame that ICMS started for first train
offset_start = 1324;  %approximate frame ICMS ended for first train 
%train types should load in when you load data

%plot PV
spline_params = [0.02, 0.02, 0.09, 0.09, 0.05, 0.05, 0.02, 0.02, ...
    0.09, 0.09, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, ...
    0.05, 0.05, 0.05, 0.02];
plot_traces(PV_all_data, spline_params, train_types, frate, stim_vectors_1, 1)

%plot SOM
%plot_traces(SOM_all_data, spline_params, train_types, frate, stim_vectors_1, 0)


function plot_traces(all_data,spline_params, train_types, frate, stim_vectors_1, deconv)
    for curr_train = 1:22
        figure
        clear avg_across_trials avg_across_trials_inh pos_mod_neurons neg_mod_neurons pos_mod_neurons_inh neg_mod_neurons_inh
        % Define baseline period (this depends on your data structure and experiment)
        baseline_period_start = 1; % Adjust this according to your data
        baseline_period_end = ceil(10/frate); % Adjust to match your baseline duration

        % Initialize variables to store averages for positive and negative modulation
        avg_pos_mod = [];
        avg_neg_mod = [];
        avg_pos_mod_inh = [];
        avg_neg_mod_inh = [];
        neg_mod_sum = 0;
        neg_mod_sum_inh = 0;

        for curr_trial = 1:4 %average across trials
            % Extract the response for excitatory neurons
            curr_resp = all_data{curr_train,1}(:,ceil(5/frate)+(curr_trial-1)*ceil(45/frate):(curr_trial)*ceil(45/frate)+ceil(10/frate));
            avg_across_trials_1(curr_trial,:) = nanmean(curr_resp,1);

            % Extract the baseline response (using baseline period from start to baseline_period_end)
            baseline = nanmean(curr_resp(:,baseline_period_start:baseline_period_end), 2); % per neuron
            baseline_std = nanstd(curr_resp(:,baseline_period_start:baseline_period_end), [], 2);  % per neuron
            
            % Repeat the same for inhibitory neurons
            curr_resp_inh = all_data{curr_train,2}(:,ceil(5/frate)+(curr_trial-1)*ceil(45/frate):(curr_trial)*ceil(45/frate)+ceil(10/frate));
            avg_across_trials_inh_1(curr_trial,:) = nanmean(curr_resp_inh, 1);

            % Extract the baseline response for inhibitory neurons
            baseline_inh = nanmean(curr_resp_inh(:,baseline_period_start:baseline_period_end), 2);  % per neuron
            baseline_std_inh = nanstd(curr_resp_inh(:,baseline_period_start:baseline_period_end), [], 2);  % per neuron

        end
        mean_exc1 = nanmean(avg_across_trials_1,1);
        [~, smoothed_response]  = spline_fit(mean_exc1, frate, spline_params(curr_train));

        %plot excitatory response - smoothed and normal
        plot([1:1472]*frate, smoothed_response, 'Color', [0 1 0 1],'LineWidth',2)
        hold on
        plot([1:1472]*frate, mean_exc1,'Color', [0 1 0 1],'LineWidth',2)

        %plot inhibitory response - smoothed and normal
        mean_inh1 = nanmean(avg_across_trials_inh_1,1);
        [~, smoothed_response_inh]  = spline_fit(mean_inh1,frate, spline_params(curr_train));
        plot([1:1472]*frate, smoothed_response_inh ,'Color', [0 0 1 1],'LineWidth',2)
        plot([1:1472]*frate, mean_inh1,'Color', [0 0 1 1],'LineWidth',2)

        yline(0, '--', 'LineWidth', 2)
        xline(10,'--','LineWidth',2)
        xline(40,'--','LineWidth',2)
        legend('non-PV','PV')
        title(train_types{curr_train})
        xlabel('Time (s)')
        ylabel('dF/F0')
        ylim([-0.55 1.25])

        if deconv
            stim_vectors_curr = stim_vectors_1(1,ceil(5/frate)+(curr_trial-1)*ceil(45/frate):(curr_trial)*ceil(45/frate)+ceil(10/frate));
            %also plot deconvolution
            stim_deconvolution(nanmean(avg_across_trials_1,1),stim_vectors_curr)
            stim_deconvolution(nanmean(avg_across_trials_inh_1,1),stim_vectors_curr)
        end
    end
end