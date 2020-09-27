clear all; close all;clc;
mex -setup C
mex -setup C++
mex code_CUBN.c ran1.c gasdev.c;
parameters_CUBN; % to generate the structure net_CUBN with all the parameters of the network
simulation_length = 2000; % units: (ms)
M = simulation_length/net_CUBN.Dt; % length of the simulation in time steps
external_signal_intensity = 1.5; % units; (spikes/ms)/cell 
external_signal = ones(M,1) * external_signal_intensity * net_CUBN.Dt;
SEED_OU = 1; % positive integer number
INPUT2E = [250*randn(4000,M);100*randn(1000,M)];
INPUT2E(:,M/2:M/2+4) = INPUT2E(:,M/2:M/2+4)-100000;
INPUT2E(:,M/2+7:M/2+11) = INPUT2E(:,M/2+7:M/2+11)+100000;
INPUT2I = INPUT2E;
SEED_connections = 2; % positive integer number
SEED_poisson = 3; % positive integer number
[E2EI,I2EI,eFR,iFR,SPN] = code_CUBN(net_CUBN, INPUT2E, INPUT2I, SEED_connections, SEED_poisson);

%% Plotting LFP
%   Note that in our model LFP = eRm*(I2EI-E2EI), where eRm is the membrane
%   resistance of the excitatory neurons (see paper for explanation).
lfp = net_CUBN.eRm*(I2EI-E2EI);
time = 0:net_CUBN.Dt:simulation_length-net_CUBN.Dt;
figure;
plot(time,lfp,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('LFP [mV]','FontSize',20);
axis([xlim -10^5 10^5])
saveas(gcf,'Figs/LFP.png');

%% Plotting FR
Z = smooth(double(eFR)/net_CUBN.Dt,20/net_CUBN.Dt,'moving');%%what filter should i use?
figure;
plot(time,Z,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('Firing rate (spikes/ms)','FontSize',20);
title('E');
%saveas(gcf,'Figs/EFR.png');

Z = smooth(double(iFR)/net_CUBN.Dt,20/net_CUBN.Dt,'moving');%%what filter should i use?
figure;
plot(time,Z,'-b');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.5]);
xlabel('time [ms]','FontSize',20);
ylabel('Firing rate (spikes/ms)','FontSize',20);
title('I')
%saveas(gcf,'Figs/IFR.png');


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
axis([0 simulation_length 0 5000]);
saveas(gcf,'Figs/Raster.png');