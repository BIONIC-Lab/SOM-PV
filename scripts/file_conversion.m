%Code for automatic ROI sorting
%% convert ome files to matfiles in 200 frame bins
%base_dir = 'E:\SOM_animal_10.15.23\TSeries-10152023-1852-8444';
base_dir = 'E:\ME_09.12.24\Data to process';
save_dir = 'E:\Processed multielectrode\09.12.24\Matfiles';
cd(base_dir)
d = dir;
list = regexp({d.name},'TSeries','match'); %find all TSeries folder
idx = find(~cellfun(@isempty,list));

for curr_series = 1:length(idx)
    curr_folder = d(idx(curr_series)).name;
    cd([base_dir, '\', curr_folder])
    curr_d = dir;
    
    for curr_ch = 2:3
        Ch = ['Ch', num2str(curr_ch)]; 
        filename = [curr_d(6).name(1:27),'-',Ch,'.tif'];
        curr_save = [save_dir, '\', Ch, '\', filename(23:27), '-2'];

        cd([save_dir, '\', Ch])
        if ~exist(curr_save, 'dir')
            mkdir(curr_save)
        end

        w = waitbar(0, ['Converting ome files to mat for ' filename]);  

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

