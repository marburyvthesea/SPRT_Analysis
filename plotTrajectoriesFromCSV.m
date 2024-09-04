%% select and load csv file
csvFileName = '20221019-12-41-58_T01-547_DMKDLC_resnet50_SPRTAug15shuffle1_1000000.csv';

% Read the CSV file into a cell array
rawData = readcell(csvFileName, 'Delimiter', ','); % Use readcell instead of readtable

% Extract the 2nd and 3rd rows: headers and column names
headerRow2 = rawData(2, :);
headerRow3 = rawData(3, :);

% Combine the 2nd and 3rd rows to create new column names
combinedHeaders = strcat(headerRow2, '_', headerRow3);

% Replace hyphens with underscores in the column names
combinedHeaders = strrep(combinedHeaders, '-', '_');

% Extract the data rows (excluding the header rows)
dataRows = rawData(4:end, :);

% Create a new table with the combined headers
dataTable = cell2table(dataRows, 'VariableNames', combinedHeaders);

% Display the first few rows of the table
disp(head(dataTable));

%% perform some cleanup of DLC trajectory data

% list of coordinate pairs to use 
baseColumns = {'R_finger', 'R_wrist', 'L_finger', ...
    'L_wrist', 'L_wrist', 'Nose', 'Food'    
};
%remove indices with low likelihood of bodypart detection 
likelihoodThreshold = .95 ;
dataTable = replaceCoordinatesBelowLikelihood(dataTable, baseColumns, likelihoodThreshold);
coordinatePairs = {
    'R_finger_x', 'R_finger_y'; 'R_wrist_x', 'R_wrist_y';
    'L_finger_x', 'L_finger_y'; 'L_wrist_x', 'L_wrist_y';
    'Nose_x', 'Nose_y'; 'Food_x', 'Food_y'
};
% add columns with euclidean distances in successive frames to dataTable 
dataTable = calcEuclidDistColumnPairs(coordinatePairs,dataTable);

%% find outliers in distance columns 
distanceColumns = {'R_finger_delta', 'R_wrist_delta', 'L_finger_delta', ... 
    'L_wrist_delta', 'Nose_delta', 'Food_delta'};
dataTable = addStandardDeviationColumns(dataTable, distanceColumns);
% now for data points where the standard deviation exceeds a given threshold
% (e.g. stdThreshold=4) replace the corresponsing coordinates with an
% average of the points preceeding the deviation from the threshold and
% those following
stdThreshold=10; 
correctedTable = correctOutlierCoordinates(dataTable, distanceColumns, stdThreshold);

correctedTable = calcEuclidDistColumnPairs(coordinatePairs, correctedTable);
correctedTable = addStandardDeviationColumns(correctedTable, distanceColumns);

%% select frames representing paw crossing panel 

% Define the values to match
target_mouse = 547;
target_day = 1;

% Filter the table based on Mouse and Day values
filtered_rows = (DLC_trajs.Mouse == target_mouse) & (DLC_trajs.Day == target_day);

% Extract the values from the frame column where the conditions are met
frames_list = DLC_trajs.frame(filtered_rows);

% Display the result
disp('List of frame values:');
disp(frames_list);

%% select regions of DLC table from frameNumList
numSubsetFramesToSave = 50;

% Create a containers.Map to store the subsets of the table
dataMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Iterate through each frame number in frames_list
for i = 1:length(frames_list)
    reachFrame = frames_list(i);
    
    % Calculate the range of rows to extract
    startFrame = max(1, reachFrame - numSubsetFramesToSave);
    endFrame = min(height(correctedTable), reachFrame + numSubsetFramesToSave);

    % Extract the subset of rows for the current frame
    subsetTable = correctedTable(startFrame:endFrame, :);
    
    % Store the subset table in the map with the frame index as the key
    dataMap(reachFrame) = subsetTable;
end

%% replace missing values with linear interpolation 
filledDataMap = fillNaNRegions(dataMap, frames_list, bodyPartName);

%% plot velocity of an input body part
bodyPartName = 'L_finger' ; 
velocitiesCellArray = calculateInstantaneousVelocity(bodyPartName, filledDataMap, ... 
    frames_list) ;



