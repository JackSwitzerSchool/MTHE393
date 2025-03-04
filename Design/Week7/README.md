# Blackbox Analysis Scripts

This directory contains MATLAB scripts for analyzing the blackbox system through frequency domain analysis, denoising, and transfer function identification.

## Important: GUI Handling and File Dependencies

**CRITICAL**: 
1. These scripts require the blackbox GUI to be open and ready *before* running. Do not use `clear all` or `close all` as this will close the GUI interface.

2. The scripts add the path to the Blackbox directory containing csfunc2.p:
   ```
   C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Blackbox
   ```
   Make sure this file exists in this location before running the scripts.

## Starting the Blackbox GUI

Before running any of the analysis scripts, you must first open the blackbox GUI:

**Option 1**: Use the provided helper script:
```matlab
run LaunchBlackboxGUI.m
```
This script will automatically launch the GUI from the Blackbox directory.

**Option 2**: Manually launch the GUI:
1. Navigate to the `Design/Blackbox/` directory
2. Open the main GUI file (typically this would be run by opening a GUI file, though the exact filename may vary)
3. Wait for the GUI to initialize completely

## Analysis Workflow

### Step 1: Single Frequency Test

First, run the single frequency test to verify the GUI interaction is working correctly:

```matlab
run SingleFrequencyTest.m
```

This script will:
1. Test a single frequency (1 Hz)
2. Collect and denoise the data
3. Calculate magnitude and phase
4. Generate plots of the results

### Step 2: Full Frequency Response Analysis 

After confirming the single frequency test works, proceed with the full frequency sweep:

```matlab
run FrequencyResponseAnalysis_Fixed.m
```

This script will:
1. Test multiple frequencies (from 0.1 Hz to 10 Hz)
2. For each frequency, collect multiple trials for denoising
3. Calculate magnitude and phase at each frequency
4. Generate a Bode plot of the frequency response
5. Save all data to the 'frequency_sweep_results' directory

### Step 3: Transfer Function Identification

After collecting the frequency response data, identify the transfer function:

```matlab
run TransferFunctionIdentifier.m
```

This script will:
1. Load the frequency response data
2. Try different transfer function orders
3. Select the best model based on fit metrics
4. Generate plots comparing the model to the measured data
5. Save the identified transfer function and test its response to various inputs

## Troubleshooting

If you encounter errors:

1. **Path to csfunc2.p**: If you see an error about `csfunc2.p` not being found, make sure:
   - The file exists in `C:\Users\jacks\Documents\Life\School\3rd Year\W2025\MTHE393\Design\Blackbox`
   - MATLAB has permission to access this file

2. **GUI not found**: Make sure the GUI is open before running the scripts.

3. **Handle errors**: If you get errors about handles or fields, it might mean:
   - The GUI is not open
   - The GUI structure has changed
   - The wrong GUI figure is being detected

4. **Data directory issues**: Make sure you have write permissions in the directory where the scripts are running.

## Results

The scripts will generate several output files:

- **freq_test_results/**: Contains results from the single frequency test
- **frequency_sweep_results/**: Contains all data from the frequency sweep
  - Bode plots (magnitude and phase)
  - Data for each tested frequency
  - Denoised signals
- **identified_model.mat**: The final transfer function model
- **transfer_function.txt**: The transfer function expression in a readable format 