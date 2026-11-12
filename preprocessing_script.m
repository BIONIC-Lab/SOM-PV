%Code for automatic ROI sorting
%% convert ome files to matfiles in 200 frame bins
%have to first save ome files from specified TSeries folders
base_dir = %specify folder with TSeries to be processed example" 'E:\02.26.24\ME_02.26.24\Data to process'
save_dir = %specify where to save output - typically a folder called "Processed\Matfiles" will save within specific channel folder
cd(base_dir)
d = dir;
list = regexp({d.name},'TSeries','match'); %find all TSeries folder
idx = find(~cellfun(@isempty,list));

%scans through relevant folders
for curr_series = 1:length(idx)
    curr_folder = d(idx(curr_series)).name;
    cd([base_dir, '\', curr_folder])
    curr_d = dir;
    
    for curr_ch = 3 %sepcify the channels you want, 2 for red 3 for green
        Ch = ['Ch', num2str(curr_ch)]; 
        filename = [curr_d(6).name(1:27),'-',Ch,'.tif'];
        curr_save = [save_dir, '\', Ch, '\', filename(23:27)];

        cd([save_dir, '\', Ch])
        if ~exist(curr_save, 'dir')
            mkdir(curr_save)
        end

        w = waitbar(0, ['Converting ome files to mat for ' filename]);  

        %initialize tif
%         cd([base_dir, '\', curr_folder])
%         t = imread(curr_d(6).name);
%         cd(tiff_dir)
%         imwrite(t, filename)
        for curr_bin = 1:ceil((length(curr_d)-5)/200) 
            avg_tiff = [];
            cd(curr_save)
            if curr_bin < 10
                filename2 = ['avg_tiff_', filename(23:27),'_', Ch, '_0', num2str(curr_bin) '.mat'];
            else
                filename2 = ['avg_tiff_', filename(23:27),'_', Ch, '_', num2str(curr_bin) '.mat'];
            end
            
            if ~isfile(filename2)           
                %when we get to end, have to change size
                if ceil(length(curr_d)-5) > 200*curr_bin
                    fin = 200*curr_bin+5;
                else
                    fin = length(curr_d);
                end

                for curr_img = 6+200*(curr_bin-1):fin
                    if contains(curr_d(curr_img).name,Ch)
                        cd([base_dir, '\', curr_folder])
                        t = imread(curr_d(curr_img).name);
                        avg_tiff = cat(3,avg_tiff,t);
                    end
                end
                waitbar(2*(curr_bin)/ceil(length(curr_d)/200),w,['Converting ome files to mat for ' filename]);
                % save files for easy loading
                if ~isempty(avg_tiff)
                    cd(curr_save)
                    %filename2 = ['avg_tiff_', filename(23:26),'_', Ch, '_', num2str(curr_bin) '.mat'];
                    save(filename2, 'avg_tiff')
                end
            end
        end
        close(w)
    end     
end


%% motion correction - apply normcorre and set data to NaN if it deviates too much in the red channel
%motion correct red channel
load_dir = 'G:\Processed\SOM_06.21.24\Matfiles\Ch2';
save_dir = 'G:\Processed\SOM_06.21.24\Corr TIFFs\Red';
cd(load_dir)
d = dir;
template = cell(1,length(d));
start_tag = 'TSeries-01242024-1329-';
template = motion_correction('Red',load_dir,save_dir,template, start_tag);

%motion correct green channel
load_dir = 'G:\Processed\SOM_06.21.24\Matfiles\Ch3';
save_dir = 'G:\Processed\SOM_06.21.24\Corr TIFFs\Green';
motion_correction('Green',load_dir,save_dir,template, start_tag)

%% helper functions
function template = motion_correction(channel,load_dir,save_dir,template,start_tag)
    % motion correction

    %addpath(genpath('C:\Users\chugh\Documents\GitHub'))
    cd(load_dir)
    d = dir; 
    for curr_folder = 3:size(d)
        w = waitbar(0, ['Motion correcting ', d(curr_folder).name, ' ', channel]); 
        curr_d = [d(curr_folder).folder, '\' d(curr_folder).name];
        cd(curr_d)
        d2 = dir;

        cd(save_dir)
        %this is a clause used to not repeat files that already exist
        %should input the file name as an input into the function instead
        if ~exist([start_tag,num2str(d(curr_folder).name),'_corr.tif'], 'file') 
            for curr_bin = 3:size(d2,1)
                start = 1;
                cd(curr_d)
                load(d2(curr_bin).name)
                if ~isempty(avg_tiff)
                    [avg_tiff_corr,shifts,template{curr_folder},~,~] = normcorre(avg_tiff, template{curr_folder});
                    %filename = ['avg_tiff_', curr_tiff(end-7:end-4),'_', num2str(curr_bin) '.mat'];
                    cd(save_dir)
                    if curr_bin == 3
                        imwrite(uint16(avg_tiff_corr(:,:,1)),[start_tag,num2str(d(curr_folder).name),'_corr.tif'])
    %                         t = Tiff(['TSeries-01242024-1329-',num2str(d(curr_folder).name),'_corr.tif'], 'w8');
    %                         setTag(t,tagstruct)
    %                         write(t,uint16(avg_tiff_corr(:,:,1)))
    %                         close(t)
                            start = 2;
                    end
                    for i = start:size(avg_tiff_corr,3)
                        imwrite(uint16(avg_tiff_corr(:,:,i)),[start_tag,num2str(d(curr_folder).name),'_corr.tif'],"WriteMode","append")
    %                         t = Tiff(['TSeries-01242024-1329-',num2str(d(curr_folder).name),'_corr.tif'], 'a');
    %                         setTag(t,tagstruct) %?
    %                         write(t,uint16(avg_tiff_corr(:,:,i)))
    %                         close(t)
                    end
                    waitbar(curr_bin/size(d2,1),w, ['Motion correcting ', d(curr_folder).name, ' ', channel]);
                    cd(curr_d)
                    filename = d2(curr_bin).name;%['avg_tiff_', curr_tiff(end-7:end-4),'_', num2str(curr_bin) '.mat'];
                    save(filename, 'avg_tiff') %overwrite uncorrected file
                end
            end          
        end
        close(w)
    end
end