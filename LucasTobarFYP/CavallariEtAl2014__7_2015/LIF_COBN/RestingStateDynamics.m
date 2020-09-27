clear all; close all;clc;

mex code_COBN.c ran1.c gasdev.c;
parameters_COBN; % to generate the structure net_CUBN with all the parameters of the network
simulation_length = 4500; % units: (ms)
M = simulation_length/net_COBN.Dt; % length of the simulation in time steps
external_signal_intensity = 0; % units; (spikes/ms)/cell 
external_signal = ones(M,1) * external_signal_intensity * net_COBN.Dt;
SEED_OU = 1; % positive integer number
external_noise = OU_process(M, net_COBN.Dt, 16, 0.16*net_COBN.Dt, SEED_OU);
INPUT2E = external_signal + external_noise;
INPUT2I = INPUT2E;
SEED_connections = 2; % positive integer number
SEED_poisson = 3; % positive integer number
[E2EI,I2EI,eFR,iFR,SPN] = code_COBN(net_COBN, INPUT2E, INPUT2I, SEED_connections, SEED_poisson);

%% Plotting LFP
%   Note that in our model LFP = eRm*(I2EI-E2EI), where eRm is the membrane
%   resistance of the excitatory neurons (see paper for explanation).
lfp = net_COBN.eRm*(I2EI-E2EI);
time = 0:0.05:4499.95;
figure;
plot(time,lfp,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('LFP [mV]','FontSize',20);
saveas(gcf,'Figs/LFP.png');

%% Plotting FR
Z = smooth(double(eFR)/0.05,100,'moving');%%what filter should i use?
figure;
plot(time,Z,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('Firing rate (spikes/ms)','FontSize',20);
saveas(gcf,'Figs/EFR.png');

Z = smooth(double(iFR)/0.05,100,'moving');%%what filter should i use?
figure;
plot(time,Z,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('Firing rate (spikes/ms)','FontSize',20);
saveas(gcf,'Figs/IFR.png');


%% Plotting spike times:
[I,J] = find(SPN>0);
figure;
hold on;
plot(time(J(1)),I(1),'b.');%dummy for legend
plot(time(J(1)),I(1),'r.');%dummy for legend
plot(time(J(I<4001)),I(I<4001),'b.');
plot(time(J(I>4000)),I(I>4000),'r.');
hold off;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('Neuron','FontSize',20);
[h,icons] = legend('Excitatory','Inhibitory','FontSize',15,'Location','NorthEastOutside');
icons = findobj(icons,'Type','line');
icons = findobj(icons,'Marker','none','-xor');
set(icons,'MarkerSize',30);
saveas(gcf,'Figs/Raster.png');