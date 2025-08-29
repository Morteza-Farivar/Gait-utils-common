function df_list = step01_load_data(data_folder)
% STEP01_LOAD_DATA
% Load and validate Excel gait files (FW/BW) and slice them into trials.
%
% INPUT (optional):
%   data_folder : char/string, path to folder containing .xlsx files.
%                 If omitted, a default path (your current one) is used.
%
% OUTPUT:
%   df_list : cell array of tables, sized {nFiles x nTrials}, where each
%             cell holds the time column + 36 columns of the selected trial.
%
% NOTES:
%   - Expects filenames like S01_FW_SegCalc.xlsx or S20_BW_SegCalc.xlsx
%   - Trials order follows your current script:
%       ["walk100","walk120","walk140","walk160","walk60","walk80"]
%   - This step only loads and slices trials (no cleaning, no events).

    % ---------- Default folder if not provided ----------
    if nargin < 1 || isempty(data_folder)
        data_folder = 'C:\Users\Student\Desktop\3. MATLAB Code for both Projects\Data_SegCalc_FW_BW\FW';
    end

    % ---------- List and basic validation ----------
    disp(['Checking folder: ', data_folder]);
    d = dir(fullfile(data_folder, '*.xlsx'));

    if isempty(d)
        error('No Excel files found in the folder: %s. Please check the folder path.', data_folder);
    else
        disp('Files found in the folder:');
        for i = 1:length(d), disp(d(i).name); end
    end

    % ---------- Keep only valid filenames ----------
    valid_files = repmat(struct('name','','folder','','date','', ...
        'bytes',0,'isdir',false,'datenum',0), length(d), 1);
    valid_count = 0;

    for i = 1:length(d)
        filename = d(i).name;
        match = regexp(filename, '^S\d{2}_(FW|BW)_SegCalc\.xlsx$', 'once');
        if ~isempty(match)
            valid_count = valid_count + 1;
            valid_files(valid_count) = d(i);
        else
            disp(['Skipping file: ', filename, '. Invalid subject ID format.']);
        end
    end

    valid_files = valid_files(1:valid_count);
    d = valid_files;

    if isempty(d)
        error('No valid files found in the folder: %s. Please check the file names.', data_folder);
    else
        disp(['Valid files detected: ', num2str(length(d))]);
        for i = 1:length(d), disp(d(i).name); end
    end

    % ---------- Trials (your original order) ----------
    trials = ["walk100","walk120","walk140","walk160","walk60","walk80"];

    % ---------- Preallocate output ----------
    df_list = cell(length(d), length(trials));

    % ---------- Read each file and slice into trials ----------
    for file_idx = 1:length(d)
        filename = d(file_idx).name;
        filepath = fullfile(data_folder, filename);

        % Read data table
        try
            data = readtable(filepath); % headers auto-adjusted by MATLAB
        catch ME
            disp(['Error reading file: ', filename, '. Skipping...']);
            disp(['Error Message: ', ME.message]);
            continue;
        end

        % Slice trials (time column = 1, then blocks of 36 columns)
        for trial_idx = 1:length(trials)
            start_col = 2 + (trial_idx - 1) * 36;
            end_col   = 1 + trial_idx * 36;

            if end_col <= size(data, 2)
                df_list{file_idx, trial_idx} = data(:, [1, start_col:end_col]);
            else
                disp(['Skipping trial ', char(trials(trial_idx)), ' for file ', filename, ...
                      ': Columns exceed dataset size.']);
                df_list{file_idx, trial_idx} = [];
            end
        end
    end

    % ---------- Summary ----------
    disp(['Step 1 completed: ', num2str(length(d)), ' valid files processed.']);
    disp(['df_list size: ', num2str(size(df_list,1)), ' x ', num2str(size(df_list,2))]);
end
