%%  bar plots comparing 10 HzB vs 20 HzB intensity - Fig. 5 E,F
%10 Hz B vs 20 Hz B combined
%depends on plot_combined_mean_activation_bars
trains_curr = {'10 Hz Burst 20 uA', '20 Hz Burst 20 uA'}; %different ICMS trains used 
cell_types = {'non-PV','PV', 'non-SOM','SOM'};
plot_combined_mean_activation_bars(trains_curr, PV_all_data_split, SOM_all_data_split, train_types, cell_types, onset_start, offset_stop)

