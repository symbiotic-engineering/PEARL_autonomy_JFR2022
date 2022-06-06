clear all
close all

%---------------------------------------------------------------------%
% Code for plotting PEARL path following and power usage statistics. 
% 
% Statistics variables were calculated for various waypoint missions
% using the PEARL_waypoint_stats.m script. Does not need any log 
% files to run.
%---------------------------------------------------------------------%

%% Path Following Statistics Variables
%Total path length
path_length = [239.7 238.5 177.1 1330.4];

%Root mean square error statistics
rmse_mean = [1.8357 0.93154 1.5407 2.2];
rmse_std = [0.28842 0.30921 0.23041 0];
rmse_std_low = -rmse_std;
rmse_std_high = rmse_std;

%Max deviation from ideal path statistics
dev_mean = [3.8332 1.9396 2.8432 6.1];
dev_std = [0.67582 0.39587 0.36799 0];
dev_std_low = -dev_std;
dev_std_high = dev_std;

%Path length difference statistics
dist_mean = [13.6519 6.5158 6.9476 9.2*3]./path_length*100;
dist_std = [6.691 2.4787 4.1784 0];
dist_std_low = -dist_std;
dist_std_high = dist_std;

%Averages and high/low errors for plotting
path_means = [rmse_mean; dev_mean; dist_mean];
path_err_low = [rmse_std_low; dev_std_low; dist_std_low];
path_err_high = [rmse_std_high; dev_std_high; dist_std_high];

%% Power Usage Statistics Variables
%Energy generated statistics
e_used_mean = [2.38 2.72 2.32 1.98];
e_used_std = [0.0321 0.3164 0.1573 0];
e_used_std_low = -e_used_std;
e_used_std_high = e_used_std;

%Energy generated statistics
e_gen_mean = [2.42 1.77 0.88 1.14];
e_gen_std = [0.3564 0.36 0.3217 0];
e_gen_std_low = -e_gen_std;
e_gen_std_high = e_gen_std;

%Change in battery state of charge over the course of the mission
dBatt_mean = [0.01 -0.85 -1.39 -10.25];
dBatt_std = [0.3761 0.1465 0.1903 0];
dBatt_std_low = -dBatt_std;
dBatt_std_high = dBatt_std;

%Change in battery state of charge per hour without solar energy generation
wBatt_mean = [-11.19 -12.76 -10.88 -9.29];
wBatt_std = [0.1531 1.4835 0.7321 0];
wBatt_std_low = -wBatt_std;
wBatt_std_high = wBatt_std;

%Averages and high/low errors for plotting
power_means = [e_used_mean; e_gen_mean; dBatt_mean; wBatt_mean];
power_err_low = [e_used_std_low; e_gen_std_low; dBatt_std_low; wBatt_std_low];
power_err_high = [e_used_std_high; e_gen_std_high; dBatt_std_high; wBatt_std_high];

%% Path Following Statistics Plotting
figure(1)
xlabels = {'Mean RMSE';'Mean Max Deviation';'Mean Path Difference'}; 
b = bar(path_means);
colors = [0 .45 .7;.8 .4 0;0 .6 .5;.8 .6 .7];
l = cell(1,4);
l{1}='Star';l{2}='Perimeter';l{3}='Figure 8';l{4}='Multi-Behavior';
legend(b,l);
for i = 1:size(b,2)
   b(i).FaceColor = colors(i,:); 
end
set(gca,'xticklabel',xlabels)
ylabel('Distance [m]');
ylim([0 13])
grid on
hold on
ngroups = size(path_means, 1);
nbars = size(path_means, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, path_means(:,i), path_err_low(:,i), path_err_high(:,i), 'k.', 'LineWidth',1,'HandleVisibility','off');
end
hold off
for i = 1:length(path_means)
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
title('Waypoint Pattern Track Statistics')

%% Power Usage Statistics Plotting
figure(2)
% xlabels = {'Mean Energy/min Consumed [Wh]';'Mean Energy/min Generated';'Mean Battery % Change';'Mean Battery % Change (no sun)'}; 
xlabels = {'';'';'';''}; 
b = bar(power_means);
colors = [0 .45 .7;.8 .4 0;0 .6 .5;.8 .6 .7];
l = cell(1,4);
l{1}='Star';l{2}='Perimeter';l{3}='Figure 8';l{4}='Multi-Behavior';
legend(b,l);
for i = 1:size(b,2)
   b(i).FaceColor = colors(i,:); 
end
set(gca,'xticklabel',xlabels)
ylabel('Distance [m]');
ylim([-15 8])
grid on
hold on
ngroups = size(power_means, 1);
nbars = size(power_means, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, power_means(:,i), power_err_low(:,i), power_err_high(:,i), 'k.', 'LineWidth',1,'HandleVisibility','off');
end
hold off
for i = 1:length(power_means)
    xtips = b(i).XEndPoints;
    ytips = b(i).YEndPoints + 0.6;
    ytips(3:4) = 0.3;
    data = round(b(i).YData,1);
    for k = 1:length(data)
       if data(k)<=-10
          data(k) = round(data(k)); 
       end
    end
    labels = string(data);
    text(xtips,ytips,labels,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','FontSize',8)
end
title('Waypoint Pattern Power Statistics')
