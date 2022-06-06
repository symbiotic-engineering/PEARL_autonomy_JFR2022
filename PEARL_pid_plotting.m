clear all
% close all

%---------------------------------------------------------------------%
% Code for PEARL PID heading controller performance plots. To generate 
% the plots used in the paper, run the script twice, once with GAINS 
% set to "Tuned" and once with GAINS set to "Untuned".
% 
% Requires the following log files:
%   LOG_PEARL_SIMPLE_23_3_2021_____15_25_19  (Untuned gains example)
%   LOG_PEARL_SQUARE_24_3_2021_____13_46_33  (Tuned gains example)
%---------------------------------------------------------------------%

GAINS = "Tuned";  %Valid entries: "Untuned", "Tuned"

%% Setup Parameters for Selected Mission
if GAINS=="Untuned"
    mission = "SIMPLE";
    dates = ["23_3_2021_____15_25_19"];
elseif GAINS=="Tuned"
    mission = "SQUARE";
    waypointsX = [-40 -40 -10 -10 -40];    %square
    waypointsY = [0 -30 -30 0 0];        %square
    dates = ["24_3_2021_____13_46_33"];
end

files_folder = "PEARL_logfiles";
mission_folder = "LOG_PEARL_" + mission + '_' + dates;
data_folder = files_folder + '/' +  mission_folder + '/' + mission_folder + "_alvtmp/";

%% Load Variables
navX = readtable(data_folder + "NAV_X.klog", 'FileType', 'text');
navY = readtable(data_folder + "NAV_Y.klog", 'FileType', 'text');
dHeading = readtable(data_folder + "DESIRED_HEADING.klog", 'FileType', 'text');
gpsHeading = readtable(data_folder + "GPS_HEADING_GPRMC.klog", 'FileType', 'text');

%Convert data to arrays
time = table2array(navX(:,1))/60;
navX = table2array(navX(:,4));
navY = table2array(navY(:,4));
dHtime = table2array(dHeading(:,1))/60;
gHtime = table2array(gpsHeading(:,1))/60;
dHeading = table2array(dHeading(:,4));
gpsHeading = table2array(gpsHeading(:,4)) - 13;

if GAINS=="Untuned"
    waypointsX = [navX(1) -20];
    waypointsY = [navY(1) -7];
end

%% Plotting
fontSize = 15;

figure(1)
if GAINS=="Untuned"
    subplot(1,2,1)
    axis equal
    axis([-85 -15 -45 25])
elseif GAINS=="Tuned"
    subplot(1,2,2)
    axis equal
    axis([-60 10 -45 25])
end
hold on
plot(navX,navY,'g','LineWidth',1.2,'DisplayName','PEARL Track')
plot(waypointsX,waypointsY,'b--o','LineWidth',1.5,'DisplayName','Ideal Track')
for m = 1:length(waypointsX)
    circle(waypointsX(m),waypointsY(m),4);
end
% axis square
grid on
legend
x = xlabel('Local X Coordinate [m]');
set(x,'FontSize',12);
y = ylabel('Local Y Coordinate [m]');
set(y,'FontSize',12);
t = title([GAINS + " PID Gains"]);
set(t,'FontSize',12);

figure(2)
if GAINS=="Untuned"
    subplot(2,1,1)
    axis([0.27 5.6 0 360])
elseif GAINS=="Tuned"
    subplot(2,1,2)
    axis([0.4 4.8 0 360])
end
hold on
plot(dHtime,dHeading,'LineWidth',1.5,'DisplayName','Desired Heading')
plot(gHtime,gpsHeading,'LineWidth',1.5,'DisplayName','Reported GPS Heading')
legend
grid on
t1 = title(["Heading Controller Performance - " + GAINS]);
set(t1,'FontSize',fontSize);
x1 = xlabel('Mission Elapsed Time [min]');
set(x1,'FontSize',fontSize);
y1 = ylabel('Heading Angle [deg]');
set(y1,'FontSize',fontSize);

function h = circle(x,y,r)
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit,yunit,'k--','HandleVisibility','off');
hold off
end