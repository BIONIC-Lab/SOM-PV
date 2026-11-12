%% plots for mean intensity violin plots and preference bars for frequencies first 3 s - Fig 1C,D,E Supp Fig. 1 A,B
%% 20 uA frequency first 3s
%depends on plot_ICMS_violin, plot_pref_bars, and plot_combined_pref_bars
frate = 0.034;
onset_start = 437; %approximate frame that ICMS started for first train
onset_stop = floor(onset_start+3/frate); %first 3 s of ICMS

%PV 20 uA
cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz 20 uA', '20 Hz 20 uA', '40 Hz 20 uA', '100 Hz 20 uA', '200 Hz 20 uA'}; %different ICMS trains used 
[pairwise_stats_PV_freq_20uA, anova_stats_PV_freq_20uA] = plot_ICMS_violin(trains_curr, PV_all_data_split, train_types, cell_types, onset_start, onset_stop);
plot_pref_bars(trains_curr, PV_all_data_split, train_types, cell_types, onset_start, onset_stop)

%SOM 20 uA
cell_types = {'non-SOM','SOM'};
trains_curr = {'10 Hz 20 uA', '20 Hz 20 uA', '40 Hz 20 uA', '100 Hz 20 uA', '200 Hz 20 uA'}; %different ICMS trains used 
[pairwise_stats_SOM_freq_20uA, anova_stats_SOM_freq_20uA] = plot_ICMS_violin(trains_curr, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop);
plot_pref_bars(trains_curr, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop)

cell_types = {'non-PV','PV', 'non-SOM','SOM'};
plot_combined_pref_bars(trains_curr, PV_all_data_split, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop)

%% 10 uA frequency first 3s

% PV 10 uA
cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz 10 uA', '20 Hz 10 uA', '40 Hz 10 uA', '100 Hz 10 uA', '200 Hz 10 uA'}; %different ICMS trains used 
anova_stats_PV_freq_10uA = plot_ICMS_line(trains_curr, PV_all_data_split, train_types, cell_types, onset_start, onset_stop);
plot_pref_bars(trains_curr, PV_all_data_split, train_types, cell_types, onset_start, onset_stop)

%SOM 10 uA
cell_types = {'non-SOM','SOM'};
trains_curr = {'10 Hz 10 uA', '20 Hz 10 uA', '40 Hz 10 uA', '100 Hz 10 uA', '200 Hz 10 uA'}; %different ICMS trains used 
anova_stats_SOM_freq_10uA = plot_ICMS_line(trains_curr, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop);
plot_pref_bars(trains_curr, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop)

cell_types = {'non-PV','PV', 'non-SOM','SOM'};
plot_combined_pref_bars(trains_curr, PV_all_data_split, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop)
