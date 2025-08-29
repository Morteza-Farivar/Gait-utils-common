%% Step 5: Process, Center, Normalize, and Filter Gait Cycles for All Trials Based on Heel Strikes

% Validate input
if ~exist('df_drop_nan', 'var') || isempty(df_drop_nan) || ...
   ~exist('Lheel_strikes_all', 'var') || isempty(Lheel_strikes_all) || ...
   ~exist('Rheel_strikes_all', 'var') || isempty(Rheel_strikes_all)
    error('Required variables are missing or undefined. Ensure Steps 2, 3, and 4 run successfully before Step 5.');
end

% Define the number of points for normalization
num_points = 100;

% Define filter parameters
filter_cutoff = 10; % Cutoff frequency in Hz
filter_order = 4;   % Filter order
sampling_rate = 250; % Sampling rate in Hz 
[b, a] = butter(filter_order, filter_cutoff / (sampling_rate / 2), 'low'); % Low-pass Butterworth filter

% Preallocate storage for centered, normalized, and filtered data
num_files = size(df_drop_nan, 1); % Number of files
num_trials = size(df_drop_nan, 2); % Number of trials per file
centered_cycles_all = cell(num_files, num_trials); % Store centered data
normalized_cycles_all = cell(num_files, num_trials); % Store normalized data

% Process each file and trial
disp('Processing, centering, normalizing, and filtering gait cycles for all files and trials...');
for file_idx = 1:num_files
    for trial_idx = 1:num_trials
        % Validate data for the current trial
        if ~isempty(df_drop_nan{file_idx, trial_idx}) && ...
           ~isempty(Lheel_strikes_all{file_idx, trial_idx}) && ...
           length(Lheel_strikes_all{file_idx, trial_idx}) > 1

            trial_data = df_drop_nan{file_idx, trial_idx};
            Lheel_strikes = Lheel_strikes_all{file_idx, trial_idx};
            Rheel_strikes = Rheel_strikes_all{file_idx, trial_idx};

            % Preallocate for the current trial
            num_cycles = length(Lheel_strikes) - 1; % Number of gait cycles
            centered_cycles = cell(num_cycles, 1); % Store centered data
            normalized_cycles = cell(num_cycles, 1); % Store normalized data

            for cycle_idx = 1:num_cycles
                % Define start and end indices of the current gait cycle
                start_idx = Lheel_strikes(cycle_idx);
                end_idx = Lheel_strikes(cycle_idx + 1);

                % Validate range for the current cycle
                if end_idx <= size(trial_data, 1)
                    % Extract current gait cycle
                    current_cycle = trial_data(start_idx:end_idx, :);

                    % Center the gait cycle (subtract mean for each column)
                    centered_cycle = current_cycle - mean(current_cycle, 1, 'omitnan');

                    % Normalize the centered gait cycle to 100 points
                    normalized_cycle = resample(centered_cycle, num_points, size(centered_cycle, 1));

                    % Apply filtering to each column of normalized data
                    filtered_cycle = zeros(size(normalized_cycle));
                    for col_idx = 1:size(normalized_cycle, 2)
                        filtered_cycle(:, col_idx) = filtfilt(b, a, normalized_cycle(:, col_idx));
                    end

                    % Store centered, normalized, and filtered data
                    centered_cycles{cycle_idx} = centered_cycle;
                    normalized_cycles{cycle_idx} = struct( ...
                        'L_thigh_X', filtered_cycle(:, 17)', ...
                        'L_thigh_Y', filtered_cycle(:, 18)', ...
                        'L_thigh_Z', filtered_cycle(:, 19)', ...
                        'L_shank_X', filtered_cycle(:, 20)', ...
                        'L_shank_Y', filtered_cycle(:, 21)', ...
                        'L_shank_Z', filtered_cycle(:, 22)', ...
                        'L_foot_X', filtered_cycle(:, 14)', ...
                        'L_foot_Y', filtered_cycle(:, 15)', ...
                        'L_foot_Z', filtered_cycle(:, 16)', ...
                        'R_thigh_X', filtered_cycle(:, 26)', ...
                        'R_thigh_Y', filtered_cycle(:, 27)', ...
                        'R_thigh_Z', filtered_cycle(:, 28)', ...
                        'R_shank_X', filtered_cycle(:, 29)', ...
                        'R_shank_Y', filtered_cycle(:, 30)', ...
                        'R_shank_Z', filtered_cycle(:, 31)', ...
                        'R_foot_X', filtered_cycle(:, 23)', ...
                        'R_foot_Y', filtered_cycle(:, 24)', ...
                        'R_foot_Z', filtered_cycle(:, 25)', ...
                        'pelvis_X', filtered_cycle(:, 35)', ...
                        'pelvis_Y', filtered_cycle(:, 36)', ...
                        'pelvis_Z', filtered_cycle(:, 37)', ...
                        'trunk_X', filtered_cycle(:, 32)', ...
                        'trunk_Y', filtered_cycle(:, 33)', ...
                        'trunk_Z', filtered_cycle(:, 34)' ...
                    );
                else
                    fprintf('Skipping cycle %d in file %d, trial %d: Data range insufficient.\n', ...
                        cycle_idx, file_idx, trial_idx);
                end
            end

            % Save centered and normalized cycles for the current trial
            centered_cycles_all{file_idx, trial_idx} = centered_cycles;
            normalized_cycles_all{file_idx, trial_idx} = normalized_cycles;
        else
            fprintf('Skipping file %d, trial %d: Missing or insufficient heel strikes.\n', file_idx, trial_idx);
        end
    end
end

disp('Gait cycle centering, normalization, and filtering completed for all files and trials.');

% Save centered, normalized, and filtered data to Workspace
assignin('base', 'centered_cycles_all', centered_cycles_all);
assignin('base', 'normalized_cycles_all', normalized_cycles_all);

disp('Step 5 completed: Centered, normalized, and filtered data for all files and trials saved successfully.');