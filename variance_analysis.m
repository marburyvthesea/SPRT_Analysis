%% calculate peak velocity from instantaneous speed traces
speed_data = DLC_trajs.speed;

% Extract the unique values in the "Reach" column
unique_reaches = unique(DLC_trajs.Reach);

% Initialize an array to store the maximum values
max_values = zeros(height(DLC_trajs), 1);

% Iterate through each cell and find variance of reach

% Calculate mean trajectory 
sum_x = zeros(height(DLC_trajs.traj{1,1}), 1);
sum_y = zeros(height(DLC_trajs.traj{1,1}), 1);
count_valid_points = zeros(height(DLC_trajs.traj{1,1}), 1);  % To keep track of number of valid (non-NaN) data points

num_traj = height(DLC_trajs);

% Create arrays to store indices where NaNs are created
nan_indices_x = [];
nan_indices_y = [];

for i = 1:num_traj
    % Access x and y coordinates of the i-th trajectory
    traj_i_x = DLC_trajs.traj{i}(:, 2);
    traj_i_y = DLC_trajs.traj{i}(:, 1);
    
    % Create masks to exclude NaNs and zeros
    valid_mask_x = ~isnan(traj_i_x) & traj_i_x ~= 0;
    valid_mask_y = ~isnan(traj_i_y) & traj_i_y ~= 0;

    % Ensure masks are the same length
    valid_mask = valid_mask_x & valid_mask_y;
    
    % Replace NaNs with zeros in traj_i_x and traj_i_y
    traj_i_x(isnan(traj_i_x)) = 0;
    traj_i_y(isnan(traj_i_y)) = 0;

    % Accumulate sum of valid x and y coordinates
    sum_x = sum_x + (traj_i_x .* valid_mask);
    sum_y = sum_y + (traj_i_y .* valid_mask);

    % Accumulate count of valid points
    count_valid_points = count_valid_points + valid_mask;
    
    % Check for NaNs in sum_x and sum_y and store indices
    if any(isnan(sum_x))
        nan_indices_x = [nan_indices_x; i];
    end
    if any(isnan(sum_y))
        nan_indices_y = [nan_indices_y; i];
    end

end

% Compute average trajectory, avoiding division by zero
avg_traj_x = sum_x ./ max(count_valid_points, 1);  % Use max to avoid division by zero
avg_traj_y = sum_y ./ max(count_valid_points, 1);

% Create a table or store the average trajectory as needed
average_trajectory_mask = table(avg_traj_y, avg_traj_x, 'VariableNames', {'y', 'x'});

%%
% Create a new figure
figure;
hold on;  % Keep the current plot so that subsequent plots overlap

% Iterate through each trajectory
%numToPlot = height(DLC_trajs);
numToPlot = 5; 
for i = 1:numToPlot
    % Access x and y coordinates of the i-th trajectory
    traj_i_x = DLC_trajs.traj{i}(:, 2);
    traj_i_y = DLC_trajs.traj{i}(:, 1);
    
    % Plot the trajectory
    plot(traj_i_x, traj_i_y, 'LineWidth', 1);  % Adjust LineWidth for visibility
end

% Add labels and title
xlabel('X Coordinate');
ylabel('Y Coordinate');
title('Overlay of All Trajectories');


% Display grid
grid on;

% Release the hold on the plot
hold off;



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
tableToAnalyze = DLC_trajs_late; 

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
