%code for loading in and organizing data
frate = 0.034; %frame rate
x_label = [1:7200]*frate; %time axis
onset_start = 437; %approximate frame that ICMS started for first train
offset_start = 1324;  %approximate frame ICMS ended for first train 
train_types = {'10 Hz 10 uA', '10 Hz 20 uA', '10 Hz Burst 10 uA', '10 Hz Burst 20 uA',...
    '100 Hz 10 uA', '100 Hz 20 uA', '20 Hz 10 uA', '20 Hz 20 uA', ...
    '20 Hz Burst 10 uA', '20 Hz Burst 20 uA', '200 Hz 10 uA', '200 Hz 20 uA',  ...
    '40 Hz 10 uA', '40 Hz 20 uA', 'BioAmp 100 Hz', 'BioAmp 200 Hz', ... 
    'BioFreq 100 Hz 10 uA', 'BioFreq 100 Hz 20 uA', 'BioFreq 200 Hz 10 uA', 'BioFreq 200 Hz 20 uA', ...
    'TBS 10 uA', 'TBS 20 uA'}; %different ICMS trains used 

%create stim vectors that show when stimulation is delivered to be used for
%correlation
%the first stim vector will be generally when stimulation is on or off
%the second stim vector will indicate within each train when specific
%bursts or other kind of profile should be occurring
%we can then extract both components and include both of them
stim_vectors_1 = create_stim_vectors_1(train_types,onset_start,offset_start); %will create a function to do this
stim_vectors_2 = create_stim_vectors_2(train_types,onset_start,offset_start);

%first load in PV neurons
PV_base_dir ='C:\Users\chugh\Documents\GitHub\SOM-PV\Results\PV\Averages_old';
PV_animals = {'012824', '042924', '050624', '050924'}; %animal IDs, 
PV_cell_types = {'non-PV','PV','Unc'};
[PV_all_data,PV_error_all,PV_all_data_split,PV_error_all_split,PV_perc_act,PV_perc_log, PV_exc_idx, PV_inh_idx] = ...
    initial_load_function(PV_base_dir, PV_animals, train_types, PV_cell_types, stim_vectors_1, stim_vectors_2, 1, 0);

%then load in SOM neurons
SOM_base_dir ='C:\Users\chugh\Documents\GitHub\SOM-PV\Results\SOM\Averages_old';
SOM_animals = {'040824', '042524', '062624', '090524'}; %animal IDs, 
SOM_cell_types = {'non-SOM','SOM','Unc'};
[SOM_all_data,SOM_error_all,SOM_all_data_split,SOM_error_all_split,SOM_perc_act,SOM_perc_log, SOM_exc_idx, SOM_inh_idx] = ...
    initial_load_function(SOM_base_dir, SOM_animals, train_types, SOM_cell_types, stim_vectors_1, stim_vectors_2, 1, 0);