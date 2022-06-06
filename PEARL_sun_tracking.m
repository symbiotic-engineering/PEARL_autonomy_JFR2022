clear all;
close all;

%---------------------------------------------------------------------%
% Code for PEARL sun-tracking mode data analysis and plotting. 
% 
% See below for the necessary log files.
%---------------------------------------------------------------------%

mission = "SIMPLE";

%Afternoon Sun-Tracking Tests [SUN-TRACKING ON,SUN-TRACKING OFF]
titleString = "Morning";
% dates = ["10_4_2021_____14_36_51","10_4_2021_____14_58_01"];
% dates = ["10_4_2021_____15_19_23","10_4_2021_____15_40_42"];
% dates = ["10_4_2021_____16_02_27","10_4_2021_____16_23_34"];
%dates = ["14_4_2021_____14_02_26","14_4_2021_____14_23_59"]; %<-- this one for JFR paper

%Morning Sun-Tracking Tests [SUN-TRACKING ON,SUN-TRACKING OFF]
%titleString = "Morning";
dates = ["15_4_2021_____07_16_10","15_4_2021_____07_38_20"]; %<-- this one for JFR paper
% dates = ["15_4_2021_____07_59_15","15_4_2021_____08_36_48"];

rmse = [];
for i = 1:2
    files_folder = "PEARL_logfiles";
    mission_folder = "LOG_PEARL_" + mission + '_' + dates(i) ;
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
    fontSize = 15;
    
    figure(i)
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
    if i==1
        t = title(["PEARL Station-keeping "+titleString+" Test","Sun-Tracking ON"]);
    elseif i==2
        t = title(["PEARL Station-keeping "+titleString+" Test","Sun-Tracking OFF"]);
    end
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
    
    
    figure(i+2)
    subplot(3,1,1)
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
    if i==1
        t = title(["PEARL Station-keeping "+titleString+" Test","Sun-Tracking ON"]);
    elseif i==2
        t = title(["PEARL Station-keeping "+titleString+" Test","Sun-Tracking OFF"]);
    end
    set(t,'FontSize',fontSize);
    set(gca,'YColor',[0 0 0]);
    xlim([0 18])
    ylim([0 70])
    
    subplot(3,1,2)
    hold on
    plot(chg_time/60,bSOC,'LineWidth',1.5,'DisplayName','Battery State of Charge')
    ylim([0 102])
    y = ylabel('Battery SOC [%]');
    set(y,'FontSize',fontSize);
    grid on
    xlim([0 18])

    subplot(3,1,3)
    hold on
    plot(sTime/60,360-sHeading,'b','LineWidth',1.5,'DisplayName','Sun Heading')
    plot(time/60,heading,'k-','LineWidth',1.5,'DisplayName','PEARL Heading')
    plot(sTime/60,sElevation,'LineWidth',1.5,'DisplayName','Solar Elevation Angle')
    legend
    grid on
    x = xlabel('Mission Elapsed Time [min]');
    set(x,'FontSize',fontSize);
    y = ylabel('Angle [deg]');
    set(y,'FontSize',fontSize);
    ylim([0 380])
    set(gca,'YColor',[0 0 0]);
    xlim([0 18])
    
    %% Power Statistics
    disp("-----------------------------------------------")
    if i==1
        disp("Power statistics with SUN-TRACKING mode ON:")
    elseif i==2
        disp("Power statistics with SUN-TRACKING mode OFF:")
    end
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
    
    
    %% RMS error
    rmse_heading = [];
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
    for j = 1:length(heading_for_rmse)
        if sHeading_for_rmse(j) < 10
            desired = 360-sHeading_for_rmse(j);
        else
            desired = sHeading_for_rmse(j);
        end
        rmse_heading(j) = (desired - heading_for_rmse(j));
    end
%    rmse(i) = sqrt(sum(rmse_heading.^2)/length(rmse_heading));
    rmse(i) = rms(rmse_heading);
    disp(["RMS heading error: " + num2str(rmse(i))])
end



