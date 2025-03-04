% How to Use the GUI with a Script
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
freq_data_dir = 'C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\freq_data';
if ~exist(freq_data_dir, 'dir')
    mkdir(freq_data_dir);
end
current_dir = pwd;
cd(freq_data_dir);

% This will let you pick the Field radio button
set(handles.radioField, 'Value', 1);

% Generate logarithmically spaced frequencies
frequencies = logspace(-4, 4, 50);  % 200 points between 10^-4 and 10^4

% Setup progress reporting
total_iterations = length(frequencies);
fprintf('Starting frequency sweep with %d points...\n', total_iterations);
progress_interval = max(1, floor(total_iterations/20)); % Report progress ~20 times

% Disable unnecessary output
orig_state = warning('off', 'all'); % Turn off warnings
diary off; % Turn off diary if it's on

% for loop over frequencies
for k = 1:length(frequencies)
    % Report progress at intervals
    if mod(k, progress_interval) == 0 || k == 1 || k == length(frequencies)
        fprintf('Processing frequency %d of %d (%.2f%%): %.6e rad/s\n', ...
                k, total_iterations, (k/total_iterations)*100, frequencies(k));
    end
    
    % Create sinusoidal input with current frequency
    name = sprintf('sin(%g*t)', frequencies(k));
    set(handles.input, 'String', name);

    % This invokes the input Callback - capture and discard output
    evalc('feval(get(handles.input,''Callback''),handles, event)');

    % This changes the start time
    set(handles.axisStart, 'String', '0');
    % This changes the end time
    set(handles.axisEnd, 'String', '10');
    % This changes the step size
    set(handles.stepSize, 'String', '0.001');
    % This changes the refine output
    set(handles.refineOutput, 'String', '5');

    % Use the run button - capture and discard output
    evalc('feval(get(handles.run,''Callback''),handles, event)');
    
    % Convert frequency to string without decimal points (using exponential notation)
    freq_str = sprintf('freq_%d', round(frequencies(k) * 1e6));  % Scale by 1e6 to preserve precision
    % This changes the save file name (just the filename, no path)
    set(handles.saveFile, 'String', freq_str);
    % Use the save button - capture and discard output
    evalc('feval(get(handles.save,''Callback''),handles, event)');
end

% Restore warning state
warning(orig_state);

% Return to original directory
cd(current_dir);

fprintf('\nFrequency sweep complete! Generated %d files in %s\n', total_iterations, freq_data_dir);

%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp);