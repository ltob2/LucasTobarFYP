clear all; close all; clc;
%% Intralaminar Model
% Refer to supplementary material of Mejias et al. 2016 (Science Advances).

%% Initial Values

%time constants
tau_E_SG = 6; 
tau_I_SG = 15;
tau_E_IG = 30; 
tau_I_IG = 75;

%Synaptic Strengths
J_EE = 1.5; J_IE = 3.5;
J_EI = -3.25; J_II = -2.5;

%Gaussian white noise strengths
sigma_SG = 0.30;
sigma_IG = 0.30;

%sampling rate
Fs = 1000; %samples/s
dt = 1; %ms

tau_c = 0.0005;


%%
S_cons = cell(1,1);
FR_E_cons = cell(1,1);
FR_I_cons = cell(1,1);
contrasts = [0,2,4,6];

for I = 1:length(contrasts)
    S = [];
    FR_E = [];
    FR_I = [];
    
    for trial = 1:500
        r_E = 1;
        r_I = 1;
        for t = 1:14100

            for i = 1:2
                Inet_E = J_EE*r_E + J_EI*r_I;
                Iext_E = 0;
                if (t>2000 && t<12100)
                    Iext_E = contrasts(I);
                end
                xe = Inet_E+Iext_E;

                Inet_I = J_IE*r_E + J_II*r_I;
                xi = Inet_I;


                %supragranular
                r_E = r_E + (dt/2)*(-r_E +exp(-tau_c.*xe.^2)*xe/(1-exp(-xe)) + sqrt(tau_E_SG)*sigma_SG*randn(1))/tau_E_SG;
                r_I = r_I + (dt/2)*(-r_I +exp(-tau_c.*xi.^2)*xi/(1-exp(-xi)) + sqrt(tau_I_SG)*sigma_SG*randn(1))/tau_I_SG;
            end


            FR_E(trial,t) = r_E;
            FR_I(trial,t) = r_I;

        end

        dat = FR_E(trial,2051:12050);
        N = length(dat);
        W = fft(dat);
        W = abs(W).^2/(N*Fs);
        W = W(1:N/2);
        S(trial,:) = W;
    end
    S_cons{I} = S;
    FR_E_cons{I} = FR_E;
    FR_I_cons{I} = FR_I;
end
%%


omega = (0:(N-1-floor(N/2)))*(Fs/N);
%figure; plot(omega,mean(S_cons{1}),omega,mean(S_cons{2}),omega,mean(S_cons{3}),omega,mean(S_cons{4}));
figure; plot(omega,smooth((mean(S_cons{2})-mean(S_cons{1})),20),omega,smooth((mean(S_cons{3})-mean(S_cons{1})),20),omega,smooth((mean(S_cons{4})-mean(S_cons{1})),20),'LineWidth',2);
legend(['Input = ',num2str(contrasts(2))],['Input = ',num2str(contrasts(3))],['Input = ',num2str(contrasts(4))],'FontSize',15);
xlabel('Frequency (Hz)','FontSize',20);
ylabel('Power (resp. rest)','FontSize',20);
%set(gca, 'YScale', 'log');
axis([10 80 0 0.001]);
saveas(gcf,'Fig11.png');

%figure; hold on; plot(mean(FR_E_cons{4}));plot(mean(FR_I_cons{4}));hold off;