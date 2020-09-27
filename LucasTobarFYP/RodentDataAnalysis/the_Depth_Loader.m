function OUTPUT = the_Depth_Loader
%% Basic Function
%cd([base '\Master Analysis']);
%load('lucas_depth_Master.mat','depth_Master');
load('Lucas_DATA.mat','DATA');
%OUTPUT = depth_Master;
OUTPUT = DATA;
if nargin>1
    % Can add more functionality here at any point
end
end