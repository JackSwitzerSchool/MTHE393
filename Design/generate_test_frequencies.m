% Generate test frequency signals script
% High frequency: sin(10000*t)
% Low frequency: sin(0.001*t)
% 50 iterations for each frequency

%================Start Editing=============================================

% Toggle switches for control
RUN_HIGH_FREQ = true;     % Set to false to skip high frequency tests
RUN_LOW_FREQ = true;     % Set to false to skip low frequency tests
GENERATE_SIGNALS = false; % Set to false to skip signal generation phase
PERFORM_AVERAGING = true;  % Set to false to skip averaging phase
BATCH_SIZE = 10;          % Process files in batches to avoid memory issues

% If you want to average existing signals, specify timestamp here
% Leave empty to use current timestamp for new signals
EXISTING_TIMESTAMP = ''; % Example: '20250318_123456'

% Initialize error log file handle
log_fid = -1;

try
    % GUI setup is only needed when generating signals
    if GENERATE_SIGNALS
        %================Do Not Edit (GUI Setup)===========================
        % Find handle to hidden figure
        temp = get(0,'showHiddenHandles');
        set(0,'showHiddenHandles','on');
        hfig = gcf;
        % Get the handles structure
        handles = guidata(hfig);
        event = struct('Source', handles, 'EventName', 'ButtonPushed');
        addpath('C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Blackbox');
        %==================================================================
        
        % Configure the Field radio button
        set(handles.radioField, 'Value', 1);
    end
    
    % Test configuration
    freq_settings = [
        struct('name', 'high_freq', 'freq', 10000, 'formula', 'sin(10000*t)', 'end_time', 0.003142, 'refine', 10000, 'step_size', 0.000001), 
        struct('name', 'low_freq', 'freq', 0.001, 'formula', 'sin(0.001*t)', 'end_time', 31415.926536, 'refine', 1, 'step_size', 10.000000)
    ];
    iterations = 50;
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % If using existing timestamp, override the current one
    if ~isempty(EXISTING_TIMESTAMP)
        timestamp = EXISTING_TIMESTAMP;
        fprintf('Using existing timestamp: %s\n', timestamp);
    else
        fprintf('Using new timestamp: %s\n', timestamp);
    end
    
    % Create base directory for results
    base_dir = 'Design\Data';
    if ~exist(base_dir, 'dir')
        mkdir(base_dir);
    end
    
    % Create error log file
    log_file = fullfile(base_dir, sprintf('error_log_%s.txt', timestamp));
    log_fid = fopen(log_file, 'w');
    if log_fid == -1
        error('Could not create error log file');
    end
    
    % Process each frequency setting
    for freq_idx = 1:length(freq_settings)
        freq_setting = freq_settings(freq_idx);
        freq_name = freq_setting.name;
        freq = freq_setting.freq;
        formula = freq_setting.formula;
        end_time = freq_setting.end_time;
        refine = freq_setting.refine;
        step_size = freq_setting.step_size;
        
        % Create directory for this frequency
        freq_dir = fullfile(base_dir, freq_name);
        if ~exist(freq_dir, 'dir')
            mkdir(freq_dir);
        end
        
        % Generate data prefix for filenames
        data_prefix = sprintf('%s_%s', freq_name, timestamp);
        
        % SIGNAL GENERATION PHASE
        if GENERATE_SIGNALS
            fprintf('\nGenerating signals for %s...\n', freq_name);
            fprintf('Parameters: end_time=%.6f, refine=%d, step_size=%.6f\n', end_time, refine, step_size);
            
            % Set input formula
            set(handles.input, 'String', formula);
            evalc('feval(get(handles.input,''Callback''),handles, event)');
            
            % Set time parameters
            set(handles.axisStart, 'String', '0');
            set(handles.axisEnd, 'String', num2str(end_time));
            set(handles.stepSize, 'String', num2str(step_size));
            set(handles.refineOutput, 'String', num2str(refine));
            
            % Generate multiple signals
            success_count = 0;
            for i = 1:iterations
                try
                    % Run simulation
                    evalc('feval(get(handles.run,''Callback''),handles, event)');
                    
                    % Save signal
                    filename = sprintf('%s_signal_%03d', data_prefix, i);
                    set(handles.saveFile, 'String', filename);
                    evalc('feval(get(handles.save,''Callback''),handles, event)');
                    
                    success_count = success_count + 1;
                    if mod(i, 10) == 0
                        fprintf('  Generated signal %d/%d\n', i, iterations);
                    end
                catch ME
                    fprintf('  WARNING: Error generating signal %d: %s\n', i, ME.message);
                    fprintf(log_fid, 'Signal Generation Error - %s - Iteration %d\n', freq_name, i);
                    fprintf(log_fid, 'Error: %s\n', ME.message);
                    fprintf(log_fid, 'Stack: %s\n\n', getReport(ME, 'extended'));
                end
            end
        else
            fprintf('Skipping signal generation for %s (toggled off)\n', freq_name);
            
            % If using existing data, count how many files exist
            if ~isempty(EXISTING_TIMESTAMP)
                file_pattern = fullfile(freq_dir, sprintf('%s_%s_signal_*.mat', data_prefix, timestamp));
                signal_files = dir(file_pattern);
                success_count = length(signal_files);
                fprintf('Found %d existing signal files for timestamp %s\n', success_count, timestamp);
            end
        end
        
        % AVERAGING PHASE
        if PERFORM_AVERAGING
            fprintf('Performing averaging for %s...\n', freq_name);
            
            % Find all signal files for this frequency
            file_pattern = fullfile(freq_dir, '*.mat');
            signal_files = dir(file_pattern);
            
            % Skip averaging files to avoid processing results
            valid_files = [];
            for i = 1:length(signal_files)
                if ~contains(signal_files(i).name, 'average') && ~contains(signal_files(i).name, 'summary')
                    valid_files = [valid_files; signal_files(i)];
                end
            end
            signal_files = valid_files;
            
            if isempty(signal_files)
                fprintf('  WARNING: No signal files found matching pattern %s\n', file_pattern);
                continue;
            else
                fprintf('  Found %d .mat files to process\n', length(signal_files));
            end
            
            % Memory-efficient batch processing approach
            fprintf('  Processing files in batches of %d to conserve memory\n', BATCH_SIZE);
            
            % First get signal dimensions from the first file
            first_file = fullfile(signal_files(1).folder, signal_files(1).name);
            try
                first_loaded = load(first_file);
                first_fields = fieldnames(first_loaded);
                
                if ~isempty(first_fields)
                    first_data_struct = first_loaded.(first_fields{1});
                    if isstruct(first_data_struct) && isfield(first_data_struct, 'output')
                        first_output = first_data_struct.output;
                        if isfield(first_output, 'time') && isfield(first_output, 'signal')
                            time_values = first_output.time;
                            signal_length = length(first_output.signal);
                            
                            % Initialize storage for running totals
                            sum_signal = zeros(signal_length, 1);
                            sum_squared = zeros(signal_length, 1);
                            valid_count = 0;
                            
                            % Process files in batches
                            for batch_start = 1:BATCH_SIZE:length(signal_files)
                                batch_end = min(batch_start + BATCH_SIZE - 1, length(signal_files));
                                batch_files = signal_files(batch_start:batch_end);
                                
                                fprintf('  Processing batch %d/%d (files %d-%d)\n', ...
                                    ceil(batch_start/BATCH_SIZE), ceil(length(signal_files)/BATCH_SIZE), ...
                                    batch_start, batch_end);
                                
                                % Process each file in the batch
                                for file_idx = 1:length(batch_files)
                                    try
                                        loaded = load(fullfile(batch_files(file_idx).folder, batch_files(file_idx).name));
                                        field_names = fieldnames(loaded);
                                        
                                        if ~isempty(field_names)
                                            data_struct = loaded.(field_names{1});
                                            if isstruct(data_struct) && isfield(data_struct, 'output')
                                                output = data_struct.output;
                                                if isfield(output, 'time') && isfield(output, 'signal')
                                                    y = output.signal;
                                                    
                                                    % Verify dimensions match
                                                    if length(y) == signal_length
                                                        % Add to running totals for mean and variance
                                                        sum_signal = sum_signal + y;
                                                        sum_squared = sum_squared + (y .* y);
                                                        valid_count = valid_count + 1;
                                                        
                                                        fprintf('    Processed file %d: %s\n', batch_start + file_idx - 1, batch_files(file_idx).name);
                                                    else
                                                        fprintf('    WARNING: Signal file %s has mismatched dimensions. Skipping.\n', batch_files(file_idx).name);
                                                    end
                                                else
                                                    fprintf('    WARNING: File %s missing time or signal data. Skipping.\n', batch_files(file_idx).name);
                                                end
                                            else
                                                fprintf('    WARNING: File %s has incorrect structure. Skipping.\n', batch_files(file_idx).name);
                                            end
                                        else
                                            fprintf('    WARNING: File %s has no data fields. Skipping.\n', batch_files(file_idx).name);
                                        end
                                        
                                        % Clear loaded data after processing
                                        clear loaded field_names data_struct output y;
                                        
                                    catch load_error
                                        fprintf('    WARNING: Error loading file %s: %s\n', batch_files(file_idx).name, load_error.message);
                                    end
                                end
                                
                                % Force garbage collection between batches
                                clear batch_files;
                                java.lang.System.gc();
                            end
                            
                            % Calculate final statistics
                            if valid_count > 0
                                fprintf('  Successfully processed %d valid files\n', valid_count);
                                
                                % Calculate mean
                                avg_signal = sum_signal / valid_count;
                                
                                % Calculate standard deviation
                                % std = sqrt(E[X²] - (E[X])²)
                                mean_squared = sum_squared / valid_count;
                                variance = mean_squared - (avg_signal .* avg_signal);
                                variance(variance < 0) = 0; % Fix any numerical issues
                                std_signal = sqrt(variance);
                                
                                % Save comprehensive average data
                                avg_filename = sprintf('%s_all_signals_average.mat', data_prefix);
                                avg_data = struct(...
                                    'time', time_values, ...
                                    'signal', avg_signal, ...
                                    'std', std_signal, ...
                                    'freq', freq, ...
                                    'refine', refine, ...
                                    'step_size', step_size, ...
                                    'end_time', end_time, ...
                                    'total_files', length(signal_files), ...
                                    'files_used', valid_count);
                                
                                save(fullfile(freq_dir, avg_filename), 'avg_data');
                                
                                % Create plot of average with error bands
                                try
                                    figure('Position', [100, 100, 1000, 600]);
                                    
                                    % Plot mean signal
                                    plot(time_values, avg_signal, 'b-', 'LineWidth', 2);
                                    hold on;
                                    
                                    % Plot standard deviation bands (mean ± std)
                                    plot(time_values, avg_signal + std_signal, 'r--', 'LineWidth', 1);
                                    plot(time_values, avg_signal - std_signal, 'r--', 'LineWidth', 1);
                                    
                                    % Add reference sine wave for comparison
                                    ref_sine = sin(freq * time_values);
                                    plot(time_values, ref_sine, 'g:', 'LineWidth', 1.5);
                                    
                                    % Customize plot
                                    title(sprintf('Averaged Signal for %.6f Hz (%d iterations)', freq, valid_count));
                                    xlabel('Time (s)');
                                    ylabel('Amplitude');
                                    grid on;
                                    legend('Average Signal', '+1 Std Dev', '-1 Std Dev', 'Reference sin(freq*t)');
                                    
                                    % Save plot
                                    saveas(gcf, fullfile(freq_dir, sprintf('%s_average.png', data_prefix)));
                                    saveas(gcf, fullfile(freq_dir, sprintf('%s_average.fig', data_prefix)));
                                    close(gcf);
                                    
                                catch plot_error
                                    fprintf('  WARNING: Error creating plots: %s\n', plot_error.message);
                                    fprintf(log_fid, 'Plot Error - %s\n', freq_name);
                                    fprintf(log_fid, 'Error: %s\n', plot_error.message);
                                    fprintf(log_fid, 'Stack: %s\n\n', getReport(plot_error, 'extended'));
                                end
                            else
                                fprintf('  WARNING: No valid signals processed for %s\n', freq_name);
                            end
                        else
                            fprintf('  WARNING: First file missing time or signal data\n');
                        end
                    else
                        fprintf('  WARNING: First file has incorrect structure\n');
                    end
                else
                    fprintf('  WARNING: First file has no data fields\n');
                end
            catch first_file_error
                fprintf('  WARNING: Error loading first file: %s\n', first_file_error.message);
                fprintf(log_fid, 'First File Error - %s\n', freq_name);
                fprintf(log_fid, 'Error: %s\n', first_file_error.message);
                fprintf(log_fid, 'Stack: %s\n\n', getReport(first_file_error, 'extended'));
            end
        else
            fprintf('Skipping averaging for %s (toggled off)\n', freq_name);
        end
    end
    
    % Close error log
    if log_fid ~= -1
        fclose(log_fid);
    end
    
    fprintf('\nAll processing complete!\n');
    fprintf('Results saved in:\n');
    fprintf('  - Design\\Data\\high_freq\n');
    fprintf('  - Design\\Data\\low_freq\n');
    fprintf('Timestamp for this run: %s\n', timestamp);
    fprintf('Error log: %s\n', log_file);
    
    if ~GENERATE_SIGNALS
        fprintf('Note: GUI access skipped (signal generation was toggled off)\n');
    end
    
catch ME
    % Ensure error log is closed
    if log_fid ~= -1
        fclose(log_fid);
    end
    
    % Re-throw the error
    rethrow(ME);
end 