%% violin plots for burst patterns - Fig. 5A-D
onset_start = 437; %approximate frame that ICMS started for first train +3*ceil(45/frate)
onset_stop = onset_start + ceil(3/frate);
s20 = floor(onset_start+20/frate); %20 s into ICMS train
offset_start = 1324;  %approximate frame ICMS ended for first train
offset_stop = floor(offset_start+3/frate); %3 s after end of train his was set to 2 at some point for some reason, should make sure it is 3 for the figures or update text

%% plot for last 10 s 5 C,D
%PV 20 uA
cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz Burst 20 uA', '20 Hz Burst 20 uA', ' TBS 20 uA'}; %different ICMS trains used 
[pairwise_stats_PV_burst_20uA_last, anova_stats_PV_burst_20uA_last] = plot_ICMS_violin(trains_curr, PV_all_data_split, train_types, cell_types, s20, offset_stop)

%SOM 20 uA
cell_types = {'non-SOM','SOM'};
[pairwise_stats_SOM_burst_20uA_last, anova_stats_SOM_burst_20uA_last] = plot_ICMS_violin(trains_curr, SOM_all_data_split, train_types, cell_types, s20, offset_stop)

%% plot for first 3 s 5 A,B
%PV 20 uA
cell_types = {'non-PV','PV'};
trains_curr = {'10 Hz Burst 20 uA', '20 Hz Burst 20 uA', ' TBS 20 uA'}; %different ICMS trains used 
[pairwise_stats_PV_burst_20uA_first, anova_stats_PV_burst_20uA_first] = plot_ICMS_violin(trains_curr, PV_all_data_split, train_types, cell_types, onset_start, onset_stop)

%SOM 20 uA
cell_types = {'non-SOM','SOM'};
[pairwise_stats_SOM_burst_20uA_first, anova_stats_SOM_burst_20uA_first] = plot_ICMS_violin(trains_curr, SOM_all_data_split, train_types, cell_types, onset_start, onset_stop)
