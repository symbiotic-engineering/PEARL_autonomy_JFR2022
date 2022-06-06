clear all;
close all;

%-------------------------------------------------------------%
% Code for plotting PEARL thrust mappings. 
% 
% Requires the following log files:
%   LOG_PEARL_SIMPLE_29_3_2021_____14_54_09
%   LOG_PEARL_SIMPLE_29_3_2021_____15_30_11
%-------------------------------------------------------------%

mission = "SIMPLE";
dates = ["29_3_2021_____14_54_09","29_3_2021_____15_30_11"];

for i = 1:2
    
    files_folder = "PEARL_logfiles";
    mission_folder = "LOG_PEARL_" + mission + '_' + dates(i) ;
    data_folder = files_folder + '/' + mission_folder + '/' + mission_folder + "_alvtmp/";
    
    %% Load Data
    navX = readtable(data_folder + "NAV_X.klog", 'FileType', 'text');  %X position [m]
    navY = readtable(data_folder + "NAV_Y.klog", 'FileType', 'text');  %Y position [m]
    bSOC = readtable(data_folder + "CHG_BATTERY_SOC.klog", 'FileType', 'text');  %Battery state of charge
    lPower = readtable(data_folder + "CHG_LOAD_POWER.klog", 'FileType', 'text');  %Load power [W]
    pvPower = readtable(data_folder + "CHG_PV_POWER.klog", 'FileType', 'text');  %PV power [W]
    lCurr = readtable(data_folder + "CHG_LOAD_CURRENT.klog", 'FileType', 'text');  %Load current [A]
    pvCurr = readtable(data_folder + "CHG_PV_CURRENT.klog", 'FileType', 'text');  %PV current [W]
    lVolt = readtable(data_folder + "CHG_LOAD_VOLTAGE.klog", 'FileType', 'text');  %Load voltage [V]
    pvVolt = readtable(data_folder + "CHG_PV_VOLTAGE.klog", 'FileType', 'text');  %PV voltage [V]
    speed = readtable(data_folder + "GPS_SPEED.klog", 'FileType', 'text');  %GPS speed [m/s]
    omega = readtable(data_folder + "IMU_GYROZ.klog", 'FileType', 'text');  %Rotational velocity [deg/s]
    rThrust = readtable(data_folder + "REPORTED_RIGHT_THRUST.klog", 'FileType', 'text');  %Right motor thrust %
    lThrust = readtable(data_folder + "REPORTED_LEFT_THRUST.klog", 'FileType', 'text');  %Left motor thrust %

    %Convert data to arrays
    time = table2array(navX(:,1))/60;
    chgTime = table2array(bSOC(:,1))/60;
    gpsTime = table2array(speed(:,1))/60;
    imuTime = table2array(omega(:,1))/60;
    navX = table2array(navX(:,4));
    navY = table2array(navY(:,4));
    bSOC = table2array(bSOC(:,4));
    lPower = table2array(lPower(:,4));
    pvPower = table2array(pvPower(:,4));
    pvCurr = table2array(pvCurr(:,4));
    lCurr = table2array(lCurr(:,4));
    pvVolt = table2array(pvVolt(:,4));
    lVolt = table2array(lVolt(:,4));
    speed = table2array(speed(:,4));
    omega = table2array(omega(:,4));
    rThrust = table2array(rThrust(:,4));
    lThrust = table2array(lThrust(:,4));
    
    %% Plot first dataset
    fontSize = 12;
    if i == 1
        start_i = 1;
        end_i = length(imuTime);
        
        %Account for differences in sampling time between charge controller and IMU
        chgDiff = length(imuTime) - length(chgTime);
        
        figure(1)
        subplot(2,1,1)
        hold on
        yyaxis left
        plot(imuTime(start_i:end_i),abs(lThrust(start_i:end_i)),'LineWidth',1.5);
        y = ylabel('Thrust [%]');
        set(y,'FontSize',fontSize);
        yyaxis right
        plot(imuTime(start_i:end_i),omega(start_i:end_i),'LineWidth',1.5);
        y = ylabel('Angular Velocity [deg/s]');
        set(y,'FontSize',fontSize);
        grid on
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        ylim([0 30])
        t = title("Thrust to Angular Velocity");
        set(t,'FontSize',fontSize);
        xlim([19 29.2])
        
        subplot(2,1,2)
        hold on
        yyaxis left
        plot(imuTime(start_i:end_i),abs(lThrust(start_i:end_i)),'LineWidth',1.5);
        y = ylabel('Thrust [%]');
        set(y,'FontSize',fontSize);
        yyaxis right
        plot(chgTime(start_i:end_i-chgDiff),lPower(start_i:end_i-chgDiff),'LineWidth',1.5);
        y = ylabel('Load Power [W]');
        set(y,'FontSize',fontSize);
        grid on
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        t = title("Thrust to Load Power");
        set(t,'FontSize',fontSize);
        xlim([19 29.2])
    end
    
    %% Plot second dataset
    if i == 2
        start_i = 1;
        end_i = length(imuTime);

        chgDiff = length(imuTime) - length(chgTime);
        gpsDiff = length(imuTime) - length(gpsTime);
        
        figure(2)
        subplot(2,1,1)
        hold on
        yyaxis left
        plot(imuTime(start_i:end_i),lThrust(start_i:end_i),'LineWidth',1.5);
        y = ylabel('Thrust [%]');
        set(y,'FontSize',fontSize);
        yyaxis right
        plot(gpsTime(start_i:end_i-gpsDiff),speed(start_i:end_i-gpsDiff),'LineWidth',1.5);
        y = ylabel('Velocity [m/s]');
        set(y,'FontSize',fontSize);
        grid on
        ylim([0 0.6])
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        t = title("Thrust to Velocity");
        set(t,'FontSize',fontSize);
        xlim([2 9])
        
        subplot(2,1,2)
        hold on
        yyaxis left
        plot(imuTime(start_i:end_i),lThrust(start_i:end_i),'LineWidth',1.5); %,'DisplayName','Left Motor Thrust')
        y = ylabel('Thrust [%]');
        set(y,'FontSize',fontSize);
        yyaxis right
        plot(chgTime(start_i:end_i-chgDiff),lPower(start_i:end_i-chgDiff),'LineWidth',1.5); %,'DisplayName','Z-Axis Angular Velocity')
        y = ylabel('Load Power [W]');
        set(y,'FontSize',fontSize);
        grid on
        x = xlabel('Mission Elapsed Time [min]');
        set(x,'FontSize',fontSize);
        t = title("Thrust to Load Power");
        set(t,'FontSize',fontSize);
        xlim([2 9])
    end
        
    load_energy = sum(lPower)/3600;
    pv_energy = sum(pvPower)/3600;
    mission_time = (time(end) - time(1));
    disp(["Mission elapsed time: " + num2str(mission_time) + " min"])
    disp(["Used energy: " + num2str(load_energy) + " Wh"])
    disp(["Generated energy: " + num2str(pv_energy) + " Wh"])
    disp(["Wh used per minute: " + num2str(load_energy/mission_time)])
    disp(["Wh generated per minute: " + num2str(pv_energy/mission_time)])

    
    %% Plot angular velocity dataset as thrust vs. velocity
    fontSize = 12;
    if i == 1
        %interpolate heading onto same time
        %[C,ia,ic] = unique(A) also returns index vectors ia and ic using any of the previous syntaxes.
        %If A is a vector, then C = A(ia) and A = C(ic).
        [imuTime_unique,imuTime_unique_ind,imuTime_ind] = unique(imuTime);
        lThrust_unique = lThrust(imuTime_unique_ind);
        %figure; plot(imuTime, lThrust, imuTime_unique, lThrust_unique,'--');

        omega_unique = omega(imuTime_unique_ind);
        
        [chgTime_unique,chgTime_unique_ind,chgTime_ind] = unique(chgTime);
        lPower_unique = lPower(chgTime_unique_ind);
        %figure; plot(chgTime, lPower, chgTime_unique, lPower_unique,'--');
        
        plotTime = chgTime_unique;
        lThrust_unique_int = interp1(imuTime_unique, lThrust_unique, plotTime);
        omega_unique_int = interp1(imuTime_unique, omega_unique, plotTime);
        %figure; plot(imuTime, lThrust, imuTime_unique, lThrust_unique,'--', plotTime, lThrust_unique_int, '.');
        
        %start after 19 and end before 29.2
        start_ind = min(find(plotTime > 19));
        end_ind = min(find(plotTime > 29.2));
        lThrust_for_plot = lThrust_unique_int(start_ind:end_ind);
        omega_for_plot = omega_unique_int(start_ind:end_ind);
        lPower_for_plot = lPower_unique(start_ind:end_ind);

        figure(3)
        subplot(2,1,1)
        hold on
        plot(abs(lThrust_for_plot), omega_for_plot,'.','MarkerSize',15,'Color',[0 0.45 0.70]);%'LineWidth',1.5);
        p1 = polyfit(abs(lThrust_for_plot),omega_for_plot,1);
        corrcoef1 = corrcoef(abs(lThrust_for_plot),omega_for_plot);
        R21 = corrcoef1(2)^2;
        yLin1 = polyval(p1,abs(lThrust_for_plot));
        plot(abs(lThrust_for_plot),yLin1,'--','LineWidth',1.5,'Color','k');
        x = xlabel('Thrust [%]');
        eq1 = sprintf('Angular Velocity = %0.4f(Thrust) + %0.4f',p1);
        text(max(xlim),min(ylim),[eq1  '; R^2 = '  num2str(R21)],'VerticalAlignment','bottom','HorizontalAlignment','right')
        set(x,'FontSize',fontSize);
        y = ylabel('Angular Velocity [deg/s]');
        grid on
        set(y,'FontSize',fontSize);
        ylim([0 30])
        t = title("Thrust to Angular Velocity");
        set(t,'FontSize',fontSize);
        legend('Measured','Best Fit','Location','NorthWest');
        
        subplot(2,1,2)
        hold on
        plot(abs(lThrust_for_plot),lPower_for_plot,'.','MarkerSize',15,'Color',[0.80 0.40 0]);%'LineWidth',1.5);
        p2 = polyfit(abs(lThrust_for_plot),lPower_for_plot,2);
        corrcoef2 = corrcoef(abs(lThrust_for_plot),lPower_for_plot);
        R22 = corrcoef2(2)^2;
        yLin2 = polyval(p2,abs(lThrust_for_plot));
        plot(abs(lThrust_for_plot),yLin2,'--','LineWidth',1.5,'Color','k');
        eq2 = sprintf('Power = %0.4f(Thrust)^2 + %0.4f(Thrust) + %0.4f',p2);
        text(max(xlim),min(ylim),[eq2  '; R^2 = '  num2str(R22)],'VerticalAlignment','bottom','HorizontalAlignment','right')
        x = xlabel('Thrust [%]');
        x = xlabel('Thrust [%]');
        set(x,'FontSize',fontSize);
        y = ylabel('Load Power [W]');
        set(y,'FontSize',fontSize);
        grid on
        t = title("Thrust to Load Power");
        set(t,'FontSize',fontSize);
        legend('Measured','Best Fit','Location','NorthWest');
    end
    
    %% Plot second dataset
    if i == 2
        %interpolate heading onto same time
        %[C,ia,ic] = unique(A) also returns index vectors ia and ic using any of the previous syntaxes.
        %If A is a vector, then C = A(ia) and A = C(ic).
        [imuTime_unique,imuTime_unique_ind,imuTime_ind] = unique(imuTime);
        lThrust_unique = lThrust(imuTime_unique_ind);
        %figure; plot(imuTime, lThrust, imuTime_unique, lThrust_unique,'--');
        
        [chgTime_unique,chgTime_unique_ind,chgTime_ind] = unique(chgTime);
        lPower_unique = lPower(chgTime_unique_ind);
        %figure; plot(chgTime, lPower, chgTime_unique, lPower_unique,'--');

        [gpsTime_unique,gpsTime_unique_ind,gpsTime_ind] = unique(gpsTime);
        speed_unique = speed(gpsTime_unique_ind);
        
        plotTime = gpsTime_unique;
        lThrust_unique_int = interp1(imuTime_unique, lThrust_unique, plotTime);
        lPower_unique_int = interp1(chgTime_unique, lPower_unique, plotTime);
        %figure; plot(imuTime, lThrust, imuTime_unique, lThrust_unique,'--', plotTime, lThrust_unique_int, '.');
        
        %start after 2 and end before 9
        start_ind = min(find(plotTime > 2));
        end_ind = min(find(plotTime > 9));
        lThrust_for_plot = lThrust_unique_int(start_ind:end_ind);
        speed_for_plot = speed_unique(start_ind:end_ind);
        lPower_for_plot = lPower_unique_int(start_ind:end_ind);
        
        figure(4)
        subplot(2,1,1)
        hold on
        plot(abs(lThrust_for_plot),speed_for_plot,'.','MarkerSize',15,'Color',[0 0.45 0.70]);
        p3 = polyfit(abs(lThrust_for_plot),speed_for_plot,1);
        corrcoef3 = corrcoef(abs(lThrust_for_plot),speed_for_plot);
        R23 = corrcoef3(2)^2;
        yLin3 = polyval(p3,abs(lThrust_for_plot));
        plot(abs(lThrust_for_plot),yLin3,'--','LineWidth',1.5,'Color','k');
        eq3 = sprintf('Velocity = %0.4f(Thrust) + %0.4f',p3);
        text(max(xlim),min(ylim),[eq3  '; R^2 = '  num2str(R23)],'VerticalAlignment','bottom','HorizontalAlignment','right')
        x = xlabel('Thrust [%]');
        set(x,'FontSize',fontSize);
        y = ylabel('Velocity [m/s]');
        grid on
        set(y,'FontSize',fontSize);
        ylim([0 0.6])
        t = title("Thrust to Velocity");
        set(t,'FontSize',fontSize);
        legend('Measured','Best Fit','Location','NorthWest');
        
        subplot(2,1,2)
        hold on
        plot(abs(lThrust_for_plot),lPower_for_plot,'.','MarkerSize',15,'Color',[0.80 0.40 0]);%'LineWidth',1.5);
        p4 = polyfit(abs(lThrust_for_plot),lPower_for_plot,2);
        corrcoef4 = corrcoef(abs(lThrust_for_plot),lPower_for_plot);
        R24 = corrcoef4(2)^2;
        yLin4 = polyval(p4,abs(lThrust_for_plot));
        plot(abs(lThrust_for_plot),yLin4,'--','LineWidth',1.5,'Color','k');
        eq4 = sprintf('Power = %0.4f(Thrust)^2 + %0.4f(Thrust) + %0.4f',p4);
        text(max(xlim),min(ylim),[eq4  '; R^2 = '  num2str(R24)],'VerticalAlignment','bottom','HorizontalAlignment','right')
        x = xlabel('Thrust [%]');
        set(x,'FontSize',fontSize);
        y = ylabel('Load Power [W]');
        set(y,'FontSize',fontSize);
        grid on
        t = title("Thrust to Load Power");
        set(t,'FontSize',fontSize);
        legend('Measured','Best Fit','Location','NorthWest');
    end
        
end








