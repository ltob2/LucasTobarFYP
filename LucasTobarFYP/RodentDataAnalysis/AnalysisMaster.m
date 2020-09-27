clear all; close all; clc;

%%
OUTPUT = the_Depth_Loader;

for exp = [1,3]
    %% Sort Data
    DATA = applyDepthThresholdRules(OUTPUT(exp,:,:),5,0.9,50,0,0);
    n = size(DATA,1);
    m = size(DATA,2);
    currentLevel = [];
    sDepth = [];
    rDepth = [];
    bRate = [];
    fRate = [];
    nThreshold = [];
    thresh = [];
    aThresh = [];
    for i = 1:n
        for j = 1:m
            if ~isempty(DATA{i,j})
                bRate = [bRate, DATA{i,j}.BASERATE'];
                %fRate = [fRate, DATA{i,j}.FIRINGRATE'];
                fRate = [fRate, DATA{i,j}.FRPEAKMAG'];
                thresh = [thresh,DATA{i,j}.THRESHOLD'];
                aThresh = [aThresh,DATA{i,j}.ABOVETHRESH'];
                rDepth = [rDepth, DATA{i,j}.RDEPTH'];
                currentLevel = [currentLevel, ones(length(DATA{i,j}.RDEPTH),1)*DATA{i,j}.CURRENT]; %#ok<*AGROW>
                sDepth = [sDepth, ones(length(DATA{i,j}.RDEPTH),1)*DATA{i,j}.SDEPTH];

                %nThreshold = [nThreshold, nansum(DATA{sesh,i,j}.ABOVETHRESH)];
                %bRate = [bRate, nnz(~isnan(DATA{sesh,i,1}.BASERATE))];
            end
        end
    end
    index = isnan(fRate);
    bRate(index) = [];
    fRate(index) = [];
    thresh(index) = [];
    aThresh(index) = [];
    rDepth(index) = [];
    currentLevel(index) = [];
    sDepth(index) = [];

    p_order = 2; %order of polynomial for curve fitting
    %% Plot
    for stimDepth = [450,1850]
        offset = 0; %no reason for the offsets to be the same between the two groups!! can be diff if u want totally up to u!
        IG = (rDepth>1175+offset)&sDepth==stimDepth;
        SG = (rDepth<1175-offset)&sDepth==stimDepth;%look at averaging from a specific range to get better results!!!
        fRate_SG = fRate(SG);
        bRate_SG = bRate(SG);
        fRate_IG = fRate(IG);
        bRate_IG = bRate(IG);
        currents_SG = currentLevel(SG);
        currents_IG = currentLevel(IG);

        mean_fRate_SG = [];
        mean_bRate_SG = [];
        mean_fRate_IG = [];
        mean_bRate_IG = [];

        err = [];
        mean_currentLevel = [-1,1:11,14];
        for curr = [-1,1:11,14]%do error bars within here!
            curr_f_SG = fRate_SG(currents_SG==curr);
            curr_b_SG = bRate_SG(currents_SG==curr);
            curr_f_IG = fRate_IG(currents_IG==curr);
            curr_b_IG = bRate_IG(currents_IG==curr);
            if isempty(curr_f_SG)||isempty(curr_b_SG)||isempty(curr_f_IG)||isempty(curr_b_IG)
                mean_currentLevel(find(mean_currentLevel==curr)) = [];
            else
                mean_fRate_SG = [mean_fRate_SG,mean(curr_f_SG)];
                mean_bRate_SG = [mean_bRate_SG,mean(curr_b_SG)];
                mean_fRate_IG = [mean_fRate_IG,mean(curr_f_IG)];
                mean_bRate_IG = [mean_bRate_IG,mean(curr_b_IG)];
                err = [err,[std(curr_f_SG)/sqrt(length(curr_f_SG));std(curr_b_SG)/sqrt(length(curr_b_SG));std(curr_f_IG)/sqrt(length(curr_f_IG));std(curr_b_IG)/sqrt(length(curr_b_IG))]];
            end

        end
        
        figure; hold on;
        errorbar(mean_currentLevel,mean_fRate_SG,err(1,:),'b*','LineWidth',2,'LineStyle','none');
        errorbar(mean_currentLevel,mean_bRate_SG,err(2,:),'r*','LineWidth',2,'LineStyle','none');
        errorbar(mean_currentLevel,mean_fRate_IG,err(3,:),'k*','LineWidth',2,'LineStyle','none');
        errorbar(mean_currentLevel,mean_bRate_IG,err(4,:),'m*','LineWidth',2,'LineStyle','none');

        plot(mean_currentLevel,polyval(polyfit(mean_currentLevel,mean_fRate_SG,p_order),mean_currentLevel),'b-','LineWidth',3);
        plot(mean_currentLevel,polyval(polyfit(mean_currentLevel,mean_bRate_SG,p_order),mean_currentLevel),'r-','LineWidth',3);
        plot(mean_currentLevel,polyval(polyfit(mean_currentLevel,mean_fRate_IG,p_order),mean_currentLevel),'k-','LineWidth',3);
        plot(mean_currentLevel,polyval(polyfit(mean_currentLevel,mean_bRate_IG,p_order),mean_currentLevel),'m-','LineWidth',3);

        legend('fRate (SG)','bRate (SG)','fRate (IG)','bRate (IG)','Location','NorthWest','FontSize',13);
        xlabel('current(uA)','FontSize',20);
        ylabel('firing rate (spikes/s)','FontSize',20);
        if exp == 1
            title(['Stimulation depth = ',num2str(stimDepth)],'FontSize',20);
        end
        axis([-2,15,0,1000]);
        hold off;
        ax = gca;
        ax.FontSize = 18;
        saveas(gcf,['Fig',num2str(exp),'_',num2str(stimDepth),'.png']);
    end
end