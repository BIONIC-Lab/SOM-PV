%% plots for change index and preference pies across all frequencies and bursts - Fig. 4H,I, Supp. Fig. 2A-F, Supp Fig. 3A

%% first trial
offset_start = 1324;  %approximate frame ICMS ended for first train +3*ceil(45/frate)
offset_stop = floor(offset_start+3/frate); %3 s after end of train

%for change index
onset_start = 437; %approximate frame that ICMS started for first train
onset_stop = ceil((offset_start-onset_start)/2+onset_start);
second_range_start = onset_stop+1;
second_range_stop = offset_start;

s20 = floor(onset_start+20/frate); %20 s into ICMS train

%PV 20 uA
cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz 20 uA', '20 Hz 20 uA', '40 Hz 20 uA', '100 Hz 20 uA', '200 Hz 20 uA', '10 Hz Burst 20 uA', '20 Hz Burst 20 uA', ' TBS 20 uA'}; %different ICMS trains used 
plot_pref_pies(trains_curr, PV_all_data_split, train_types, cell_types, s20, offset_stop)
[change_indices_PV, pairwise_stats_PV_freq_20uA_adapt, anova_stats_PV_freq_20uA_adapt] = plot_change_index_bar(trains_curr, PV_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);

%SOM 20 uA
cell_types = {'non-SOM','SOM'};
plot_pref_pies(trains_curr, SOM_all_data_split, train_types, cell_types, s20, offset_stop)
[change_indices_SOM, pairwise_stats_SOM_freq_20uA_adapt, anova_stats_SOM_freq_20uA_adapt] = plot_change_index_bar(trains_curr, SOM_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
                              
%% last trial
offset_start = 1324+3*ceil(45/frate);  %approximate frame ICMS ended for first train +3*ceil(45/frate)
offset_stop = floor(offset_start+3/frate); %3 s after end of train

%for change index
onset_start = 437+3*ceil(45/frate); %approximate frame that ICMS started for first train
onset_stop = ceil((offset_start-onset_start)/2+onset_start);
second_range_start = onset_stop+1;
second_range_stop = offset_start;

s20 = floor(onset_start+20/frate); %20 s into ICMS train

%PV 20 uA
cell_types = {'non-PV','PV'};
plot_pref_pies(trains_curr, PV_all_data_split, train_types, cell_types, s20, offset_stop)
[change_indices_PV, pairwise_stats_PV_freq_20uA_adapt, anova_stats_PV_freq_20uA_adapt] = plot_change_index_bar(trains_curr, PV_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
%SOM 20 uA
cell_types = {'non-SOM','SOM'};
plot_pref_pies(trains_curr, SOM_all_data_split, train_types, cell_types, s20, offset_stop)
[change_indices_SOM, pairwise_stats_SOM_freq_20uA_adapt, anova_stats_SOM_freq_20uA_adapt] = plot_change_index_bar(trains_curr, SOM_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
                              
%% 10 uA first trial
offset_start = 1324;  %approximate frame ICMS ended for first train +3*ceil(45/frate)
offset_stop = floor(offset_start+3/frate); %3 s after end of train

%for change index
onset_start = 437; %approximate frame that ICMS started for first train
onset_stop = ceil((offset_start-onset_start)/2+onset_start);
second_range_start = onset_stop+1;
second_range_stop = offset_start;

s20 = floor(onset_start+20/frate); %20 s into ICMS train

cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz 10 uA', '20 Hz 10 uA', '40 Hz 10 uA', '100 Hz 10 uA', '200 Hz 10 uA', '10 Hz Burst 10 uA', '20 Hz Burst 10 uA', 'TBS 10 uA'}; %different ICMS trains used 
[change_indices_PV, pairwise_stats_PV_freq_20uA_adapt, anova_stats_PV_freq_20uA_adapt] = plot_change_index_bar(trains_curr, PV_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
cell_types = {'non-SOM','SOM'};
[change_indices_SOM, pairwise_stats_SOM_freq_20uA_adapt, anova_stats_SOM_freq_20uA_adapt] = plot_change_index_bar(trains_curr, SOM_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
                              
 %% 10 uA last trial
offset_start = 1324+3*ceil(45/frate);  %approximate frame ICMS ended for first train +3*ceil(45/frate)
offset_stop = floor(offset_start+3/frate); %3 s after end of train

%for change index
onset_start = 437+3*ceil(45/frate); %approximate frame that ICMS started for first train
onset_stop = ceil((offset_start-onset_start)/2+onset_start);
second_range_start = onset_stop+1;
second_range_stop = offset_start;

s20 = floor(onset_start+20/frate); %20 s into ICMS train


cell_types = {'non-PV','PV'};
[change_indices_PV, pairwise_stats_PV_freq_20uA_adapt, anova_stats_PV_freq_20uA_adapt] = plot_change_index_bar(trains_curr, PV_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);
cell_types = {'non-SOM','SOM'};
[change_indices_SOM, pairwise_stats_SOM_freq_20uA_adapt, anova_stats_SOM_freq_20uA_adapt] = plot_change_index_bar(trains_curr, SOM_all_data_split, train_types, cell_types, ...
                                  onset_start, onset_stop, second_range_start, second_range_stop);