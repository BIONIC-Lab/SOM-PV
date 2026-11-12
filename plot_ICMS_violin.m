function [pairwise_stats, anova_stats] = plot_ICMS_violin(trains_curr, all_data_split, train_types, cell_types, onset_start, onset_stop)
    %analyze and plot mean intensity violin plots for ICMS responses
    frate = 0.034; % frame rate
    num_cells = length(cell_types);
    num_trains = length(trains_curr);
    num_animals = size(all_data_split, 2);

    mean_3s = cell(1, num_cells);
    std_3s = cell(1, num_cells);
    mean_3s_split = cell(num_cells, num_animals);

    %loop over cell types and stimulation trains
    for curr_cell = 1:num_cells
        for curr_train = 1:num_trains
            curr_idx = find(strcmp(trains_curr{curr_train}, train_types));
            temp = [];
            temp2 = [];
            temp3 = [];
            for curr_animal = 1:num_animals
                curr_data = all_data_split{curr_idx, curr_animal, curr_cell};
                comp_data = [all_data_split{curr_idx, curr_animal, 1}; all_data_split{curr_idx, curr_animal, 2}];
                if isempty(curr_data)
                    continue;
                end
                for trial = 1 %can change if we want to do more than first trial
                    mean_vals = nanmean(curr_data(:, onset_start+(trial-1)*ceil(45/frate):onset_stop+(trial-1)*ceil(45/frate)), 2)';
                    mean_val_stats = nanmean(curr_data(:, onset_start+(trial-1)*ceil(45/frate):onset_stop+(trial-1)*ceil(45/frate)), 2)'-nanmean(nanmean(comp_data(:, onset_start+(trial-1)*ceil(45/frate):onset_stop+(trial-1)*ceil(45/frate)), 2));
                end
                std_vals = nanstd(curr_data(:, 1:onset_start-1), [], 2)';

                temp = [temp, mean_vals];
                temp2 = [temp2, std_vals];
                temp3 = [temp3, mean_val_stats];
                mean_3s_split{curr_cell, curr_animal}(curr_train, :) = nanmean(curr_data(:, onset_start:onset_stop), 2);
            end
            mean_3s{curr_cell}(curr_train, :) = temp;
            std_3s{curr_cell}(curr_train, :) = temp2;
            mean_3s_stats{curr_cell}(curr_train, :) = temp3;
        end
    end

    max_cols = max(size(mean_3s_stats{1}, 2), size(mean_3s_stats{2}, 2));
    padded_1 = [mean_3s{1}, NaN(size(mean_3s{1},1), max_cols - size(mean_3s{1},2))];
    padded_2 = [mean_3s{2}, NaN(size(mean_3s{2},1), max_cols - size(mean_3s{2},2))];
    mean_3s_comb = NaN(max_cols, 2 * size(mean_3s{1}, 1));
    mean_3s_comb(:, 1:2:end) = padded_1';
    mean_3s_comb(:, 2:2:end) = padded_2';

    x_label = cell(1, 2 * num_trains);
    for i = 1:num_trains
        x_label{2*i - 1} = [trains_curr{i}, ' ', cell_types{1}];
        x_label{2*i}     = [trains_curr{i}, ' ', cell_types{2}];
    end
    
    figure
    violin(mean_3s_comb);
    ax = gca;
    ax.XTick = 1:length(x_label);
    ax.XTickLabel = x_label;
    ylabel('Mean intensities first 3 s');
    title('Mean intensity response to different ICMS freqs');
    yline(0);
    xtickangle(45);

    %stats
    pairwise_stats = cell(1, num_trains);
    anova_stats = struct();  % Initialize as a structure

    %pairwise comparisons (non-PV vs PV, non-SOM vs SOM)
    sig_stars = cell(1, num_trains * 2); % To store significance markers
    hold on;
    for curr_train = 1:num_trains
        % Compare non-PV vs PV for each train type
        [p, h] = ranksum(mean_3s{1}(curr_train, :), mean_3s{2}(curr_train, :)); % non-PV vs PV
        if p < 0.001
            sig_stars{curr_train * 2 - 1} = '***';
        elseif p < 0.01
            sig_stars{curr_train * 2 - 1} = '**';
        elseif p < 0.05
            sig_stars{curr_train * 2 - 1} = '*';
        else
            sig_stars{curr_train * 2 - 1} = '';
        end
        pairwise_stats{curr_train}.p_value = p;
        pairwise_stats{curr_train}.test_stat = h;
        pairwise_stats{curr_train}.significance = sig_stars{curr_train * 2 - 1};
    end

    %ANOVA across all groups
    all_data = [];
    for curr_train = 1:num_trains
        for curr_cell = 1:num_cells
            all_data = [all_data, mean_3s{curr_cell}(curr_train, :)'];
        end
    end
    [p_all, tbl, stats] = anova1(all_data, [], 'off');
    
    if p_all < 0.001
        sig_stars_2 = '***';
    elseif p_all < 0.01
        sig_stars_2 = '**';
    elseif p_all < 0.05
        sig_stars_2 = '*';
    else
        sig_stars_2 = '';
    end
    anova_stats.p_value = p_all;
    anova_stats.anova_table = tbl;
    anova_stats.anova_stats = stats;
    anova_stats.significance = sig_stars_2;

    %display significance markers on the plot
    for i = 1:length(sig_stars)
        if ~isempty(sig_stars{i})
            text(i, max(mean_3s_comb(:)) + 0.05, sig_stars{i}, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
        end
    end
    
    %for the ANOVA significance, place the marker at a suitable location on the plot
    text(5, max(mean_3s_comb(:)) + 0.5, sig_stars_2, 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end