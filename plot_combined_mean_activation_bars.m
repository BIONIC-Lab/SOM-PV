function plot_combined_mean_activation_bars(trains_curr, all_data_split1, all_data_split2, train_types, cell_types, onset_start, onset_stop)
    frate = 0.034; 
    num_trains = length(trains_curr);
    num_cell_types = length(cell_types);

    all_data_combined = cat(3,all_data_split1(:,:,1:2), all_data_split2(:,:,1:2));
    num_animals_total = size(all_data_combined, 2);
    mean_activations = zeros(num_trains, num_cell_types);
    sem_activations = zeros(num_trains, num_cell_types);
    raw_data = cell(num_trains, num_cell_types);

    for cell_idx = 1:num_cell_types
        for train_idx = 1:num_trains
            train_label = trains_curr{train_idx};
            train_type_idx = find(strcmp(train_label, train_types));

            activation_vals = [];
            for animal_idx = 1:num_animals_total
                curr_data = all_data_combined{train_type_idx, animal_idx, cell_idx};
                if isempty(curr_data)
                    continue;
                end
                %average over frames in the window for each neuron
                mean_vals = nanmean(curr_data(:, onset_start:onset_stop), 2);
                activation_vals = [activation_vals; mean_vals];
            end

            %store for stats
            raw_data{train_idx, cell_idx} = activation_vals;

            %compute mean and SEM across neurons
            mean_activations(train_idx, cell_idx) = nanmean(activation_vals);
            sem_activations(train_idx, cell_idx) = nanstd(activation_vals) / sqrt(sum(~isnan(activation_vals)));
        end
    end

    %% --- PLOT 1: Combined Across All Cell Types ---
    figure; hold on;

    % Combine mean and SEM across cell types
    combined_mean = nanmean(mean_activations, 2);
    combined_sem = nanstd(mean_activations, 0, 2) / sqrt(num_cell_types);

    bar(combined_mean);
    errorbar(1:num_trains, combined_mean, combined_sem, 'k.', 'LineWidth', 1);

    xticks(1:num_trains);
    xticklabels(trains_curr);
    xtickangle(45);
    ylabel('Mean Activation');
    title('Mean Activation by Train Type (All Cell Types Combined)');

    % --- Stats for Plot 1 ---
    data_1 = [];
    data_2 = [];
    if num_trains == 2
        for cell_idx = 1:num_cell_types
            data_1 = [data_1; raw_data{1, cell_idx}];
            data_2 = [data_2; raw_data{2, cell_idx}];
        end
        [~, p_combined] = ttest2(data_1, data_2);

        % Add annotation
        y_max = max([combined_mean + combined_sem]) * 1.1;
        line([1, 2], [y_max, y_max], 'Color', 'k');
        text(1.5, y_max * 1.05, p_to_asterisk(p_combined), 'HorizontalAlignment', 'center');
    end

    hold off;

    %% --- PLOT 2: Grouped by Cell Type (CellType1_10Hz, CellType1_20Hz, ...) ---
    figure; hold on;

    % Rearrange data: each bar is (cell type, train)
    data_reordered = reshape(mean_activations, 1, []);
    sems_reordered = reshape(sem_activations, 1, []);

    % Create group and position info
    bar_labels = {};
    for cell_idx = 1:num_cell_types
        for train_idx = 1:num_trains
            bar_labels{end+1} = sprintf('%s - %s', cell_types{cell_idx}, trains_curr{train_idx});
        end
    end

    bar(data_reordered);
    errorbar(1:length(data_reordered), data_reordered, sems_reordered, 'k.', 'LineWidth', 1);

    xticks(1:length(data_reordered));
    xticklabels(bar_labels);
    xtickangle(45);
    ylabel('Mean Activation');
    title('Mean Activation by Cell Type and Train Type');

    % --- Stats: 10Hz vs 20Hz within each cell type ---
    for cell_idx = 1:num_cell_types
        d1 = raw_data{1, cell_idx};
        d2 = raw_data{2, cell_idx};
        [~, p_cell] = ttest2(d1, d2);

        idx1 = (cell_idx - 1) * num_trains + 1;
        idx2 = idx1 + 1;

        y1 = data_reordered(idx1) + sems_reordered(idx1);
        y2 = data_reordered(idx2) + sems_reordered(idx2);
        y_max = max([y1, y2]) * 1.1;

        line([idx1, idx2], [y_max, y_max], 'Color', 'k');
        text(mean([idx1, idx2]), y_max * 1.05, p_to_asterisk(p_cell), 'HorizontalAlignment', 'center');
    end

    % --- Additional Stats: PV vs non-PV and SOM vs non-SOM ---
    % Assuming non-PV = 1, PV = 2 | non-SOM = 3, SOM = 4
    if num_cell_types >= 4
        label_shift = 0.3;  % offset for drawing lines

        for train_idx = 1:num_trains
            % PV vs non-PV
            pv_data = raw_data{train_idx, 2};
            nonpv_data = raw_data{train_idx, 1};
            [~, p_pv] = ttest2(pv_data, nonpv_data);

            idx1 = (0) * num_trains + train_idx;  % non-PV
            idx2 = (1) * num_trains + train_idx;  % PV

            y1 = data_reordered(idx1) + sems_reordered(idx1);
            y2 = data_reordered(idx2) + sems_reordered(idx2);
            y_max = max([y1, y2]) * 1.2;

            line([idx1, idx2], [y_max, y_max], 'Color', 'b');
            text(mean([idx1, idx2]), y_max * 1.05, ['PV: ' p_to_asterisk(p_pv)], ...
                'Color', 'b', 'HorizontalAlignment', 'center');

            % SOM vs non-SOM
            som_data = raw_data{train_idx, 4};
            nonsom_data = raw_data{train_idx, 3};
            [~, p_som] = ttest2(som_data, nonsom_data);

            idx1 = (2) * num_trains + train_idx;  % non-SOM
            idx2 = (3) * num_trains + train_idx;  % SOM

            y1 = data_reordered(idx1) + sems_reordered(idx1);
            y2 = data_reordered(idx2) + sems_reordered(idx2);
            y_max = max([y1, y2]) * 1.2;

            line([idx1, idx2], [y_max, y_max], 'Color', 'r');
            text(mean([idx1, idx2]), y_max * 1.05, ['SOM: ' p_to_asterisk(p_som)], ...
                'Color', 'r', 'HorizontalAlignment', 'center');
        end
    end

    hold off;
end

%% Helper function: convert p-value to asterisk notation
function out = p_to_asterisk(p)
    if p < 0.001
        out = '***';
    elseif p < 0.01
        out = '**';
    elseif p < 0.05
        out = '*';
    else
        out = 'n.s.';
    end
end
