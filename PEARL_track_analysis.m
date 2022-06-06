clear all;
close all;

%---------------------------------------------------------------------%
% Code for PEARL Track image analysis. 
% 
% Log files used to produce plot in OCEANS paper:
%   LOG_PEARL_SIMPLE_29_3_2021_____15_30_11  (Rotational thrust test)
% 
%---------------------------------------------------------------------%

mission = "SIMPLE";
dates = ["29_3_2021_____15_30_11"];

ii = 1;

files_folder = "PEARL_logfiles";
mission_folder = "LOG_PEARL_" + mission + '_' + dates(ii) ;
data_folder = files_folder + '/' + mission_folder + '/' + mission_folder + "_alvtmp/";

%% Load Variables
%PEARL variables
navX = readtable(data_folder + "NAV_X.klog", 'FileType', 'text');
navY = readtable(data_folder + "NAV_Y.klog", 'FileType', 'text');

%Account for different sampling rates of IMU and GPS data
startGPS = 97;
lastGPS = 465;

%Convert data to arrays
navX = table2array(navX(startGPS:lastGPS,4));
navY = table2array(navY(startGPS:lastGPS,4));

fontSize = 15;

%% PEARL Track
figure
hold on
plot(navX,navY,'LineWidth',1.5,'DisplayName','PEARL Track');
grid on
x = xlabel('Local X Position [m]');
set(x,'FontSize',fontSize);
y = ylabel('Local Y Position [m]');
set(y,'FontSize',fontSize);
axis ([-81 -52 -23 6])
axis square
t = title('PEARL Track');
set(t,'FontSize',fontSize);