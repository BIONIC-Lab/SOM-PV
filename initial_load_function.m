%going to try splitting up parts into separate scripts to make things
%easier to parse

function [all_data, error_all, all_data_split, error_all_split, perc_act, perc_log, exc_idx, inh_idx] = initial_load_function(base_dir, animals, train_types, cell_types,stim_vectors_1, stim_vectors_2, excl_act, nnmf_adjust)
    %set up load directory
    cd(base_dir)
    d = dir;

    frate = 0.034; %frame rate
    x_label = [1:7200]*frate; %time axis

    onset_start = 437; %approximate frame that ICMS started for first train
    onset_stop = floor(onset_start+3/frate); %first 3 s of ICMS
    s20 = floor(onset_start+20/frate); %20 s into ICMS train
    offset_start = 1324;  %approximate frame ICMS ended for first train
    offset_stop = floor(offset_start+2/frate); %3 s after end of train

    all_data = cell(length(d)-2,length(cell_types)); %will save all data
    all_data_norm = cell(length(d)-2,length(cell_types)); %will save all data normalized (may not need this one)
    all_data_split = cell(length(d)-2,length(animals),length(cell_types)); %save all data split by animal 
    error_all = cell(length(d)-2,length(cell_types)); %save the standard deviation for all data
    error_all_split = cell(length(d)-2,length(animals),length(cell_types)); %save the standard deviation for all data split by animal

    act_hist_data = [];

    %go through data and load in to data arrays for processing
    for curr_train = 1:length(d)-2

        %set directory for green channel data
        curr_dir = [base_dir, '\', d(curr_train+2).name];
        cd([curr_dir, '\Green'])
        d_green = dir;

        %set directory for red channel data
        cd([curr_dir, '\Red'])
        d_red = dir;


        for curr_animal = 1:length(animals)

            %call to function that labels inhibitory neurons based on
            %regression correction with baseline in green channel
            [exc_idx{curr_animal},inh_idx{curr_animal},oth_idx{curr_animal},meangreen{curr_animal},meanred{curr_animal}] = geteimask_SOMPV(base_dir,animals{curr_animal},1,onset_start*frate,frate,0);

            %load in green channel for current animal
            cd([curr_dir, '\Green'])
            greeninfo = dir(fullfile(base_dir,sprintf('%s',d(curr_train+2).name),'Green',sprintf('%s*.csv',animals{curr_animal})));
            m_green = readmatrix(fullfile(greeninfo.folder,greeninfo.name));
            m_green = m_green(:,2:end);

            %some had slightly longer lengths so need to adjust
            size_diff2 = size(m_green,1)-7200;
            m_green = m_green(size_diff2+1:end,:);

            %read in red channel
            cd([curr_dir, '\Red'])
            redinfo  = dir(fullfile(base_dir,sprintf('%s',d(curr_train+2).name),'Red',sprintf('%s*.csv',animals{curr_animal})));
            m_red = readmatrix(fullfile(redinfo.folder,redinfo.name));
            m_red = m_red(:,2:end);

            %some had slightly longer lengths so need to adjust
            size_diff = size(m_red,1)-7200;
            m_red = m_red(size_diff+1:end,:);

            %filter data for noise- same as previous papers
            m_green(m_green==0) = NaN; %blanking made zeros instead of NaNs
            m_green = smoothdata(m_green,'Gaussian',[7,7]);

            %calculate baseline for green channel
            baseline_green = nanmean(m_green(1:onset_start,:)); %find mean across all ROIs during baseline period

            %remove trials where not enough baseline (double check this logic)
            if sum(isnan(baseline_green)) > 300
                m_green = NaN(size(m_green,1),size(m_green,2));
            end

            %calculate dF/F0 of green channel
            m_green_norm = (m_green-baseline_green)./abs(baseline_green);

            %only use neurons modulated i.e. with some significant increase
            %or decrease
            curr_error = nanstd(m_green_norm(1:floor((10/frate)),:),[],1); %std for each ROI in first 10 s 
            baseline_mean{curr_train,curr_animal} = nanmean(m_green_norm(1:floor((10/frate)),:),1); %baseline mean
            
            %alternative active index
            clear act_idx
            act_idx_pre = abs(m_green_norm(onset_start:offset_start,:)) > abs(baseline_mean{curr_train,curr_animal})+curr_error*3;
            act_idx_all = any(act_idx_pre);
            for curr_neuron = 1:size(act_idx_pre,2) %active neurons are above three standard deviations for at least 15 consecutive samples
                act_idx(curr_neuron) = numel(strfind(act_idx_pre(:,curr_neuron)',ones(1,15)));
            end
            act_idx(act_idx>1) = 1;
            
            if excl_act
                m_green_norm(:,~act_idx) = NaN; %turns inactive neurons into NaNs
            end
            m_green_norm2 = m_green_norm./max(m_green_norm); %normalize to max on each ROI
            
            %we use non-negative matrix factorization to manually remove
            %sensory deviations
            if nnmf_adjust
                m_green_norm = nnmf_code(m_green_norm, stim_vectors_1(curr_train,:), stim_vectors_2(curr_train,:), train_types{curr_train}, onset_start);
            end
            
            %parse data into bigger arrays for all data
            %place excitatory neurons in first slot
            all_data{curr_train,1} = [all_data{curr_train,1}; m_green_norm(:,exc_idx{curr_animal})'];
            all_data_norm{curr_train,1} = [all_data_norm{curr_train,1}; m_green_norm2(:,exc_idx{curr_animal})'];
            all_data_split{curr_train,curr_animal,1} = m_green_norm';
            all_data_split{curr_train,curr_animal,1}(~exc_idx{curr_animal},:) = NaN;        
            %error is std of baseline only
            error_all{curr_train,1} = [error_all{curr_train,1}; curr_error(exc_idx{curr_animal})'];
            error_all_split{curr_train,curr_animal,1} = curr_error';
            error_all_split{curr_train,curr_animal,1}(~exc_idx{curr_animal}) = NaN;

            %place inhibitory neurons in second slot
            all_data{curr_train,2} = [all_data{curr_train,2}; m_green_norm(:,inh_idx{curr_animal})'];
            all_data_norm{curr_train,2} = [all_data_norm{curr_train,2}; m_green_norm2(:,inh_idx{curr_animal})'];
            all_data_split{curr_train,curr_animal,2} = m_green_norm';
            all_data_split{curr_train,curr_animal,2}(~inh_idx{curr_animal},:) = NaN;
            error_all{curr_train,2} = [error_all{curr_train,2}; curr_error(inh_idx{curr_animal})'];
            error_all_split{curr_train,curr_animal,2} = curr_error';
            error_all_split{curr_train,curr_animal,2}(~inh_idx{curr_animal}) = NaN;

            %place mixed neurons in third slot
            all_data{curr_train,3} = [all_data{curr_train,3}; m_green_norm(:,oth_idx{curr_animal})'];
            all_data_norm{curr_train,3} = [all_data_norm{curr_train,3}; m_green_norm2(:,oth_idx{curr_animal})'];
            all_data_split{curr_train,curr_animal,3} = m_green_norm';
            all_data_split{curr_train,curr_animal,3}(~oth_idx{curr_animal},:) = NaN;
            error_all{curr_train,3} = [error_all{curr_train,3}; curr_error(oth_idx{curr_animal})'];
            error_all_split{curr_train,curr_animal,3} = curr_error';
            error_all_split{curr_train,curr_animal,3}(~oth_idx{curr_animal}) = NaN;

            %save the total percent of each population that is active in each
            %animal
            perc_act{1}(curr_train,curr_animal) = sum(~isnan(m_green_norm(1,exc_idx{curr_animal})))/(sum(exc_idx{curr_animal}));
            perc_act{2}(curr_train,curr_animal) = sum(~isnan(m_green_norm(1,inh_idx{curr_animal})))/(sum(inh_idx{curr_animal}));

            %save logical indices to find what percent of neurons are not
            %active for any train
            perc_log{1,curr_animal}(curr_train,:) = ~isnan(m_green_norm(1,exc_idx{curr_animal}));
            perc_log{2,curr_animal}(curr_train,:) = ~isnan(m_green_norm(1,inh_idx{curr_animal}));
        end
    end
end
