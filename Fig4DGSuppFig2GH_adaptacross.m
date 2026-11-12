%% adaptation across trials - Fig. 4D-G, Supp Fig. 2G-H

trains_curr = {'20 Hz 20 uA', '40 Hz 20 uA',  '20 Hz Burst 20 uA', ' TBS 20 uA' }; 

% Combine SOM and PV data (columns 1–2 only)
all_data = cat(2, SOM_all_data(:,1:2), PV_all_data(:,1:2));

[p_adapt_fig4dg, stats_fig4dg] = adapt_over_trial(all_data, trains_curr, train_types);

trains_curr = {'10 Hz 20 uA', '100 Hz 20 uA', '200 Hz 20 uA', '10 Hz Burst 20 uA'}; 
[p_adapt_suppfig2g, stats_suppfig2g] = adapt_over_trial(all_data, trains_curr, train_types);

trains_curr = {'10 Hz 10 uA', '20 Hz 10 uA', '40 Hz 10 uA', '100 Hz 10 uA', '200 Hz 10 uA', '10 Hz Burst 10 uA', '20 Hz Burst 10 uA', 'TBS 10 uA' }; 
[p_adapt_suppfig2h, stats_suppfig2h] = adapt_over_trial(all_data, trains_curr, train_types);

function [p_adapt, stats] = adapt_over_trial(all_data, trains_curr, train_types)

    frate = 0.034;
    onset_start = 437; %approximate frame that ICMS started for first train +3*ceil(45/frate)
    s20 = floor(onset_start+20/frate); %20 s into ICMS train
    offset_start = 1324;  %approximate frame ICMS ended for first train
    offset_stop = floor(offset_start+3/frate); %3 s after end of train was 2 at another point

    % Trial time ranges
    trial_1_range = s20:offset_start;
    trial_4_range = s20+ceil(135/frate):offset_start+ceil(135/frate);

    % Cell type labels
    cell_labels = {'non-SOM','SOM','non-PV', 'PV'};

    % Get distinct colors for all trains
    num_trains = length(trains_curr);
    colors = turbo(num_trains);

    % Initialize figure handles
    for c = 1:4
        figure_handles(c) = figure('Name', cell_labels{c});
        hold on
        title(['Trial 1 vs 4 - ', cell_labels{c}])
        xlabel('Trial')
        ylabel('Mean dF/F0')
        xticks([1 2])
        xlim([0.5 2.5])
        ylim([0 1.5])
        xticklabels({'Trial 1', 'Trial 4'})
    end

    % Initialize storage for stats
    trial1_data = cell(4, num_trains);  % cell_type x train
    trial4_data = cell(4, num_trains);

    % Loop over each train
    for t = 1:num_trains
        train_type_idx = find(strcmp(trains_curr{t}, train_types));

        for curr_cell = 1:4
            curr_resp = all_data{train_type_idx, curr_cell};
            if isempty(curr_resp)
                continue
            end

            % Compute per-trial mean response for each neuron
            trial1_vals = abs(nanmean(curr_resp(:, trial_1_range), 2));
            trial4_vals = abs(nanmean(curr_resp(:, trial_4_range), 2));

            [p_adapt(curr_cell,t),tbl,stats] = anova1([trial1_vals, trial4_vals]);

            % Store for stats
            trial1_data{curr_cell, t} = trial1_vals;
            trial4_data{curr_cell, t} = trial4_vals;

            % Compute mean and SEM
            mean_response = [nanmean(trial1_vals), nanmean(trial4_vals)];
            sem_response = [
                nanstd(trial1_vals) / sqrt(sum(~isnan(trial1_vals))), ...
                nanstd(trial4_vals) / sqrt(sum(~isnan(trial4_vals)))
            ];

            % Plot
            figure(figure_handles(curr_cell));
            errorbar(1:2, mean_response, sem_response, '-o', ...
                'DisplayName', strtrim(trains_curr{t}), ...
                'Color', colors(t,:), ...
                'LineWidth', 1.5, ...
                'CapSize', 8, ...
                'MarkerSize', 6);

            %should maybe put some stats in here
        end
    end

    % Add legends
    for c = 1:4
        figure(figure_handles(c));
        legend('Location', 'best');
    end
end