function [emask,imask,exclmask,meangreen,meanred] = geteimask_SOMPV(basedir,animalid,rmsmult,basetime,frate,plot_func)
% usage eimask = geteimask(basedir,animalid)
% 
% This function loads in the red and green roidata for all stimulation conditions
% Then computes the average value during baseline
% Fits a linear model between the red and green baselilne activity in order to correct for the green fluorescence contaminating the red channel
% corrects the red value given the fit
% 
% returns 3 logical arrays corresponding to where the average red fluorescence across all 4 trains lies 
% relative to the regression line
% Excitatory cells are any cells with red fluorescence below the regression line
% Inhibitory cells are any cells with red fluorescence above the line plus root mean square * rms mult 
% excluded cells (exclmask) are the cells that are above the regression line but below the rms*rmsmult
% 
% Inputs
% 
%         basedir         - path to the github directory for the data
%         animalid        - the animalid for going into the right folder
%         rmsmult         - integer for how many rms above the line to exclude cells
%         basetime        - time in seconds to calculate the baseline
%         frate           - the frame period
% 
% Outputs
% 
%         emask           - logical array cells x 1 where any cell with red fluorescence below regression line
%         imask           - logical array cells x 1 where any cell with red fluorescece above the regression line + rms mult*rms
%         exclmask        - any remaining cell that didnt fit the above criteria
% 
% 


    % navigate to the right animal directory and load all of the roi files
    % for green and red

    redvals = [];
    greenvals = [];
    
    cd(basedir)
    d = dir;

    for istim = 1:length(d)-2
        redinfo = dir(fullfile(basedir,sprintf('%s',d(istim+2).name),'Red',sprintf('%s*.csv',animalid)));
        greeninfo = dir(fullfile(basedir,sprintf('%s',d(istim+2).name),'Green',sprintf('%s*.csv',animalid)));

        tmpred = readmatrix(fullfile(redinfo.folder,redinfo.name));
        tmpgreen = readmatrix(fullfile(greeninfo.folder,greeninfo.name));
        
        %have to write this in because some of the processes are messed up
        %right now - should be able to remove when fixed
        size_diff = size(tmpred,1)-7200;
        tmpred = tmpred(size_diff+1:end,:);
        
        size_diff2 = size(tmpgreen,1)-7200;
        tmpgreen = tmpgreen(size_diff2+1:end,:);

        redvals = cat(3,redvals,tmpred(:,2:end)); %this won't work if the ROI maps are not consistent
        
        %correct green values based on z change before using baseline
        %can still try to optimize this
%         tmpgreen = z_correction(tmpgreen(:,2:end), tmpred(:,2:end),0);
        
        greenvals = cat(3,greenvals,tmpgreen(:,2:end));

    end

    % average across stim patterns and baseline
    onset = floor(basetime/frate); %find where ICMS starts
    baseframes = 1:onset; %use the period up until ICMS starts
    
    meanred = squeeze(nanmean(nanmean(redvals(baseframes,:,:),3),1));
    meangreen = squeeze(nanmean(nanmean(greenvals(baseframes,:,:),3),1));
    
    % create a linear model between the red and the green values
    mdl = fitlm(meangreen,meanred);
    intercept = table2array(mdl.Coefficients(1,1));
    slope = table2array(mdl.Coefficients(2,1));

%% original method
    imask = meanred' > mdl.Fitted + rmsmult*mdl.RMSE; % 
    emask = meanred' < mdl.Fitted; %

    exclmask = ~imask & ~emask;
    
    if plot_func
        %plot histogram before correction
        figure
        h1 = histogram(meanred,50);
        xlabel('Baseline F Red Channel')
        ylabel('# of ROIs')
        title('Red Channel ROIs before correction')
        
        %plot cumulative sum and divisions
        yyaxis right
        cs = cumsum(h1.Values);
        plot(h1.BinEdges(2:end),cs, 'LineWidth', 2)
        ylabel('Cumulative sum of ROIs')

        %plot model
        figure
        
        %mark exc, inh, and mix to color     
        scatter(meangreen(emask), meanred(emask), 'filled', 'b')
        hold on
        scatter(meangreen(imask), meanred(imask), 'filled', 'r')
        scatter(meangreen(exclmask), meanred(exclmask), 'filled', 'm')

        
        plot(meangreen, mdl.Fitted, 'k')
        plot(meangreen, mdl.Fitted+mdl.RMSE, 'c')

        legend('off')
        xlabel('Baseline F Green Channel')
        ylabel('Baseline F Red Channel')
        title('Influence of GCaMP on Red Channel')
    end


