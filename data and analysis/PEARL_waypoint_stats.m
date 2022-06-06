clear all;
close all;

%---------------------------------------------------------------------%
% Code for PEARL waypoint track plotting and statistics. See 
% PEARL_waypoint_stats_plotting.m for bar graphs of statistics 
% computed by this script.
% 
% See the 'Set Parameters for Selected Waypoint Pattern' section for
% the necessary log files for each waypoint pattern.
%---------------------------------------------------------------------%

MISSION = "Lawnmower";  %Valid entries: "Star", "Perimeter", "Figure-Eight", "Multi-Behavior, "Lawnmower"
PRINT_POWER = 1;  %Compute and print power statistics for each waypoint mission

%% Set Parameters for Selected Waypoint Pattern
if MISSION=="Star"
    %STAR
    mission = "WAYPOINT";
    waypointsX = [35 0 -15 0 -40 0 10 0];     %star X
    waypointsY = [15 0 25 0 -20 0 -25 0];     %star Y
    % dates = ["25_3_2021_____14_19_12","25_3_2021_____14_35_08","27_3_2021_____14_41_16","27_3_2021_____14_53_27","2_4_2021_____10_49_56","2_4_2021_____11_05_53","2_4_2021_____11_18_58"];
    dates = ["2_4_2021_____10_49_56","2_4_2021_____11_05_53","2_4_2021_____11_18_58"];
elseif MISSION=="Perimeter"
    %PERIMETER
    mission = "WAYPOINT";
    waypointsX = [-40 -50 -30 5 30 45 35 10 -15 -40];    %perimeter X
    waypointsY = [10 -15 -25 -25 -15 10 25 30 25 10];    %perimeter Y
    % dates = ["24_3_2021_____14_49_26","30_3_2021_____15_32_04","30_3_2021_____15_45_20","30_3_2021_____16_11_26","30_3_2021_____16_22_51","31_3_2021_____14_50_14","31_3_2021_____15_16_48"];
    dates = ["30_3_2021_____15_32_04","30_3_2021_____15_45_20","30_3_2021_____16_11_26","30_3_2021_____16_22_51","31_3_2021_____14_50_14","31_3_2021_____15_16_48"];
elseif MISSION=="Figure-Eight"
    %FIGURE-EIGHT
    mission = "WAYPOINT";
    waypointsX = [30 40 10 -20 -40 -30];     %figure-eight X
    waypointsY = [-15 10 25 -30 -20 10];     %figure-eight Y
%     dates = ["25_3_2021_____13_52_14","25_3_2021_____14_07_52","31_3_2021_____16_26_50","31_3_2021_____16_13_05","2_4_2021_____14_57_36","2_4_2021_____15_10_36"];
    dates = ["31_3_2021_____16_26_50","31_3_2021_____16_13_05","2_4_2021_____14_57_36","2_4_2021_____15_10_36"];
elseif MISSION=="Multi-Behavior"
    %LONG
    mission = "SQUARE";
    waypointsX = [-40 -50 -40 -70 -40 -30 -40 -15 -40 -50 -65 -70 -55 -30 -15 -15 -25 -50]; %long mission X
    waypointsY = [-15 15 -15 -25 -15 -40 -15 -5 -15 15 0 -25 -40 -40 -25 -5 10 15];  %long mission Y
    waypointsX = [waypointsX waypointsX waypointsX]; waypointsY = [waypointsY waypointsY waypointsY]; %repeat pattern three times
    dates = ["8_4_2021_____14_00_49"];
elseif MISSION=="Lawnmower"
    %LAWNMOWER
    mission = "WAYPOINT";
    dates = ["4_4_2021_____12_25_55"];
    waypointsX = [-70 -50 -40 -60 -50 -30 -20 -40 -30 -10 0 -20 -10 10 20 0, 10 30 40 20 30 45 -60 -65 40 35 -70];
    waypointsY = [5 -40 -36 9 13 -32 -28 17 21 -24 -20 25 29 -16 -12 33 37 -8 -4 41 45 10 -30 -20 25 35 -5];
else
    disp("Unrecognized mission name!");
end

all_rmse = [];
all_dist = [];
all_dev = [];

%%
for i = 1:length(dates)
    
    files_folder = "PEARL_logfiles";
    mission_folder = "LOG_PEARL_" + mission + '_' + dates(i);
    data_folder = files_folder + '/' + mission_folder + '/' + mission_folder + "_alvtmp/";
    
    %% Load Variables
    %PEARL variables
    navX = readtable(data_folder + "NAV_X.klog", 'FileType', 'text');
    navY = readtable(data_folder + "NAV_Y.klog", 'FileType', 'text');
    dHeading = readtable(data_folder + "DESIRED_HEADING.klog", 'FileType', 'text');
    gpsHeading = readtable(data_folder + "GPS_HEADING_GPRMC.klog", 'FileType', 'text');
    lThrust = readtable(data_folder + "REPORTED_LEFT_THRUST.klog", 'FileType', 'text');
    rThrust = readtable(data_folder + "REPORTED_RIGHT_THRUST.klog", 'FileType', 'text');
    
    %Charge controller variables
    bSOC = readtable(data_folder + "CHG_BATTERY_SOC.klog", 'FileType', 'text');
    bPower = readtable(data_folder + "CHG_BATTERY_POWER.klog", 'FileType', 'text');
    lPower = readtable(data_folder + "CHG_LOAD_POWER.klog", 'FileType', 'text');
    pvPower = readtable(data_folder + "CHG_PV_POWER.klog", 'FileType', 'text');
    bCurr = readtable(data_folder + "CHG_BATTERY_CURRENT.klog", 'FileType', 'text');
    lCurr = readtable(data_folder + "CHG_LOAD_CURRENT.klog", 'FileType', 'text');
    pvCurr = readtable(data_folder + "CHG_PV_CURRENT.klog", 'FileType', 'text');
    bNetCurr = readtable(data_folder + "CHG_BATTERY_NET_CURRENT.klog", 'FileType', 'text');
    bVolt = readtable(data_folder + "CHG_BATTERY_VOLTAGE.klog", 'FileType', 'text');
    lVolt = readtable(data_folder + "CHG_LOAD_VOLTAGE.klog", 'FileType', 'text');
    pvVolt = readtable(data_folder + "CHG_PV_VOLTAGE.klog", 'FileType', 'text');
    
    %Convert data to arrays
    time = table2array(navX(:,1));
    chg_time = table2array(bSOC(:,1));
    dHtime = table2array(dHeading(:,1));
    gHtime = table2array(gpsHeading(:,1));
    Ttime = table2array(lThrust(:,1));
    navX = table2array(navX(:,4));
    navY = table2array(navY(:,4));
    dHeading = table2array(dHeading(:,4));
    gpsHeading = table2array(gpsHeading(:,4));
    lThrust = table2array(lThrust(:,4));
    rThrust = table2array(rThrust(:,4));
    
    
    bSOC = table2array(bSOC(:,4));
    bPower = table2array(bPower(:,4));
    lPower = table2array(lPower(:,4));
    pvPower = table2array(pvPower(:,4));
    bCurr = table2array(bCurr(:,4));
    lCurr = table2array(lCurr(:,4));
    pvCurr = table2array(pvCurr(:,4));
    bNetCurr = table2array(bNetCurr(:,4));
    bVolt = table2array(bVolt(:,4));
    lVolt = table2array(lVolt(:,4));
    pvVolt = table2array(pvVolt(:,4));
   
    %% Split PEARL Track
    %--------------------------------%
    % Determine when PEARL 'captures' a waypoint and sets next waypoint as
    % target so that tracking performance can be individually evaluated
    % on each segment of the waypoint mission. Creates arrays 'pointsX' and
    % 'pointsY' which contain the data indices where PEARL hits each waypoint. 
    %--------------------------------%
    max_dist = 0;
    pointsX = [0];
    pointsY = [0];
    index = 1;
    for j = 1:length(waypointsX)
        xRef = waypointsX(j);
        yRef = waypointsY(j);
       for k = 1:length(navX)-1
          xVal = navX(k);
          yVal = navY(k);
          xVal_1 = navX(k+1);
          yVal_1 = navY(k+1);
          metric = sqrt((xRef-xVal)^2 + (yRef-yVal)^2);
          metric_1 = sqrt((xRef-xVal_1)^2 + (yRef-yVal_1)^2);
          if (metric_1 > metric && metric < 10 && k > pointsX(end)) || (k == length(navX) - 1)
             index = k;
             break
          end
       end
       pointsX = [pointsX index];
       pointsY = [pointsY index];
    end
    pointsX(1) = [];
    pointsY(1) = [];
    
    %% Compute PEARL Track Statistics
    rmse_segment = zeros(length(waypointsX)-1,1);
    xValsALL = [];
    yValsALL = [];
    xIdealALL = [];
    yIdealALL = [];
    distance = [];
    %Find RMSE and max deviation from ideal path for each segment
    for j = 1:length(waypointsX)-1
       error = 0;
       xVals = navX(pointsX(j):pointsX(j+1));
       yVals = navY(pointsY(j):pointsY(j+1));
       
       xRef = [waypointsX(j) waypointsX(j+1)];
       yRef = [waypointsY(j) waypointsY(j+1)];
       
       m = (yRef(2) - yRef(1))/(xRef(2) - xRef(1));
       b = yRef(1) - m*xRef(1);
       mi = -1/m;
       bi = yVals - mi*xVals;
       xIdeal = (b - bi)/(mi - m);
       yIdeal = m*xIdeal + b;
       
       xValsALL = [xValsALL; xVals];
       yValsALL = [yValsALL; yVals];
       xIdealALL = [xIdealALL; xIdeal];
       yIdealALL = [yIdealALL; yIdeal];
       
       d2 = (xVals - xIdeal).^2 + (yVals - yIdeal).^2;
       dist = max(sqrt(d2));
       if dist>max_dist
          max_dist = dist;
       end
       
       rmse_segment(j) = sqrt(sum(d2)/length(d2));
    end
    d2_total = (xValsALL - xIdealALL).^2 + (yValsALL - yIdealALL).^2;
    d2_total = rmmissing(d2_total);
    rmse = sqrt(sum(d2_total)/length(d2_total));
    all_rmse = [all_rmse, rmse];
    all_dist = [all_dist, max_dist];
    
    %Compute ideal path length
    points_ideal = [waypointsX' waypointsY'];
    points_actual = [navX(pointsX(1):pointsX(end)) navY(pointsY(1):pointsY(end))];
    diff_ideal = [diff(points_ideal,1); points_ideal(end,:) - points_ideal(1,:)];
    diff_actual = [diff(points_actual,1); points_actual(end,:) - points_actual(1,:)];
    dist_ideal = sum(sqrt(sum(diff_ideal.*diff_ideal,2)));
    dist_actual = sum(sqrt(sum(diff_actual.*diff_actual,2)));
    all_dev = [all_dev, dist_actual - dist_ideal];
    
    disp("---------------------------------------")
    disp(["PATTERN: " + num2str(i)])
    disp(["Ideal path length: " + num2str(dist_ideal) + " m"])
    disp(["Actual path length: " + num2str(dist_actual) + " m"])
    disp(["Path length difference: " + num2str(dist_actual - dist_ideal) + " m"])
    %Compute and print power statistics if desired
    if PRINT_POWER==1
        load_energy = sum(lPower)/3600;
        pv_energy = sum(pvPower)/3600;
        net_energy = pv_energy - load_energy;
        total_energy = 1280;
        mission_time = (time(end) - time(1))/60;
        disp(["Mission elapsed time: " + num2str(mission_time) + " min"])
        disp(["Used energy: " + num2str(load_energy) + " Wh"])
        disp(["Generated energy: " + num2str(pv_energy) + " Wh"])
        disp(["Net energy: " + num2str(net_energy) + " Wh"])
        disp(["Battery usage: " + num2str(round(net_energy/total_energy * 100,2)) + "%"])
        disp(["Worst-case battery usage per hour: " + num2str(round((-load_energy/total_energy*100)*(60/mission_time),2)) + "%"])
        disp(["Wh used per minute: " + num2str(load_energy/mission_time)])
        disp(["Wh generated per minute: " + num2str(pv_energy/mission_time)])
    end
    
    %% Plotting
    
    figure(1)
    hold on
    if i == 1
        plot(navX,navY,'g','LineWidth',1.2,'DisplayName','PEARL Track')
        plot(waypointsX,waypointsY,'b--o','LineWidth',1.5,'DisplayName','Ideal Track')
        plot(navX(pointsX),navY(pointsY),'r.','MarkerSize',15,'HandleVisibility','off')
    else
        plot(navX,navY,'g','LineWidth',1.2,'HandleVisibility','off')
        plot(waypointsX,waypointsY,'b--o','LineWidth',1.5,'HandleVisibility','off')
        plot(navX(pointsX),navY(pointsY),'r.','MarkerSize',15,'HandleVisibility','off')
    end
    for m = 1:length(waypointsX)
        circle(waypointsX(m),waypointsY(m),4);
    end
    grid on
    legend
    x = xlabel('Local X Coordinate [m]');
    set(x,'FontSize',14);
    y = ylabel('Local Y Coordinate [m]');
    set(y,'FontSize',14);
    t = title([MISSION + " Mission"]);
    set(t,'FontSize',14);
    axis equal
%    axis([-105 5 -50 20])
%    xticks([-100 -90 -80 -70 -60 -50 -40 -30 -20 -10 0])
%     axis([-55 55 -35 35])
%     xticks([-50 -40 -30 -20 -10 0 10 20 30 40 50])
     axis([-85 50 -50 60])
%     xticks([-50 -40 -30 -20 -10 0 10 20 30 40 50])

    figure(4+i)
    hold on
    plot(chg_time/60,lPower,'LineWidth',1.5,'DisplayName','Load Power')
    plot(chg_time/60,pvPower,'LineWidth',1.5,'DisplayName','PV Power')
    ylim([0 300])
    legend
    grid on
    xlabel('Mission Elapsed Time [min]');ylabel('Power [W]');
    title('PEARL Power Consumption and Generation')
    
end

disp("---------------------------------------")
if i>1
    disp(["Cumulative Statistics for all " + num2str(i) + " patterns:"])
end
disp(["[Average, Std Dev] RMSE: [" + num2str(mean(all_rmse)) + " m, " + num2str(std(all_rmse)) + " m]"])
disp(["[Average, Std Dev] Max Deviation: [" + num2str(mean(all_dist)) + " m, " + num2str(std(all_dist)) + " m]"])
disp(["[Average, Std Dev] Path Difference: [" + num2str(mean(all_dev)) + " m, " + num2str(std(all_dev))+ " m]"])



function h = circle(x,y,r)
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit,yunit,'k--','HandleVisibility','off');
hold off
end


