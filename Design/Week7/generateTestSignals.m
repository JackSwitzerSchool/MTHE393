% Script to generate test signals for sin(0.01*t) and sin(1000*t)
% Based on CopyScript.m

%================Do Not Edit===============================================
% Find handle to hidden figure
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
% Get the handles structure
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );

%================Start Editing=============================================
% Add path to Blackbox directory
addpath('C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Blackbox');

% Create and cd to frequency data directory
base_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\freq_data';
if ~exist(base_dir, 'dir')
    mkdir(base_dir);
end

% Create subdirectories for each frequency
low_freq_dir = fullfile(base_dir, 'low_freq');
high_freq_dir = fullfile(base_dir, 'high_freq');

if ~exist(low_freq_dir, 'dir')
    mkdir(low_freq_dir);
end

if ~exist(high_freq_dir, 'dir')
    mkdir(high_freq_dir);
end

current_dir = pwd;

% This will let you pick the Field radio button
set(handles.radioField, 'Value', 1);

% Define the frequencies to test
frequencies = [0.01, 1000];
freq_names = {'low_freq', 'high_freq'};
freq_dirs = {low_freq_dir, high_freq_dir};
num_iterations = 100;  % Generate 100 outputs for each frequency

% Setup progress reporting
total_iterations = length(frequencies) * num_iterations;
fprintf('Starting signal generation with %d total outputs...\n', total_iterations);

% Disable unnecessary output
orig_state = warning('off', 'all'); % Turn off warnings
diary off; % Turn off diary if it's on

% Loop through each frequency
for freq_idx = 1:length(frequencies)
    current_freq = frequencies(freq_idx);
    current_dir_name = freq_names{freq_idx};
    current_output_dir = freq_dirs{freq_idx};
    
    % Change to the appropriate directory
    cd(current_output_dir);
    
    fprintf('\nGenerating %d outputs for sin(%.2f*t) in %s\n', num_iterations, current_freq, current_dir_name);
    
    % Generate multiple outputs for the same frequency with different noise
    for k = 1:num_iterations
        if mod(k, 10) == 0 || k == 1 || k == num_iterations
            fprintf('  Generating output %d of %d (%.2f%%)\n', k, num_iterations, (k/num_iterations)*100);
        end
        
        % Create sinusoidal input with current frequency
        name = sprintf('sin(%g*t)', current_freq);
        set(handles.input, 'String', name);

        % This invokes the input Callback - capture and discard output
        evalc('feval(get(handles.input,''Callback''),handles, event)');

        % Set appropriate time parameters based on frequency
        if current_freq < 1
            % For low frequency, use longer time span
            set(handles.axisStart, 'String', '0');
            set(handles.axisEnd, 'String', '1000');  % Long enough to capture multiple cycles
            set(handles.stepSize, 'String', '0.1');  % Larger step size for efficiency
        else
            % For high frequency, use shorter time span with finer resolution
            set(handles.axisStart, 'String', '0');
            set(handles.axisEnd, 'String', '0.1');   % Short enough to be efficient
            set(handles.stepSize, 'String', '0.0001'); % Small enough to capture the high frequency
        end
        
        % Set refine output
        set(handles.refineOutput, 'String', '5');

        % Use the run button - capture and discard output
        evalc('feval(get(handles.run,''Callback''),handles, event)');
        
        % Create a unique filename for this iteration
        filename = sprintf('%s_iter_%03d', current_dir_name, k);
        
        % This changes the save file name
        set(handles.saveFile, 'String', filename);
        
        % Use the save button - capture and discard output
        evalc('feval(get(handles.save,''Callback''),handles, event)');
    end
end

% Restore warning state
warning(orig_state);

% Return to original directory
cd(current_dir);

fprintf('\nSignal generation complete!\n');
fprintf('Generated %d files for sin(0.01*t) in %s\n', num_iterations, low_freq_dir);
fprintf('Generated %d files for sin(1000*t) in %s\n', num_iterations, high_freq_dir);

%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp); 