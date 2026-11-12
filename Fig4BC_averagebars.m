%% Bar averages - Fig. 4B,C
%NEXT WE SHOULD ADD IN ADAPTATION ACROSS TRIALS
%INSTEAD OF USING LAST 10S, MAYBE SHOULD DO SOMETHING THAT ALIGNS MORE WITH
%WHAT WE DID IN THE BIOMIMETIC PAPER
onset_start = 437; %approximate frame that ICMS started for first train +3*ceil(45/frate)
s20 = floor(onset_start+20/frate); %20 s into ICMS train
offset_start = 1324;  %approximate frame ICMS ended for first train
offset_stop = floor(offset_start+3/frate); %3 s after end of train

%plot first trial Figure 4B
cell_types = {'non-PV','PV', 'non-SOM', 'SOM'};
trains_curr = {'10 Hz 20 uA', '20 Hz 20 uA', '40 Hz 20 uA', '100 Hz 20 uA', '200 Hz 20 uA', '10 Hz Burst 20 uA', '20 Hz Burst 20 uA', ' TBS 20 uA'}; %different ICMS trains used 
[pairwise_stats_all, anova_stats_all] = plot_ICMS_bar(trains_curr, PV_all_data_split, SOM_all_data_split, train_types, cell_types, s20, offset_start, 1);

%plot trials 2-4 Figure 4C
[pairwise_stats_all, anova_stats_all] = plot_ICMS_bar(trains_curr, PV_all_data_split, SOM_all_data_split, train_types, cell_types, s20, offset_start, [2:4]);
