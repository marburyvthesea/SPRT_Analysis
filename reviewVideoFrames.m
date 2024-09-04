function reviewVideoFrames(videoFile, frames_list, numFramesToLoad, target_mouse, target_day)
    % Create a VideoReader object
    vidObj = VideoReader(videoFile);
    
    % Preallocate a list to store user choices
    userChoices = cell(length(frames_list), 2);  % [frameNumber, choice]

    % Create a figure for GUI
    fig = uifigure('Name', 'Review Video Clips', 'Position', [100 100 800 600]);

    % Create axes for video display
    ax = uiaxes('Parent', fig, 'Position', [0.1 0.3 0.8 0.6]);
    
    % Create buttons for user input
    uibutton(fig, 'Text', 'Good', 'Position', [100 50 100 30], 'ButtonPushedFcn', @(btn, event) saveChoice('good'));
    uibutton(fig, 'Text', 'Bad', 'Position', [250 50 100 30], 'ButtonPushedFcn', @(btn, event) saveChoice('bad'));
    
    % Function to play clip and get user input
    function playAndReviewClip(reachFrame)
        % Calculate the range of frames to read
        startFrame = max(1, reachFrame - numFramesToLoad);
        endFrame = min(vidObj.NumFrames, reachFrame + numFramesToLoad);
        
        % Read frames around reachFrame
        frames = cell(endFrame - startFrame + 1, 1);
        for j = startFrame:endFrame
            frames{j - startFrame + 1} = read(vidObj, j);
        end
        
        % Play the video clip
        for k = 1:numel(frames)
            imshow(frames{k}, 'Parent', ax);
            pause(1/vidObj.FrameRate);  % Adjust to frame rate of the video
        end
        
        % Wait for user to provide input
        uiwait(fig);
    end

    % Function to save the user choice
    function saveChoice(choice)
        % Store the choice for the current frame
        userChoices{i, 1} = frames_list(i);
        userChoices{i, 2} = choice;
        % Resume execution
        uiresume(fig);
    end

    % Iterate through each frame number in frames_list
    for i = 1:length(frames_list)
        reachFrame = frames_list(i);
        
        % Check if the frame number is within the range of the video
        if reachFrame > vidObj.NumFrames
            warning('Frame number %d exceeds the total number of frames in the video.', reachFrame);
            continue;
        end
        
        % Play and review clip
        playAndReviewClip(reachFrame);
    end
    
    % Close the figure
    close(fig);
    
    % Save userChoices to a file
    save('userChoices.mat', 'userChoices');
end