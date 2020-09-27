clear all; close all; clc;
%% Interlaminar Model
% Refer to supplementary material of Mejias et al. (Science Advances).

%% Initial Values

%time constants
tau_L2E = 6; 
tau_L2I = 15;
tau_L5E = 30; 
tau_L5I = 75;
tau = [tau_L2E;tau_L2I;tau_L5E;tau_L5I];

%Synaptic Strengths
J_EE = 1.5; J_IE = 3.5;
J_EI = -3.25; J_II = -2.5;
J_52 = 1; J_25 = 0.75;
J_25_EE = 0.75;

%Gaussian white noise strengths
sigma_L2 = 0.30;
sigma_L5 = 0.30;
sigma = [sigma_L2;sigma_L2;sigma_L5;sigma_L5];

%Initialising outputs
FR = cell(1,1); %Firing rate matrix
S = cell(1,1); %FFT power values 
S_mean = cell(1,1); %Mean power values

%Input current (arbitrary units)
input = 8;

%sampling rate
Fs = 1000; %samples/s

%Cap-off time constant: change to zero to see without time constant
%tau_c = -0.003 % optimum value for current from 0 ->16
tau_c = 0.0005; %optimum value for current from 0 ->32


%% Simulations

for cond = 1:2 %condition 1 = coupled, condition 2 = uncoupled
    if cond == 2
        J_52 = 0; J_25 = 0;J_25_EE = 0;
    else
        J_52 = 1; J_25 = 0.75;J_25_EE = 0.75;
    end
    
    for trial = 1:100
        %Initialise mean firing rates (any non-zero should do)
        r_L2E = 1; r_L2I= 1; r_L5E = 1;r_L5I = 1;
        r = [r_L2E;r_L2I;r_L5E;r_L5I];

        for t = 1:14100 %millisecond time steps
            I_ext = [0;0;0;0];
            
            %stimulus (input current) in excitatory populations of each layer for 10s
            if (t>2000 && t<12100)
                I_ext = [input;0;input;0];
            end
            
            %dt = 0.5ms
            for i = 1:2
                I_net = [J_EE J_EI J_25_EE 0; J_IE J_II J_25 0; J_52 0 J_EE J_EI; 0 0 J_IE J_II]*r;
                x = I_net+I_ext;
                r = r + 0.5.*(-r + exp(-tau_c.*x.^2).*x./(1-exp(-x)) + sqrt(tau).*sigma.*randn(4,1))./tau;
            end
            
            %update firing rate matrix
            FR{cond}(:,t,trial) = r;
        end
        
        %FFT
        dat = FR{cond}(:,2051:12050,trial); %only get data that falls within stimulus time
        N = length(dat);
        W = fft(dat,[],2);
        W = abs(W).^2./(N*Fs);
        W = W(:,1:N/2);
        S{cond}(:,:,trial) = W; %store power values in S
    end
    
    %average power values for each condition across trials
    S_mean{cond} = mean(S{cond},3);
end




%% Plots
omega = (0:(N-1-floor(N/2)))*(1000/N);

figure; loglog(omega,S_mean{2}(1,:),'k',omega,S_mean{1}(1,:),'g','LineWidth',2);
axis([10^(0) 10^2 10^-5 10^-2]);
ylabel('L 2/3 Power','FontSize',20);
xlabel('Frequency (Hz)','FontSize',20);
legend('Uncoupled','Coupled','FontSize',10);
pbaspect([1 1 1]);
saveas(gcf,'Fig3.png');

figure; loglog(omega,S_mean{2}(3,:),'k',omega,S_mean{1}(3,:),'r','LineWidth',2);
axis([10^(0) 10^2 10^-6 10^-1]);
ylabel('L 5/6 Power','FontSize',20);
xlabel('Frequency (Hz)','FontSize',20);
legend('Uncoupled','Coupled','FontSize',10);
pbaspect([1 1 1]);
saveas(gcf,'Fig4.png');
%Note: if you want to plot average firing rates, the values are stored in
%FR.

figure; plot(mean(FR{1},3)','LineWidth',2);
title('Coupled','FontSize',20)
ylabel('Firing rate (dimensionless)','FontSize',20);
xlabel('Time (ms)','FontSize',20);
legend('L2E','L2I','L5E','L5I','FontSize',10);

figure; plot(mean(FR{2},3)','LineWidth',2)
title('Uncoupled','FontSize',20)
ylabel('Firing rate (dimensionless)','FontSize',20);
xlabel('Time (ms)','FontSize',20);
legend('L2E','L2I','L5E','L5I','FontSize',10);

%FR fig for report
figure; hold on; plot(mean(FR{2}([2],:,:),3)','LineWidth',2);plot(mean(FR{2}([4],:,:),3)'+0.1,'LineWidth',2);hold off;
ylabel('Firing rate (dimensionless)','FontSize',20);
xlabel('Time (ms)','FontSize',20);
legend('L2/3','L5/6','FontSize',10);
axis([5000 6000 2.9 3.2])
saveas(gcf,'Fig22.png');