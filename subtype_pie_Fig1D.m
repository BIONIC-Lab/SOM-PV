%% pie plots for percent of each subtype - Fig 1D
%calculate percent division into each category
%PV
PV_total_cnt = zeros(1,3);
for curr_cell = 1:3
    for curr_train = 1:4
        PV_total_cnt(curr_cell) = PV_total_cnt(curr_cell)+sum(~isnan(PV_all_data{curr_train,curr_cell}(:,1)));
    end
end
figure
pie(PV_total_cnt)
legend('non-PV','PV','Unc')

%SOM
SOM_total_cnt = zeros(1,3);
for curr_cell = 1:3
    for curr_train = 1:4
        SOM_total_cnt(curr_cell) = SOM_total_cnt(curr_cell)+sum(~isnan(SOM_all_data{curr_train,curr_cell}(:,1)));
    end
end
figure
pie(SOM_total_cnt)
legend('non-SOM','SOM','Unc')