%% After removing x-y motion with normcorre, we remove frames where there
% too much movement in the z direction based on the red channel

%read in image and then select reference frame
load_dir = 'F:\Processed multielectrode'; %specify directory where pre-processed data is
cd(load_dir)
d0 = dir;
for curr_animal = 3:length(d0) %animals should be in separate folders, named by date (determined during pre-processing)
    curr_load_dir = [load_dir, '\', d0(curr_animal).name, '\Corr TIFFs'];
    cd([curr_load_dir, '\Red']) %this only works if you have a non-activity dependent channel here "red"
    d=dir;
    
    template = [];

    for curr_trial = 3:length(d) 
        
        cd([curr_load_dir, '\Red'])
        curr_tiff = tiffreadVolume(d(curr_trial).name);

        %make 200 sample averages, plot, and choose template
        for curr_avg = 1:size(curr_tiff,3)/20
            curr_idx = (curr_avg-1)*20+1:curr_avg*20;
            tiff_avgs(:,:,curr_avg) = nanmean(curr_tiff(:,:,curr_idx),3);
        end

        %% load in previous template for comparison
        %need to have template0 to start
        if isfile([curr_load_dir, '\template', num2str(curr_trial-3), '.mat']) %skip if we do not have a template yet
            load([curr_load_dir, '\template', num2str(curr_trial-3), '.mat'])
            figure, imagesc(template)
            colormap(gray)
        end
        
        template = [];
        figure

        for curr_img = 1:size(tiff_avgs,3)
        %     imagesc(tiff_avgs(:,:,curr_img))
            template2 = tiff_avgs(:,:,curr_img);
            smooth_background = smoothdata(template2,1,'Gaussian',100);
            smooth_background = smoothdata(smooth_background,2,'Gaussian',100);
            template2 = (template2-smooth_background./(smooth_background));
            threshold = smooth_background+3*(nanmean(nanstd(template2)));
            temp_mask = template2>threshold; 
            temp_mask2 = smoothdata(temp_mask,1,'Gaussian',10);
            temp_mask2 = smoothdata(temp_mask2,2,'Gaussian',10);
            temp_mask3 = temp_mask2;
            temp_mask3(temp_mask3<0.2) = 0;
            save_mask(:,:,curr_img)=temp_mask3;
            if isempty(template) %once we define template can move forward
                imagesc(tiff_avgs(:,:,curr_img))
                colormap(gray)
%                 caxis([0 1000])
            %     imcontrast
                curr_in = input(num2str(curr_img)); %user will select the frame that reflects the center frame
                %frame selection will be put to the test later and user can
                %reject or redo
                if curr_in == 1
                    template = temp_mask3;
                end
            end
        end
        
        save([curr_load_dir '\template', num2str(curr_trial-2), '.mat'], 'template')
        
        
        for curr_img = 1:size(save_mask,3)
            curr_temp = template.*save_mask(:,:,curr_img);
            corr_mat_3(curr_img) = nanmean(nanmean(curr_temp));
        end
        corr_mat_3 = corr_mat_3/max(corr_mat_3);

        %this will plot the correlation of the chosen frame with the rest
        %of the frames, should be higher if it matches the position of
        %other frames
        figure
        plot(corr_mat_3)
        yline(0.5)
        above_corr = sum(corr_mat_3 > 0.5)/length(corr_mat_3);
        annotation('textbox',[0.75 0.75 0.1 0.1], 'String', num2str(above_corr))
        
        %check and give chance to abort change
        x = input('');

        %will try to find an optimal cut-off
        blank_idx = corr_mat_3 < 0.5;
        tiff_avg2 = tiff_avgs;
        tiff_avg2(:,:,blank_idx) = NaN(512,512,sum(blank_idx));

        %for blanking of actual images, need to put blanking idx into correct
        %format
        blank_idx_2 = zeros(1,length(blank_idx)*20);
        for curr_idx = 1:length(blank_idx)
            blank_idx_2((curr_idx-1)*20+1:curr_idx*20) = repmat(blank_idx(curr_idx),1,20);
        end

        % blank parts of red channel tseries
        blank_idx_2 = logical(blank_idx_2);
        curr_tiff(:,:,blank_idx_2) = NaN(512,512,sum(blank_idx_2));
        %%
        cd([curr_load_dir, '\Red'])

        for curr_samp = 1:size(curr_tiff,3)
            if curr_samp == 1
                imwrite(curr_tiff(:,:,curr_samp),d(curr_trial).name)
            else
                imwrite(curr_tiff(:,:,curr_samp),d(curr_trial).name,"WriteMode","append")
            end
        end

        clear curr_tiff

        %use to correct green channel also
        cd([curr_load_dir, '\Green'])
        d=dir;
        curr_tiff = tiffreadVolume(d(curr_trial).name);
        curr_tiff(:,:,logical(blank_idx_2)) = NaN(512,512,sum(blank_idx_2));

        for curr_samp = 1:size(curr_tiff,3)
            if curr_samp == 1
                imwrite(curr_tiff(:,:,curr_samp),d(curr_trial).name)
            else
                imwrite(curr_tiff(:,:,curr_samp),d(curr_trial).name,"WriteMode","append")
            end
        end
    end
end
                        
%after z-motion correction, we handled the rest in ImageJ by loading in the
%fixed Tiff files and manually labeling ROIs and saving the averages across
%the ROIs

