# Blackbox Analysis: Product Requirements Document (PRD)

## Project Overview
This document outlines the requirements and steps for analyzing the blackbox system as part of the MTHE 393 course project. The primary goal is to determine the transfer function of the blackbox system by first establishing its properties and then applying appropriate system identification techniques.

## Background
The project involves analyzing a blackbox system with unknown internal dynamics. Based on the MATLAB scripts reviewed, we are working with time-domain signals, testing time-invariance properties, and applying denoising techniques to clean up the output signals.

## Objectives
1. Prove that the blackbox system is Linear Time-Invariant (LTI)
2. Denoise the output signals to remove random noise
3. Determine the transfer function of the blackbox system
4. Validate the derived transfer function with test signals

## Methodology

### 1. Proving LTI Properties
#### Linearity Testing
- Test the system with input signals x₁(t) and x₂(t) separately
- Test with a linear combination a·x₁(t) + b·x₂(t)
- Compare if the output follows the superposition principle: y(a·x₁(t) + b·x₂(t)) = a·y(x₁(t)) + b·y(x₂(t))

#### Time-Invariance Testing
- Test the system with input signal x(t)
- Test with a time-shifted version x(t-τ)
- Compare if the output of the time-shifted input is equivalent to the time-shifted output: y(x(t-τ)) = y(x(t))-τ

### 2. Signal Denoising
- Run multiple identical tests to collect output data (as seen in CopyScript.m)
- Average the signals to reduce random noise (as implemented in outputAverage.m)
- Save the clean signal for further analysis
- Optional: Apply additional filtering techniques if needed

### 3. Transfer Function Identification
- Apply frequency domain analysis:
  - Use sinusoidal inputs at various frequencies
  - Measure amplitude and phase changes
  - Plot Bode diagrams (magnitude and phase)
- Apply time domain analysis:
  - Use impulse or step response methods
  - Curve fit the response to standard transfer function forms
- Consider parametric identification methods:
  - Least squares estimation
  - System identification toolbox functions

### 4. Validation
- Generate predicted outputs using the derived transfer function
- Compare with actual system outputs for various test inputs
- Calculate error metrics (MSE, correlation, etc.)
- Iterate and refine if necessary

## Deliverables
1. MATLAB code demonstrating the LTI properties of the system
2. Denoised output signals saved in appropriate format
3. Derived transfer function in standard form (ratio of polynomials in s or z)
4. Validation results showing the accuracy of the derived transfer function
5. Final report documenting the methodology and results

## Tools and Resources
- MATLAB with appropriate toolboxes (Signal Processing, System Identification, Control Systems)
- Blackbox system access through the provided interface
- Signal generation and data collection scripts

## Timeline
- Week 6: Testing LTI properties
- Week 7: Signal denoising and initial response analysis
- Week 8-9: Transfer function identification
- Week 10: Validation and documentation

## References
- MTHE 393 Project Description
- MTHE 393 Lab Manual
- "A Mathematical Approach to Classical Control"
- Week 7 Notes on signal processing 