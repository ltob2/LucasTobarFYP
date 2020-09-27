clear all; close all; clc;
%% Modified Interlaminar Model
% Refer to supplementary material of Mejias et al. 2016 (Science Advances).

%% Initial Values

%time constants
tau_L2E = 6; 
tau_L2I = 15;
tau_L5E = 30; 
tau_L5I = 75;
tau = [tau_L2E;tau_L2I;tau_L5E;tau_L5I];

%Cap-off time constant: change to zero to see without time constant
tau_c = 0.0005; %optimum value for current from 0 ->32

%Synaptic Strengths
J_EE = 1.5; J_IE = 3.5;
J_EI = -3.25; J_II = -2.5;
J_52 = 1; 
J_25_EE = 0.75;
J_25 = 0.75;
J_a=[J_EE J_EI J_25_EE 0; J_IE J_II J_25 0; J_52 0 J_EE J_EI; 0 0 J_IE J_II];

%Gaussian white noise strengths
sigma_L2 = 0.30;
sigma_L5 = 0.30;
sigma = [sigma_L2;sigma_L2;sigma_L5;sigma_L5];

%Initialising outputs
FR = []; %Firing rate matrix

%Time step
dt = 0.02; %ms

%Time range (ms)
time = 0:dt:1000;

%stimulus pulse
pw = 0.200; %pulse width in ms
phase_int = 0.100; %inter-phase interval in ms


%Post-Exp Analysis Variables
mean_fRate_SG = []; %mean firing rate after stimulus (SG)
mean_bRate_SG = []; %base firing rate after stimulus (SG)
mean_fRate_IG = []; %mean firing rate after stimulus (IG)
mean_bRate_IG = []; %base firing rate after stimulus (IG)

%% Simulations
currentLevel = [-1,4,8,12,16,20,24,28,32,36]; %Input current (arbitrary units)
err = [];%std error

%select which layers/populations get the input e.g. [1;0;1;0] means L2E and L5E get input stimulus
stim_site = cell(1,2); stim_site{1} = [1;1;0;0]; stim_site{2} = [0;0;1;1]; 
ax = cell(1,1);
tiledlayout(1,2)
for ss = 1:length(stim_site)
    sel = stim_site{ss};
    
    mean_fRate_SG = [];
    mean_bRate_SG = []; 
    mean_fRate_IG = []; 
    mean_bRate_IG = []; 
    err = [];    
    for input = currentLevel%stimulus magnitude
        I_ext = zeros(4,length(time));
        I_ext(:,(floor(length(time)/2)-pw/dt+1):floor(length(time)/2)) = -input*sel*ones(1,pw/dt);
        I_ext(:,(floor(length(time)/2)+1)+phase_int/dt:(floor(length(time)/2)+1)+phase_int/dt+pw/dt-1) = input*sel*ones(1,pw/dt);
        
        peakFR_SG = [];
        BR_SG = [];
        peakFR_IG = [];
        BR_IG = [];
        for trial = 1:25
            %Initialise mean firing rates (any non-zero should do)
            r_L2E = 0.5; r_L2I= 0.5; r_L5E = 0.5;r_L5I = 0.5;
            r = [r_L2E;r_L2I;r_L5E;r_L5I];

            for t = 1:length(time) 

                for i = 1:2
                    I_net = J_a*r;
                    x = I_net+I_ext(:,t);
                    r = r + (dt/2).*(-r + exp(-tau_c.*x.^2).*x./(1-exp(-x)) + sqrt(tau).*sigma.*randn(4,1))./tau;%changing how often we update n0ise could affect things so watch out!
                end

                %update firing rate matrix
                FR(:,t,trial) = r;
            end   
            peakFR_SG = [peakFR_SG,max(sum(FR(1:2,floor(length(time)/2):length(time),trial),1))];
            BR_SG = [BR_SG,max(sum(FR(1:2,floor(length(time)/4):floor(length(time)/2),trial),1))];
            peakFR_IG = [peakFR_IG,max(sum(FR(3:4,floor(length(time)/2):length(time),trial),1))];
            BR_IG = [BR_IG,max(sum(FR(3:4,floor(length(time)/4):floor(length(time)/2),trial),1))];
        end
        mean_fRate_SG = [mean_fRate_SG,mean(peakFR_SG)]; 
        mean_bRate_SG = [mean_bRate_SG,mean(BR_SG)]; 
        mean_fRate_IG = [mean_fRate_IG,mean(peakFR_IG)]; 
        mean_bRate_IG = [mean_bRate_IG,mean(BR_IG)];
        err = [err,[std(peakFR_SG);std(BR_SG);std(peakFR_IG);std(BR_IG)]/sqrt(trial)];
    end

    %Plot
    %figure;
    ax{ss} = nexttile;
    hold on;
    errorbar(currentLevel,mean_fRate_SG,err(1,:),'LineWidth',2);
    errorbar(currentLevel,mean_bRate_SG,err(2,:),'LineWidth',2);
    errorbar(currentLevel,mean_fRate_IG,err(3,:),'LineWidth',2);
    errorbar(currentLevel,mean_bRate_IG,err(4,:),'LineWidth',2);
    legend('Response: SG','Base rate: SG','Response: IG','Base rate: IG','Location','NorthWest','FontSize',14)
    ylabel('Firing rate (dimensionless)','FontSize',20);
    xlabel('Current (dimensionless)','FontSize',20);
    ax{ss}.FontSize = 18;
    if sel(1)>sel(3)
        stim_layer = 'SG';
    elseif sel(3)>sel(1)
        stim_layer = 'IG';
    else
        stim_layer = 'No Stimulation';
    end
    title(['Stimulation site: ',stim_layer],'FontSize',20);
    hold off;
    
end

%% Figures
%% Figure 1
linkaxes([ax{1},ax{2}],'xy')
ax{1}.XLim = [currentLevel(1)-1 currentLevel(length(currentLevel))+1];
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.7, 0.5]);
saveas(gcf,'Fig3.png');

%% Figure 2
mean_FR = mean(FR,3);
L2_sum = sum(mean_FR(1:2,:),1);
L5_sum = sum(mean_FR(3:4,:),1);
figure; 
hold on;
plot(time,mean_FR,'LineWidth',1)
plot(time,[L2_sum;L5_sum],'LineWidth',2)
plot([500 500],[0.2 ,1.4],'k--','LineWidth',1)
hold off;
ylabel('Firing rate','FontSize',20);
xlabel('time (ms)','FontSize',20);
legend('L2E','L2I','L5E','L5I','L2 sum','L5 sum','FontSize',10,'Location','NorthEastOutside');
pbaspect([1 1 1]);
axis([200 1000 ylim])
saveas(gcf,'Fig4.png');