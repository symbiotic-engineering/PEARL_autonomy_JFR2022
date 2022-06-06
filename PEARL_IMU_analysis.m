clear all;
close all;

%---------------------------------------------------------------------%
% Code for PEARL IMU data analysis. 
% 
% Log files used to produce plots in OCEANS paper:
%   LOG_PEARL_SIMPLE_29_3_2021_____14_54_09  (Forward thrust test)
%   LOG_PEARL_SIMPLE_29_3_2021_____15_30_11  (Rotational thrust test)
% 
% Other log files than can be plotted:
%   LOG_PEARL_SIMPLE_22_6_2021_____12_40_13  (Test with external IMU
%                                             conducted by Henry)
%   LOG_PEARL_SIMPLE_22_6_2021_____15_42_01  (Test with external IMU
%                                             conducted by Henry)
%---------------------------------------------------------------------%

mission = "SIMPLE";
dates = ["29_3_2021_____14_54_09","29_3_2021_____15_30_11","22_6_2021_____12_40_13","22_6_2021_____15_42_01"];

for i = 2
    files_folder = "PEARL_logfiles";
    mission_folder = "LOG_PEARL_" + mission + '_' + dates(i) ;
    data_folder = files_folder + '/' + mission_folder + '/' + mission_folder + "_alvtmp/";

    %% Load Variables
    %PEARL variables
    navX = readtable(data_folder + "NAV_X.klog", 'FileType', 'text');
    navY = readtable(data_folder + "NAV_Y.klog", 'FileType', 'text');
    gps_heading = readtable(data_folder + "GPS_HEADING_GPRMC.klog", 'FileType', 'text');
    speed = readtable(data_folder + "GPS_SPEED.klog", 'FileType', 'text');
    rThrust = readtable(data_folder + "REPORTED_RIGHT_THRUST.klog", 'FileType', 'text');
    lThrust = readtable(data_folder + "REPORTED_LEFT_THRUST.klog", 'FileType', 'text');
    
    %Charge Controller Variables
    bSOC = readtable(data_folder + "CHG_BATTERY_SOC.klog", 'FileType', 'text');
    pvPower = readtable(data_folder + "CHG_PV_POWER.klog", 'FileType', 'text');
    lPower = readtable(data_folder + "CHG_LOAD_POWER.klog", 'FileType', 'text');
    pvCurr = readtable(data_folder + "CHG_PV_CURRENT.klog", 'FileType', 'text');
    lCurr = readtable(data_folder + "CHG_LOAD_CURRENT.klog", 'FileType', 'text');
    battCurr = readtable(data_folder + "CHG_BATTERY_CURRENT.klog", 'FileType', 'text');
    pvVolt = readtable(data_folder + "CHG_PV_VOLTAGE.klog", 'FileType', 'text');
    lVolt = readtable(data_folder + "CHG_LOAD_VOLTAGE.klog", 'FileType', 'text');
    
    %IMU Variables
    accX = readtable(data_folder + "IMU_ACCX.klog", 'FileType', 'text');
    accY = readtable(data_folder + "IMU_ACCY.klog", 'FileType', 'text');
    accZ = readtable(data_folder + "IMU_ACCZ.klog", 'FileType', 'text');
    gyroX = readtable(data_folder + "IMU_GYROX.klog", 'FileType', 'text');
    gyroY = readtable(data_folder + "IMU_GYROY.klog", 'FileType', 'text');
    gyroZ = readtable(data_folder + "IMU_GYROZ.klog", 'FileType', 'text');
    magX = readtable(data_folder + "IMU_MAGX.klog", 'FileType', 'text');
    magY = readtable(data_folder + "IMU_MAGY.klog", 'FileType', 'text');
    magZ = readtable(data_folder + "IMU_MAGZ.klog", 'FileType', 'text');
    heading = readtable(data_folder + "IMU_HEADING.klog", 'FileType', 'text');
    pitch = readtable(data_folder + "IMU_PITCH.klog", 'FileType', 'text');
    roll = readtable(data_folder + "IMU_ROLL.klog", 'FileType', 'text');
    
    %Account for different sampling rates of IMU and GPS data
    startIMU = 1;
    lastIMU = height(rThrust);
    startGPS = 97;
    lastGPS = 465;
    
    %Convert data to arrays
    time = table2array(magX(startIMU:lastIMU,1))/60;
    chg_time = table2array(bSOC(:,1))/60;
    gps_time = table2array(gps_heading(startGPS:lastGPS,1))/60;
    navX = table2array(navX(startGPS:lastGPS,4));
    navY = table2array(navY(startGPS:lastGPS,4));
    gps_heading = table2array(gps_heading(startGPS:lastGPS,4));
    speed = table2array(speed(startGPS:lastGPS,4));
    rThrust = table2array(rThrust(startIMU:lastIMU,4));
    lThrust = table2array(lThrust(startIMU:lastIMU,4));
    
    bSOC = table2array(bSOC(:,4));
    pvPower = table2array(pvPower(:,4));
    lPower = table2array(lPower(:,4));
    pvCurr = table2array(pvCurr(:,4));
    lCurr = table2array(lCurr(:,4));
    battCurr = table2array(battCurr(:,4));
    pvVolt = table2array(pvVolt(:,4));
    lVolt = table2array(lVolt(:,4));
    
    accX = table2array(accX(startIMU:lastIMU,4));
    accY = table2array(accY(startIMU:lastIMU,4));
    accZ = table2array(accZ(startIMU:lastIMU,4));
    gyroX = table2array(gyroX(startIMU:lastIMU,4));
    gyroY = table2array(gyroY(startIMU:lastIMU,4));
    gyroZ = table2array(gyroZ(startIMU:lastIMU,4));
    magX = table2array(magX(startIMU:lastIMU,4));
    magY = table2array(magY(startIMU:lastIMU,4));
    magZ = table2array(magZ(startIMU:lastIMU,4));
    heading = table2array(heading(startIMU:lastIMU,4));
    pitch = table2array(pitch(startIMU:lastIMU,4));
    roll = table2array(roll(startIMU:lastIMU,4));
    
    fontSize = 15; 
    

    %% IMU Heading vs. GPS Heading vs. Thrust
    figure
    hold on
    yyaxis left
    plot(time,heading,'LineWidth',1.5,'DisplayName','IMU Heading');
    plot(gps_time,gps_heading,'k-','LineWidth',1.5,'DisplayName','GPS Heading');
    grid on
    legend
    x = xlabel('Mission Elapsed Time [min]');
    set(x,'FontSize',fontSize);
    y = ylabel('Heading [deg]');
    set(y,'FontSize',fontSize);
    ylim([0 360])
    yyaxis right
    plot(time,rThrust,'LineWidth',1.5,'DisplayName','Thrust');
    ylim([0 100])
    y = ylabel('% Thrust Commanded');
    set(y,'FontSize',fontSize);
    t = title('Reported Heading Values');
    set(t,'FontSize',fontSize);
    xlim([1.9 9])    
    
    %% Raw Magnetometer Data
%     figure
%     hold on
%     plot(time,accX,'LineWidth',1.5,'DisplayName','X')
%     plot(time,accY,'LineWidth',1.5,'DisplayName','Y')
%     plot(time,accZ,'LineWidth',1.5,'DisplayName','Z')
%     grid on
%     xlabel('Mission Elapsed Time [min]');ylabel('Acceleration [m/s^2]');
%     title(["Accelerometer","Both Motors Forward, External IMU"])
%     legend
%     
%     figure
%     hold on
%     plot(time,gyroX,'LineWidth',1.5,'DisplayName','X')
%     plot(time,gyroY,'LineWidth',1.5,'DisplayName','Y')
%     plot(time,gyroZ,'LineWidth',1.5,'DisplayName','Z')
%     grid on
%     xlabel('Mission Elapsed Time [min]');ylabel('Gyroscopic Rate [rad/s]');
%     title(["Gyroscope","Both Motors Forward, External IMU"])
%     legend
% 
%     figure
%     hold on
%     plot3(magX,magY,magZ)
%     grid on
%     xlabel('Mag X');ylabel('Mag Y');zlabel('Mag Z');
%     view(3)
%     axis equal
%     title(["Magnetometer","Both Motors Forward, External IMU"])

    %% Biot-Savart Law Calculations
    mu0 = 4*pi*10^(-7);
    rSolar = 102e-3; %distance from solar panel wires to IMU [mm]e-3  %52
    rMotor = 152e-3; %distance from motor wires to IMU [mm]e-3   %320
    ss_lCurr = 0.8;  %Steady-state load current (0% thrust)
    B_pv = (mu0*pvCurr)/(2*pi*rSolar)*10^6;  %B field component due to solar panel current [uTesla]
    B_load = (mu0*(lCurr-ss_lCurr))/(2*pi*rMotor)*10^6;  %B field component due to load current [uTelsa]
    B = B_pv + B_load;  %Bios-Savart B field estimate
%     magAll = sqrt(magX.^2 + magY.^2 + magZ.^2) - 20;
    magError = -magZ;  %Actual magnetometer error approximated by magnetometer Z value
    
    figure
    hold on
%     yyaxis left
%     plot(time,magX,'k-','LineWidth',1.5,'DisplayName','X')
%     plot(time,magY,'g-','LineWidth',1.5,'DisplayName','Y')
%     plot(time,magZ,'b-','LineWidth',1.5,'DisplayName','Z')
%     plot(chg_time,pvError,'k-','LineWidth',1.5,'DisplayName','Estimated Error (PV Contribution)')
%     plot(chg_time,lError,'g-','LineWidth',1.5,'DisplayName','Estimated Error (Motor Contribution)')
    plot(time,magError,'b-','LineWidth',1.5,'DisplayName','Actual Mag Error')
    plot(chg_time,B,'r-','LineWidth',1.5,'DisplayName','Mag Error Estimated by B-S Law')
    xlim([0 24])
    ylim([-10 50])
    grid on
    legend
    x = xlabel('Mission Elapsed Time [min]');
    set(x,'FontSize',fontSize);
    y = ylabel('Magnetic Field Intensity [uTesla]');
    set(y,'FontSize',fontSize);
    t = title('Magnetometer Error');
    set(t,'FontSize',fontSize);
%     yyaxis right
%     plot(time,rThrust,'DisplayName','Thrust')
%     ylabel('Percent Thrust Commanded')
%     plot([0 10],[40 40],'LineWidth',1.5,'HandleVisibility','off')
%     xlim([2.28 9])

%     figure
%     hold on
%     plot(time,pitch,'DisplayName','Pitch')
%     plot(time,roll,'DisplayName','Roll')
%     plot(chg_time,lCurr,'DisplayName','Load Current')
% %     plot(chg_time,pvCurr,'DisplayName','PV')
% %     plot(chg_time,battCurr,'DisplayName','Battery')
%     plot(chg_time,lCurr-battCurr,'DisplayName','Net Current')
%     grid on
%     legend

end
