%% motion correction
%motion correct red channel
load_dir = 'F:\Processed\SOM_09.05.24\Matfiles\Ch2';
save_dir = 'F:\Processed\SOM_09.05.24\Corr TIFFs\Red';
m_corr('Red',load_dir,save_dir)

%% motion correct green channel
load_dir = 'F:\Processed\SOM_09.05.24\Matfiles\Ch3';
save_dir = 'F:\Processed\SOM_09.05.24\Corr TIFFs\Green';
m_corr('Green',load_dir,save_dir)

%% functions

function m_corr(channel,load_dir,save_dir)
    % motion correction

    %addpath(genpath('C:\Users\chugh\Documents\GitHub'))
    cd(load_dir)
    d = dir; 
    template = [];
    for curr_folder = 3:size(d)
        w = waitbar(0, ['Motion correcting ', d(curr_folder).name, ' ', channel]); 
        curr_d = [d(curr_folder).folder, '\' d(curr_folder).name];
        cd(curr_d)
        d2 = dir;

        %set tags
%         tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
%         tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         %tagstruct.Software = 'MATLAB';
%         tagstruct.ImageLength = 512;
%         tagstruct.ImageWidth = 512;
%         %tagstruct.ImageDescription = fiji_desc;
%         tagstruct.ImageDescription = ['ImageJ=1.47v',newline,'images=27200',...
%             newline,'slices=27200',newline,'loop=false',newline,'min=0.0',newline,'max=8191.0'];

        cd(save_dir)
        if ~exist(['TSeries-01242024-1329-',num2str(d(curr_folder).name),'_corr.tif'], 'file')
            for curr_bin = 3:size(d2,1)
                start = 1;
                cd(curr_d)
                load(d2(curr_bin).name)
                if ~isempty(avg_tiff)
                    [avg_tiff_corr,shifts,template,~,~] = normcorre(avg_tiff, template);
                    %filename = ['avg_tiff_', curr_tiff(end-7:end-4),'_', num2str(curr_bin) '.mat'];
                    cd(save_dir)
                    if curr_bin == 3
                        imwrite(uint16(avg_tiff_corr(:,:,1)),['TSeries-',num2str(d(curr_folder).name),'_corr.tif'])
%                             t = Tiff(['TSeries-01242024-1329-',num2str(d(curr_folder).name),'_corr.tif'], 'w8');
%                             setTag(t,tagstruct)
%                             write(t,uint16(avg_tiff_corr(:,:,1)))
%                             close(t)
                            start = 2;
                    end
                    for i = start:size(avg_tiff_corr,3)
                        imwrite(uint16(avg_tiff_corr(:,:,i)),['TSeries-',num2str(d(curr_folder).name),'_corr.tif'],"WriteMode","append")
%                             t = Tiff(['TSeries-01242024-1329-',num2str(d(curr_folder).name),'_corr.tif'], 'a');
%                             setTag(t,tagstruct) %?
%                             write(t,uint16(avg_tiff_corr(:,:,i)))
%                             close(t)
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