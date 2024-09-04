%% calculate peak velocity from instantaneous speed traces
speed_data = DLC_trajs.speed;

% Extract the unique values in the "Reach" column
unique_reaches = unique(DLC_trajs.Reach);

% Initialize an array to store the maximum values
max_values = zeros(height(DLC_trajs), 1);

% Iterate through each cell and find the maximum value
for i = 1:height(DLC_trajs)
    max_values(i) = max(speed_data{i});
    mean_speeds = zeros(length(unique_reaches), 1);
    std_speeds = zeros(length(unique_reaches), 1);
end

DLC_trajs.max_speed = max_values;

%% separate into early and late training days
% Assuming DLC_trajs is your original table

% Filter the table to create DLC_trajs_early with rows containing Day 1 or 2
DLC_trajs_early = DLC_trajs(DLC_trajs.Day == 1 | DLC_trajs.Day == 2, :);

% Filter the table to create DLC_trajs_late with rows containing Day 9 or 10
DLC_trajs_late = DLC_trajs(DLC_trajs.Day == 9 | DLC_trajs.Day == 10, :);

% Display the new tables
disp('DLC_trajs_early:');
disp(DLC_trajs_early);

disp('DLC_trajs_late:');
disp(DLC_trajs_late);

%%
tableToAnalyze = DLC_trajs_early; 

% Extract the unique values in the "Reach" column
unique_reaches = unique(DLC_trajs.Reach);

% Initialize arrays to store the results
mean_max_speeds = zeros(length(unique_reaches), 1);
mean_speeds = zeros(length(unique_reaches), 1);
std_speeds = zeros(length(unique_reaches), 1);
std_dev_max_speeds = zeros(length(unique_reaches), 1);
sem_max_speeds = zeros(length(unique_reaches), 1);

% Iterate through each unique reach and calculate the required statistics
for i = 1:length(unique_reaches)
    reach = unique_reaches{i};
    % Get the indices of rows with the current reach value
    indices = strcmp(tableToAnalyze.Reach, reach);
    % Calculate the mean max speed for the current reach value
    mean_max_speeds(i) = nanmean(tableToAnalyze.max_speed(indices));
    std_dev_max_speeds(i) = nanstd(tableToAnalyze.max_speed(indices));

    % Calculate the standard error of the mean (SEM) for the max speed
    n = sum(~isnan(tableToAnalyze.max_speed(indices)));
    sem_max_speeds(i) = std_dev_max_speeds(i) / sqrt(n);

    % Calculate the mean and standard deviation across columns
    %mean_speeds_cell{i} = mean(speed_values, 2);
    %std_speeds_cell{i} = std(speed_values, 0, 2);
end

% Create a new table with the results
avg_max_speed_table = table(unique_reaches, mean_max_speeds, std_dev_max_speeds, sem_max_speeds, mean_speeds, std_speeds, ...
    'VariableNames', {'Reach', 'Avg_Max_Speed', 'STD_max_speed', 'SEM_Max_Speed', 'Avg_Speed', 'Std_Speed'});
