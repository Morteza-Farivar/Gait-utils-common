%% Step 4: Gait Cycle Determination for Each Trial 

% Validate input
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan)
    error('df_drop_nan is undefined or empty. Ensure Steps 2 and 3 run successfully before Step 4.');
end

% Debugging: Check the structure of df_drop_nan
disp('Debugging df_drop_nan structure:');
disp(['Number of trials in df_drop_nan: ', num2str(length(df_drop_nan))]);

% Preallocate cell arrays for all files and trials
num_files = size(df_drop_nan, 1); % Number of files
num_trials = size(df_drop_nan, 2); % Number of trials per file

LHeel_Y_all = cell(num_files, num_trials); % Left Heel Y-coordinates for all files and trials
RHeel_Y_all = cell(num_files, num_trials); % Right Heel Y-coordinates for all files and trials
Lheel_strikes_all = cell(num_files, num_trials); % Left Heel strikes for all files and trials
Rheel_strikes_all = cell(num_files, num_trials); % Right Heel strikes for all files and trials

% Initialize storage for gait cycle counts
gait_cycles_count = struct();

% Process each file and trial
disp('Processing Heel Strike data for each file and trial...');
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Ensure the trial contains valid data
        if ~isempty(df_drop_nan{file_idx, trial_idx}) && size(df_drop_nan{file_idx, trial_idx}, 2) >= 9
            % Extract Y-coordinates for Left and Right Heel
            LHeel_Y_all{file_idx, trial_idx} = df_drop_nan{file_idx, trial_idx}(:, 3); % Column 3: Left Heel
            RHeel_Y_all{file_idx, trial_idx} = df_drop_nan{file_idx, trial_idx}(:, 9); % Column 9: Right Heel

            % Detect Heel Strikes
            threshold_factor = 0.3; % Define threshold as 30% of the maximum value

            % Left Heel Strikes
            threshold_L = threshold_factor * max(LHeel_Y_all{file_idx, trial_idx});
            [~, Lheel_strikes_all{file_idx, trial_idx}] = findpeaks(LHeel_Y_all{file_idx, trial_idx}, ...
                'MinPeakHeight', threshold_L, 'MinPeakDistance', 50);

            % Right Heel Strikes
            threshold_R = threshold_factor * max(RHeel_Y_all{file_idx, trial_idx});
            [~, Rheel_strikes_all{file_idx, trial_idx}] = findpeaks(RHeel_Y_all{file_idx, trial_idx}, ...
                'MinPeakHeight', threshold_R, 'MinPeakDistance', 50);

            % Count Gait Cycles
            num_Lheel_strikes = length(Lheel_strikes_all{file_idx, trial_idx});
            num_Rheel_strikes = length(Rheel_strikes_all{file_idx, trial_idx});

            % Store Gait Cycle Count
            subject_key = sprintf('Subject_%d', file_idx);
            trial_key = sprintf('Trial_%d', trial_idx);

            if ~isfield(gait_cycles_count, subject_key)
                gait_cycles_count.(subject_key) = struct();
            end
            gait_cycles_count.(subject_key).(trial_key) = struct(...
                'LeftHeelStrikes', num_Lheel_strikes, ...
                'RightHeelStrikes', num_Rheel_strikes);
        else
            fprintf('Skipping trial %d in file %d: Not enough columns or no data.\n', trial_idx, file_idx);
        end
    end
end
disp('Heel Strike detection for all files and trials completed.');

% Save all data to Workspace
assignin('base', 'LHeel_Y_all', LHeel_Y_all);
assignin('base', 'RHeel_Y_all', RHeel_Y_all);
assignin('base', 'Lheel_strikes_all', Lheel_strikes_all);
assignin('base', 'Rheel_strikes_all', Rheel_strikes_all);

% Save Gait Cycle Counts
assignin('base', 'gait_cycles_count', gait_cycles_count);

disp('Step 4 completed: Data for all files and trials saved successfully.');
disp('Gait Cycle Counts saved to Workspace.');