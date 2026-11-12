function plot_pref_bars(trains_curr, all_data_split, train_types, cell_types, onset_start, onset_stop)
% plot_pref_bars - For each cell type, plot bar charts showing distribution
% of neurons' maximal activation across different ICMS trains.
    frate = 0.034; % frame rate
    num_cells = length(cell_types);
    num_trains = length(trains_curr);
    num_animals = size(all_data_split, 2);

    figure
    for curr_cell = 1:num_cells
        cell_responses = [];

        for curr_train = 1:num_trains
            curr_idx = find(strcmp(trains_curr{curr_train}, train_types));
            train_data = [];

            for curr_animal = 1:num_animals
                curr_data = all_data_split{curr_idx, curr_animal, curr_cell};
                if isempty(curr_data)
                    continue;
                end

                for curr_trial = 1
                    mean_vals = nanmean(curr_data(:, onset_start+(curr_trial-1)*ceil(45/frate):onset_stop+(curr_trial-1)*ceil(45/frate)), 2);
                    train_data = [train_data, mean_vals'];
                end
            end

            cell_responses(curr_train, :) = train_data;
        end

        cell_responses = cell_responses(:, all(~isnan(cell_responses), 1));

        %determine max-activation train for each neuron - "preference"
        [~, max_train_idx] = max(cell_responses, [], 1);

        %count how many neurons had their max response for each train
        counts = histcounts(max_train_idx, 0.5:1:(num_trains+0.5));

        %create bar plot for this cell type
        subplot(1, num_cells, curr_cell);
        bar(counts, 'FaceColor', [0.2 0.6 0.8]);
        set(gca, 'XTick', 1:num_trains, 'XTickLabel', trains_curr);
        xtickangle(45);
        ylabel('Number of Neurons');
        title(sprintf('Max activation distribution (%s)', cell_types{curr_cell}));
    end
end
