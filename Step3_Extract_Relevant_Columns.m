%% Step 3: Extract Relevant Columns for Segment Angles for All Trials

% Validate that df_drop_nan exists and contains data
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan)
    error('df_drop_nan is undefined or empty. Ensure Step 2 runs successfully before Step 3.');
end

% Preallocate cell arrays for all files and trials
num_files = size(df_drop_nan, 1); % Number of files
num_trials = size(df_drop_nan, 2); % Number of trials per file

L_thigh_trials = cell(num_files, num_trials);
L_shank_trials = cell(num_files, num_trials);
L_foot_trials = cell(num_files, num_trials);
R_thigh_trials = cell(num_files, num_trials);
R_shank_trials = cell(num_files, num_trials);
R_foot_trials = cell(num_files, num_trials);
trunk_trials = cell(num_files, num_trials);
pelvis_trials = cell(num_files, num_trials);
time_trials = cell(num_files, num_trials); % Include the time column for each trial

disp('Step 3: Extracting segment data for all files and trials...');

% Loop through each file and trial
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Check if df_drop_nan{file_idx, trial_idx} contains data
        if ~isempty(df_drop_nan{file_idx, trial_idx})
            % Access the trial data
            trial_data = df_drop_nan{file_idx, trial_idx};

            % Ensure the data has enough columns
            if size(trial_data, 2) >= 37
                % Extract the time column (always column 1)
                time_trials{file_idx, trial_idx} = trial_data(:, 1);

                % Extract segments for the Left Leg (L)
                L_thigh_trials{file_idx, trial_idx} = trial_data(:, 17:19); % Columns 17-19
                L_shank_trials{file_idx, trial_idx} = trial_data(:, 20:22); % Columns 20-22
                L_foot_trials{file_idx, trial_idx} = trial_data(:, 14:16); % Columns 14-16

                % Extract segments for the Right Leg (R)
                R_thigh_trials{file_idx, trial_idx} = trial_data(:, 26:28); % Columns 26-28
                R_shank_trials{file_idx, trial_idx} = trial_data(:, 29:31); % Columns 29-31
                R_foot_trials{file_idx, trial_idx} = trial_data(:, 23:25); % Columns 23-25

                % Extract trunk and pelvis segments
                trunk_trials{file_idx, trial_idx} = trial_data(:, 32:34); % Columns 32-34
                pelvis_trials{file_idx, trial_idx} = trial_data(:, 35:37); % Columns 35-37
            else
                fprintf('Trial %d in file %d skipped: Not enough columns in the data.\n', trial_idx, file_idx);
            end
        else
            fprintf('Trial %d in file %d skipped: No data found.\n', trial_idx, file_idx);
        end
    end
end

disp('Step 3 completed: Segment angle data extracted successfully.');