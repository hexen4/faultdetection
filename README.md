# Fault Detection in Electrical Systems Using Machine Learning
## Introduction
This project focuses on predicting electrical failures in transmission wires by utilizing machine learning models. By analyzing data generated from SIMULINK simulations, we aim to create a machine learning model with 100% detection accuracy within 20 milliseconds of fault inception time. This project is inspired by the research outlined in the paper: Differential Fault Detection Scheme for Islanded AC Microgrids Using Digital Signal Processing and Machine Learning Techniques.

## How to Build
Prerequisites:

MATLAB with SIMULINK installed
Required MATLAB toolboxes (e.g., Signal Processing Toolbox, Statistics and Machine Learning Toolbox)
Setup:

Clone this repository to your local machine.
Ensure all MATLAB .m files and .slx files are in the same directory.
How to Run
Follow these steps to execute the simulation and the subsequent machine learning models:

## Run SIMULINK Simulation:

Open simulation.slx in MATLAB and run the simulation using simulation_code.m.
This will generate the initial training data for the machine learning models.
Apply Data Pruning:

Execute pruner.m to reduce the size of the training data generated in step 1.
This step optimizes the dataset for faster processing and better model accuracy.
Simulate Current Transformer Saturation:

Run saturation_applier.m to simulate the effects of current transformer saturation on the data.
Apply Digital Signal Processing:

Execute dsp.m and featurevector_generation.m to apply Fast Fourier Transform (FFT) and other digital signal processing techniques to the data.
Run Fault Classification:

Use classification.m to train and evaluate the fault classification machine learning model.
Run Fault Location Regression:

Finally, execute model_metrics.m to apply the regression model for fault location identification. The ensemble model is used here, as it achieved the best R² scores (0.95 -> corresponding to +-200 m accuracy)
How to Use
Once you have followed the steps above, you can use the trained models to detect faults and predict fault locations in electrical transmission systems. The models are designed to operate with high accuracy and speed, making them suitable for real-time fault detection scenarios.

## To further improve the models:

Apply trained model on IEEE 34 Node Test Feeder to validate model

## Acknowledgments
This project is based on the methodology presented in the paper Differential Fault Detection Scheme for Islanded AC Microgrids Using Digital Signal Processing and Machine Learning Techniques. We acknowledge the original authors for their contribution to the field.

