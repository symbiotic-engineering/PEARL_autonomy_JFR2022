clear all;
close all;

%---------------------------------------------------------------------%
% Code for PEARL analyzing all good sun-tracking tests. 
% 
% See below for the necessary log files.
%---------------------------------------------------------------------%

mission = "SIMPLE";
plotOn = 0;
dispStats = 0;

%Afternoon Sun-Tracking Tests [SUN-TRACKING ON,SUN-TRACKING OFF]
%titleString = "Afternoon";
afternoon_on = ["9_4_2021_____14_24_16", "9_4_2021_____15_07_10", ...
    "10_4_2021_____14_36_51","10_4_2021_____15_19_23",...
    "10_4_2021_____16_02_27","14_4_2021_____14_02_26"];
afternoon_off = ["9_4_2021_____14_45_56", "9_4_2021_____15_29_03",...
    "10_4_2021_____14_58_01","10_4_2021_____15_40_42",...
    "10_4_2021_____16_23_34","14_4_2021_____14_23_59"];
% dates = ["9_4_2021_____14_24_16","9_4_2021_____14_45_56"];
% dates = ["9_4_2021_____15_07_10","9_4_2021_____15_29_03"];
% dates = ["10_4_2021_____14_36_51","10_4_2021_____14_58_01"];
% dates = ["10_4_2021_____15_19_23","10_4_2021_____15_40_42"];
% dates = ["10_4_2021_____16_02_27","10_4_2021_____16_23_34"];
% dates = ["14_4_2021_____14_02_26","14_4_2021_____14_23_59"];

%Morning Sun-Tracking Tests [SUN-TRACKING ON,SUN-TRACKING OFF]
%titleString = "Morning";
morning_on = ["15_4_2021_____07_16_10","15_4_2021_____07_59_15","15_4_2021_____08_57_54"];
morning_off = ["15_4_2021_____07_38_20","15_4_2021_____08_36_48"];

% dates = ["15_4_2021_____07_16_10","15_4_2021_____07_38_20"];
% dates = ["15_4_2021_____07_59_15","15_4_2021_____08_36_48"];
% dates = ["15_4_2021_____08_57_54"];

tests = "Morning ON";

if tests == "Afternoon ON"
    dates = afternoon_on;
    titleString = "Afternoon Test Sun-Tracking ON";
    dispString = "SUN-TRACKING mode ON:";
elseif tests == "Afternoon OFF"
    dates = afternoon_off;
    titleString = "Afternoon Test Sun-Tracking OFF";
    dispString = "SUN-TRACKING mode OFF:"; 
elseif tests == "Morning ON"
    dates = morning_on;
    titleString = "Morning Test Sun-Tracking ON";
    dispString = "SUN-TRACKING mode ON:";
elseif tests == "Morning OFF"
    dates = morning_off;
    titleString = "Morning Test Sun-Tracking OFF";
    dispString = "SUN-TRACKING mode OFF:";
end

for ii = 1:length(dates)
    
    files_folder = "PEARL_logfiles";
    mission_folder = "LOG_PEARL_" + mission + '_' + dates(ii) ;
    data_folder = files_folder + '/' + mission_folder + '/' + mission_folder + "_alvtmp/";
    
    %% Load Variables
    %Charge Controller Variables
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
    %PEARL Variables
    dHeading = readtable(data_folder + "DESIRED_HEADING.klog", 'FileType', 'text');
    heading = readtable(data_folder + "IMU_HEADING.klog", 'FileType', 'text');    
    lThrust = readtable(data_folder + "REPORTED_LEFT_THRUST.klog", 'FileType', 'text');
    rThrust = readtable(data_folder + "REPORTED_RIGHT_THRUST.klog", 'FileType', 'text');
    %Sun Variables
    sHeading = readtable(data_folder + "SOLAR_HEADING.klog", 'FileType', 'text');
    sElevation = readtable(data_folder + "SOLAR_SUN_ELEVATION.klog", 'FileType', 'text');
    
    %Convert data to arrays
    chg_time = table2array(bSOC(:,1));
    dHtime = table2array(dHeading(:,1));
    sTime = table2array(sElevation(:,1));
    time = table2array(lThrust(:,1));
    lTime = table2array(lPower(:,1));
    bTime = table2array(bPower(:,1));
    pvTime = table2array(pvPower(:,1));
    bNCTime = table2array(bNetCurr(:,1));
    bVTime = table2array(bVolt(:,1));
    
    bSOC = table2array(bSOC(:,4))*100;
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
    bPowerCalc = bNetCurr.*bVolt;
    
    dHeading = table2array(dHeading(:,4));
    heading = table2array(heading(:,4));
    sHeading = table2array(sHeading(:,4));
    sElevation = table2array(sElevation(:,4));
    
    lThrust = table2array(lThrust(:,4));
    rThrust = table2array(rThrust(:,4));
    
    netH = abs(length(rThrust) - length(heading));
    heading = heading(1:length(heading)-netH);
    netS = abs(length(sHeading) - length(sElevation));
    sHeading = sHeading(1:length(sHeading) - netS);
    
    %% Plotting
    if plotOn == 1 % NEED TO FIX
        fontSize = 15;
    
        figure(ii)
        subplot(2,1,1)
        yyaxis left
        hold on
        plot(chg_time/60,lPower,'b','LineWidth',1.5,'DisplayName','Load Power')
        plot(chg_time/60,pvPower,'g-','LineWidth',1.5,'DisplayName','PV Power')
        ylim([0 120])
        legend
        grid on
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        y = ylabel('Power [W]');
        set(y,'FontSize',fontSize);
        t = title(["PEARL Station-keeping "+titleString]);
        set(t,'FontSize',fontSize);
        set(gca,'YColor',[0 0 0]);
        yyaxis right
        plot(chg_time/60,bSOC,'LineWidth',1.5,'DisplayName','Battery State of Charge')
        ylim([0 102])
        y = ylabel('Battery SOC [%]');
        set(y,'FontSize',fontSize);
        xlim([0 18])

        subplot(2,1,2)
        yyaxis left
        hold on
        plot(sTime/60,sHeading,'b','LineWidth',1.5,'DisplayName','Sun Heading')
        plot(time/60,heading,'k-','LineWidth',1.5,'DisplayName','PEARL Heading')
        legend
        grid on
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        y = ylabel('Heading Angle [deg]');
        set(y,'FontSize',fontSize);
        ylim([0 380])
        set(gca,'YColor',[0 0 0]);
        yyaxis right
        plot(sTime/60,sElevation,'LineWidth',1.5,'DisplayName','Solar Elevation Angle')
        y = ylabel('Solar Elevation Angle [deg]');
        set(y,'FontSize',fontSize);
        ylim([0 60])
        xlim([0 18])
    end
    %% Power Statistics
    
    load_energy(ii) = trapz(lTime,lPower)/3600; %sum(lPower)/3600; 
    pv_energy(ii) = trapz(pvTime,pvPower)/3600; %sum(pvPower)/3600;
    net_energy(ii) = pv_energy(ii) - load_energy(ii);
    total_energy(ii) = 1280;
    mission_time(ii) = (time(end) - time(1))/60;
    battery_start_SOC(ii) = bSOC(1);
    battery_end_SOC(ii) = bSOC(end);
    battery_energy_SOC(ii) = (bSOC(end)-bSOC(1))/100*total_energy(ii);
    battery_energy(ii) = trapz(bTime,bPower)/3600; %sum(bPower)/3600;
    battery_energy_Calc(ii) = trapz(bTime,bPowerCalc)/3600; %calculated from net current * voltage

    start_pv_power = min(find(pvTime > (2*60)));
    end_pv_power = min(find(pvTime > (18*60)))-1;
    pvPower_for_std = pvPower(start_pv_power:end_pv_power);
    pv_power_std(ii) = std(pvPower_for_std);
    
    rmse_heading = [];
    desired = [];
    %interpolate heading onto same time
    %[C,ia,ic] = unique(A) also returns index vectors ia and ic using any of the previous syntaxes.
    %If A is a vector, then C = A(ia) and A = C(ic).
    [sTime_unique,sTime_unique_ind,sTime_ind] = unique(sTime);
    sHeading_unique = sHeading(sTime_unique_ind);
    sHeading_int = interp1(sTime_unique, sHeading_unique, time);
    %start after 2mins and end at 18mins:
    start_rmse = min(find(time > (2*60)));
    end_rmse = min(find(time > (18*60)))-1;
    heading_for_rmse = heading(start_rmse:end_rmse);
    sHeading_for_rmse = sHeading(start_rmse:end_rmse);
    if strcmp(dates(ii),"15_4_2021_____07_16_10") || strcmp(dates(ii),"15_4_2021_____07_38_20") || strcmp(dates(ii),"15_4_2021_____08_36_48") 
       desired = 360 + sHeading_for_rmse;
       measured = heading_for_rmse;
    elseif strcmp(dates(ii),"15_4_2021_____07_59_15") || strcmp(dates(ii),"15_4_2021_____08_57_54")
       desired = 360 + sHeading_for_rmse;
       measured = heading_for_rmse;
       measured(measured < 150) = measured(measured < 150)+360;
    elseif strcmp(dates(ii),"9_4_2021_____15_29_03") || strcmp(dates(ii),"14_4_2021_____14_23_59")
       desired = sHeading_for_rmse;
       measured = heading_for_rmse;
       measured(measured < 150) = measured(measured < 150)+360;
    elseif strcmp(dates(ii),"10_4_2021_____15_40_42") || strcmp(dates(ii),"10_4_2021_____16_23_34")
       desired = sHeading_for_rmse;
       measured = heading_for_rmse;
       measured(measured > 150) = measured(measured > 150)-360;
    else 
       desired = sHeading_for_rmse;
       measured = heading_for_rmse;
    end
    %figure; plot(time(start_rmse:end_rmse), heading_for_rmse, time(start_rmse:end_rmse), sHeading_for_rmse,'--')
    %figure; plot(time(start_rmse:end_rmse), heading_for_rmse, time(start_rmse:end_rmse), sHeading_for_rmse,'--',time(start_rmse:end_rmse), desired,':',time(start_rmse:end_rmse), measured,'--')
    %figure; plot(time(start_rmse:end_rmse), heading_for_rmse, time(start_rmse:end_rmse), sHeading_for_rmse,'--',time(start_rmse:end_rmse), desired,':',time(start_rmse:end_rmse), measured,'--')
    rmse_heading = desired - measured;
    rmse(ii) = rms(rmse_heading);
    
    if dispStats == 1
        disp("-----------------------------------------------")
        disp("Power statistics with " + dispString)
        disp(["Mission elapsed time: " + num2str(mission_time(ii)) + " min"])
        disp(["Used energy: " + num2str(load_energy(ii)) + " Wh"])
        disp(["Generated energy: " + num2str(pv_energy(ii)) + " Wh"])
        disp(["Net energy: " + num2str(net_energy(ii)) + " Wh"])
        disp(["Battery usage: " + num2str(round(net_energy(ii)/total_energy(ii) * 100,2)) + "%"])
        disp(["Worst-case battery usage per hour: " + num2str(round((-load_energy(ii)/total_energy(ii)*100)*(60/mission_time(ii)),2)) + "%"])
        disp(["Wh used per minute: " + num2str(load_energy(ii)/mission_time(ii))])
        disp(["Wh generated per minute: " + num2str(pv_energy(ii)/mission_time(ii))])
        disp(["RMS heading error: " + num2str(rmse(ii))])
        disp(["PV Power STD: " + num2str(pv_power_std(ii))])
    end
    
end
disp("-----------------------------------------------")
disp("-----------------------------------------------")
disp("Power statistics with " + dispString)
disp("-----------------------------------------------")
disp("Load Energy [Wh] - MEAN: " + num2str(mean(load_energy)) + ", STD: " +num2str(std(load_energy)))
disp("PV Energy [Wh] - MEAN: " + num2str(mean(pv_energy)) + ", STD: " +num2str(std(pv_energy)))
disp("Net Energy [Wh] - MEAN: " + num2str(mean(net_energy)) + ", STD: " +num2str(std(net_energy)))
disp("Battery Energy [Wh] - MEAN: " + num2str(mean(battery_energy)) + ", STD: " +num2str(std(battery_energy)))
disp("Battery Energy  Calc [Wh] - MEAN: " + num2str(mean(battery_energy_Calc)) + ", STD: " +num2str(std(battery_energy_Calc)))
disp("Mission Time [mins] - MEAN: " + num2str(mean(mission_time)) + ", STD: " +num2str(std(mission_time)))
disp("RMS heading error - MEAN: " + num2str(mean(rmse)) + ", STD: " +num2str(std(rmse)))
disp("PV Power STD - MEAN: " + num2str(mean(pv_power_std)) + ", STD: " +num2str(std(pv_power_std)))

load_energy
pv_energy
net_energy
battery_energy
battery_energy_Calc
mission_time
rmse
pv_power_std
%%
%Averages and high/low errors for plotting
% afternoon on, afternoon off, morning on, morning off
% load_energy_means = [6.0869 4.0826 5.3352 4.2856];
% load_energy_std = [1.2580 0.1034 0.8368 0.5605];
% load_energy_std_low = -load_energy_std;
% load_energy_std_high = load_energy_std;
% 
% pv_energy_means = [6.4655 3.7088 23.6649 22.3344];
% pv_energy_std = [1.1896 0.3739 11.0620 7.5475];
% pv_energy_std_low = -pv_energy_std;
% pv_energy_std_high = pv_energy_std;
% 
% net_energy_means = [0.3785 -0.3738 18.3297 18.0488];
% net_energy_std = [0.6014 0.3306 10.2354 6.9871];
% net_energy_std_low = -net_energy_std;
% net_energy_std_high = net_energy_std;
% 
% battery_start_SOC_means = [98 99.8333 83 84.5000];
% battery_start_SOC_std = [1.6733 0.4082 9 6.3640];
% battery_start_SOC_std_low = -battery_start_SOC_std;
% battery_start_SOC_std_high = battery_start_SOC_std;
% 
% battery_end_SOC_means = [99.8333 98.1667 86.6667 86.5000];
% battery_end_SOC_std = [0.4082 1.7224 6.0277 4.9497];
% battery_end_SOC_std_low = -battery_end_SOC_std;
% battery_end_SOC_std_high = battery_end_SOC_std;
% 
% battery_energy_means = [23.4667 -21.3333 46.9333 25.6000];
% battery_energy_std = [20.5066 20.9023 39.1046 18.1019];
% battery_energy_std_low = -battery_energy_std;
% battery_energy_std_high = battery_energy_std;

% morning on, morning off, afternoon on, afternoon off, 
load_energy_means = [5.3352 4.2856 6.0869 4.0826 ];
load_energy_std = [0.8368 0.5605 1.2580 0.1034 ];
load_energy_std_low = -load_energy_std;
load_energy_std_high = load_energy_std;

pv_energy_means = [23.6649 22.3344 6.4655 3.7088 ];
pv_energy_std = [11.0620 7.5475 1.1896 0.3739 ];
pv_energy_std_low = -pv_energy_std;
pv_energy_std_high = pv_energy_std;

net_energy_means = [18.3297 18.0488 0.3785 -0.3738 ];
net_energy_std = [10.2354 6.9871 0.6014 0.3306 ];
net_energy_std_low = -net_energy_std;
net_energy_std_high = net_energy_std;

battery_start_SOC_means = [83 84.5000 98 99.8333 ];
battery_start_SOC_std = [9 6.3640 1.6733 0.4082 ];
battery_start_SOC_std_low = -battery_start_SOC_std;
battery_start_SOC_std_high = battery_start_SOC_std;

battery_end_SOC_means = [86.6667 86.5000 99.8333 98.1667 ];
battery_end_SOC_std = [6.0277 4.9497 0.4082 1.7224 ];
battery_end_SOC_std_low = -battery_end_SOC_std;
battery_end_SOC_std_high = battery_end_SOC_std;

%WHERE DO BATTERY ENERGY MEANS COME FROM? SOMETHING WRONG HERE.... 5/7/2022
%MNH
battery_energy_means = [46.9333 25.6000 23.4667 -21.3333 ];
battery_energy_std = [39.1046 18.1019 20.5066 20.9023];
battery_energy_std_low = -battery_energy_std;
battery_energy_std_high = battery_energy_std;

rmse_means = [7.3506 51.8687 8.7218 146.5684];
rmse_std = [2.8290 0.6740 2.4614 53.7979];
rmse_std_low = -rmse_std;
rmse_std_high = rmse_std;

pv_power_std_means = [6.4645 6.4406 8.3700 8.3987];
pv_power_std = [4.3638 0.4679 3.4426 2.9732];
pv_power_std_low = -pv_power_std;
pv_power_std_high = pv_power_std;

%energy_means = [load_energy_means; pv_energy_means; net_energy_means; battery_energy_means];
%energy_err_low = [load_energy_std_low; pv_energy_std_low; net_energy_std_low; battery_energy_std_low];
%energy_err_high = [load_energy_std_high; pv_energy_std_high; net_energy_std_high; battery_energy_std_high];

% Removed battery energy because something wrong - does not make sense -
% 5/8/22 MNH
energy_means = [load_energy_means; pv_energy_means; net_energy_means];
energy_err_low = [load_energy_std_low; pv_energy_std_low; net_energy_std_low];
energy_err_high = [load_energy_std_high; pv_energy_std_high; net_energy_std_high];

figure(1)
xlabels = {'Load','PV','Net'};%,'Battery'}; 
b = bar(energy_means);
colors = [0 .45 .7;.8 .4 0;0 .6 .5;.8 .6 .7];
l = cell(1,4);
l{1}='Morning ON'; l{2}='Morning OFF';l{3}='Afternoon ON';l{4}='Afternoon OFF';
legend(b,l);
for i = 1:size(b,2)
   b(i).FaceColor = colors(i,:); 
end
set(gca,'xticklabel',xlabels)
ylabel('Energy [Wh]');
%ylim([0 13])
grid on
hold on
ngroups = size(energy_means, 1);
nbars = size(energy_means, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, energy_means(:,i), energy_err_low(:,i), energy_err_high(:,i), 'k.', 'LineWidth',1,'HandleVisibility','off');
end
hold off
for i = 1:nbars
    xtips = b(i).XEndPoints;
    ytips = b(i).YEndPoints + 0.6;
    ytips(2) = ytips(2) + 0.2;
    if i == 1
        ytips(2) = ytips(2) + 0.2;
    end
    labels = string(round(b(i).YData,1));
    text(xtips,ytips,labels,'BackgroundColor', 'White','HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
title('Sun-Tracking Test Energy Statistics')

%%

performance_means = [rmse_means; pv_power_std_means];
performance_error_low = [rmse_std_low; pv_power_std_low];
performance_error_high = [rmse_std_high; pv_power_std_high];

figure(2)
xlabels = {'Mean RMSE', 'Mean PV Power STD'}; 
b = bar(performance_means);
colors = [0 .45 .7;.8 .4 0;0 .6 .5;.8 .6 .7];
l = cell(1,4);
l{1}='Morning ON'; l{2}='Morning OFF';l{3}='Afternoon ON';l{4}='Afternoon OFF';
legend(b,l);
for i = 1:size(b,2)
   b(i).FaceColor = colors(i,:); 
end
set(gca,'xticklabel',xlabels)
ylabel('Angle [deg]');
%ylim([0 13])
grid on
hold on
ngroups = size(performance_means, 1);
nbars = size(performance_means, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, performance_means(:,i), performance_error_low(:,i), performance_error_high(:,i), 'k.', 'LineWidth',1,'HandleVisibility','off');
end
hold off
for i = 1:nbars
    xtips = b(i).XEndPoints;
    ytips = b(i).YEndPoints + 0.6;
    ytips(2) = ytips(2) + 0.2;
    if i == 1
        ytips(2) = ytips(2) + 0.2;
    end
    labels = string(round(b(i).YData,1));
    text(xtips,ytips,labels,'BackgroundColor', 'White','HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
title('Sun-Tracking RMS Statistics')