
% This program reads raw data processes it and triggers hypo alarms 
% Changes that have been implemented in this version: 
% 1. Capabilities "act_on_default_inputs" and "act_on_bedtime_cb" (carbs/bolus) have been added
% 2. Parameter "SET_FORCED_MISSING" has been set to 1 to disable the linear combination method

clear
dataOut = [];
pid=[];th=[];alfa=[];Tf=[];Td=[];Nst=[];tnab5=[];tnab20=[];tnae5=[];tnae20=[];trd=[];anap=[]; % Define parameters of variables below 
%***********************************************

%------------------------------------------------------------------------------------------------------------------
% CODE MODE SELECTION
%------------------------------------------------------------------------------------------------------------------
MODE_SET = 0;                        % Sets mode of operation: 0 = development mode, 1 = real-time verification mode
%-----------------------------------------------------------------------------------------------------------------


scan_threshold = 1; 

% Scanned parameter #   
nps = 1; 

% Range and increment of scanning the thresholds [min increment max]
rist(1,:) = [-15 0.2 15]; 
rist(2,:) = [-10 0.2 10]; 
rist(3,:) = [-25 1.0 -5]; 
rist(4,:) = [-12 0.2 -2]; 
%***********************************************

% Marking threshold for false alarm rate, % of detected hypos  
mfa = 120; 

% ID's of variables 
%  1 - po2hr, 2 - po2_3, 3 - qtc, 4 - random, 5 - po2_5, 6 - hr_var, 7 - po2_1 
%  8 - po2-B, 9 - hr_var2, 10 - hr_var3, 11 - hr_var_auto, 12 - hr_auto, 13 - dc 
%  14 - sim_cgm, 15 - ramp, 16 - ddo_count, 17 - cdo_count

%------------------------------------------------------------------------------------------------------------------
%FORCED ALGORITHM SELECTION
%------------------------------------------------------------------------------------------------------------------
SET_FORCED_MISSING = 1; % 0 - Run ALG337 on occasions where user inputs are available, 1 - will force run ALG340 
%------------------------------------------------------------------------------------------------------------------


%------------------------------------------------------------------------------------------------------------------
% ALG337 SCALING SETTINGS 
%------------------------------------------------------------------------------------------------------------------
C_HYPO_HIGH_PROJ_MAX_SCALE = 1.4;       
C_HYPO_HIGH_PROJ_MIN_SCALE = 0.4;       
C_HYPO_HIGH_PROJ_LOW_CUT = -1.1;      
C_HYPO_HIGH_PROJ_DUR1 = 0.4;
C_HYPO_LOW_PROJ_MAX_SCALE = 2.0;                          
C_HYPO_LOW_PROJ_MIN_SCALE = 0.6;           
C_HYPO_LOW_PROJ_LOW_CUT = -0.5;           
C_HYPO_LOW_PROJ_DUR1 = 0.4;
%------------------------------------------------------------------------------------------------------------------


if 1==1
% HR ***********************************************
pid = [pid          12]; % Variable's ID
Tf = [Tf            0.8]; % Filtering time, hr
th = [th           -4.4]; % Threshold 
alfa = [alfa        1.7]; % Power in the BGL-rescaling coefficient 
Td = [Td            0.0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           1]; % Calculate difference of the trend 1="yes", 0="no" 
anap = [anap         1]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end 


if 1==0
% HRV ********************************************
pid = [pid          11]; % Variable's ID
Tf = [Tf           2.2]; % Filtering time, hr
th = [th           5.2]; % Threshold 
alfa = [alfa         0]; % Power in the BGL-rescaling coefficient 
Td = [Td             0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           1]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         1]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end


if 1==0
% ddo count (decaying drop-out count) ***********************************************
pid = [pid          16]; % Variable's ID
Tf = [Tf           0.0]; % Filtering time, hr
th = [th          -11.9]; % Threshold 
alfa = [alfa       0.0]; % Power in the BGL-rescaling coefficient
Td = [Td           0.0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           0]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         0]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end 


if 1==0
% cdo count (cumulative drop-out count) ***********************************************
pid = [pid          17]; % Variable's ID
Tf = [Tf           0.0]; % Filtering time, hr
th = [th           0.0]; % Threshold 
alfa = [alfa       0.0]; % Power in the BGL-rescaling coefficient
Td = [Td           0.0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           0]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         0]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end 


if 1==0
% HRVF **********************************************
pid = [pid          11]; % Variable's ID
Tf = [Tf         0.095];  % Filtering time, hr 
th = [th         -14.2]; % Threshold 
alfa = [alfa       1.6]; % Power in the BGL-rescaling coefficient 
Td = [Td             0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           1]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         1]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end


if 1==0
% Ramp ***********************************************
pid = [pid          15]; % Variable's ID
Tf = [Tf             0]; % Filtering time, hr
th = [th          -1.3]; % Threshold 
alfa = [alfa       0.0]; % Power in the BGL-rescaling coefficient 
Td = [Td             0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           0]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         1]; % Apply no-alarm period 1="yes", 0="no" 
%*************************************************
end 


if 1==0
% CGM ***********************************************
pid = [pid          14]; % Variable's ID
Tf = [Tf          0.25]; % Filtering time, hr
th = [th          -4.2]; % Threshold 
alfa = [alfa       0.0]; % Power in the BGL-rescaling coefficient 
Td = [Td           0.0]; % Delay time, hr (0<=Td)
Nst = [Nst           3]; % Number of filtering stages 
trd = [trd           0]; % Calculate difference of the trend 1="yes", 0="no"
anap = [anap         1]; % Apply no-alarm period 1="yes", 0="no" 
%**************************************************
end


% Logical expression for combining the variables has the form (V1+V3)*(V2+V6)
% Variables appearing in the bilinear terms cannot be included into linear terms. The variable number is limited by 9 
%logic = '(V1+V2)*V3'; 
%logic = 'V1*V2'; 
logic = 'V1+V2'; 
% Apply biased "AND", meaning that the second factor in (V1+V2)*(V3+V4) can only be used for confirmation of alarms rather than triggering of alarms 
% If and_bias = 0, usual "AND" condition is applied 
and_bias = 1; 
% Time window for logical "AND" before the main response 
tand_b = 1.2; 
% Time window for logical "AND" after the main response. This parameter is not used in plain "AND" condition.  
tand_a = tand_b; 
% CGM no-alarm threshold, mmol/L
thpai = 48; 
% Hypo value of BGL for rescaling purposes 
VAR_Ghpn = 1.8;

% No-alarm period at the beginning of the night; hr 
%***************************************************
tnab5 = 0.7;   tnab20 = 4.5; 
% Cap of no-alarm period, hr
napcap = 3.0; 
% Floor of no-alarm period, hr
napfloor = 1.0; 
%***************************************************


% Use HR settling filter 
%**************************************************
hr_settling_filter = 1; 
%Filtering time of high-pass filter 
Thp = Tf(1)/0.8*0.9;
%Active time of high-pass filter, hr 
Tahp = 1.7; 
%Exponential amplitude of taper function 
Aex = 4.2; 
%Exponential decay coefficient of taper function (inactive when Aex=0)
edctf = 4.0; 
%**************************************************


% BGL projection options
%***********************************
% Extrapolate BGL into the night
BGLpj = 1; 
% Slope threshold for linear projection of no-alarm period. 
thtg = -2000.0; 
%thtg = -2.0; 
% Minimum accpetable time difference between bedtime BGL and evening BGL, hr
t21min = 1.0; 
% Maximum acceptable time difference between bedtime BGL and evening BGL, hr
t21max = 3; 
% Threshold of BGL for calculation of projected no-alarm period 
Gthnap = 3.8; 
% Use projected scaling (Projected BGL value is subsituted into the scaling factor)
proj_scaling = 1; 
% Projection length, hr (For scaling purposes)
tpjs = 1.5; 
% Projection adjustment factor 
%uafsp = 1.05; % Currently disabled
% Cap of scaling function (does not apply to recal)
%sccap = 2.58919454145690;  % Calculated from original scaling
sccap = 2.5; 
% Floor of scaling function  (does not apply to recal)
%scfloor = 0.32065664525786;   % Calculated from original scaling
scfloor = 0.6; 
% Trigger responses by BGL projection at recalibration
active_BGLpj = 1; 
% Slope threshold for active projection
thtga = -5.0; 
% The longest active BGL projection, hr (when it can trigger responses)
Tpj = 1.2; 
% Delay from the end of NAP to the BGL projection response, hr 
Tpjd = 0.7; 
%***************************************************


% ----------PATIENT PARAMETER CONSTANTS----------------------------------------------------------------------------------------------------
C_DIA = 5;                                                              % Duration of Insulin Action for Rapid Acting Bolus Insulin
C_CHO_RULE = 500;                                                       % Rule for Carbohydate Meals (Value, no units)
C_INS_RULE = 109;                                                       % Rule for Rapid Acting Bolus Insulin (Value, no units)
% -----------------------------------------------------------------------------------------------------------------------------------------

% ----------BGL PROJECTION PARAM CONSTANTS-------------------------------------------------------------------------------------------------
C_PROJ_SHORT = 0.5;
C_PROJ_LONG = 1.5;
C_PROJ_ADJ_PARAM = 1.05;
% -----------------------------------------------------------------------------------------------------------------------------------------

% BGL check (Recalibration) parameters
%*******************************************
% Percentage of patients using random BGL checks (0-100)
bglcp = 0*100; 
% The time of BGL check 
tck0 = 3.0; 
% Standard deviation, hr 
STDtck = 0.5; 
% Use managed recalibration scheme 
managed_recal = 1; 
recal_version = 2; % (1-simple, 2-bolus insulin dynamics)
carb_count = 2; %(1-simple,2-upgraded)
% Correct scaling for carbs/bolus at recalibrations
carb_bolus_recal = 1; 
SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE = 1;                              % = 0 no partially complaint sessions are recalled, =1 all partially compliant sessions are recalled
SET_SIMUL_RECAL_IN_FULL_COMPLIANCE = 1;                                 % = 0 no full complaint sessions are recalled, =1 all full compliant sessions are recalled
C_UTOB_OFFSET = 1;  % 1                                                 % Offset time applied to UTOB
C_LSD_BG_THRESHOLD = 10;                                                % Threshold applied to VAR_BED_BG and VAR_ALG_PROJECTED_BG to determine LSD membership
C_pLSD_THRESHOLD = 0.39;                                                % Threshold applied to pLSD for determining LSD membership
% Bring-forward window of check time, hr
dtca = 1.5; 
% Minimum acceptable BGL check time     
tckmin = 1.0;   
% Apply the floor of no-alarm period to technical alarms
%TA_nap_floor = 1; 
TA_nap_floor = 0; 
% Drop-out rate threshold triggering belt adjustment, % 
%dorth = 6.0; 
dorth = 100.0; 
%**********************************************


% Actions 
%*****************************************************
% Engage actions that minimise wrong predictions caused by default user inputs 
act_on_default_inputs = 1; 
% Act on bedtime carbs/bolus
act_on_bedtime_cb = 1; 
% BGL data source 
bgl_data_source = 2;    % 1- YSI, 2- cgm, 3-finger Pricks
if MODE_SET==1
    bgl_data_source = 3;    % 1- YSI, 2- cgm, 3-finger Pricks
end
ysi_error_band = 1; % 0-no error band, 1-clinical study 
% Specify some input data in file "input_param" for someone else's easy use 
call_input_param = 0; 
% Adjust projection length and no-scaling level in the low stratum of BGL2<=7.0mmol/L
strata_scaling = 1; 
%Update calibration BGL after upright events near bedtime
update_cal = 0; 
% Start HR with the median value of 6 non-dropout samples (Start delay is done by pre-rpocessing code if needed)
median_start = 1; 
% Amplitude of random signal used instead of variable 1
arnd = 0;    % 0 disables this action
% Plot ture positive BGL band (mean+-STD)
plot_Gtp = 0; 
% Taper scaling factor vs. time
taper_scaling = 0; 
% Cut-off time of BGL scaling (where taper function turns to 0.5)
tcot = 6.5; 
% Decay time of taper function 
%tdtf = 0.6;    
tdtf = 0.6;    
% Add calibration error to the reference BGL (not BGL1 and BGL2) 
add_cal_error = 0; 
% STD of added calibration error, mmol/L 
sdce = 0.0; 
% Model use of finger prick instead of YSI 
model_finger_prick = 0;  
% 1- Add error to BGL1 and BGL2 only 
% 2- Add error to all BGL data
% Stop monitoring if BGL correction occurs (currently applies to clinical data 4000-8500 only)
stop_at_BGL_correction = 1; 
% Adjust the code to perform in agreement with the real-time version 
adjust_to_rt = 1; 
% Include responses within the no-alarm period
% Use interpolation to determine BGL1 and BGL2 (This option is used for verification of real-time code)
interp_BGL12 = 0;
incl_nap_resp = 0; 
% Order of BGL interpolation: 1 - linear, 3 - cubic
BGL_interp = 3;
% Force BGL porfile to be flat and equal to the value at algorithm start 
force_flat_BGL = 0; 
% Produce output of first response time of variable specified below, with respect to BGL data start. 
% With this option, first hour of BGL data is discounted from calculation of no-alarm period to allow variation of algorithm start time. 
first_response_time = 0; 
% Variable number subjected to calculation of first response time 
nvrd = 2;   
% Evaluate the algorithm performance, using responses of each frame 
performace_by_samples = 0; 
% The time interval of keeping an alarm active, hr  
taa = 1.0; 
% Save plots for each patient to a ppt file 
save_plots = 0; 
% Flip late hypos to normals if not enough time is allowed for hypo detection 
flip_late_hypos = 0; 
% No-alarm period at the end of the night; hr 
tnae5 = 15;   tnae20 = 15; 
correlation_analysis = 0; 
% Calculate normalized change of the parameter 
%Calculate derivative of parameter 1 for correlation analysis 
correlation_of_derivative_1 = 0; 
%Calculate derivative of parameter 2 for correlation analysis 
correlation_of_derivative_2 = 0;
normalized_change = 0; 
% Bridge gaps between data drop-outs
bridge_gaps = 1; 
% Output data for trend differences to files 
save_trend_differences = 0; 
% Save performance parameters to file (Sensitivity and specificity vs. threshold)
save_performance = 1; 
% Plot details of each patient in case of a fixed threshold 
plot_each_patient =  1; 
plot_hr = 1; 
% Find best polynomial fit of raw HR data and use it for initial value
fit_within_Tf = 0; 
% Polynomial order 
Pffo = 2; 
% Training criterion 
training_gage = 1; 
% 1 - Sensitiviy + Specificity 
% 2 - Advantage over noise (values geater than 1 are acceptable)
% Minimum acceptable sensitivity in training_gage = 2, % 
Stvtsmin = 15; 
% Late-meal start delay (delay algorithm start in patients having late meal)
lm_start_delay = 0; 
% Latest acceptable meal time, hr
tmacc = -3.0; 
% BGL2 time in delayed algorithm start 
tBGL2d = 1.0; 
% BGL projection length in case of delayed algorithm start
tpjsd = 1.5; 
%************************
% Output pairs of finger prick and corresponding CGM reading
fp_cgm_pairs = 0; % All outher prints below should be disabled for this action
% 1 - HypoMon calibration finger pricks
% 2 - CGM calibration finger pricks
% Time interval of finger prick selection 
tfpti = [-0.1  0.1];  %(when fp_cgm_pairs = 2)
output_G01 = 0;  % (when fp_cgm_pairs = 1)
%************************
print_pat_numbers = 1;
print_predictions = 1;
print_night_duration = 0; 
% Print BGL derivative at hypo onset (Gth) 
print_dBGdtHo = 0; 
print_LagGthd = 0;
print_LagGth = 0; 
print_LagGthn = 0; 
% Print time of hypo onset
print_t_hypo = 0;
% Print time of deep hypo onset
print_t_dhypo = 0;
% Print t(BGL1)
print_t1 = 0; 
% Print t(BGL2)
print_t2 = 0; 
% Print BGL1
print_BGL1 = 0;  
% Print BGL2
print_BGL2 = 0;
% Print BGL derivative 
print_dBGdt = 0; 
% Apply p-hypo instead of projection scaling  (This capability has not been developed for use with recalibrations yet)
apply_p_hypo = 0; 
%*********************************************


% Ramp simulation options
%****************************************
% Specify ramp reference (location of 0) if "Ramp" feature is used 
ramp_ref = 1; 
% 1 - start of data, 2 - midnight
% Print algorithm predictions (tp, tn, fp, fn)
% Proportion of nights with alarm clock disengaged 
ppdac = 1; 
% Optimization options
%*******************************************
run_optimization = 0; 
% Targeted specificity, % 
spfct = 83; 
% Coefficient of preference of targeted specificity 
cpts = 2; 
% The number of iterations in optimization of filtering times 
Nitop = 1; 
% Range and increment of scanning the filtering times of variables [min increment max]
ris(1,:) = [1.2   0.1    1.2]; 
ris(2,:) = [2.1   0.1    2.1]; 
ris(3,:) = [0.15  0.01  0.17]; 
% Threshold tolerance as a portion of standard deviation of width of sensitivity graph  
%thtoL = 0.075; 
thtoL = 0.05; 
% Broadening of peak at the lower measurement level (integer number)
brlow = 3;
% Step down to the lower level of peak width measurement, %
stepab = 10; 
%******************************************** 
% Produce data files for SPSS processing 
output_for_spss = 0; 
% Scan Tlag time over values, hr
Tlags = 0.1:0.1:0.3; 
% Scan Tf over values, hr 
Tfs = 0.1:0.1:0.3; 
% Output sampling interval, hr 
dtos = 2/60; 
%**********************************************
% Print data for each individual patient (Maximum of 3 columns are available)
%from column
frcol = 1; 
% to column
tocol = 2; 
%***************************************
% Parameter scaling factors 
%      po2hr po2  qtc  random  po2_5  hr_var  po2_1  po2_8  hr_var2  hr_var3    hr_var_auto    hr_auto   dc     sim_cgm   ramp   ddo_count  cdo_count
psf = [  1    1  -300    30    -1000   1/50     1    -1000   0.025    0.025       0.025          -1      2e-5    1.0      1.0     -0.1        -0.1 ]; 
% Targeted percentage of detected hypos, % 
Hdp = 80; 
% Acceptabel rate of false alarms at detection rate Hdp, per night 
Fac = 2; 
%Fac = 6; 
% Maximum detection rate (%) assumed in calculation of acceptable level of false alarms 
Hdpm = 90; 
% Universal time increment, hr 
dtss = 0.025; 
% Errors of BGL reference devices 
% ********************************************************
% Standard deviation of YSI in hypo region, mmol/L 
Sysih = 0.12; 
% Standard deviation of YSI in eugly region, mmol/L 
Sysie = 0.17; 
% Standard deviation of Finger Prick in hypo region, mmol/L 
Sfph = 0.23;   
% Standard deviation of Finger Prick in eugly region, % of BGL value  
Sfpe = 5.6;   
% Conversion coefficient of units (ccf=plazma/WB)
ccf = 1.12; 
% Default BGL input in plasma units, mmol/L 
Gdefault = 8.0; 
% Optimum BGL in single-BGL scaling (plasma units), mmol/L  (to replace untrusted BGL inputs)
Gopt = 7.0; 


%**********************************************************
%**********************************************************
%**********************************************************
%**********************************************************

% Convert to whole-blood units
Gopt = Gopt/ccf; 

% Define settings depending on the BGL data source
%****************************************************************
% Define error band
error_band = ysi_error_band; 
read_absolute_time = 1; 
% Absolute time of study end, hr (decimal system) 
tabse = 6.0; 
% Lapsed time of study end, hr (This quantity will be used if it is less than other engaged quantities)
tLse = 20; 

% BGL1 and BGL2 parameters 
%***************************
BGL1_source = 1; % 1- Main stream, 2- Finger pricks 
% BGL1 elapsed time 
tBGL1 = -1.0; 
% BGL1 time tolerance 
tlr1 = 0.1; 
BGL2_source = 1; % 1- Main stream, 2- Finger pricks
% BGL2 elapsed time 
tBGL2 = 0; 
% BGL2 time tolerance
tlr2 = 0.1; 
% HypoMon finger pricks priority
HM_fp_priority = 2; % 1- normal, 2- top (no closer samples are looked for if both BGL's are available from HypoMon calibration)
% Use new format of initial BGL files
new_ibls_format = 0; 
%***************************


% Choose settings depending on the BGL data source (YSI, CGM, FP)
%***************************************
if MODE_SET == 1
    % Verification Mode
    scan_threshold = 0;     
    BGL1_source = 1; % 1- Main stream, 2- Finger pricks 
    % BGL1 elapsed time 
    tBGL1 = -2.0;  
    BGL2_source = 1; % 1- Main stream, 2- Finger pricks    
    % Use new format of initial BGL files
    new_ibls_format = 0; 
    error_band = 1; % 0-no error band, 1-YSI, 2-CGM, 3-FP 
    read_absolute_time = 0; 
    % Lapsed time of study end, hr (This quantity will be used if it is less than other engaged quantities)
    tLse = 10.0;
    % Act on Defaults
    act_on_default_inputs = 1;
    % Act on Defaults
    act_on_bedtime_cb = 1;
    
    
    SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE = 1;                              % = 0 no partially complaint sessions are recalled, =1 all partially compliant sessions are recalled
    SET_SIMUL_RECAL_IN_FULL_COMPLIANCE = 1;                                 % = 0 no full complaint sessions are recalled, =1 all full compliant sessions are recalled
    % Use managed recalibration scheme 
    managed_recal = 1;  
    recal_version = 2; % (1-simple, 2-bolus insulin dynamics)

    if (SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE==1 & SET_SIMUL_RECAL_IN_FULL_COMPLIANCE ==1)
        disp('Currently MODE_SET will RECAL all partial complaint and full compliant recalibrations')
    else
        disp('Currently MODE_SET will NOT RECAL all partial complaint and full compliant recalibrations')
    end
    
    
elseif     bgl_data_source==1  % YSI
% Use managed recalibration scheme 
managed_recal = 0;     
% Minimum accpetable time difference between bedtime BGL and evening BGL, hr
t21min = 0; 
elseif bgl_data_source==2  % cgm
    
% BGL1 elapsed time 
tBGL1 = -2.0;  
error_band = 3; % 0-no error band, 1-YSI, 2-CGM, 3-FP  
read_absolute_time = 0; 
% Lapsed time of study end, hr (This quantity will be used if it is less than other engaged quantities)
tLse = 10.0; 
    
elseif bgl_data_source==3  % finger pricks
      
scan_threshold = 0;     
BGL1_source = 2; % 1- Main stream, 2- Finger pricks 
% BGL1 elapsed time 
tBGL1 = -2.0;  
BGL2_source = 2; % 1- Main stream, 2- Finger pricks    
% Use new format of initial BGL files
new_ibls_format = 1; 
error_band = 3; % 0-no error band, 1-YSI, 2-CGM, 3-FP 
read_absolute_time = 0; 
% Lapsed time of study end, hr (This quantity will be used if it is less than other engaged quantities)
tLse = 10.0; 

else
end
%****************************************
%******************************************************************************




if strata_scaling==1
% Clip scaling function at least as much as strata scaling requres    
sccap = min(sccap,2.5);
scfloor = max(scfloor,0.6);
end


% Convertion of calibration BGL's to whole blood units 
if bgl_data_source==1
cal_BGLs_to_WB = 0;
else
cal_BGLs_to_WB = 1;
end


if call_input_param == 1
% Modify some parameters according to input_param file 
input_param 
disp(' ')
disp('File "input_param.m" is used')
end


if error_band == 0
% Glucose threshold referred to as hypo, plasma units
Gth = 3.5*ccf; 
% Glucose threshold referred to as deep hypo, plasma units
Gthd = 3.5*ccf; 
% Time interval adding to true positives before the hypo start, min
dtbe = 10;            dtbe = dtbe/60; 
% Time interval adding to true positives after the ending event, min
dtae = 100;            dtae = dtae/60; 
% Ending event of true postivies. Starting event is always hypo start. 
ending_event = 1;    % 1-hypo start, 2-hypo end 
% Count false positives in hypo patients 
count_fp_in_hypos = 1; 
end


% Define performance evaluation settings
if error_band == 1
% Glucose threshold referred to as hypo, plasma units
Gth = 3.8*ccf; 
% Glucose threshold referred to as deep hypo, plasma units 
Gthd = 3.0*ccf; 
% Time interval adding to true positives before the hypo start, min
dtbe = 40;            dtbe = dtbe/60; 
% Time interval adding to true positives after the ending event, min
dtae = 40;            dtae = dtae/60; 
% Ending event of true postivies. Starting event is always hypo start. 
ending_event = 2;    % 1-hypo start, 2-hypo end 
% Count false positives in hypo patients 
count_fp_in_hypos = 1; 
end

% Define performance evaluation settings
if error_band == 2
% Glucose threshold referred to as hypo, plazma units
Gth = 6.0; 
% Glucose threshold referred to as deep hypo, plazma units 
Gthd = 3.4; 
% Time interval adding to true positives before the hypo start, min
dtbe = 40;            dtbe = dtbe/60; 
% Time interval adding to true positives after the ending event, min
dtae = 40;            dtae = dtae/60; 
% Ending event of true postivies. Starting event is always hypo start. 
ending_event = 2;    % 1-hypo start, 2-hypo end 
% Count false positives in hypo patients 
count_fp_in_hypos = 1; 
end


% Define performance evaluation settings
if error_band == 3
% Glucose threshold referred to as hypo, plazma units
Gth = 5.0; 
% Glucose threshold referred to as deep hypo, plazma units 
Gthd = 3.5; 
% Time interval adding to true positives before the hypo start, min
dtbe = 0;            dtbe = dtbe/60; 
% Time interval adding to true positives after the ending event, min
dtae = 0;            dtae = dtae/60; 
% Ending event of true postivies. Starting event is always hypo start. 
ending_event = 2;    % 1-hypo start, 2-hypo end 
% Count false positives in hypo patients 
count_fp_in_hypos = 1; 
end

% Convert error band to whole blood units if ysi is used as a reference 
if bgl_data_source==1
Gth = Gth/ccf; 
Gthd = Gthd/ccf;    
end


% Define group of patients 
group_of_patients 

if MODE_SET == 1
    scan_threshold = 0;
    pn = pn(1);
end

% Define lag time to be equal to the filtering constant
Tlag = Tf; 

% The number of patients 
Np = length(pn);  

if Np==1
plot_each_patient=1; 
end

% Turn off scanning of threshold in case of only one patient 
if Np==1
scan_threshold = 0; 
end


if run_optimization == 0; 
Nitop = 1; 
end

% The number of variables processed 
Nv = length(pid); 


% The number of variables that undergo optimization of filtering time 
if run_optimization == 1 
Nvft = Nv; 
else 
Nvft = 1; 
end 

if (stop_at_BGL_correction == 1 & MODE_SET == 0)
% Read data matrix about BGL corrections
BGL_corrections
% Height of matrix of BGL corrections 
a = size(BGLC); 
Hbglc = a(1); 
end

% loop of the number of iterations in optimizaiton of filtering times 
for nitop = 1:Nitop

% show iteration number 
if run_optimization == 1 
disp(' ')
disp(['Iteration ' num2str(nitop) ' started **********************'])    
end    
    
% Scan variable number for optimization of filtering times
for nvft = 1:Nvft
    


% Scanned filtering time 
if run_optimization == 1 
Tsc = ris(nvft,1):ris(nvft,2):ris(nvft,3); 
nps = nvft;    
else
Tsc = Tf(1); 
end

% Define range of scanned threhsolds 
ths = rist(nps,1):rist(nps,2):rist(nps,3); 


% The length of scanning vector of filtering time 
Ntsc = length(Tsc); 

% Define initial key values defining the optimum threshold 
% Maximum value 
pprmaxo = -1e10; 
thopto = 0; 
wppro = 0; 
ntsco = 1; 


% Scan filtering time to find its optimum value 
for ntsc = 1:Ntsc 


Tf(nvft) = Tsc(ntsc);  
Tlag(nvft) = Tsc(ntsc);  
     

if scan_threshold == 1
% Memorize assumed optimum threshold of scanned parameter 
aoth = th(nps); 
% Assign very low threshold to the variable whose threshold is scanned
% This is to minimize the width of response matrix kr below 
th(nps) = -10000; 
end


% Define a set of colours for different variables 
col(1) = 'm'; 
col(2) = 'b'; 
col(3) = 'g'; 
col(4) = 'r';
col(5) = 'c'; 
col(6) = 'k'; 


% Assign single values to thresholds if output for spss is engaged
if output_for_spss == 1
th(1) = 0; 
th(2) = 0; 
end


if scan_threshold == 0; 
% Threshold array is equal to a single value 
ths = th(nps); 
end

% The number of elements in threshold scannning array  
Nths = length(ths); 


clear Ntp Nfp Nfpa Ntn Nfn Ntps Nfps Nfpas Ntns Nfns Gtp Gtps Gtp2s

% Define vector of the number of true positive cases vs scanned threshold 
Ntps(1:Nths) = 0; 
% Define vector of the number of false negative cases vs scanned threshold 
Nfns(1:Nths) = 0; 
% Define vector of the numbe of true negative cases vs scanned threshold 
Ntns(1:Nths) = 0; 
% Define vector of the number of false positive cases vs scanned threshold 
Nfps(1:Nths) = 0; 
% Define vector of false positive alarms in normal patients for scanning the threhsold 
Nfpas(1:Nths) = 0; 
% Define vector of true positive BGL values
Gtps(1:Nths) = 0; 
% Define vector of true positive BGL values squared
Gtp2s(1:Nths) = 0; 



% Do not plot each patient if the threshold is scanned 
if Nths>1 
plot_each_patient = 0; 
end


%No-alarm times are specified at these two values of BGL 
G1 = 5;    G2 = 20;     

% Plot no-alarm time line 
%***************************************************
if Nths > 1 & run_optimization==0
figure(59)
hold on 
x = [4 25]; 
y = tnab5*(x-G2)/(G1-G2) + tnab20*(x-G1)/(G2-G1); 
plot(x,y,col(1))
end
%****************************************************


% Define the number of patients with hypo 
Nph = 0;  

% Define the number of patients wthout hypo 
Npn = 0;


% Define the total number of hours processed in normal patients 
ttn = 0; 

% Define vector of correlation coefficients 
vcc = []; 



% Extract variable numbers from the string that defines logical combination of variables 
%**********************************************************************************
% Length of the logical expression that defines combination of variables 
Nlogic = length(logic);  

% Determine the element number forresponding to "*" sign 
Nss = 0; 
for k=1:Nlogic
if strcmp(logic(k),'*')==1
Nss = k;     
end
end

% Define arrays of variable numbers that are included into the "and" combination 
% or1 & or2
or1 = [];
or2 = [];  

if 0<Nss
% Read variable numbers to the left from the "*" sign
if strcmp(logic(Nss-1),')')==1
    k=Nss; 
    while strcmp(logic(k),'(')==0
       if strcmp(logic(k),'V')==1
       or1 = [or1 str2num(logic(k+1))];
       end    
    k=k-1;     
    end     
else  
or1 = [or1 str2num(logic(Nss-1))]; 
end
or1 = fliplr(or1); 


% Read variable numbers to the right from the "*" sign
if strcmp(logic(Nss+1),'(')==1
    k=Nss; 
    while strcmp(logic(k),')')==0
       if strcmp(logic(k),'V')==1
       or2 = [or2 str2num(logic(k+1))];
       end    
    k=k+1;     
    end     
else  
or2 = [or2 str2num(logic(Nss+2))];
end
end % if 0<Nss
%*****************************************************************************


if apply_p_hypo == 1
% disengage projection scaling    
alfa = alfa*0; 
% Define file name 
File = ['p_hypo.txt'];  
% Read data from file to matrix of p-hypo 
Mph = dlmread(File,' ',1,0); 
% Height of matrix Mph 
Nmph = length(Mph(:,1)); 
end


if lm_start_delay == 1 
% Read matrix of last meal time (Patient ID and meal time)
last_meal_time_10000 
% Height of matrix 
NLMT = length(LMT(:,1));  
end


% Define average time of hrv response 
atvar = 0; 
% The number of patients with hrv response 
npvar = 0;
% Array of time delay from hypo onset to alarm 
Athoa = [];
% Array of time delay from deep hypo onset to alarm 
Atdhoa = [];




% Open cycle of patient number 
%****************************************************
for p = 1:Np;  
    
% Define time lag from hypo onset to alarm, hr 
thoa = 100;   
% Define BGL derivative at hypo onset, mmol/L/hr
dBGdtho = 100; 
% Define time lag from deep hypo onset to alarm, hr 
tdhoa = 100;   
% Define: Time of hypo onset nearest to a true positive response
% It is measured at BGL falling to the upper threshold of error band 
thontp = 100; 
% Define time lag from nearest hypo onset to alarm, hr 
thoan = 100; 

% Re-define time of calibration and pre-calibration BGL in current patient
tBGL1p = tBGL1; 
tBGL2p = tBGL2; 


% Decide if BGL check needs to be used
if 0<bglcp & rand<=bglcp/100 
use_bgl_checks = 1; 
else
use_bgl_checks = 0; 
end    


if lm_start_delay == 1 
% Determine if algorithm start needs to be delayed because of late meal    
%********************************
k=1;     
while k<=NLMT & LMT(k,1)~=pn(p) 
k=k+1;   
end    

if NLMT<k
error('Patient is missing in file ''last_meal_time'' ')
end

% Last meal time of current patient 
lmtcp = LMT(k,2); 

if plot_each_patient == 1 & output_for_spss == 0
%******************************************************     
figure(10 + p)
subplot(211)
hold on 
plot(lmtcp,2,'^')
%*********************************************************
end 

if p==1  % (when patient number is 1)
% Memorise original setting of BGL1     
tBGL1p_o = tBGL1p; 
% Memorise original setting of BGL projection length
tpjs_o = tpjs; 
% BGL1 time tolerance
tlr1 = 0.1; 
% BGL2 time tolerance
tlr2 = 0.1; 
% HypoMon finger pricks priority
HM_fp_priority = 1; % 1- normal, 2- top (no closer samples are looked for if both BGL's are available from HypoMon calibration)
end

% Determine if algorithm start needs to be delayed because of late meal
if tmacc<lmtcp
late_start = 1;
% BGL projection length 
tpjs = tpjsd; 
BGL1_source = 2; 
tBGL1p = 0; 
BGL2_source = 1; 
tBGL2p = tBGL2d; 
else
late_start = 0; 
% BGL projection length 
tpjs = tpjs_o; 
BGL1_source = 1; 
tBGL1p = tBGL1p_o; 
BGL2_source = 2; 
tBGL2p = 0; 
end  %if tBGL1p-tmBGL1<lmtcp
%*******************************
end % if lm_start_delay == 1 



% Start of BGL data processing
%***********************************************************************
%**********************************************************************
% Define file name 
if bgl_data_source == 1 | bgl_data_source == 2 
File = ['pat_' num2str(pn(p)) '_bgl_adj.txt'];
elseif bgl_data_source == 3 
File = ['pat_' num2str(pn(p)) '_PlasmaEqRefBGL.txt'];
end    

 
% Read data from file 
A = dlmread(File,' ',1,0); 
% Time in glucose measurment 
tg = A(:,1); 
% Glucose level 
G = A(:,2); 
clear A 


% The number of elements in glucose data 
Ng = length(tg); 


if bgl_data_source == 2
% Read finger prick data     
File = ['pat_' num2str(pn(p)) '_fp.txt']; 
% Read data from file 
A = dlmread(File,' ',1,0); 
a = size(A); 
if a(1)==0
% Length of vector of finger pricks 
Nfp = 0;  
tfp=[]; 
Gfp=[]; 
else
% Time in glucose measurment 
tfp = A(:,1);  
% Glucose level 
Gfp = A(:,2); 
% Length of vector of finger pricks 
Nfp = length(tfp);
end
clear A 
end


if model_finger_prick == 2
% Bring total error up to the finger prick value in all BGL data     
%************************************************
% Generate vector of Ng random numbers with standard deviation of 1
vrndn = randn(Ng,1); 
% Calculate standard deviation of additional error in case of BGL<=4.4
Saddh = sqrt(Sfph^2-Sysih^2); 

for k = 1:Ng
    % Standard deviation of added error 
    if G(k)<=4.4
    Sadd = Saddh; 
    else 
    Sadd = sqrt((Sfpe*G(k)/100)^2-Sysie^2); 
    end
    % Add error to G(k)
    G(k) = G(k) + vrndn(k)*Sadd; 
end % for k = 1:Ng
%******************************************************
end % if model_finger_prick == 2




if adjust_to_rt == 1
% Lapsed time of study end, hr (decimal system) 
eet = 7.0;      
if 7000<pn(p) & pn(p)<8000 & eet<tg(Ng)
% Interpolated glucose value at 6hr of lapsed time      
Geet = spline(tg,G,eet);   
% Find element nearest to 6hr of lapsed time 
[a Nnear] = min(abs(tg-eet)); 
% Add element at 6hr and drop all elements after 6hr
if tg(Nnear)<eet
tg = tg(1:Nnear);
G = G(1:Nnear);  
tg(Nnear+1) = eet; 
G(Nnear+1) = Geet;
else
tg = tg(1:Nnear-1);
G = G(1:Nnear-1);     
tg(Nnear) = eet; 
G(Nnear) = Geet;   
end    
end % if eet<tg(Ng)   
% Round BGL reading to an integer number of 0.1mmol/L    
G = 0.1*round(G/0.1); 
end  % if adjust_to_rt == 1


% The number of elements in glucose data 
Ng = length(tg); 

% The earliest glucose reading time 
tgmin = tg(1); 
% The latest glucose reading time 
tgmax = tg(Ng); 

% Define the time of the end of experiement and modify it later 
% It is defined as the maximum time when all the variables and BGL are still available 
tee = tgmax; 
%**********************************    



% Extract absolute reference time 
%*************************************************************
if read_absolute_time == 1 
File = ['pat_' num2str(pn(p)) '_hmv_hypomon_autohr.txt']; 
% Read first line from the file 
fid = fopen(File);
str = fgetl(fid); 
fclose(fid);
str = [str ' '];
% Length of string 
Nstr = length(str); 

% Find first 0. or 1 in the string
k=0; 
n=0; 
while n==0  
k=k+1; 
if strcmp(str(k:k+1),'0.') | strcmp(str(k:k+1),'1.')
n = k; 
% absolute normalized time of algorithm start 
absnt = str2num(str(n:n+4));  
end
if strcmp(str(k),'1')
n = k; 
% absolute normalized time of algorithm start 
absnt = str2num(str(n));   
end
end % while


% Determine lapsed time of the study end (by protocol)
tstde = absnt*24-24;   
tstde = tabse-tstde;  
% Update the end of the night time 
tee = min(tee,tstde); 
% Lapsed time of midnight 
t24 = 24-24*absnt; 
end % if read_absolute_time == 1
%*****************************************************************

% Update the end of the night time 
tee = min(tee,tLse);  


if stop_at_BGL_correction ==  1 & read_absolute_time == 1
%*****************************************************************
% Define matrix of BGL corrections for current patient 
BGLCp = [];
  
% Check if current patient has been corrected during the ngith 
for k = 1:Hbglc
% Create matrix of BGL corrections of current patient 
if  pn(p)==BGLC(k,1)   
    BGLCp = [BGLCp
            BGLC(k,2:4)]; 
end    
end  % for k = 1:Hbglc  

% Height of matrix 
a = size(BGLCp); 
HBGLCp = a(1); 

if length(BGLCp)>=1
% Convert absolute time into decimal system 
BGLCp(:,2) = BGLCp(:,1) + BGLCp(:,2)/60; 
% Discard first column
BGLCp = BGLCp(:,2:3); 
% Convert time to lapsed units 
BGLCp(:,1) = BGLCp(:,1) + (tstde-tabse);  
% Update end of the nigth time 
tee = min(tee,min(BGLCp(1,1)));  

if plot_each_patient == 1 & output_for_spss == 0
for k = 1:HBGLCp
figure(10 + p)
subplot(211)
hold on 
plot(BGLCp(k,1),BGLCp(k,2),'bd')
end
end % if plot_each_patient == 1 & output_for_spss == 0

end % if length(BGLCp)>=1
%****************************************************************
end % if stop_at_BGL_correction =  1


% Define reference of the no-alarm period 
% Define time of common start of data 
tcds = tgmin;  


for nv = 1:Nv
%******************************    
% Parameter name 
if pid(nv) == 1
pnv = 'po2hr'; 
end
if pid(nv) == 2
pnv = 'po2'; 
end
if pid(nv) == 3
pnv = 'qtc'; 
end   
if pid(nv) == 4
pnv = 'rs'; 
end   
if pid(nv) == 5
pnv = 'po2_5'; 
end   
if pid(nv) == 6
pnv = 'hr_var'; 
end   
if pid(nv) == 7
pnv = 'po2_1'; 
end   
if pid(nv) == 8
pnv = 'po2_8'; 
end   
if pid(nv) == 9
pnv = 'hr_var2'; 
end   
if pid(nv) == 10
pnv = 'hr_var3'; 
end   
if pid(nv) == 11
pnv = 'hr_var_auto'; 
end   
if pid(nv) == 12
pnv = 'hr_auto'; 
end   
if pid(nv) == 13
pnv = 'dc'; 
end    
if pid(nv) == 14
pnv = 'sim_cgm'; 
end    
if pid(nv) == 15
pnv = 'hr_auto'; 
end    
if pid(nv) == 16
pnv = 'ddo_count'; 
end    
if pid(nv) == 17
pnv = 'cdo_count'; 
end    


% Read variable nv  
% Define file name 
File = ['pat_' num2str(pn(p)) '_' pnv '.txt'];  
% Read data from file 
A = dlmread(File,' ',1,0); 

if MODE_SET == 1
% Read hrN and hrA for technical alarm analysis
FilehrA = ['pat_' num2str(pn(p)) '_hrA.txt']; 
FilehrN = ['pat_' num2str(pn(p)) '_hrN.txt']; 
hrA = dlmread(FilehrA,' ',1,0); 
hrN = dlmread(FilehrN,' ',1,0); 
clear FilehrA FilehrN
end


% Save different variables in different matrices
if nv==1
A1 = A;    
k = length(A(:,1)); 
tee = min(tee,A(k,1)); % Update end of experiment time
tcds = max(tcds,A(1,1)); % update time of common data start 
elseif nv==2
A2 = A;   
k = length(A(:,1)); 
tee = min(tee,A(k,1)); 
tcds = max(tcds,A(1,1)); 
elseif nv==3
A3 = A;     
k = length(A(:,1)); 
tee = min(tee,A(k,1)); 
tcds = max(tcds,A(1,1)); 
elseif nv==4
A4 = A;     
k = length(A(:,1)); 
tee = min(tee,A(k,1)); 
tcds = max(tcds,A(1,1)); 
elseif nv==5    
A5 = A; 
k = length(A(:,1)); 
tee = min(tee,A(k,1)); 
tcds = max(tcds,A(1,1)); 
end

clear A
%*******************************
end % for nv = 1:Nv



% Modify time of common data start
if first_response_time == 1
tcds = tgmin+1; 
end


% Extract readings of HypoMon calibration finger pricks
if BGL1_source == 2 | BGL2_source == 2
%***************************************************************

if new_ibls_format == 0 
%**************************
% Open file 
fid2 = fopen('initial_bgls_10000.txt');  
% Skip one line 
str = fgetl(fid2);   
% Get next string 
str = fgetl(fid2);  

% Find string corresponding to current patient 
while 0<length(str) & pn(p)~=str2num(str(1:5))
% Get next string 
str = fgetl(fid2);    
end 

% close file 
fclose(fid2); 

if length(str)==0
error('This patient is missing in file "initial_bgls.txt"')
end

% BGL1 value from HypoMon file 
Ghm = str2num(str(50:53)); 
% BGL2 value from HypoMon file 
Ghm = [Ghm str2num(str(58:61))];  

% Absolute time of BGL1
tGhm = str2num(str(21:22)) + str2num(str(24:25))/60;
% Absolute time of BGL2
tGhm = [tGhm str2num(str(41:42)) + str2num(str(44:45))/60];

% Vector length
NGhm = length(Ghm); 

% Convert to lapsed time referred to midnight 
for k=1:NGhm
if tGhm(k)<24 & 12<tGhm(k)
tGhm(k) = tGhm(k)-24; 
end
end

% Convert to lapsed time 
tGhm = tGhm-tGhm(NGhm); 
%***************************************
end % if new_ibls_format == 0 

if new_ibls_format == 1 
File = ['pat_' num2str(pn(p)) '_initial_bgls.txt'];      
% Open file 
fid2 = fopen(File);   
% Skip one line 
str = fgetl(fid2);    
% Get next string 
str = fgetl(fid2);      
% Vector of data in file 
A = str2num(str); 
% Vector of time of BGL1 and BGL2
tGhm = A(1:2); 
% Vector of BGL1 and BGL2 
Ghm = A(3:4);    
clear A

% If BGL2 is missing, BGL1 is actually taken at bedtime
if length(num2str(tGhm(2)))==3 & num2str(tGhm(2))=='NaN'
tGhm = tGhm(1); 
Ghm = Ghm(1); 
end

% close file 
fclose(fid2);     
end  % if new_ibls_format == 1 

%*******************************************************************
end % ifBGL1_source == 2 | BGL2_source == 2


if update_cal == 1
   if 1/3<tcds          
    tBGL2p = tcds;  
   end   
      if 1.0<tcds        
        tBGL1p = 0; 
      end   
end % if update_cal == 1


% Find BGL1 and BGL2
%*******************************************************************************

% Find BGL1 from calibration finger pricks of HypoMon 
if BGL1_source == 2
% Element number nearest to the targeted time of BGL1   
[a n] = min(abs(tGhm-tBGL1p));
G01 = Ghm(n); 
tnar1 = tGhm(n); 
end

% Find BGL2 from calibration finger pricks of HypoMon 
if BGL2_source == 2
% Element number nearest to the targeted time of BGL2   
[a n] = min(abs(tGhm-tBGL2p));
G02 = Ghm(n);   
tnar2 = tGhm(n); 
end       

% If BGL1 is entered at the same time as BGL2
if new_ibls_format == 1 & tnar1==tnar2 
G02 = Ghm(2);    
end


% Stop further search for BGL1 and BGL2 if they are found from HypoMon finger pricks
% and HypoMon finger pricks priority is "top"
if BGL1_source == 2 & BGL2_source == 2 & HM_fp_priority == 2
sch_flag = 0; 
else
sch_flag = 1; 
end


% Continue search for BGL1 from calibration finger pricks of CGM
if BGL1_source == 2 & tnar1~=tBGL1p & sch_flag == 1
% Try to find a better suited BGL1 finger prick in file "pat_..._fp.txt"    
[b n] = min(abs(tfp-tBGL1p)); 
if b<abs(tnar1-tBGL1p)
G01 = Gfp(n); 
tnar1 = tfp(n); 
end  
end

% Continue search for BGL2 from calibration finger pricks of CGM
if BGL2_source == 2 & tnar2~=tBGL2p & sch_flag == 1
% Try to find a better suited BGL1 finger prick in file "pat_..._fp.txt"    
[b n] = min(abs(tfp-tBGL2p)); 
if b<abs(tnar2-tBGL2p)
G02 = Gfp(n); 
tnar2 = tfp(n); 
end  
end

% Output pairs of FP and CGM samples
if BGL1_source == 2 & BGL2_source == 2 & fp_cgm_pairs == 1
if p==1
disp(['FP  CGM'])
end    
% Output G01:
if output_G01 == 1 & tnar1~=tnar2
% Find nearest time sample of main BGL data stream 
[a n] = min(abs(tg-tnar1)); 
if a<=5/60 
disp([num2str(G01) ' ' num2str(G(n))])    
end    
end
% Output G02:
% Find nearest time sample of main BGL data stream 
[a n] = min(abs(tg-tnar2)); 
if a<=5/60 
disp([num2str(G02) ' ' num2str(G(n))])    
end    
end % if BGL1_source == 2


% Find BGL1 from the main data stream
%************************************
if BGLpj == 1 & (BGL1_source == 1 | (tlr1<abs(tnar1-tBGL1p) & sch_flag==1))
% Find BGL value G01
if interp_BGL12 == 1 & 0<=tBGL1p
% Determine sample number of BGL1
% and bring tanr1 to grid of variable 1
[a NBGL1] = min(abs(tnv-tBGL1p)); 
tnar1 = tnv(NBGL1)   
% Initial glucose level 
G01 = interp1(tg,G,tnar1,'linear'); 
% Keep first decimal place 
G01 = round(G01*10)/10; 
else
% Glucose element number corresponding to the first reference time
[a Ntnar1] = min(abs(tg-tBGL1p)); 
% Initial glucose level 
G01 = G(Ntnar1); 
% Time references of the no-alarm period 
tnar1 = tg(Ntnar1); 
end % if interp_BGL12 == 1
end % if BGLpj == 1 & (BGL1_source == 1 | (tlr1<abs(tnar1-tBGL1p)))
%***************************************



% Find BGL2 from the main data stream
%**************************************
if BGL2_source == 1 | (tlr2<abs(tnar2-tBGL2p) & sch_flag==1)
% Find BGL value G02
if interp_BGL12 == 1
% Determine sample number of BGL2
% and bring tanr2 to grid of variable 1
[a NBGL2] = min(abs(tnv-tBGL2p)); 
tnar2 = tnv(NBGL2);  
% Initial glucose level 2
G02 = interp1(tg,G,tnar2,'linear'); 
% Keep first decimal place 
G02 = round(G02*10)/10; 
else
% Do all the same for BGL2
[a Ntnar2] = min(abs(tg-tBGL2p)); 
G02 = G(Ntnar2);
tnar2 = tg(Ntnar2); 
end % if interp_BGL12 == 1
end 
%******************************************
% End of search for BGL1 and BGL2
%*******************************************************************************


if cal_BGLs_to_WB == 1
% Convert to whole-blood values
if BGLpj==1
G01 = G01/ccf; 
end
G02 = G02/ccf; 
end


% Add random error to BGL1 and BGL2 
%**********************************************
if model_finger_prick==1
% Generate vector of two random numbers with standard deviation of 1
vrndn = randn(2,1); 

if BGLpj == 1
% Standard deviation of added error 
if G01<=4.4
Sadd = sqrt(Sfph^2-Sysih^2); 
else 
Sadd = sqrt((Sfpe*G01/100)^2-Sysie^2); 
end
% Add error to G01
G01 = G01 + vrndn(1)*Sadd; 
end % if BGLpj == 1

% Standard deviation of added error 
if G02<=4.4
Sadd = sqrt(Sfph^2-Sysih^2); 
else 
Sadd = sqrt((Sfpe*G02/100)^2-Sysie^2); 
end
% Add error to G02
G02 = G02 + vrndn(2)*Sadd; 
end  % if model_finger_prick==1
%************************************************


% Add random calibration error to the reference BGL data (Not BGL1 nor BGL2)
if add_cal_error == 1
G = G + randn*sdce; 
end

% Put glucose data on a fine time grid
%********************************************
% Sampling interval of splined data, hr  
dtgs = 1/60; 
% The number of sampling elements 
Ntgs = fix((tgmax-tgmin)/dtgs)+1; 
% Fine time array 
tgs = tgmin:dtgs:tgmin+dtgs*(Ntgs-1); 

tgs = rot90(fliplr(tgs));  

% Update BGL interpolation order
if adjust_to_rt==1 
BGL_interp = 1; 
end


% Spline the glucose data 
if BGL_interp == 1
Gsp = interp1(tg,G,tgs,'linear');     
else 
Gsp = spline(tg,G,tgs); 
end

if force_flat_BGL == 1
Gsp = Gsp*0 + G02; 
end


if plot_each_patient == 1 & output_for_spss == 0
%******************************************************     
figure(10 + p)
subplot(211)
hold on 
if (bgl_data_source ==1 | bgl_data_source ==3)
plot(tgs,Gsp,'r')
else
plot(tg,G,'r.')
plot(tfp,Gfp,'rd')
end
%plot(tgs(1:Ntgs-1),abs(diff(Gsp)/dtgs),'b')  % Plot BGL derivative 
plot([-15 15],[Gth Gth],'c')
plot([-15 15],[Gthd Gthd],'c')
%plot(tgs,Gsp,'r')
grid on 
ylabel('BGL, mmol/L')
title(['Patient ' num2str(pn(p))])
%axis([tgmin tgmax 0 max(Gsp)*1.1])
axis([tgmin-1 tgmax+1 1.0 18])
%*********************************************************
end 


% Output pairs of FP and CGM samples
if fp_cgm_pairs == 2
% The number of finger prick samples 
Ntfp = length(tfp); 
if p==1
disp(['FP  CGM'])
end    
for k=1:Ntfp
% Find nearest time sample of main BGL data stream 
[a n] = min(abs(tg-tfp(k)));
% Include delay
if a<=5/60 & tfpti(1)<=tfp(k) & tfp(k)<=tfpti(2)
disp([num2str(Gfp(k)) ' ' num2str(G(n))])    
end    
end    
end
%**************************************************




% Calculate no-alarm period tnab
%**********************************************************************
if BGLpj == 1
    % BGL derivative at the beginning of the night 
    if tnar2~=tnar1
        dBGdt = (G02-G01)/(tnar2-tnar1);    
    else    
        dBGdt = 0;    
    end
end

if act_on_default_inputs==1 & (G01==Gdefault/ccf | G02==Gdefault/ccf)
    
    if G02~=Gdefault/ccf
        % Time interval of neglecting the alarms in the beginning of the night, hr
        tnab = tnab5*(G02-G2)/(G1-G2) + tnab20*(G02-G1)/(G2-G1); 
    else
        % Time interval of neglecting the alarms in the beginning of the night, hr  
        tnab = tnab5*(Gopt-G2)/(G1-G2) + tnab20*(Gopt-G1)/(G2-G1); 
    end 
    
elseif BGLpj == 1 & dBGdt<thtg
    % Time interval of neglecting the alarms in the beginning of the night, hr
    tnab = -(G02-Gthnap)/dBGdt;
else 
    % Time interval of neglecting the alarms in the beginning of the night, hr
    tnab = tnab5*(G02-G2)/(G1-G2) + tnab20*(G02-G1)/(G2-G1);
end   

% End of no-alarm period at the beginning of the night 
tnabe = tnar2 + tnab; 
%*********************************************************************


% Cap no-alarm period 
tnab = min((tnabe-tnar2),napcap);


% Exclude negative tnab, which can result in no-alarm period ending before the aglgorithm start 
tnab = max(0,tnab); 


if managed_recal == 1 | MODE_SET==1
% floor no-alarm period to the minimum acceptable BGL check time 
% If manage recal is on, recal will be scheduled for 1hr if BGL2<=5mmol/L. 
% Therefore, alarms need to be prevented untill 1hr. It results in requirement of the no-alarm period floor of 1hr. 
tnab = max(tnab,napfloor); 
end


% End of no-alarm period
tnabe = tnar2 + tnab; 

% Time interval after which the alarms are neglected at the end of the night, hr
tnae = tnae5*(G02-G2)/(G1-G2) + tnae20*(G02-G1)/(G2-G1); 

if adjust_to_rt == 1 & BGLpj == 0
tnabe = dtnv*round(tnabe/dtnv); 
end


% Start of no-alarm period at the end of the night 
tnaes = tnar2 + tnae;    

 if plot_each_patient == 1 
%******************************************************     
figure(10 + p)
subplot(211)
hold on 
plot(tnar2,G02,'ro')
if BGLpj == 1
plot(tnar1,G01,'ro')
end
plot(tnabe,Gth,'rv')
%*********************************************************
end


% BGL element number corresponding to the no-alarm reference time  
[a Ntsp0] = min(abs(tgs-tnar2)); 

% Find all time intervals of BGL below threshold
%**********************************************************
% Define the matrix of true positive intervals  
clear ttpi 
ttpi(1,1:2) = 100; 
% Define the number of true-positive intervals 
ntpi = 0;
% Define initial value of cycle index 
k = Ntsp0+1; 
% Define the minimum BGL value that has been seen so far 
Gsmin = 100; 

%**********************************
while k<=Ntgs & (Gthd<Gsmin | Gsp(k-1)<=Gth)
% Find the beginnings of the hypo region  
if (Gsp(k-1)>Gth & Gsp(k)<=Gth) | (Gsp(Ntsp0)<=Gth & k==Ntsp0+1) 
% Update the number of true positives 
ntpi = ntpi+1; 
% Save the start time of true positive interval 
ttpi(ntpi,1) = tgs(k-1);  
end   

% Find the ends of the hypo regions
if (Gsp(k-1)<=Gth & Gsp(k)>Gth) | (Gsp(k)<Gth & k==Ntgs)
% Save the end time of true positive interval   
ttpi(ntpi,2) = tgs(k); 
end   

% Update the minimum BGL and its time 
if Gsp(k)<Gsmin
Gsmin = Gsp(k); 
end

% Update the cycle number 
k = k+1; 
end % of while 
%***********************************
%*****************************************************

% BGL sample number corresponding to the end of experiment 
[a Ntgse] = min(abs(tgs-tee)); 

% Update the minimum BGL 
Gsmin = min(Gsp(Ntsp0:Ntgse));    

% Round to the first decimal point 
if adjust_to_rt==1
Gsmin = 0.1*round(Gsmin/0.1); 
end

% The time of start of the hypo 
tsh = ttpi(1,1);    

% Determine BGL derivative at hypo onset
if tsh~=100
[a n] = min(abs(tgs-tsh)); 
dBGdtho = (Gsp(n)-Gsp(n-1))/dtgs;   
end

% Find the time of entering the deep hypo 
% Define it first 
tedh = 100; 
if Gsmin<Gthd
k=Ntsp0;     
while Gthd<Gsp(k)    
k = k+1;     
end     
% Time of entering deep hypo 
tedh = tgs(k); 
end

% Save matrix of hypo intervals for further use below 
mhi = ttpi; 

% Change the reference event of end of true positives if it is hypo onset  
if ending_event == 1
ttpi(:,2) = ttpi(:,1); 
end

% Add required interval at the beginning of ture positive period 
ttpi(:,1) = ttpi(:,1) - dtbe; 
% Add required interval at the end of ture positive period 
ttpi(:,2) = ttpi(:,2) + dtae; 
%**********************************************************


% Flip late hypos to normals if not enough time is allowed for hypo detection 
if flip_late_hypos == 1 
    Lexpr = tee<tetp; 
else
    Lexpr = 1; 
end


% Plot initial glucose level vs no-alarm time 
if BGLpj == 1 & dBGdt<thtg
else 
        if Nths > 1 & Gsmin<=Gth & run_optimization==0
        figure(59)
        hold on 
        plot(G02,tsh-tnar2,'ro')
        end        
end   % if BGLpj == 1


% Sort between hypo and non-hypo patients
%*************************************************
if Gsmin<=Gth & Lexpr
    % Identifier of hypo patient 
    hypo = 1;     
    % Count the number of patients having a hypo during the night     
    Nph = Nph+1; 
else % treat patient as normal if he wakes up before letting Hypomon to detect the hypo 
    % Identifier of hypo patient 
    hypo = 0;   
    % Count total number of hours in normal patients 
    ttn = ttn + (tgmax-tgmin); 
    % Count the number of patients without hypo 
    Npn = Npn+1; 
end
%**************************************************

%*****************************************************************
%*****************************************************************
% End of BGL data processing

%-------------------------------------------------------------------------------------------------------------------
% Loading of User Input Data
%-------------------------------------------------------------------------------------------------------------------
 

%-----------------------------------------------------------------
 % Import UI data from Pat_xxxx_User_Inputs_Excl_Treat.txt
 %-----------------------------------------------------------------

 DAT_USER_INPUTS = get_AlgData(pn(p),'User_Inputs_Excl_Treat');   
 %-----------------------------------------------------------------
 
 
 % Define missing elements in vector DAT_USER_INPUTS as "NaN"
 %**************************
 % Vector length
 L = length(DAT_USER_INPUTS); 
 
 if L<23
 DAT_USER_INPUTS(L+1:23)=NaN; 
 end
 clear L
 %***************************
 
 
 %-----------------------------------------------------------------
 % Assign DAT_USER_INPUTS to variables
 %-----------------------------------------------------------------
 VAR_STUDYSTART = DAT_USER_INPUTS(1);
 VAR_GENDER = DAT_USER_INPUTS(2);             % 1 = Male, 2 = Female
 VAR_AGE = DAT_USER_INPUTS(3);
 VAR_DOD = DAT_USER_INPUTS(4); % ? duration of desease
 VAR_HEIGHT = DAT_USER_INPUTS(5); 
 VAR_WEIGHT = DAT_USER_INPUTS(6); 
 VAR_AVE_TDD = DAT_USER_INPUTS(7); % ? 
 VAR_EXERCISE_LEVEL = DAT_USER_INPUTS(8); 
 VAR_EXERCISE_TIME = DAT_USER_INPUTS(9);
 VAR_COUNT_HYPO = DAT_USER_INPUTS(10);
 VAR_DINNER_BG = DAT_USER_INPUTS(11); 
 VAR_DINNER_BG_TIME = DAT_USER_INPUTS(12);
 VAR_DINNER_CHO = DAT_USER_INPUTS(13); 
 VAR_DINNER_BOLUS = DAT_USER_INPUTS(14);
 VAR_EVENING_BG = DAT_USER_INPUTS(15);
 VAR_EVENING_BG_TIME = DAT_USER_INPUTS(16);
 VAR_BED_BG = DAT_USER_INPUTS(17);
 VAR_BED_BG_TIME = DAT_USER_INPUTS(18);
 VAR_BED_CHO = DAT_USER_INPUTS(19);
 VAR_BED_BOLUS = DAT_USER_INPUTS(20);
 VAR_RECAL_TIME = DAT_USER_INPUTS(21); 
 VAR_RECAL_CHO = DAT_USER_INPUTS(22);
 VAR_RECAL_BOLUS = DAT_USER_INPUTS(23); 
 %-----------------------------------------------------------------
 

 
 
 %-----------------------------------------------------------------
 % Cast Default Value to NaN 
 %-----------------------------------------------------------------
 VAR_GENDER = F_Cast_Default(VAR_GENDER,1,'NaN');
 VAR_AGE = F_Cast_Default(VAR_AGE,15,'NaN');
 VAR_DOD = F_Cast_Default(VAR_DOD,1,'NaN');
 VAR_HEIGHT = F_Cast_Default(VAR_HEIGHT,150,'NaN');
 VAR_WEIGHT = F_Cast_Default(VAR_WEIGHT,50,'NaN');
 VAR_AVE_TDD = F_Cast_Default(VAR_AVE_TDD,0.81*VAR_WEIGHT,'NaN');
 VAR_EXERCISE_LEVEL = F_Cast_Default(VAR_EXERCISE_LEVEL,0,'NaN');
 VAR_EXERCISE_TIME = F_Cast_Default(VAR_EXERCISE_TIME,-24,'NaN');
 VAR_COUNT_HYPO = F_Cast_Default(VAR_COUNT_HYPO,0,'NaN');
 VAR_DINNER_BG = F_Cast_Default(VAR_DINNER_BG,8,'NaN');
 VAR_DINNER_BG_TIME = F_Cast_Default(VAR_DINNER_BG_TIME,-4,'NaN');
 VAR_DINNER_CHO = F_Cast_Default(VAR_DINNER_CHO,0,'NaN');
 VAR_DINNER_BOLUS = F_Cast_Default(VAR_DINNER_BOLUS,0,'NaN');
 VAR_EVENING_BG = F_Cast_Default(VAR_EVENING_BG,8,'NaN');
 VAR_EVENING_BG_TIME = F_Cast_Default(VAR_EVENING_BG_TIME,-2,'NaN');
 VAR_BED_BG = F_Cast_Default(VAR_BED_BG,8,'NaN');
 VAR_BED_BG_TIME = F_Cast_Default(VAR_BED_BG_TIME,0,'NaN');
 VAR_BED_CHO = F_Cast_Default(VAR_BED_CHO,0,'NaN');
 VAR_BED_BOLUS = F_Cast_Default(VAR_BED_BOLUS,0,'NaN');
 VAR_RECAL_TIME = F_Cast_Default(VAR_RECAL_TIME,NaN,'NaN');  
 VAR_RECAL_CHO = F_Cast_Default(VAR_RECAL_CHO,0,'NaN');
 VAR_RECAL_BOLUS = F_Cast_Default(VAR_RECAL_BOLUS,0,'NaN'); 
 %-----------------------------------------------------------------
 
%-------------------------------------------------------------------------------------------------------------------



%-------------------------------------------------------------------------------------------------------------------
% Validate and Update User Inputs
%-------------------------------------------------------------------------------------------------------------------


 %-----------------------------------------------------------------
% Overwrite VAR_EVENING_BG VAR_BED_BG VAR_STUDYSTART
%-----------------------------------------------------------------
if MODE_SET == 1
    VAR_EVENING_BG = VAR_EVENING_BG/ccf;
    VAR_BED_BG = VAR_BED_BG/ccf;
    if cal_BGLs_to_WB == 1
        VAR_DINNER_BG = VAR_DINNER_BG/ccf;
    end
    VAR_BED_BG_TIME = 0;    
else
    VAR_EVENING_BG = G01;
    VAR_EVENING_BG_TIME = tnar1;
    VAR_BED_BG = G02;
    VAR_STUDYSTART = tnar2;
    VAR_BED_BG_TIME = tnar2;
    if cal_BGLs_to_WB == 1
        VAR_DINNER_BG = VAR_DINNER_BG/ccf;
    end
end
%-----------------------------------------------------------------

%-----------------------------------------------------------------
% Conversion to Absolute Elapsed Time Variable
%-----------------------------------------------------------------
VAR_ABS_ELAPSED_BED_TIME = abs(VAR_BED_BG_TIME);                                                    % VAR_ABS_ELAPSED_BED_TIME calculation
VAR_ABS_ELAPSED_EVENING_TIME = abs(VAR_EVENING_BG_TIME);                                            % VAR_ABS_ELAPSED_EVENING_TIME calculation
VAR_ABS_ELAPSED_DINNER_TIME = abs(VAR_DINNER_BG_TIME);                                              % VAR_ABS_ELAPSED_DINNER_TIME calculation
VAR_ABS_ELAPSED_EXERCISE_TIME = abs(VAR_EXERCISE_TIME);                                             % VAR_ABS_ELAPSED_EXERCISE_TIME calculation
VAR_ABS_RECAL_TIME = abs(VAR_RECAL_TIME);                                                           % VAR_ABS_RECAL_TIME calculation
%-----------------------------------------------------------------


%-------------------------------------------------------------------------------------------------------------------



%-------------------------------------------------------------------------------------------------------------------
% Parameter Calculation
%-------------------------------------------------------------------------------------------------------------------

if (isnan(VAR_ABS_ELAPSED_EVENING_TIME) | VAR_ABS_ELAPSED_DINNER_TIME<VAR_ABS_ELAPSED_EVENING_TIME)
    % Case VAR_ABS_ELAPSED_EVENING_TIME does not exist
    VAR_ABS_BED_CHO_TIME = (VAR_ABS_ELAPSED_DINNER_TIME)/2;
    VAR_ABS_BED_BOLUS_TIME = (VAR_ABS_ELAPSED_DINNER_TIME)/2;
else
    VAR_ABS_BED_CHO_TIME = (VAR_ABS_ELAPSED_EVENING_TIME)/2;
    VAR_ABS_BED_BOLUS_TIME = (VAR_ABS_ELAPSED_EVENING_TIME)/2;
end


if VAR_ABS_ELAPSED_DINNER_TIME>=0                                                                   % VAR_DINNER_BOB_AT_BED (Bolus-on-board at bedtime due to the dinner Bolus)
    VAR_DINNER_BOB_AT_BED = VAR_DINNER_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_ELAPSED_DINNER_TIME),0));
else
    VAR_DINNER_BOB_AT_BED = 0;
end


if VAR_ABS_BED_BOLUS_TIME>=0                                                                        % VAR_BED_BOB_AT_BED (Bolus-on-board at bedtime due to the Bed Bolus)
    VAR_BED_BOB_AT_BED = VAR_BED_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_BED_BOLUS_TIME),0));
else
    VAR_BED_BOB_AT_BED = 0;
end

if isnan(VAR_WEIGHT)                                                                            % VAR_WEIGHT Calculation / Validation
    % If VAR_WEIGHT is not entered
    VAR_WEIGHT = 50;
else
    % VAR_WEIGHT has been entered, do nothing
end

if isnan(VAR_AVE_TDD)                                                                           % VAR_AVE_TDD Calculation / Validation
    % If TDD is not entered
    VAR_AVE_TDD = 0.81*VAR_WEIGHT;
else
    % Validate VAR_AVE_TDD
    if (VAR_AVE_TDD>0.55*VAR_WEIGHT & VAR_AVE_TDD<1.1*VAR_WEIGHT)                     
        % Do Nothing
    else
        VAR_AVE_TDD = 0.81*VAR_WEIGHT;
    end
end

VAR_ISF = C_INS_RULE/VAR_AVE_TDD;                                                                % VAR_ISF Calculation (Insulin Sensitivity Factor (ISF))

VAR_CF = C_CHO_RULE/VAR_AVE_TDD;                                                                 % VAR_CF Calculation Carb (CHO) Factor

VAR_TOTAL_ACTIVE_BOLUS = (VAR_DINNER_BOB_AT_BED + VAR_BED_BOB_AT_BED);                           % VAR_TOTAL_ACTIVE_BOLUS Calculation       

VAR_ACTUAL_BOB_BG_POWER = VAR_TOTAL_ACTIVE_BOLUS*VAR_ISF;                                        % VAR_ACTUAL_BOB_BG_POWER Calculation

if isnan(VAR_EVENING_BG) | VAR_ABS_ELAPSED_EVENING_TIME<t21min | VAR_ABS_ELAPSED_EVENING_TIME>t21max  % VAR_BG_GRADIENT Calculation 
    VAR_BG_GRADIENT = 0;                                                                        % Cases where evening BG is unknown for timing of Evening BG is non-compliant range
else
    VAR_BG_GRADIENT = (VAR_BED_BG - VAR_EVENING_BG)/((VAR_BED_BG_TIME - VAR_EVENING_BG_TIME));              % Case where time between evening and bed BG is >= 1 hour and <= 3 hours 
end


% Projection is compromised by bedtime carbs/bolus if this statement is equal to 1
projection_compromised = 0<VAR_BED_CHO & 0<VAR_BED_BOLUS & VAR_EVENING_BG<VAR_BED_BG | 0<VAR_BED_BOLUS & VAR_BED_CHO==0 & VAR_EVENING_BG<VAR_BED_BG | 0<VAR_BED_CHO & VAR_BED_BOLUS==0 & VAR_BED_BG<=VAR_EVENING_BG; 

% Calculate scaling BGL values at calibration
%***************************************
if act_on_default_inputs==1 & ( VAR_EVENING_BG==Gdefault/ccf | VAR_BED_BG==Gdefault/ccf)

    if VAR_BED_BG~=Gdefault/ccf
        % Bedtime BGL is used as projected BGL 
        VAR_ALG_PROJ_BG_LONG = C_PROJ_ADJ_PARAM*VAR_BED_BG; 
        VAR_ALG_PROJ_BG_SHORT = VAR_ALG_PROJ_BG_LONG; 
    else
        % Optimum BGL is used as projected BGL 
        VAR_ALG_PROJ_BG_LONG = C_PROJ_ADJ_PARAM*Gopt;
        VAR_ALG_PROJ_BG_SHORT = VAR_ALG_PROJ_BG_LONG; 
    end
     
elseif act_on_bedtime_cb==1 & projection_compromised==1
      % Optimum BGL is used as projected BGL 
      VAR_ALG_PROJ_BG_LONG = C_PROJ_ADJ_PARAM*Gopt; 
      VAR_ALG_PROJ_BG_SHORT = VAR_ALG_PROJ_BG_LONG; 
else    
     VAR_ALG_PROJ_BG_SHORT = C_PROJ_ADJ_PARAM*(VAR_BED_BG + VAR_BG_GRADIENT*C_PROJ_SHORT);              % VAR_ALG_PROJ_BG_SHORT (Short (0.5 hour) Projection)
     VAR_ALG_PROJ_BG_LONG = C_PROJ_ADJ_PARAM*(VAR_BED_BG+VAR_BG_GRADIENT*C_PROJ_LONG); % Long (1.5 hour) Projection
end
%*********************************************


%VAR_ALG_PROJ_BG_SHORT = floor(10*VAR_ALG_PROJ_BG_SHORT)/10;                                     % Floor VAR_ALG_PROJ_BG_SHORT to nearest dec place

VAR_ALG_PROJ_BG_SHORT_FLOOR = max(VAR_ALG_PROJ_BG_SHORT,1.9);                                    % Floored version of VAR_ALG_PROJ_BG_SHORT (Short Projection) to prevent error during calculation of scaling function

%VAR_ALG_PROJ_BG_LONG = floor(10*VAR_ALG_PROJ_BG_LONG)/10;                                       % VAR_ALG_PROJ_BG_LONG Floor to nearest dec place

VAR_ALG_PROJ_BG_LONG_FLOOR = max(VAR_ALG_PROJ_BG_LONG,1.9);                                    % Floored version of VAR_ALG_PROJ_BG_LONG (Long Projection) to prevent error during calculation of scaling function


if (VAR_EXERCISE_LEVEL >= 1 & VAR_EXERCISE_TIME >= -8)                                          % VAR_PELOH Post Exercise Late Onset Hypo Risk
    VAR_PELOH = 1;
else
    VAR_PELOH = 0;
end

if VAR_ABS_RECAL_TIME>=0                                                                         % VAR_DINNER_BOB_AT_RECAL (Bolus-on-board at recal time due to the dinner Bolus)
    VAR_DINNER_BOB_AT_RECAL = VAR_DINNER_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_RECAL_TIME+VAR_ABS_ELAPSED_DINNER_TIME),0));
else
    VAR_DINNER_BOB_AT_RECAL = 0;
end

if VAR_ABS_RECAL_TIME>=0                                                                         % VAR_BED_BOB_AT_RECAL (Bolus-on-board at recal time due to the Bed Bolus)
    VAR_BED_BOB_AT_RECAL = VAR_BED_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_RECAL_TIME+VAR_ABS_BED_BOLUS_TIME),0));
else
    VAR_BED_BOB_AT_RECAL = 0;
end

VAR_TOTAL_ACTIVE_BOB_RECAL = VAR_DINNER_BOB_AT_RECAL+VAR_BED_BOB_AT_RECAL;                      % VAR_TOTAL_ACTIVE_BOB_RECAL

VAR_BED_DINNER_BG_RATIO = (VAR_BED_BG/VAR_DINNER_BG);                                           % VAR_BED_DINNER_BG_RATIO Calculation

if (isnan(VAR_DINNER_BOLUS) | isnan(VAR_DINNER_CHO))                                            % VAR_EXCESS_DINNER_BOLUS and VAR_EXCESS_DINNER_CARB Calc of the excessive bolus and carb at dinner time
    VAR_EXCESS_DINNER_BOLUS = NaN;
    VAR_EXCESS_DINNER_CARB = NaN;
elseif (VAR_DINNER_BOLUS==0 | VAR_DINNER_CHO==0)
    VAR_EXCESS_DINNER_BOLUS = 0;
    VAR_EXCESS_DINNER_CARB = 0;
else        
    if (VAR_DINNER_CHO/VAR_CF)>VAR_DINNER_BOLUS
        % Dinner Bolus Insufficient
        VAR_EXCESS_DINNER_BOLUS = 0;
        VAR_EXCESS_DINNER_CARB = abs(VAR_DINNER_BOLUS - (VAR_DINNER_CHO/VAR_CF))*VAR_CF;
    else
        % Dinner Bolus is Excess
        VAR_EXCESS_DINNER_CARB = 0;
        VAR_EXCESS_DINNER_BOLUS = VAR_DINNER_BOLUS - (VAR_DINNER_CHO/VAR_CF);
    end
end

if (isnan(VAR_BED_BOLUS) | isnan(VAR_BED_CHO))                                                  % VAR_EXCESS_BED_BOLUS and VAR_EXCESS_BED_CARB Calc of the excessive bolus and carb at bed time
    VAR_EXCESS_BED_BOLUS = NaN;
    VAR_EXCESS_BED_CARB = NaN;
else
    if (VAR_BED_CHO/VAR_CF)>VAR_BED_BOLUS
        % Bed Bolus Insufficient
        VAR_EXCESS_BED_BOLUS = 0;
        VAR_EXCESS_BED_CARB = abs(VAR_BED_BOLUS - (VAR_BED_CHO/VAR_CF))*VAR_CF;
    else
        % Bed Bolus is Excess
        VAR_EXCESS_BED_CARB = 0;
        VAR_EXCESS_BED_BOLUS = VAR_BED_BOLUS - (VAR_BED_CHO/VAR_CF);
    end
end


if VAR_EXCESS_DINNER_BOLUS<0                                                                   % VAR_EXCESS_DINNER_BOB_AT_BED (Excess Bolus-on-board at bedtime due to the dinner Bolus)
    VAR_EXCESS_DINNER_BOB_AT_BED = VAR_EXCESS_DINNER_BOLUS;
else
    if VAR_ABS_ELAPSED_DINNER_TIME>=0 
        VAR_EXCESS_DINNER_BOB_AT_BED = VAR_EXCESS_DINNER_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_ELAPSED_DINNER_TIME),0));
    else
        VAR_EXCESS_DINNER_BOB_AT_BED = 0;
    end
end

if VAR_EXCESS_BED_BOLUS<0                                                                      % VAR_EXCESS_BED_BOB_AT_BED (Excess Bolus-on-board at bedtime due to the Bed Bolus)
    VAR_EXCESS_BED_BOB_AT_BED = VAR_EXCESS_BED_BOLUS;
else
    if VAR_ABS_BED_BOLUS_TIME>=0
        VAR_EXCESS_BED_BOB_AT_BED = VAR_EXCESS_BED_BOLUS*(max(1-(1/C_DIA)*abs(VAR_ABS_BED_BOLUS_TIME),0));
    else
        VAR_EXCESS_BED_BOB_AT_BED = 0;
    end
end

VAR_TOTAL_EXCESS_ACTIVE_BOLUS = (VAR_EXCESS_DINNER_BOB_AT_BED + VAR_EXCESS_BED_BOB_AT_BED);        % VAR_TOTAL_EXCESS_ACTIVE_BOLUS Calculation (Total Excess Active Bolus Insulin at bed time)

VAR_EXCESS_BOB_BG_POWER = VAR_TOTAL_EXCESS_ACTIVE_BOLUS*VAR_ISF;                                   % VAR_EXCESS_BOB_BG_POWER Calculation

VAR_TOTAL_EXCESS_ACTIVE_CARBS = (VAR_EXCESS_DINNER_CARB + VAR_EXCESS_BED_CARB);                     % VAR_TOTAL_EXCESS_ACTIVE_CARBS (Total Excess Active Carbs at bed time)

VAR_EXCESS_CARB_BG_POWER = (VAR_TOTAL_EXCESS_ACTIVE_CARBS/20)*4.44*(60/VAR_WEIGHT);                 % VAR_EXCESS_CARB_BG_POWER (Based on Howorka Equations)

if isnan(VAR_EVENING_BG)                                                                            % VAR_MEAN_PREBED_BG (mean of bed BG and evening BG)
    % Check is VAR_EVENING_BG skipped
    VAR_MEAN_PREBED_BG = VAR_BED_BG;
else
    VAR_MEAN_PREBED_BG = (VAR_BED_BG+VAR_EVENING_BG)/2;
end

% VAR_LIN_COMB_HIGH calculated using probaliser for ALG 337
VAR_LIN_COMB_HIGH = Linear_Combination_V2_HIGH(VAR_PELOH,VAR_COUNT_HYPO,VAR_DINNER_BG,VAR_BED_DINNER_BG_RATIO,VAR_CF,VAR_ISF,VAR_EXCESS_BOB_BG_POWER,VAR_EXCESS_CARB_BG_POWER);
% VAR_LIN_COMB_LOW calculated using probaliser for ALG 337
VAR_LIN_COMB_LOW = Linear_Combination_V2_LOW(VAR_PELOH,VAR_BED_DINNER_BG_RATIO,VAR_ALG_PROJ_BG_LONG);


if (VAR_BED_BOLUS==0 & VAR_DINNER_BOLUS==0)                                                         % VAR_UTOB (Ultimate time of Bolus)
    % Case: No apparent recent Bolus taken
    VAR_UTOB = 2.5;
elseif (VAR_DINNER_BOLUS>0 & VAR_BED_BOLUS==0)                                                      % Checks if Dinner Bolus is the only recent Bolus Dose
    % Case: Dinner Bolus but no Bed Bolus
    VAR_UTOB = -1*VAR_ABS_ELAPSED_DINNER_TIME+C_DIA;                                                % Determines elapsed time of UTOB based on Dinner Bolus End
else
    % Case: Bed Bolus is assumed most recent Bolus                                                  % Else Bed Bolus is last Bolus
    VAR_UTOB = -1*VAR_ABS_BED_BOLUS_TIME+C_DIA;                                                     % Determines elapsed time of UTOB based on Bed Bolus End
end

% Validation of VAR_UTOB
VAR_UTOB = floor(10*VAR_UTOB)/10;                                                                   % Floor to 1 dec place
VAR_UTOB = VAR_UTOB+C_UTOB_OFFSET;                                                                  % Addition C_UTOB_OFFSET to UTOB
VAR_UTOB = max(VAR_UTOB,1);                                                                         % Ensures Minimum UTOB = 1
VAR_UTOB = min(VAR_UTOB,5);
VAR_UTOB = min(VAR_UTOB,tee-0.5);     % Code hack to ensure VAR_RECAL_TIME is within session

% VAR_HEIGHT, convert Height to metres
% No change
VAR_HEIGHT_METRES = (VAR_HEIGHT/100);


% VAR_EXERCISE_TIME - Calc determines elapsed time of exercise
if isnan(VAR_ABS_ELAPSED_EXERCISE_TIME)                 
    % Case did not exercise
    VAR_EXERCISE_TIME_ELAPSED = -48;
elseif  VAR_ABS_ELAPSED_EXERCISE_TIME>24
    % Case exercise > 24 hours ago
    VAR_EXERCISE_TIME_ELAPSED = -48;
else
    % Case did exercise
    VAR_EXERCISE_TIME_ELAPSED = -1*VAR_ABS_ELAPSED_EXERCISE_TIME;
end
VAR_EXERCISE_TIME_ELAPSED = floor(10*VAR_EXERCISE_TIME_ELAPSED)/10;

% Calc VAR_PREDICT_BG                                                                               % Calculates the Predicted BG based on Bed BG, ISF and Total BOB
VAR_PREDICT_BG = VAR_BED_BG-(VAR_TOTAL_ACTIVE_BOLUS)*VAR_ISF;

% Calc  VAR_INSULIN_STACK_FLAG                                                                      % Insulin Stacking Flag
if  (VAR_BED_BOB_AT_BED>0 & VAR_DINNER_BOB_AT_BED>0)
    % Above logic detects insulin stacking where a Bolus has been taken at dinner and Bed and the time between these events is < C_DIA
    VAR_INSULIN_STACK_FLAG = 1;
else
    VAR_INSULIN_STACK_FLAG = 0;
end

VAR_RECENT_CARB_BG_POWER = (VAR_BED_CHO/20)*4.44*(60/VAR_WEIGHT);                               % Based on Howorka Equations

% pLSD Calculation
VAR_pLSD = pLSD_V1_5(VAR_BED_BG, VAR_BED_CHO, VAR_ALG_PROJ_BG_LONG, VAR_ISF, VAR_RECENT_CARB_BG_POWER);

%-------------------------------------------------------------------------------------------------------------------
% End calculation of Patient Variables
%-------------------------------------------------------------------------------------------------------------------

% Add random number to the BGL check time 
if use_bgl_checks == 1 
tckp = tnar2+tck0+randn*STDtck;  
tckp = max(tnar2+tckmin,tckp);  
end   


if managed_recal == 1 & carb_count == 2 & (bgl_data_source<=2 | MODE_SET ==1)
    %*********************************    

    if recal_version == 2 
        
        %-----------------------------------------------------------------
        % Bolus Dynamics Method
        %-----------------------------------------------------------------
        if isnan(VAR_EVENING_BG) | VAR_ABS_ELAPSED_EVENING_TIME <= t21min | VAR_ABS_ELAPSED_EVENING_TIME >= t21max 
            % Non 1
            use_bgl_checks = 1; 
            VAR_RECAL_TIME = 1;
            tckp = tnar2+VAR_RECAL_TIME; 
        elseif (VAR_BED_BG*ccf<=5)
            % Non 2
            use_bgl_checks = 1;
            VAR_RECAL_TIME = 1;
            tckp = tnar2+VAR_RECAL_TIME;
        elseif 0<VAR_RECAL_BOLUS | 0<VAR_RECAL_CHO 
            use_bgl_checks = 1; 
            VAR_RECAL_TIME = min(VAR_RECAL_TIME,tee);     % Code hack to ensure VAR_RECAL_TIME is within session
            tckp = tnar2+VAR_RECAL_TIME;  
        elseif (~isnan(VAR_pLSD) & VAR_pLSD>C_pLSD_THRESHOLD)
            % Partially Compliant (case pLSD is available)
            if (VAR_INSULIN_STACK_FLAG == 1 | VAR_PREDICT_BG<3)
                if SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE == 1
                    use_bgl_checks = 1;
                    VAR_RECAL_TIME = VAR_UTOB;
                    tckp = tnar2+VAR_RECAL_TIME;   
                else
                    use_bgl_checks = 0;
                end
            else
                if SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE == 1
                    use_bgl_checks = 1;
                    VAR_RECAL_TIME = 6;
                    tckp = tnar2+VAR_RECAL_TIME;  
                else
                    use_bgl_checks = 0;
                end        
            end
        elseif ((isnan(VAR_pLSD) & (VAR_BED_BG>C_LSD_BG_THRESHOLD & VAR_ALG_PROJECTED_BG>C_LSD_BG_THRESHOLD)))
            
            % Partially Compliant (case pLSD is not available)
            if (VAR_INSULIN_STACK_FLAG == 1 | VAR_PREDICT_BG<3)
                if SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE == 1
                    use_bgl_checks = 1;
                    VAR_RECAL_TIME = VAR_UTOB;
                    tckp = tnar2+VAR_RECAL_TIME;  
                else
                    use_bgl_checks = 0;
                end
            else
                if SET_SIMUL_RECAL_IN_PARTIAL_COMPLIANCE == 1
                    use_bgl_checks = 1;
                    VAR_RECAL_TIME = 6;
                    tckp = tnar2+VAR_RECAL_TIME; 
                else
                    use_bgl_checks = 0;
                end
            end
        else
            % Fully Compliant
            if SET_SIMUL_RECAL_IN_FULL_COMPLIANCE == 1
                use_bgl_checks = 1;
                VAR_RECAL_TIME = VAR_UTOB; 
                tckp = tnar2+VAR_RECAL_TIME                 
            else
                use_bgl_checks = 0;
            end
        end
        %-----------------------------------------------------------------
    end  % if recal_version == 2 
    
    
    
    
    if recal_version == 1  % Use original recal method
        
        if (VAR_TIME_SINCE_DINNER<-3 & VAR_TIME_SINCE_BOLUS_BED<-3)
            VAR_TOTAL_ACTIVE_CARBS = 0;
        elseif (VAR_TIME_SINCE_DINNER>=-3 & VAR_TIME_SINCE_BOLUS_BED<-3)
            VAR_TOTAL_ACTIVE_CARBS = VAR_DINNER_CHO;
        elseif (VAR_TIME_SINCE_DINNER<-3 & VAR_TIME_SINCE_BOLUS_BED>-3)
            VAR_TOTAL_ACTIVE_CARBS = VAR_BED_CHO;
        else
            VAR_TOTAL_ACTIVE_CARBS = VAR_DINNER_CHO+VAR_BED_CHO;
        end
        
        
        % Non-compliance 1 (low initial BGL)
        if (G02<=5.0/ccf | (tnar2-tnar1)<1 | (tnar2-tnar1)>3)
            use_bgl_checks = 1;
            tckp = tnar2+tckmin; 
        end
        % Non-compliance 2 (use of insulin)
        if -0.5<=dBGdt & 3.0<=VAR_TOTAL_ACTIVE_BOLUS 
            use_bgl_checks = 1;
            tckp = tnar2+3.5; 
        end
        % Partial compliance (use of carbs)
        if dBGdt<=0.5 & 1.0<=VAR_TOTAL_ACTIVE_CARBS 
            use_bgl_checks = 1;
            tckp = tnar2+tckmin; 
        end
        %**********************************
    end % if recal_version == 1 
end % if managed_recal == 1 & carb_count == 2 & bgl_data_source<=2
%------------------------------------------------------------------------------------




if managed_recal == 1 & recal_version == 1 & carb_count == 1 & bgl_data_source<=2
    %*********************************    
    % Open file 
    fid3 = fopen(['pat_' num2str(pn(p)) '_calibration.txt']);  
    % Skip one line 
    str = fgetl(fid3);    
    % Get next string 
    str = fgetl(fid3);  
    % Read the data into the vector of initial conditions 
    vinit = str2num(str); 
    % close file 
    fclose(fid3); 
    
    % Non-compliance 1 (low initial BGL) 
    if G02<=5.0/ccf | (tnar2-tnar1)<1 | (tnar2-tnar1)>3
        use_bgl_checks = 1; 
        tckp = tnar2+tckmin; 
    end 
    % Non-compliance 2 (use of insulin) 
    if -0.5<=dBGdt & 3.0<=vinit(1) 
        use_bgl_checks = 1; 
        tckp = tnar2+3.5; 
    end
    % Partial compliance (use of carbs)
    if dBGdt<=0.5 & 1.0<=vinit(2) 
        use_bgl_checks = 1;
        tckp = tnar2+tckmin; 
    end
    %**********************************
end  % if managed_recal == 1 & recal_version == 1 & carb_count == 1 & bgl_data_source<=2


% In case of running the HypoMon data
if bgl_data_source==3 & ~isnan(VAR_RECAL_TIME) 
use_bgl_checks = 1;
tckp = tnar2+VAR_RECAL_TIME;                 
end


% Height of matrix A1
NA1 = length(A1(:,1)); 


% Scan threshold
%****************************************************
%******************************************************
for m=1:Nths
% Assume two attempts of processing in case of bringing re-calibration back
for natt = 1:2
 

% Process recalibration data
%********************************************************
% Define the element number of the BGL check
Ntck = NA1+1;  

% Define the number of intervals within the no-alarm period duration 
Ntnack = 0; 

if use_bgl_checks == 1 
    % Update check time after each cycle of threshold m
    if natt==1 % at first processing attempt only
        tck = tckp;  
    end      
    
    % The element number of BGL check time is after or at the BGL check entry time
    [a Ntck] = min(abs(A1(:,1)-tck));  
    
    if A1(Ntck,1)<tck
        Ntck=Ntck+1;     
    end   
    
    % Update the BgL cehck time
    if Ntck > length(A1(:,1))
        Ntck = length(A1(:,1))-1;           % check incase tck is after end of night
    else
        tck = A1(Ntck,1);   
    end
    
    VAR_RECAL_TIME = tck;
    
    if bgl_data_source==3  % Finger pricks only are used for reference
     % Find BGL value corresponding to the BGL check 
    [a k] = min(abs(tg-tck)); 
    % BGL check value rounded to the first decimal place  
    VAR_RECAL_BG = round(G(k)*10)/10;   
    else
    % Find BGL value corresponding to the BGL check 
    [a k] = min(abs(tgs-tck)); 
    % BGL check value rounded to the first decimal place  
    VAR_RECAL_BG = round(Gsp(k)*10)/10;    
    end   
    
    
    % Convert to whole-blood units
    if cal_BGLs_to_WB == 1    
        VAR_RECAL_BG = VAR_RECAL_BG/ccf;  
    end
    


%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Calculation of Parameters Required for Recalibration
%--------------------------------------------------------------------------------------------------------------------------------------------------------------


% Calculate projected BGL at recalibration
if act_on_default_inputs==1 & (VAR_BED_BG==Gdefault/ccf | VAR_RECAL_BG==Gdefault/ccf)
     if VAR_RECAL_BG~=Gdefault/ccf
        VAR_ALG_RE_PROJ_BG = C_PROJ_ADJ_PARAM*VAR_RECAL_BG;
     elseif VAR_RECAL_BG==Gdefault/ccf
        VAR_ALG_RE_PROJ_BG = C_PROJ_ADJ_PARAM*Gopt;     
     end    
elseif VAR_RECAL_TIME < 1.5
    VAR_RECAL_BG_GRADIENT = (VAR_RECAL_BG-VAR_BED_BG)/(VAR_RECAL_TIME-tnar2);                             % VAR_RECAL_BG_GRADIENT Calculation
    VAR_ALG_RE_PROJ_BG = C_PROJ_ADJ_PARAM*(VAR_BED_BG + VAR_RECAL_BG_GRADIENT*1.5);                             % VAR_ALG_RE_PROJ_BG (Re-projection through the Recalibration BG)       
else 
    VAR_ALG_RE_PROJ_BG = C_PROJ_ADJ_PARAM*VAR_RECAL_BG;    
end

    VAR_ALG_RE_PROJ_BG_FLOOR = max(VAR_ALG_RE_PROJ_BG,1.9);                                         % Floor VAR_ALG_RE_PROJ_BG_FLOOR to prevent divide by 0 error in VAR_SCALE  

    VAR_EST_BG_POST_RECAL = VAR_RECAL_BG - VAR_ISF*(VAR_TOTAL_ACTIVE_BOB_RECAL+VAR_RECAL_BOLUS)+(VAR_RECAL_CHO/VAR_CF)*VAR_ISF;     % VAR_EST_BG_POST_RECAL Calculation
%--------------------------------------------------------------------------------------------------------------------------------------------------------------
  


%*******************************************************
if active_BGLpj == 1 & use_bgl_checks==1 
% Define the state of active projection alarm
active_proj_alarm = 0;     
if act_on_default_inputs==1 & (VAR_BED_BG==Gdefault/ccf | VAR_RECAL_BG==Gdefault/ccf)    
% Active projection alarm is not activated   
elseif 0<VAR_RECAL_CHO 
% Active projection alarm is not activated   
else    
   % Derivative of active BGL projection
   dGadt = (VAR_RECAL_BG-G02)/(tck-tnar2);  
         % Length of projection 
         if dGadt==0
         tprx = 100;     
         else    
         tprx = -(VAR_RECAL_BG-Gthnap)/dGadt;  
         end
    if  dGadt<thtga & tprx < Tpj  % Active projection between precal and cal 
         % Trigger active projection alarm 
        active_proj_alarm = 1;  
           if plot_each_patient == 1 
           figure(10 + p)
           subplot(211)
           hold on     
           plot([tnar2 tck+tprx],[G02 Gthnap],'c')   
           end
    end   
end %if act_on_default_inputs==1 & (VAR_BED_BG==Gdefault/ccf | VAR_RECAL_BG==Gdefault/ccf)     
end % if active_BGLpj == 1 & use_bgl_checks==1 
%*************************************************************


    % Duration of no-alarm period following the BGL check
    if act_on_default_inputs==1 & (VAR_BED_BG==Gdefault/ccf | VAR_RECAL_BG==Gdefault/ccf) 
        
         if VAR_RECAL_BG~=Gdefault/ccf
             
              % Use only single-BGL formulas for calculation of no-alarm period
              if (VAR_RECAL_BOLUS>0 & VAR_EST_BG_POST_RECAL<=5) & carb_bolus_recal==1
                   tnack = 3; 
              else
                   tnack = tnab5*(VAR_RECAL_BG-G2)/(G1-G2) + tnab20*(VAR_RECAL_BG-G1)/(G2-G1); 
              end    
              
          elseif VAR_RECAL_BG==Gdefault/ccf
              
              if 0<VAR_RECAL_BOLUS | 0<VAR_RECAL_CHO  
                  % Calculate no-alarm period, using optimum BGL Gopt
                  tnack = tnab5*(Gopt-G2)/(G1-G2) + tnab20*(Gopt-G1)/(G2-G1);     
              else
                  % Apply original no-alarm period (determined from evening and bedtime BGLs)    
                  tnack = tnabe-tck;       
              end
              
          end % if VAR_RECAL_BG~=Gdefault/ccf
          
    elseif  (VAR_RECAL_BG-G02)/(tck-tnar2) < thtga   
        tnack = (VAR_RECAL_BG-Gthnap)/(G02-VAR_RECAL_BG)*(tck-tnar2);            
    elseif (VAR_RECAL_BOLUS>0 & VAR_EST_BG_POST_RECAL<=5) & carb_bolus_recal==1
        tnack = 3;
    else
        tnack = tnab5*(VAR_RECAL_BG-G2)/(G1-G2) + tnab20*(VAR_RECAL_BG-G1)/(G2-G1); 
    end    
    
    
    % Exclude negative values 
    tnack = max(tnack,0); 
    % Cap no-alarm period following the BGL check
    % Cap value must be less if correction (not treatment) has been done at BGL check 
    tnack = min(tnack,3.0); 
    % The number of intervals within the no-alarm period duration 
    Ntnack = floor(tnack/(A1(2,1)-A1(1,1))); 
    
  
    
    if plot_each_patient == 1 & output_for_spss == 0
        figure(10 + p)
        subplot(211)
        hold on 
        plot(tck,VAR_RECAL_BG,'ro')
        plot(tck+tnack,Gth,'mv')
    end 
end  % if use_bgl_checks == 1 
%*****************************************************************************


% there is no need to repeat the first run natt=1 at different thresholds m   
if m==1 | (use_bgl_checks == 1 & 0<dtca & natt==2)       


% Process variables
%******************************************************
%**********************************************************
% Open cycle of variable number 
for nv = 1:Nv   
    
% Read the corresponding data into matrix A  
if nv==1
A = A1;     
elseif nv==2
A = A2;     
elseif nv==3
A = A3;     
elseif nv==4
A = A4;     
elseif nv==5    
A = A5; 
end   
    

if lm_start_delay == 1 & late_start == 1
% cut-off data at t<1hr
[a n] = min(abs(A(:,1)-1.0)); 
k = length(A(:,1)); 
A = A(n:k,:); 
end


%*********************************************
% Time array 
tnv = A(:,1); 
% Correlation parameter 
cnvu = psf(pid(nv))*A(:,2); 
clear A
% Length of time array  
Ntnv = length(tnv); 
% Time interval 
dtnv = tnv(2) - tnv(1); 
%**********************************************


% Add zero elements to variable arrays to extrapolate trend difference beyond the end of data stream
if MODE_SET == 0
if bgl_data_source == 3
% The number of zero values added at the end of the night    
N = round(Tf(nv)/dtnv);   
for k=1:N
cnvu(Ntnv+k) = 0; 
tnv(Ntnv+k) = tnv(Ntnv)+dtnv*k;     
end
Ntnv = Ntnv+N; 
end
end


if MODE_SET == 1
%*********************************************************
dataInHRO = cnvu;
dataInHR = hrN;
dataInHRA = hrA;
%*********************************************************
end


% Discount HR samples around BGL check
%****************************************
if use_bgl_checks==1 & pid(nv)==12 
% Sample nearest to BGL entry -6min 
n = Ntck-round(6/60/dtnv);  
% Exclude negative or zero values of n 
n = max(1,n); 
% Sample nearest to BGL entry +2min 
k = Ntck+round(2/60/dtnv);  
cnvu(n:k)=0; 
end 
%*************************************


% Determine last sample number belonging to no-alarm period 
if Nths==1 & Np==1 
    [a n] = min(abs(tnv-tnabe)); 
    if 0<=tnabe-tnv(n)
        Nnap = n; 
    else
        Nnap = n-1;    
    end
end    


% Re-define 1st sample to be a median value of several valid samples 
% in HR data stream 
if pid(nv)==12 & median_start == 1 
% The number of samples used for calculation of median
nsa = 6; 
% define vector of samples for calculaltion of median
cnvur = []; 
% Define the number of samples read for calculation of median 
k = 0; 
% Define sample number beeing looked at
n = 1; 
while k<nsa & (n-1)*dtnv<Tf(nv)
if cnvu(n)~=0
k = k+1; 
% Vector of read values
cnvur(k) = cnvu(n); 
end  
n=n+1; 
end

if length(cnvur)==0
cnvur = -80; 
end    

%Re-define first sample
cnvu(1) = round(median(cnvur));

clear cnvur 
end  % if pid(nv)==12 & median_start == 1


% Use random numbers instead of variables
%cnvu = 12*randn(Ntnv,1); 

% Replace feature with a random signal
if 0<arnd & nv==1
cnvu = arnd*randn(Ntnv,1); 
end

% In case of using ramp as a feature, define ramp function
if pid(nv) == 15
if ramp_ref == 1  
cnvu = tnv(1)-tnv;
else
cnvu = t24-tnv; 
end
% Didengage alarm clock in some of the patients randomly 
if rand < ppdac 
cnvu = cnvu-cnvu(1)-10; 
end
end


if adjust_to_rt==1
% round the "and" windows to integer number of time intervals
tand_b = dtnv*round(tand_b/dtnv); 
tand_a = dtnv*round(tand_a/dtnv); 
end


% Open the files for spss processing and write the time and BGL arrays.
%*****************************************************************************
if output_for_spss == 1 
% Define file name for variable 1     
File = ['pat_' num2str(pn(p)) '_spss_' pnv '.txt'];   
% Open file 
fid1 = fopen(File,'wt');
fprintf(fid1,'*The first line is the lapsed time, hr.\n'); 
fprintf(fid1,'*The second line is the BGL, mmol/L.\n'); 
fprintf(fid1,'*All other lines are the trend difference functions produced by means of various pre-processing delays.\n'); 
fprintf(fid1,'The first two elements in these lines are replaced by the filtering time Tf\n'); 
fprintf(fid1,'and the lag time Tlag respectively, measured in hours.\n\n'); 
% Write the time array into the file 
for k = 1:Ntss
fprintf(fid1,'%12.6f ',tss(k));
end
fprintf(fid1,'\n'); 
%fprintf(fid1,'\n'); 
% Write the BGL array into the file 
for k = 1:Ntss
fprintf(fid1,'%12.6f ',Gs(k));
end
fprintf(fid1,'\n'); 

end 
%****************************************************************************


% The number of cycles of scanning Tf and Tlag
if output_for_spss == 1 
Nttc = length(Tfs); 
Ntlags = length(Tlags); 
else
Nttc = 1; 
Ntlags = 1; 
end

%Scan over the lag time 
for ntlags = 1:Ntlags
% Scan over the filtering time 
for nttc = 1:Nttc
%**********************************************************


if output_for_spss == 1 
Tf(1) = Tfs(nttc); 
Tlag(1) = Tlags(ntlags); 
end


% Use linear fit within initial Tf to re-define the first value of unfiltered data
if fit_within_Tf == 1 & pid(nv)==12
%****************************************************************
% The number of increments corresponding to the time lag 
if Tlag(nv)==0
Nlag1 = 1; 
else
Nlag1 = round(Tlag(nv)/dtnv); 
end

% Clear parameters after the previous patient 
clear cnvpf tnvpf tnvpfp PC Pff

% Produce vectors of time and variable nv value with drop-outs omitted
n=0; 
for k=1:Nlag1 
if cnvu(k)~=0
n=n+1; 
% vector of the variable formed for polynomial fit 
cnvpf(n)=cnvu(k); 
% time vector used for polinomial fit
tnvpf(n)=tnv(k); 
end    
end

% Find coefficients of best polynomial fit 
PC = polyfit(tnvpf,cnvpf,Pffo); 
% Define polynomial 
Pff = PC(Pffo+1); 
for k = 1:Pffo 
Pff = Pff + PC(Pffo+1-k)*tnv(1:Nlag1).^k; 
end    

if output_for_spss == 0 & nv==1 & plot_each_patient == 1 
figure(10+p)
subplot(211)
hold on 
plot(tnv(1:Nlag1),-Pff/10,'g')
end

% Set initial value to match the best fit
cnvu(1)=Pff(1); 

clear cnvpf tnvpf
%*******************************************************************
end



% enter unfiltered data each cycle of nttc
VERIF_IHRO = cnvu;
cnv = cnvu;


if 1==0
% Apply low-pass filter to paramter nv 
% *************************************************************
% Integration time of each stage 
Tstage = Tf(nv)/Nst(nv); 
if Tstage > 0
% Apply 3-stage RC filter 
for nn=1:Nst(nv)
% Remember the old value
old = cnv(1); 
for k = 1:Ntnv-1
% find derivative of filtered function  
dyfdt = (old-cnv(k))/Tstage; 
% Memorize next element before it has been modified
old = cnv(k+1); 
% filtered value at next point  
cnv(k+1) = cnv(k) + dyfdt*(tnv(k+1)-tnv(k));  
% Smooth the gaps in data drop-outs
if cnvu(k+1)==0 & nn==1 & bridge_gaps == 1
old = cnv(k+1);     
end
end
end
end % of if Tstage > 0
%*****************************************************************
end


if 1==1
% Apply low-pass filter  
%******************************************************************
if 0<Tf(nv)
b = Tf(nv)/3/dtnv; 
cnv(1:3) = cnvu(1); 
for k = 4:Ntnv
cnv(k) = 1/b^3*cnvu(k-3) + 3*(b-1)/b*cnv(k-1) - 3*(b-1)^2/b^2*cnv(k-2) + (b-1)^3/b^3*cnv(k-3);   
% Smooth the gaps in data drop-outs
if cnvu(k-3)==0 & bridge_gaps==1
cnv(k) = (3-2/b)*cnv(k-1) + 1/b^2*(1-b)*(3*b-1)*cnv(k-2) + 1/b^2*(1-b)^2*cnv(k-3); 
end
end
end % if 0<Tf(nv)
%*******************************************************************
end

if MODE_SET == 1
VERIF_HRT = cnv;
end


% Subtract intermediate filtered function 
if hr_settling_filter == 1 & pid(nv)==12
%*******************************************************************
% The number of increments corresponding to the active time of high-pass filter 
Nahp = round(Tahp/dtnv); 

% Define vector of intermidiate filtered function
iff = cnvu*0; 

% Apply low-pass filter  
%******************************************************************
b = Thp/3/dtnv; 
iff(1:3) = cnvu(1); 
for k = 4:Ntnv
iff(k) = 1/b^3*cnvu(k-3) + 3*(b-1)/b*iff(k-1) - 3*(b-1)^2/b^2*iff(k-2) + (b-1)^3/b^3*iff(k-3);   
% Smooth the gaps in data drop-outs
if cnvu(k-3)==0 & bridge_gaps==1 | Nahp<k-3
iff(k) = (3-2/b)*iff(k-1) + 1/b^2*(1-b)*(3*b-1)*iff(k-2) + 1/b^2*(1-b)^2*iff(k-3); 
end
end
%******************************************************************

if MODE_SET == 1
VERIF_HRST = iff;
end



% Taper function 
if Aex~=0
tpf = tnv*0; 
for k=1:Ntnv
tpf(k) = (1+Aex/(1+exp(edctf*((k-1)*dtnv-Tahp)/Thp))); 
end
else
tpf = tnv*0+1; 
end

if Np==1 & output_for_spss == 0 
figure(20+p+nv)
hold on 
plot(tnv,cnv,'r')
plot(tnv,iff,'b')
plot(tnv,tpf,'m')
end

% Subtract intermediate filtering function 
cnv = cnv-iff;

if MODE_SET == 1
VERIF_HRSD = cnv;
end

% Apply taper function 
if Aex~=0
cnv = cnv.*tpf; 
end

if MODE_SET == 1
VERIF_AHRSD = cnv;
end

%******************************************************************
end % if hr_settling_filter == 1



if plot_each_patient == 1  & output_for_spss == 0
if Np==1  
figure(20+p+nv)
hold on 
plot(tnv,cnvu,'g')
plot(tnv,cnv,'r')
grid on 
xlabel('Time, hr')
ylabel(['Variable  ' num2str(nv)])
title(['Patient ' num2str(pn(p))])
legend('Raw data','Trend',4)
end
if nv==1 & plot_hr==1
figure(10+p)
subplot(211)
plot(tnv,-cnvu/10,'k')
end
end


if trd(nv)==1
% Calculate real-time parameters cnv(t)-cnv(t-to)
%************************************************
% The number of increments corresponding to the time lag 
if Tlag(nv)==0
Nlag1 = 1; 
else
Nlag1 = round(Tlag(nv)/dtnv); 
end


cnv(Nlag1+1:Ntnv) = cnv(Nlag1+1:Ntnv)-cnv(1:Ntnv-Nlag1); 
% continue the arrays into the element numbers below Nlag
cnv(1:Nlag1) = cnv(Nlag1+1);  
%*************************************************
end

if MODE_SET == 1
VERIF_HRTD = cnv;
end

% Produce data for analysis of HR decay rates
%disp(max(cnv(1:59))); 


% Find permitted alarm intervals from CGM data
if pid(nv)==14
%*************************************************
%***************************************************

% Filtering time of CGM data used for no-alarm periods, hr 
Tcgmna = 0.5; 

% Apply low-pass filter to cgm data used for no-alarm periods  
%******************************************************************
b = Tcgmna/3/dtnv; 
cnvna(1:3) = cnvu(1); 
for k = 4:Ntnv
cnvna(k) = 1/b^3*cnvu(k-3) + 3*(b-1)/b*cnvna(k-1) - 3*(b-1)^2/b^2*cnvna(k-2) + (b-1)^3/b^3*cnvna(k-3);   
% Smooth the gaps in data drop-outs
if cnvu(k-3)==0 & bridge_gaps==1
cnvna(k) = (3-2/b)*cnvna(k-1) + 1/b^2*(1-b)*(3*b-1)*cnvna(k-2) + 1/b^2*(1-b)^2*cnvna(k-3); 
end
end
%*******************************************************************

    % Define matrix of permitted alarm intervals 
%mpai(1,1:2) = 100; 
mpai = [100 100]; 
    % Define the number of permitted alarm intervals 
npai = 0;

for k = 2:Ntnv    
%***************************
% Find the beginning of the interval 
if (cnvna(k-1)>thpai & cnvna(k)<=thpai) | (k==2 & cnvna(1)<=thpai) 
% Update the  number of permitted alarm intervals 
npai = npai+1; 
% Define the beginning of a new interval 
mpai(npai,1) = tnv(k-1); 
end    
    
% Find the end of the interval 
if (cnvna(k-1)<=thpai & cnvna(k)>thpai) | (k==Ntnv & cnvna(Ntnv)<=thpai)
% Define the end of the interval 
mpai(npai,2) = tnv(k); 
end
%***************************
end   % for k = 2:Ntnv   

if plot_each_patient == 1 
figure(10+p)
% Plot CGM data 
subplot(211)
plot(tnv,cnvna,'k')
plot([-3 10],[1 1]*thpai,'k')
end

clear cnvna
%******************************************************
%****************************************************    
end  % if pid(nv)==14


% Iclude delay 
tnv = tnv + Td(nv); 

% Write trend difference into a file for processing in SPSS 
if output_for_spss == 1 
%**************************************************************
% Save data for variable 1
fprintf(fid1,'%12.6f ',Tf(nv));
fprintf(fid1,'%12.6f ',Tlag(nv)); 
for k = 3:Ntnv
fprintf(fid1,'%12.6f ',cnv(k,1));
end
fprintf(fid1,'\n'); 
%****************************************************************
end

 
end  % for nttc = 1:Nttc (Cycle of filtering time)
end % for ntlags = 1:Ntlag (Cycle of lag time) 
 


%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Default or Missing Data Detection
%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Assumption is that user leave  enters VAR_DINNER_BG = 8 mmol/L (plasma equivelent) and this is converted to 7.1 mmol/L by conversion to whole blood
% isnan is a representative check to determine if data was entered by the user
if ((VAR_DINNER_BG==(8/ccf) & (VAR_DINNER_CHO==0 | VAR_DINNER_BOLUS==0)) | isnan(VAR_EXERCISE_TIME) | isnan(VAR_COUNT_HYPO) | isnan(VAR_EVENING_BG) | isnan(VAR_EXERCISE_LEVEL))
    VAR_DEFAULT_MISSING_DETECTION = 1;
else
    VAR_DEFAULT_MISSING_DETECTION = 0;
end

% Special Manipulation for simulation purpose only
if SET_FORCED_MISSING == 1
    VAR_DEFAULT_MISSING_DETECTION = 1;
end
%--------------------------------------------------------------------------------------------------------------------------------------------------------------


%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Scaling Algorithm Selection(after calibration)
% Switch Statement Based on Missing / Default Data
%--------------------------------------------------------------------------------------------------------------------------------------------------------------
switch VAR_DEFAULT_MISSING_DETECTION
    
case 0                                                                                         % ALG 337 (DATA IS AVAILABLE)
    
    if (VAR_BED_BG > 10 & VAR_ALG_PROJ_BG_LONG > 10 & ((VAR_MEAN_PREBED_BG-VAR_ACTUAL_BOB_BG_POWER)>7))     % Logical Statement for Determining Hyper Risk Sessions
        VAR_HYPER_RISK = 1;
    else
        VAR_HYPER_RISK = 0;
    end
    
    if VAR_ALG_PROJ_BG_LONG > 7                                                                % ALG337 High Branch
        if VAR_HYPER_RISK == 1
            VAR_CAL_SCALING_STATUS = 11;                                                       % Sets Status Variable to Track Scaling
            VAR_SCALE = C_HYPO_HIGH_PROJ_MIN_SCALE;
        else
            VAR_CAL_SCALING_STATUS = 12;                                                       % Sets Status Variable to Track Scaling
            VAR_SCALE = F_Fermi(C_HYPO_HIGH_PROJ_MAX_SCALE, C_HYPO_HIGH_PROJ_MIN_SCALE, C_HYPO_HIGH_PROJ_LOW_CUT, C_HYPO_HIGH_PROJ_DUR1,VAR_LIN_COMB_HIGH);
        end
    else                                                                                       % ALG337 Low Branch
        VAR_CAL_SCALING_STATUS = 13;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = F_Fermi(C_HYPO_LOW_PROJ_MAX_SCALE, C_HYPO_LOW_PROJ_MIN_SCALE, C_HYPO_LOW_PROJ_LOW_CUT, C_HYPO_LOW_PROJ_DUR1,VAR_LIN_COMB_LOW);
    end
    
    
case 1                                                                                         % ALG 339 (Data is Missing / Default)
    
    if act_on_default_inputs==1 & (VAR_BED_BG==Gdefault/ccf)
        VAR_CAL_SCALING_STATUS = 31;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_PROJ_BG_LONG_FLOOR - VAR_Ghpn))^alfa(nv);         % Scaling Function
    elseif act_on_default_inputs==1 & (VAR_EVENING_BG==Gdefault/ccf)
        VAR_CAL_SCALING_STATUS = 32;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_PROJ_BG_LONG_FLOOR - VAR_Ghpn))^alfa(nv);         % Scaling Function
    elseif act_on_bedtime_cb==1 & projection_compromised==1 
        VAR_CAL_SCALING_STATUS = 33;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_PROJ_BG_LONG_FLOOR - VAR_Ghpn))^alfa(nv);         % Scaling Function
    elseif VAR_BED_BG <= 7 & strata_scaling == 1                                               % ALG 339 Low Branch
        VAR_CAL_SCALING_STATUS = 21;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = ((5.6-VAR_Ghpn)/(VAR_ALG_PROJ_BG_SHORT_FLOOR - VAR_Ghpn))^alfa(nv);        % Scaling Function
    else                                                                                       % ALG 339 High Branch
        VAR_CAL_SCALING_STATUS = 22;                                                           % Sets Status Variable to Track Scaling
        VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_PROJ_BG_LONG_FLOOR - VAR_Ghpn))^alfa(nv);         % Scaling Function
    end
    
    % Scaling Clip and Floor
    if alfa(nv) > 0
        VAR_SCALE = min(VAR_SCALE,sccap);    % Clip to max of 2.5
        VAR_SCALE = max(VAR_SCALE,scfloor);                                                            % Clip to min of 0.6
    else
        VAR_SCALE = 1;
    end
end
%--------------------------------------------------------------------------------------------------------------------------------------------------------------



%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Perform Scaling (defined by calibration and pre-calibration)
%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% Define end sample of applying current scaling coefficient
if use_bgl_checks == 1 
k = Ntck-1; 
else    
k = Ntnv;     
end

if taper_scaling == 1 
% Taper function 
tpf2 = 1./(1+exp((tnv-tcot)/tdtf)); 
else
tpf2 = tnv*0+1; 
end

% Apply scaling 
cnv(1:k) = cnv(1:k).*VAR_SCALE.^tpf2(1:k); 


% Create Real Time Verification Data
if MODE_SET == 1
    VERIF_VAR_SCALE = VAR_SCALE;
end


%--------------------------------------------------------------------------------------------------------------------------------------------------------------
% % Rescale parameters 
% %*********************************************
% if 0 < alfa(nv)
%      
% if proj_scaling==1 & BGLpj==1
% % Scaling BGL
% Gsc = uafsp*(G02+dBGdt*tpjs); 
% 
% % No-scaling BGL, mmol/L (Scaling coefficient turns to 1 when Gsc=Gns)
% Gns = 6.0;    
% 
% if strata_scaling == 1
%    if G02<=7
%      Gsc = uafsp*(G02+dBGdt*0.5); 
%      Gns = 5.6;    
%    end  
% end
% 
% % Limit floor value of projected BGL
% Gsc = max(Gsc,Gpjf); 
% else
% Gsc = G02; 
% end
% 
% % Cap BGL value entering the scaling function 
% Gsc = min(Gsc,BGLpjcap);  
% 
% % Define end sample of applying current scaling coefficient
% if use_bgl_checks == 1 
% k = Ntck-1; 
% else    
% k = Ntnv;     
% end
% 
% if taper_scaling == 1 
% % Taper function 
% tpf2 = 1./(1+exp((tnv-tcot)/tdtf)); 
% else
% tpf2 = tnv*0+1; 
% end
% 
% % Scaling coefficient 
% VAR_SCALE = ((Gns-VAR_Ghpn)/(Gsc-VAR_Ghpn))^alfa(nv);
% 
% % Apply floor and cap
% VAR_SCALE = min(VAR_SCALE,sccap); 
% VAR_SCALE = max(VAR_SCALE,scfloor); 
% 
% % Apply scaling 
% cnv(1:k) = cnv(1:k).*VAR_SCALE.^tpf2(1:k);   
% end  %if 0 < alfa(nv)
% %************************************************


if 0 < alfa(nv) & use_bgl_checks == 1
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------
    % Determine Route for Recalibration scaling
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    if act_on_default_inputs==1 & VAR_RECAL_BG==Gdefault/ccf 
        
        if 0<VAR_RECAL_BOLUS | 0<VAR_RECAL_CHO  
            VAR_RECAL_SCALING_STATUS = 141; 
            VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_RE_PROJ_BG_FLOOR-VAR_Ghpn))^alfa(nv);    
            VAR_SCALE = min(VAR_SCALE,2.58);                                                            % Clip to max of 2.58
            VAR_SCALE = max(VAR_SCALE,0.32);          
        else
            VAR_RECAL_SCALING_STATUS = NaN; 
            % VAR_SCALE remains unchanged             
        end
        
    elseif (VAR_RECAL_BOLUS==0 & VAR_RECAL_CHO==0) | carb_bolus_recal==0                           % ALG 326, According of ALGCN1.2
        
        if  (VAR_BED_BG==Gdefault/ccf)
            VAR_RECAL_SCALING_STATUS = 142;                                                            % Sets Status Variable to Track Scaling
            VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_RE_PROJ_BG_FLOOR-VAR_Ghpn))^alfa(nv);    
            % Notes VAR_ALG_RE_PROJ_BG_FLOOR is calculated differently earlier in this condition
            VAR_SCALE = min(VAR_SCALE,2.58);                                                           % Clip to max of 2.58
            VAR_SCALE = max(VAR_SCALE,0.32);                                                           % Clip to min of 0.32   
        else
            VAR_RECAL_SCALING_STATUS = 132;                                                            % Sets Status Variable to Track Scaling
            VAR_SCALE = ((6.0-VAR_Ghpn)/(VAR_ALG_RE_PROJ_BG_FLOOR-VAR_Ghpn))^alfa(nv);    
            VAR_SCALE = min(VAR_SCALE,2.58);                                                           % Clip to max of 2.58
            VAR_SCALE = max(VAR_SCALE,0.32);                                                           % Clip to min of 0.32       
        end
    elseif  VAR_RECAL_BOLUS>0 & carb_bolus_recal==1                                                 % ALG 338 (Bolus-only or Bolus + Carb)
        if VAR_EST_BG_POST_RECAL>=10                                                                % Case Low Hypo Risk
            VAR_RECAL_SCALING_STATUS = 111;                                                          % Sets Status Variable to Track Scaling
            VAR_SCALE = 0.4;                                                                        % Scaling
        elseif VAR_EST_BG_POST_RECAL<=5                                                             % Case High Hypo Risk
            VAR_RECAL_SCALING_STATUS = 112;                                                          % Sets Status Variable to Track Scaling
            VAR_SCALE = 1.0;                                                                        % Scaling
        else                                                                                        % Case Moderate Hypo Risk
            VAR_RECAL_SCALING_STATUS = 113;                                                          % Sets Status Variable to Track Scaling
            VAR_SCALE = 0.6;                                                                        % Scaling
        end
        
    else                                                                                            % ALG 338 (CARB ONLY BRANCH)
        
        if VAR_EST_BG_POST_RECAL > 7                                                                % Case Low Hypo Risk
            VAR_RECAL_SCALING_STATUS = 121;                                                          % Sets Status Variable to Track Scaling
            VAR_SCALE = 0.4;
        else                                                                                        % Case Moderate Hypo Risk
            VAR_RECAL_SCALING_STATUS = 122;                                                          % Sets Status Variable to Track Scaling
            VAR_SCALE = 0.6;
        end
    end   % if act_on_default_inputs==1 & VAR_RECAL_BG==Gdefault/ccf 
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
    
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------
    % Perform Scaling (After recalibration)
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------    
    % Apply scaling
    cnv(Ntck:Ntnv) = cnv(Ntck:Ntnv).*VAR_SCALE.^tpf2(Ntck:Ntnv);   
else
    VAR_RECAL_SCALING_STATUS = NaN;
end  % if 0 < alfa(nv) & use_bgl_checks == 1
%--------------------------------------------------------------------------------------------------------------------------------------------------------------


% Create Real Time Verification Data
if MODE_SET == 1
    VERIF_HRTF = cnv;                       % Output Trend of HR or HRO Stream
    VERIF_CAL_STATUS = VAR_CAL_SCALING_STATUS;
    VERIF_RECAL_STATUS = VAR_RECAL_SCALING_STATUS;
    VERIF_VAR_RECALSCALE = VAR_SCALE;
end


% % Rescale parameters after BGL check 
% %*********************************************
% if 0 < alfa(nv) & use_bgl_checks == 1 
% 
% if tck-tnar2<tpjs
% Gsc = uafsp*(G02+(VAR_RECAL_BG-G02)/(tck-tnar2)*tpjs); 
% else
% Gsc = uafsp*VAR_RECAL_BG; 
% end
% 
% % Limit floor value of projected BGL
% Gsc = max(Gsc,4.2); 
% 
% % Cap BGL value entering the scaling function 
% Gsc = min(Gsc,10); 
% 
% % Scaling coefficient 
% VAR_SCALE = ((6.0-VAR_Ghpn)/(Gsc-VAR_Ghpn))^alfa(nv);
% 
% % Apply scaling
% cnv(Ntck:Ntnv) = cnv(Ntck:Ntnv).*VAR_SCALE.^tpf2(Ntck:Ntnv);    
% end  %if 0 < alfa(nv)
% %************************************************



if use_bgl_checks == 1 & pid(nv)==17
% Take decision on belt adjustment at recalibration 
%*****************************************************    
% Average updated drop-out rate, %
audr = cnv(Ntck)/psf(17)/2/Ntck*100;   % Division by 2 accounts for down-sampling

if dorth<=audr
% issue belt adjustment notification    
belt_adj = 1;     
else    
belt_adj = 0;     
end

if plot_each_patient == 1 & belt_adj == 1
% Plot beld adjustment notification    
figure(10 + p)
subplot(211)
plot(tck,2.0,'^')
end
%******************************************************
end % if use_bgl_checks == 1 & pid(nv)==17


if Nths == 1 & output_for_spss == 0
if save_trend_differences == 1 %& Np==1
% Define file name for variable nv     
File = ['pat_' num2str(pn(p)) '_trend_diff_V' num2str(nv) '.txt'];   
% Open file 
fid_td = fopen(File,'wt');
fprintf(fid_td,['  Time, hr    Variable V' num2str(nv) '\n']); 

for k = 1:Ntnv
fprintf(fid_td,'%12.9f ',tnv(k));
fprintf(fid_td,'%12.9f',cnv(k));
fprintf(fid_td,'\n'); 
end

status = fclose(fid_td);
end  % if save_trend_differences == 1
end  % if Nths == 1 & output_for_spss == 0


% Trigger active projection alarm
%*******************************************************
if active_BGLpj == 1 & use_bgl_checks==1 & active_proj_alarm==1 & nv==1 
    % Sample number corresponding to the projection response 
    [a Ntprr] = min(abs(tck+tprx+Tpjd-tnv));
    % Produce the projection response via variable 1
    cnv(Ntprr-1) = 100; 
    cnv(Ntprr) = -100;  
end % if active_BGLpj == 1 & use_bgl_checks==1 & nv==1 
%*************************************************************


 if plot_each_patient == 1 
%******************************************************     
figure(10 + p)
subplot(212)
hold on 
plot(tnv,cnv-th(nv),col(nv))
% Plot end of the night
plot(tee*[1 1],[-100 100],'r--')  
grid on 
%*********************************************************
end


% Define matrices of responses at fixed thresholds
if nv==1
kri = [];  
tri = [];    
end


% Produce information about all responses in the form of matrices 
%*************************************************************************
% Find all responses at fixed thresholds
%**********************************
% Define integer parameter for the cycle below 
n = 0; 
for k = 2:Ntnv 
if cnv(k-1)>th(nv) & cnv(k)<=th(nv) 
    n = n+1; 
   % Element numbers corresponding to responses of parameter nv 
   kri(nv,n) = k;  
   % Times of responses of parameter nv
   tri(nv,n) = tnv(k); 
end  
end
%************************************* 


% Memorize one of the variables for scanning the threshold 
if nv==nps %& 1<Nths
cnvs = cnv; 
tnvs = tnv; 
Ntnvs = Ntnv; 
end


if plot_each_patient == 1 & nv==1
%******************************************************     
figure(10 + p)
subplot(212)
grid on 
plot([tgmin-1 tgmax+1],[0 0],'k') 
axis([tgmin-1 tgmax+1 -15 15])
ylabel('Feature - th')
xlabel('Time, hr')
%*********************************************************
end


end %for nv = 1:Nv
%***********************************************************************
%***********************************************************************
% End of processing of variables

end %  if m==1 | (use_bgl_checks == 1 & 0<dtca & natt==2)       


if use_bgl_checks == 1 & 0<dtca & natt==1 
% Recycle trend difference calculated during the very first run (m==1 and natt==1)
    if m==1 
    cnvs1 = cnvs; 
    tnvs1 = tnvs; 
    Ntnvs1 = Ntnvs; 
    else
    cnvs = cnvs1; 
    tnvs = tnvs1; 
    Ntnvs = Ntnvs1; 
    end
end



%*********************************************************************
% Define vectors of responses of scanned variable 
krs = []; 
trs = []; 

% Define current threshold 
thsm = ths(m);  

% Find all responses from scanned variable 
%**********************************
% Define integer parameter for the cycle below 
n = 0; 
for k = 2:Ntnvs
if cnvs(k-1)>thsm & cnvs(k)<=thsm 
    n = n+1; 
   % Element numbers corresponding to alarms of parameter nv 
   krs(n) = k; 
   % Update vector of time of response of scanned variable 
   trs(n) = tnvs(k);   
end  
end
%*************************************


% The number of responses from current variable 
Nr = length(krs); 


% Update the row in response matrix, corresponding to the scanned variable 
%***********************
% Reset matrices to their values at fixed thresholds
kr = kri; 
tr = tri;

% Reset values of the row corresponding to the scanned variable 
kr(nps,:) = 0; 
kr(nps,1:Nr) = krs;   

tr(nps,:) = 0; 
tr(nps,1:Nr) = trs; 
%*********************************



% Discount responses that are within no-alarm period and outside of the available BGL profile  
%*********************************************************************************
% size of matrix kr 
[Hkr Wkr] = size(kr); 

% Define temporary matrices 
trt = []; 
krt = []; 

for h=1:Hkr
% Define column number of the temporary matrixe that are to be produced  
c = 0; 
for w=1:Wkr
%**********************

  % form a boolin expression    
  if incl_nap_resp == 1
  BL = 1; 
  else    
  BL =  tnabe<tr(h,w) & kr(h,w)<Ntck | Ntck+Ntnack<kr(h,w) | anap(h)==0;
  end  
  
      if tr(h,w)<tnaes & tr(h,w)<=tee & BL
      % Increment column number of new matrices 
      c = c+1; 
      % Save values into new matrices 
      trt(h,c)=tr(h,w); 
      krt(h,c)=kr(h,w); 
      
             if plot_each_patient == 1 & Nths==1
             figure(10 + p)
             subplot(211)
             plot(tr(h,w)*[1 1],[0 20],col(h))    
             end  
      end
%***********************
end  % for w=1:Wkr
end  % for h=1:Hkr

% Return to old notation  
tr = trt; 
kr = krt; 
clear trt krt 
%*********************************************************************************




% Add response from the BGL check 
%*********************************************************************************
if use_bgl_checks==1 & max(ttpi(:,1)<=tck & tck<=ttpi(:,2)) 
% size of matrix kr 
[Hkr Wkr] = size(kr); 
if Hkr+Wkr==0
kr = Ntck; 
tr = tck; 
else
for h=1:Hkr
% Temporary vectors 
a = sort([rot90(nonzeros(kr(h,:))) Ntck]);  
b = sort([rot90(nonzeros(tr(h,:))) tck]);  
for n=1:length(a)   
kr(h,n)=a(n);     
tr(h,n)=b(n);    
end
end
clear a b
end % if sum(size(kr))==0
end  % if use_bgl_checks==1 & max(ttpi(:,1)<=tck & tck<=ttpi(:,2)) 
%*********************************************************************************





% Generate additional matrices that classify responses 
%*********************************************************
% Sizes of response matrix 
[Hkr Wkr] = size(kr); 
% Define new matrices
tpr = kr*0; 
fpr = kr*0; 

for h = 1:Hkr 
for w = 1:Wkr        
% Produce matrix of true positive responses 
   if 0<kr(h,w) & max(ttpi(:,1)<=tr(h,w) & tr(h,w)<=ttpi(:,2)) 
   tpr(h,w)=1;  
   else
   tpr(h,w)=0;     
   end      
% Produce matrix of false positive responses 
   if 0<kr(h,w) & tpr(h,w)==0 & (Gthd<Gsmin | tr(h,w)<tedh)
   fpr(h,w)=1; 
   else
   fpr(h,w)=0;     
   end      
end 
end 
%**********************************************************


% Define matrix of alarm permissions
aprm = kr*0;
for h = 1:Hkr 
for w = 1:Wkr    
  if 0<kr(h,w) 
  aprm(h,w)=1;   
  end    
end
end


% Update the alarm permission matrix, using biased "AND" condition  
%**************************************************************
if 1<Nv & 0<length(or1) & 0<length(or2) & and_bias==1
% Define a temproary matrix of permitted alarms 
aprmt = aprm*0;  
    
for ho = 1:Hkr 
for wo = 1:Wkr        
 
       % if ho can be found in vector or1, the following parameter turns to 0     
       ho_or1 = min(abs(or1-ho));     
       % Define time interval to the nearest confirming response before the main response 
       TB = 1000; 
       % Define time interval to the nearest confirming response after the main response 
       TA = 1000; 
       
       for h = 1:Hkr 
       for w = 1:Wkr    
 
                % if h can be found in vector or2, the following parameter turns to 0     
                h_or2 = min(abs(or2-h));               
                % Time interval between the two current responses 
                dtr = tr(ho,wo)-tr(h,w); 
                
                % Update time interval to confirming response on the left 
                if 0<=dtr & abs(dtr)<TB & ho_or1==0 & h_or2==0 & aprm(ho,wo)==1 & aprm(h,w)==1
                TB = abs(dtr); 
                hL = h; 
                wL = w; 
                end      
                
                % Update time interval to confirming response on the right 
                if dtr<0 & abs(dtr)<TA & ho_or1==0 & h_or2==0 & aprm(ho,wo)==1 & aprm(h,w)==1
                TA = abs(dtr); 
                hR = h; 
                wR = w; 
                end        
    
       end % w = 1:Wkr    
       end % h = 1:Hkr
       
       % Form logical parameter BL
       BL = TB<=tand_b; 
       if adjust_to_rt==1
       BL = TB<tand_b; 
       end
       
              % Define alarms coming through "AND" condition 
               if BL & ho_or1==0
               aprmt(ho,wo) = 1; 
               end
               if  TA<tand_a & tand_b<TB & ho_or1==0
               aprmt(hR,wR) = 1;  
               end   
               
end  % wo = 1:Wkr    
end  % ho = 1:Hkr 

% Update the alarm permission matrix 
aprm = aprmt; 
clear aprmt
end % if 1<Nv & 0<length(or1) & 0<length(or2)
%*****************************************************************


% apply plain "AND" condition to the alarm permission matrix  
%**************************************************************
if 1<Nv & 0<length(or1) & 0<length(or2) & and_bias==0
    
% Back up the alarm permission matrix for the processing below 
aprmb = aprm;     
    
for ho = 1:Hkr 
for wo = 1:Wkr        
 
       % if ho can be found in vector or1, the following parameter turns to 0     
       ho_or1 = min(abs(or1-ho));   
        % if ho can be found in vector or2, the following parameter turns to 0     
       ho_or2 = min(abs(or2-ho));     
      
       % Define alarm permission coefficient 
       apc = 0; 
       
       for h = 1:Hkr 
       for w = 1:Wkr    
 
                % if h can be found in vector or1, the following parameter turns to 0     
                h_or1 = min(abs(or1-h));            
                % if h can be found in vector or2, the following parameter turns to 0     
                h_or2 = min(abs(or2-h));               
                % Time interval between the two current responses 
                dtr = tr(ho,wo)-tr(h,w); 
                
              if  0<=dtr & dtr<=tand_b & ((ho_or1==0 & h_or2==0) | (ho_or2==0 & h_or1==0)) & aprmb(h,w)==1
              apc = 1; 
              end         
                   
       end % w = 1:Wkr    
       end % h = 1:Hkr
  
       % update alarm permission matrix 
       aprm(ho,wo) = aprm(ho,wo)*apc; 
       
end  % wo = 1:Wkr    
end  % ho = 1:Hkr 
       
end % if 1<Nv & 0<length(or1) & 0<length(or2)
%*****************************************************************


% Total number of true positive alarms in current patient
Ntpp = sum(sum(tpr.*aprm)); 



% Forbid any alarms discounted by CGM readings
if max(pid==14) % (if CGM is used)
for h = 1:Hkr 
for w = 1:Wkr   
   if max(mpai(:,1)<=tr(h,w) & tr(h,w)<=mpai(:,2)) 
   else
    aprm(h,w) = 0;    
   end    
end 
end 
end  % if max(pid==14)


% Forbid technical alarms following belt adjustment 
if use_bgl_checks == 1 & max(pid==17)%(cumulative drop-out count is used)  
for h = 1:Hkr 
for w = 1:Wkr   
   if pid(h)==16 & belt_adj==1 & Ntck<=kr(h,w)
    aprm(h,w) = 0;   
   end    
end 
end 
end


% Forbid technical alarms preceding 1hr recalibration 
if TA_nap_floor == 1
if use_bgl_checks == 1 & tckp-tnar2==tckmin & max(pid==16) % (technical fault alarms are simulated)
for h = 1:Hkr 
for w = 1:Wkr   
   if pid(h)==16 & kr(h,w)<=Ntck
    aprm(h,w) = 0;   
   end    
end 
end 
end
end

% Determine time of the first true positive alarm
%************************************************************
if Ntpp>0  
% find the element number of the earliest true positive alarm     
tmin = 1000;  
for h = 1:Hkr 
for w = 1:Wkr    
   if tpr(h,w)*aprm(h,w)==1 & tr(h,w)<tmin
     tmin = tr(h,w); 
     hmin = h; 
     wmin = w; 
   end    
end 
end 
%time of the first true positive response     
ttpr = tmin; 
end % if Ntpp>1    
%******************************************************************


% Forbid any alarms that follow the first true positive response    
if Ntpp>0 
for h = 1:Hkr 
for w = 1:Wkr   
   if tr(h,w)>=ttpr & (0<abs(h-hmin) | 0<abs(w-wmin))
    aprm(h,w) = 0;    
   end    
end 
end 
end


% Forbid the alarm that brings recalibration back 
% and other alarms that that may happen before the recalibration brought back
if use_bgl_checks==1 & natt==2 
for h = 1:Hkr 
for w = 1:Wkr   
   if kffa<=kr(h,w) & kr(h,w)<=Ntck
    aprm(h,w) = 0; 
     if  plot_each_patient == 1 
     figure(10 + p)
     subplot(211)
     plot(tr(h,w),2.5,'g*')
     end
   end    
end 
end  
end


% Find the first false alarm 
if use_bgl_checks==1
% Define the time of first false alarm in the patient
tffa = 100; 
% Define the sample number of first false alarm in the patient
kffa = 10000; 
for h = 1:Hkr 
for w = 1:Wkr    
   if fpr(h,w)*aprm(h,w)==1 
   % The time of first false alarm 
   tffa = min(tffa,tr(h,w));   
   % The sample number of first false alarm
   kffa = min(kffa,kr(h,w)); 
   end        
end 
end 
end




% Plot alarms 
if Nths == 1
if  plot_each_patient == 1 
figure(10 + p)
subplot(211)
end
for h = 1:Hkr 
for w = 1:Wkr 
   if tpr(h,w)*aprm(h,w)==1 
       if  plot_each_patient == 1 
     plot(tr(h,w),2.5,'r*') 
       end 
     % Time lag from hypo onset to alarm 
     thoa = tr(h,w)-tsh; 
     % Element number of hypo onset nearest to true positive  
     [a n] = min(abs(mhi(:,1)-tr(h,w)));
     % If TP response cannot be associated with the next hypo onset, 
     %it should be associated with the previous one 
          if tr(h,w)<ttpi(n,1) 
              n=n-1; 
          end
     %time of hypo onset nearest to true positive    
     thontp = mhi(n,1); 
     % Time lag from nearest hypo onset to alarm 
     thoan = tr(h,w)-thontp;  
     % Time lag from deep hypo onset to alarm
       if tedh==100
          tdhoa = 100; 
       else
          tdhoa = tr(h,w)-tedh; 
       end
   end    
   if fpr(h,w)*aprm(h,w)==1 & plot_each_patient == 1 
   plot(tr(h,w),2.5,'k*')    
   end        
end 
end 



if save_plots == 1
saveppt('plots.ppt',' ')
end

end


if Nths == 1 & first_response_time == 1 
%**************************************************************
% Determine size of matrix of responses
[a b] = size(tr); 

% Time of hrv response 
if a>=nvrd
tvar = tr(nvrd,1); 
else
tvar = 0; 
end

if tvar == 0     
else    
% Delay from start of BGL data to hrv response 
tvar = tvar - tgmin;   
% Start to calculate average tvar 
atvar = atvar + tvar; 
% Update the number of patients with existing hrv response 
npvar = npvar + 1; 
end
%***********************************************************
end


if Nths==1 & Np==1 
 if sum(sum(tr))==0
disp(' ')    
disp('There are no responses')
disp(' ')    
 else   
     
% Generate comment string of feature numebr for the output below
fnm = []; 
for k = 1:length(kr(:,1))
fnm = [ 
      fnm 
     'Variable' num2str(k) ':  '
      ]; 
end 
          
% Print information about responses 
disp(' ')


disp('Response times, hr')
disp([fnm num2str(tr)])
disp(' ')
disp('Response samples')
disp([fnm num2str(kr)])
disp(' ')

if interp_BGL12 == 1
if BGLpj==1 
if 0<=tBGL1p
disp(['BGL1=' num2str(G01)])   
else    
disp(['BGL1=' num2str(G01) ', Sample ' num2str(NBGL1)])
end
end
disp(['BGL2=' num2str(G02) ', Sample ' num2str(NBGL2)])
else
if BGLpj==1
disp(['BGL1=' num2str(G01) ', t1=' num2str(tnar1)])
end
disp(['BGL2=' num2str(G02) ', t2=' num2str(tnar2)])
end
disp(' ')

disp(['Last sample within no-alarm period: ' num2str(Nnap)])
disp(' ')

disp('False positives')
disp(fpr)
disp('True positives')
disp(tpr)
disp('Alarm permissions')
disp(aprm)
    
 end % if sum(sum(tr))==0
end % if Nths==1 & Np==1 


% Evaluate performance sample by sample 
if performace_by_samples == 1
%********************************************

if plot_each_patient == 1 
figure(10 + p) 
subplot(211)
end 

% The number of time increments during which the alarm is kept active  
Ntaa = round(taa/dtnv);
% Matrix of sample numbers of false positive responses 
snfpr = nonzeros(fpr.*aprm.*kr); 

% Element number corresponding to false positive alarm 
% It is equal to 0 if there is no a false positive alarm   
if length(snfpr)==0
enfp = 0; 
else
enfp = min(min(snfpr));  
end    

% The number of false positive cases in current patient 
Nfp(m) = min(Ntaa,(Ntnv-enfp))*sign(enfp); 
% Define a dummy number of false positive alarms 
Nfpa(m) = Nfp(m); 

if enfp>0 & plot_each_patient == 1
for k=enfp:enfp+Nfp(m)
plot((k-1)*dtnv,2.5,'k.')
end
end

% Element number corresponding to true positive alarm 
% It is equal to 0 if there is no a true positive alarm
entp = sum(sum(tpr.*aprm.*kr)); 
% The number of true positive cases in current patient 
Ntp(m) = min(Ntaa,(Ntnv-entp))*sign(entp);  
if entp>0 & plot_each_patient == 1
for k=entp:entp+Ntp(m)
plot((k-1)*dtnv,2.5,'r.')
end
end

% The number of samples that need to be processed to sort out 
% the true negative and false negative cases 
Nns = Ntnv; 
if enfp>0
Nns = min(Nns,enfp-1);
end
if entp>0
Nns = min(Nns,entp-1);
end

% Put glucose data on tnv time array for the next cycle 
Gtnv = interp1(tg,G,tnv,'linear'); 

% Set initial parameters for the next cycle 
% The number of true negatives
ntn = 0; 
% The number of false negatives
nfn = 0; 
for k=1:Nns
% Update the count of true negative cases 
if Gthd<Gtnv(k)
ntn = ntn+1;  
if plot_each_patient == 1
plot((k-1)*dtnv,2.5,'c.')
end
end  
% Update the count of false negative cases     
if Gtnv(k)<=Gthd
nfn = nfn+1; 
if plot_each_patient == 1
plot((k-1)*dtnv,2.5,'m.')
end
end
end

% Define the number of true negatives and false negatives at current threshold count m 
Ntn(m) = ntn; 
Nfn(m) = nfn; 

%*******************************************
end % if performace_by_samples == 1



% Evaluate performance on patient by patient basis
if performace_by_samples == 0
    
% Logical expression 
lex = Gsmin<=Gthd; 
if adjust_to_rt == 1 
lex = Gsmin<Gthd; 
end   
     
%********************************************
if count_fp_in_hypos == 0 & lex
Nfpa(m) = 0;     
Nfp(m) = 0; 
else 
% The number of false positive alarms in current patient 
Nfpa(m) = sum(sum(fpr.*aprm));  

% The number of false positive cases in current patient 
Nfp(m) = sign(Nfpa(m)); 
end 


% The number of true positive cases in current patient  
if Nfp(m)==0
Ntp(m) = sum(sum(tpr.*aprm));  
else 
Ntp(m) = 0; 
end


% Calculate true positive BGL value in current patient at current threshold 
if Ntp(m)==1
 % Time of true positive alarm in current patient at current threshold 
 t = nonzeros(tpr.*aprm.*tr); 
 % BGL value at true positive in current patient at current threshold 
 [a n] = min(abs(tgs-t));  
 Gtp(m) = Gsp(n); 
else 
 Gtp(m) = 0; 
end


% Logical expression 
lex = Gsmin<=Gthd; 
if adjust_to_rt == 1 
lex = Gsmin<Gthd; 
end

% the number of false negative cases in current patient
if lex & (Nfp(m)+Ntp(m))==0
Nfn(m) = 1; 
else
Nfn(m) = 0; 
end


% Logical expression 
lex = Gthd<Gsmin; 
if adjust_to_rt == 1 
lex = Gthd<=Gsmin; 
end

% The number of true negative cases in current patient 
if lex & (Nfp(m)+Ntp(m))==0
Ntn(m) = 1; 
else
Ntn(m) = 0;   
end    

%*******************************************
end % if performace_by_samples == 0



clear krs trs tprs fprs 
%**************************************************************


if use_bgl_checks==1 & Nfp(m)==1 & tffa<tck & tck-tffa<=dtca & tnar2+tckmin<=tffa 
% set the time of BGL check at false alarm of first attempt  
tck = tffa+5/60; 
else
break
end

end %for natt = 1:2
end  % for m=1:Nths



% Array of night durations 
andur(p) = tee-tnar2;  


if Nths == 1    
%*************************************************************
%**************************************************************    


str_h = 'Pat ';

if print_pat_numbers == 1
str_t =  [num2str(pn(p))];     
else
str_t =  [''];       
end   


if print_predictions==1
if p==1 
str_h = [str_h '  tp tn fp fn'];
end   
% Form string of output table    
str_t = [str_t '  ' num2str(Ntp) '  ' num2str(Ntn) '  ' num2str(Nfp) '  ' num2str(Nfn) ' '];
end
 
% Form string of mean values of the columns
if p==Np
str_m = 'Mean';
str_m = [str_m '  -  -  -  - ']; 
end

if print_dBGdtHo == 1
%***************************************
if p==1
str_h = [str_h ' dBGdtHo ']; 
AdBGdtho = []; 
end
if dBGdtho==100
strn = '   -    ';  
else
strn = ['  ' num2str(round(dBGdtho*100)/100) ' ']; 
% Add value to the array
AdBGdtho = [AdBGdtho 
    dBGdtho]; 
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn];
if p==Np   
if 1<=length(AdBGdtho)
strn = ['  ' num2str(round(mean(AdBGdtho)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
%*****************************************
end % if print_LagGth == 1


if print_LagGth == 1
%***************************************
if p==1
str_h = [str_h ' LagGth ']; 
Athoa = [];
end
if Ntp==0
strn = '   -    ';  
else
strn = ['  ' num2str(round(thoa*100)/100) ' ']; 
% Add value to the array
Athoa = [Athoa 
    thoa]; 
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn];
if p==Np   
if 1<=length(Athoa)
strn = ['  ' num2str(round(mean(Athoa)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
%*****************************************
end % if print_LagGth == 1


if print_LagGthn==1
%***********************************************
% Print alarm lag with respect to the nearest hypo onset at the upper threshold of error band 
if p==1
str_h = [str_h ' LagGthn'];  
Athoan = [];
end
if Ntp==0
strn = '   -    ';  
else
strn = ['  ' num2str(round(thoan*100)/100) ' ']; 
% Add value to the array
Athoan = [Athoan 
    thoan]; 
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn];
if p==Np
if 1<=length(Athoan)
strn = ['  ' num2str(round(mean(Athoan)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
%***************************************************
end  % if print_LagGthn==1


if print_LagGthd==1
%********************************************
if p==1
str_h = [str_h ' LagGthd'];  
Atdhoa = [];
end
if Ntp==0 | tdhoa==100
    strn = '   -    ';  
else
    strn = ['  ' num2str(round(tdhoa*100)/100) ' ']; 
% Add value to the array
Atdhoa = [Atdhoa 
    tdhoa]; 
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn];

if p==Np
if 1<=length(Atdhoa)
strn = ['  ' num2str(round(mean(Atdhoa)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
%****************************************
end  % if print_LagGthd==1


if print_t1==1
if p==1
str_h = [str_h ' t(BGL1)']; 
Atnar1 = []; 
end
% String of the number to print 
strn =  ['  ' num2str(round(tnar1*100)/100) ' ']; 
% Add value to the array
Atnar1 = [Atnar1 
    tnar1]; 

while length(strn)<8
strn = [strn ' ']; 
end
% Add string of the number
str_t = [str_t strn]; 
if p==Np
if 1<=length(Atnar1)
strn = ['  ' num2str(round(mean(Atnar1)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_t2==1
    if p==1
    str_h = [str_h ' t(BGL2)'];  
    Atnar2 = [];
    end  
% String of the number to print 
strn =  ['  ' num2str(round(tnar2*100)/100) ' ']; 
% Add value to the array
Atnar2 = [Atnar2 
    tnar2]; 
while length(strn)<8
strn = [strn ' ']; 
end
% Add string of the number
str_t = [str_t strn]; 
if p==Np
if 1<=length(Atnar2)
strn = ['  ' num2str(round(mean(Atnar2)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_BGL1==1 
    if p==1
    str_h = [str_h '  BGL1  '];  
    AG01 = []; 
    end  
% String of the number to print 
strn =  ['  ' num2str(round(G01*100)/100) ' ']; 
% Add value to the array
AG01 = [AG01 
      G01]; 
while length(strn)<8
strn = [strn ' ']; 
end
% Add string of the number
str_t = [str_t strn]; 
if p==Np

if 1<=length(AG01)
strn = ['  ' num2str(round(mean(AG01)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_BGL2==1 
    if p==1
    str_h = [str_h '  BGL2  '];  
    AG02 = [];
    end  
% String of the number to print 
strn =  ['  ' num2str(round(G02*100)/100) ' ']; 
% Add value to the array
AG02 = [AG02 
      G02]; 
while length(strn)<8
strn = [strn ' ']; 
end
% Add string of the number
str_t = [str_t strn]; 
if p==Np
% Plot prevalence density of BGL2
%**********************************************************
% Resolution of prevalence density function, mmol/L 
dlg = 1.0; 
% BGL vector of density prevalence function 
g = 0:0.1:20;
% prevalence density function 
pdf = g*0; 
for k=1:Np
pdf = pdf + exp(-((g-AG02(k))/dlg).^2); 
end 
% Normalize the distribution 
pdf = pdf/(Np*dlg*sqrt(pi)); 
figure(601)
 hold on 
 grid on 
 plot(g,pdf,'b')
 ylabel('Prevalence densitiy')
 xlabel('BGL2')  
%***********************************************************


if 1<=length(AG02)
strn = ['  ' num2str(round(mean(AG02)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_dBGdt==1 & BGLpj == 1
    if p==1
    str_h = [str_h '  dBGdt  '];  
    % Define array of BGL derivative 
    AdBGdt = []; 
    end  
% String of the number to print 
strn =  ['  ' num2str(round(dBGdt*100)/100) ' ']; 
% Add value to the array
AdBGdt = [AdBGdt 
    dBGdt]; 
while length(strn)<8
strn = [strn ' ']; 
end
% Add string of the number
str_t = [str_t strn]; 
if p==Np 
% Plot data    
 figure 
 hold on 
 grid on 
 plot(AdBGdt,'r.')
 ylabel('dBGdt')
 xlabel('Patient')
if 1<=length(AdBGdt)
strn = ['  ' num2str(round(mean(AdBGdt)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_night_duration==1
if p==1
str_h = [str_h ' t(nite) ']; 
Atsh = []; 
end
if andur(p)==100
strn = '   -    ';  
else    
strn = ['  ' num2str(round(andur(p)*100)/100) ' ']; 
% Add value of hypo start to the array 
Atsh = [Atsh
tsh];
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn]; 

if p==Np
if 1<=length(andur)
strn = ['  ' num2str(round(mean(andur)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end


if print_t_hypo==1
if p==1
str_h = [str_h ' t(Gth) '];  
Atsh = []; 
end
if tsh==100
strn = '   -    ';  
else    
strn = ['  ' num2str(round(tsh*100)/100) ' ']; 
% Add value of hypo start to the array 
Atsh = [Atsh
tsh];
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn]; 

if p==Np
if 1<=length(Atsh)
strn = ['  ' num2str(round(mean(Atsh)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end

if print_t_dhypo==1
if p==1
str_h = [str_h ' t(Gthd)'];  
Atedh = []; 
end
if tedh==100
strn = '   -    ';  
else    
strn = ['  ' num2str(round(tedh*100)/100) ' ']; 
% Add value of hypo start to the array 
Atedh = [Atedh
tedh];
end
while length(strn)<8
strn = [strn ' ']; 
end
str_t = [str_t strn]; 

if p==Np
if 1<=length(Atedh)
strn = ['  ' num2str(round(mean(Atedh)*100)/100) ' ']; 
else
strn = '   -    '; 
end  
while length(strn)<8
strn = [strn ' ']; 
end
str_m = [str_m strn]; 
end
end

if first_response_time == 1
if tvar == 0
str_t = [str_t '    -']; 
else    
str_t = [str_t '    ' num2str(tvar)]; 
end
if p==1
str_h = [str_h '   resp del']; 
end
end

% Print the table 
if p==1 & 4<length(str_h)
disp(str_h)
end
disp(str_t)

if p==Np & print_predictions==1
disp(str_m)
end










if 1==0

if p==1
% The number of calibrations
Ncal = 0; 
% The numebr of belt adjustments
Nadj = 0; 
% The number of true positive belt notifications 
Btp = 0; 
% The number of false positive belt notification
Bfp = 0; 
% The number of true negative belt notifications
Btn = 0; 
% The number of false negative belt notifications
Bfn = 0;
disp('Pat    tp tn fp fn')
end

if use_bgl_checks==1
Ncal = Ncal+1; 
end

if use_bgl_checks==1 & belt_adj==1
Nadj = Nadj+1;     
end


% Matrix of false positive responses that occur after recalibration 
fprr = Ntck<fpr.*kr; 
% Feature number corresponding to fault alarms
[a n] = min(abs(pid-16));

%***************************
if use_bgl_checks==1 & n<=Hkr & 0<sum(fprr(n,:)) & belt_adj==1
Btp = Btp+1; 
disp([num2str(pn(p)) '  ' '1  0  0  0'])
end

if use_bgl_checks==1 & (Hkr<n | sum(fprr(n,:))==0) & belt_adj==0
Btn = Btn+1; 
disp([num2str(pn(p)) '  ' '0  1  0  0'])
end

if use_bgl_checks==1 & (Hkr<n | sum(fprr(n,:))==0) & belt_adj==1
Bfp = Bfp+1; 
disp([num2str(pn(p)) '  ' '0  0  1  0'])
end

if use_bgl_checks==1 & n<=Hkr & 0<sum(fprr(n,:)) & belt_adj==0
Bfn = Bfn+1; 
disp([num2str(pn(p)) '  ' '0  0  0  1'])
end
%*****************************
clear fprr



if p==Np
disp(' ')    
disp(['Ncal = ' num2str(Ncal)])
disp(['Nadj = ' num2str(Nadj)])

disp('Btp Btn Bfp Bfn')
disp([' ' num2str(Btp) '   ' num2str(Btn) '   ' num2str(Bfp) '   ' num2str(Bfn)])

disp(['Sensitivity of belt notifications = ' num2str(Btp/(Btp+Bfn+1e-10)*100) '%'])
disp(['Specificity of belt notifications = ' num2str(Btn/(Btn+Bfp+1e-10)*100) '%'])
end

end % if 1==0


%****************************************************************
%****************************************************************
end % if Nths == 1    







% Add true postivie cases from all patients     
Ntps = Ntps + Ntp; 
% Add false negative cases from all patients 
Nfns = Nfns + Nfn; 
% Add the number of false positive cases from all patients
Nfps = Nfps + Nfp; 
% Add false alarms from all normal patients 
if Gth<Gsmin
Nfpas = Nfpas + Nfpa; 
end 
% Add all true negative cases 
Ntns = Ntns + Ntn; 
% Add true positive BGLs from all patients
Gtps = Gtps + Gtp; 
% Add squares of true positive BGLs from all patients
Gtp2s = Gtp2s + Gtp.^2; 


% Close file for saving the data for SPSS
if output_for_spss == 1 
status = fclose(fid1);
end


if correlation_analysis == 1 & Nths==1 & abs(pid(2)-pid(1))>0 % & Gsmin > Gth
% ****************************************************
%*********************************************************

% Time interval dropped out of correlation analysis before and 
% after the hypo, hr 
tdba = 0.3; 


% Cancel time shift that has been caused by filtering 
% Number of intervals corresponding to the integration time 
Nint(1) = round(Tf(1)/dtss); 
Nint(2) = round(Tf(2)/dtss); 


% Cancel shift 
for r = 1:2
cnv(1:Ntss-Nint(r),r) = cnv(1+Nint(r):Ntss,r); 
cnv(Ntss-Nint(r)+1:Ntss,r) = cnv(Ntss-Nint(r),r); 
end

% Calculate derivatives for correlation analysis 
%****************************************************
if correlation_of_derivative_1 == 1
cnv(1:Ntss-1,1) = diff(cnv(:,1));  
cnv(Ntss,1) = cnv(Ntss-1,1); 
end

if correlation_of_derivative_2 == 1
cnv(1:Ntss-1,2) = diff(cnv(:,2));  
cnv(Ntss,2) = cnv(Ntss-1,2); 
end
%*****************************************************


% The number of elements dropped before and after the hypo 
Ndba = round(tdba/dtss); 

% Drop out elements that do not need to be considered in 
% calculation of correaltion ratio 
%*****************************************************
% Define integer variable n for the cycle
n = 0; 
for k = 1+Ndba:Ntss-Ndba
if  min(Gs(k-Ndba:k+Ndba)) > Gth 
n = n+1; 
cnvd(n,1:2) = cnv(k,1:2); 
tssd(n) = tss(k); 
end
end
%*******************************************************


% Subtract mean of non-hypo data from the correlation parameters
for r = 1:2
% Mean of the vector outside of the hypo 
mcnvd = mean(cnvd(:,r));   
% Subtrack the average  
cnvd(:,r) = cnvd(:,r) - mcnvd; 
% Do the same to the original data 
cnv(:,r) = cnv(:,r) - mcnvd; 
end


% Normalize correlation parameters to standard deviation of non-hypo data 
% (Normalization does not change mutual correlation of the parameters)
for r = 1:2
% Determine standard deviation of the vector outside of the hypo 
stdcnvd = std(cnvd(:,r),1); 
% Normalise it to standard deviation 
cnvd(:,r) = cnvd(:,r)/stdcnvd; 
% Do the same to the original data 
cnv(:,r) = cnv(:,r)/stdcnvd; 
end


% Standard deviation of complete data 
std1 = std(cnv(:,1)); 
std2 = std(cnv(:,2)); 


% Matrics of correlation coefficients 
mcc = corrcoef(cnvd(:,1),cnvd(:,2));  

% Correlation coefficient before transformation 
ccb = mcc(1,2);  

disp([num2str(pn(p)) '   cc = ' num2str(ccb)])


% Update vector of correlation coefficients 
vcc = [vcc ccb]; 


if 1==0
figure(30+p)
hold on 
plot(tss,cnv(:,1)/std1,'m')
plot(tss,cnv(:,2)/std2,'b')
legend('Correlation parameter 1','Correlation parameter 2',1)
title(['Patient ' num2str(pn(p)) ',  cc =' num2str(ccb)])
axis([0 8 -5 5])
grid on
end


figure(10+p)
title(['Patient ' num2str(pn(p)) ',  cc =' num2str(ccb)])


end  % of if correlation_analysis == 1


%------------------------------------------------------------------------------------------------------------------
% PRODUCE REAL_TIME VERIFICATION INPUT DATA
%------------------------------------------------------------------------------------------------------------------
if MODE_SET == 1
    
    %----------------------------------------------
    % Retrieve and Format User Input Data
    %----------------------------------------------
    GENDER = VAR_GENDER;
    if GENDER == 0
        GENDER = 2;
    end
    DOBOFFSET = VAR_AGE;
    DODOFFSET = VAR_DOD;
    HEIGHT = VAR_HEIGHT/100;
    WEIGHT = VAR_WEIGHT;
    AVGTDD = floor(VAR_AVE_TDD);
    EXERCISELEVEL = VAR_EXERCISE_LEVEL;
    EXERCISETIMEOFFSET = min(-1*VAR_EXERCISE_TIME,18);  ;
    NUMHYPOEVENTS = VAR_COUNT_HYPO;
    DINNERTIMEOFFSET = abs(VAR_DINNER_BG_TIME);
    DINNERDEFAULT = (VAR_DINNER_BG==Gdefault/ccf);
    DINNERBGL = VAR_DINNER_BG;
    DINNERCARBS = VAR_DINNER_CHO;
    DINNERBOLUS = VAR_DINNER_BOLUS;
    PRECALTIMEOFFSET = abs(VAR_EVENING_BG_TIME);
    PRECALDEFAULT = (G01==Gdefault/ccf);
    PRECALBGL = VAR_EVENING_BG;
    CALDEFAULT = (G02==Gdefault/ccf);
    CALBGL = VAR_BED_BG;
    CALCARBS = VAR_BED_CHO;
    CALBOLUS = VAR_BED_BOLUS;
    % NOTE ALL BLOOD GLUCOSE SUPPLIED TO REAL_TIME ENGINE ARE NOW IN WHOLE BLOOD UNITS

    CALCYCLE = 0;                       % Forced to be zero
    if use_bgl_checks == 1 
        RECALCYCLE = (Ntck-1)*2;        % multiplied by two to turn into cycle number (instead of frame)
        RECALDEFAULT = (VAR_RECAL_BG==Gdefault/ccf);
        RECALBGL = VAR_RECAL_BG;
        RECALCARBS = VAR_RECAL_CHO;
        RECALBOLUS = VAR_RECAL_BOLUS;
    else
        RECALDEFAULT = 0;               % Forced to be 0   
        RECALBGL = 0;                   % Forced to be 0
        RECALCARBS = 0;                 % Forced to be 0
        RECALBOLUS = 0;                 % Forced to be 0
        RECALCYCLE = 0;                 % Forced to be 0
    end
    %----------------------------------------------
    
    %----------------------------------------------
    % Retrieve and Format HR Input Data
    %----------------------------------------------
    dataInQTc(1:length(dataInHR)) = 400; % Create dummy QTC data
    dataInQTc = dataInQTc';
    dataInHR = dataInHR(:,2);
    dataInHRA = dataInHRA(:,2);
    dataInHRO;
    
    AllData(:,1) = floor(dataInHR);
    AllData(:,2) = -floor(dataInHRO);
    AllData(:,3) = floor(dataInHRA);
    AllData(:,4) = dataInQTc;
   
    AllDataSize = size(AllData);
    %----------------------------------------------
    
    
    
    %----------------------------------------------
    % Write Data to 'dataIn_' pns '.csv'
    %----------------------------------------------
    
    pns = num2str(pn(Np));
    File = ['R:\Algorithm_Verification\Verification_Test_Case_Data\AL010202\dataIn_' pns '_AL010202.csv'];
    
    % Open file 
    fid = fopen(File,'wt');
    fprintf(fid,['GENDER']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',GENDER);
    fprintf(fid,'\n');
    
    fprintf(fid,['DOBOFFSET']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DOBOFFSET);
    fprintf(fid,'\n');
    
    fprintf(fid,['DODOFFSET']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DODOFFSET);
    fprintf(fid,'\n');
    
    fprintf(fid,['HEIGHT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',HEIGHT);
    fprintf(fid,'\n');
    
    fprintf(fid,['WEIGHT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',WEIGHT);
    fprintf(fid,'\n');
    
    fprintf(fid,['AVGTDD']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',AVGTDD);
    fprintf(fid,'\n');
    
    fprintf(fid,['EXERCISELEVEL']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',EXERCISELEVEL);
    fprintf(fid,'\n');
    
    fprintf(fid,['EXERCISETIMEOFFSET']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',EXERCISETIMEOFFSET);
    fprintf(fid,'\n');
    
    fprintf(fid,['NUMHYPOEVENTS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',NUMHYPOEVENTS);
    fprintf(fid,'\n');
    
    fprintf(fid,['DINNERDEFAULT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DINNERDEFAULT);
    fprintf(fid,'\n');
    
    fprintf(fid,['DINNERTIMEOFFSET']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DINNERTIMEOFFSET);
    fprintf(fid,'\n');
    
    fprintf(fid,['DINNERBGL']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DINNERBGL);
    fprintf(fid,'\n');
    
    fprintf(fid,['DINNERCARBS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DINNERCARBS);
    fprintf(fid,'\n');
    
    fprintf(fid,['DINNERBOLUS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',DINNERBOLUS);
    fprintf(fid,'\n');
    
    fprintf(fid,['PRECALDEFAULT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',PRECALDEFAULT);
    fprintf(fid,'\n');
    
    fprintf(fid,['PRECALTIMEOFFSET']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',PRECALTIMEOFFSET);
    fprintf(fid,'\n');
    
    fprintf(fid,['PRECALBGL']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',PRECALBGL);
    fprintf(fid,'\n');
    
    fprintf(fid,['CALDEFAULT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',CALDEFAULT);
    fprintf(fid,'\n');
    
    fprintf(fid,['CALBGL']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',CALBGL);
    fprintf(fid,'\n');
    
    fprintf(fid,['CALCARBS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',CALCARBS);
    fprintf(fid,'\n');
    
    fprintf(fid,['CALBOLUS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',CALBOLUS);
    fprintf(fid,'\n');
    
    fprintf(fid,['RECALDEFAULT']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',RECALDEFAULT);
    fprintf(fid,'\n')
    
    fprintf(fid,['RECALBGL']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',RECALBGL);
    fprintf(fid,'\n');
    
    fprintf(fid,['RECALCARBS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',RECALCARBS);
    fprintf(fid,'\n');
    
    fprintf(fid,['RECALBOLUS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',RECALBOLUS);
    fprintf(fid,'\n');
    
    fprintf(fid,['CALCYCLE']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',CALCYCLE);
    fprintf(fid,'\n');
    
    fprintf(fid,['RECALCYCLE']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',RECALCYCLE);
    fprintf(fid,'\n');
    
    fprintf(fid,['HR']);
    fprintf(fid,',');
    fprintf(fid,['HRO']);
    fprintf(fid,',');
    fprintf(fid,['HRA']);
    fprintf(fid,',');
    fprintf(fid,['QTC']);
    fprintf(fid,',');
    
    for k = 1:length(dataInHR)
        fprintf(fid,'\n%d, %d, %d, %d, %d', AllData(k,:));
        fprintf(fid,'\n%d, %d, %d, %d, %d', AllData(k,:));        
    end
    
    status = fclose(fid);
    
    %----------------------------------------------

end
%------------------------------------------------------------------------------------------------------------------



%------------------------------------------------------------------------------------------------------------------
% PRODUCE REAL_TIME VERIFICATION OUTPUT DATA
%------------------------------------------------------------------------------------------------------------------
if MODE_SET == 1

    VERIF_HRTF;
    VERIF_IHRO;
    VERIF_HRT;
    VERIF_HRST;
    VERIF_HRSD;
    VERIF_AHRSD;
    VERIF_HRTD;
    VERIF_CAL_STATUS;
    VERIF_RECAL_STATUS;
    VERIF_VAR_SCALE;
    VERIF_VAR_RECALSCALE;
    VERIF_NAP_END_CYCLE = 2*(Nnap-1);            % Last frame belonging to No Alarm Period
    VERIF_RECALNAP_END_CYCLE = 2*((Ntck+Ntnack)-1);
    
    if isempty(kr)
        VERIF_N_ALARM_CYCLE = -1;
    else
        VERIF_N_ALARM_CYCLE = 2*(kr(1)-1); % cycle of first Alarm
    end
    % Display Variables
    VERIF_VAR_SCALE
    VERIF_VAR_RECALSCALE
    VERIF_CAL_STATUS
    VERIF_RECAL_STATUS
    VERIF_NAP_END_CYCLE
    VERIF_RECALNAP_END_CYCLE
    
    dataOutTS(:,1) = VERIF_HRTF;
    dataOutTS(:,2) = VERIF_IHRO;
    dataOutTS(:,3) = VERIF_HRT;
    dataOutTS(:,4) = VERIF_HRST;
    dataOutTS(:,5) = VERIF_HRSD;
    dataOutTS(:,6) = VERIF_AHRSD;
    dataOutTS(:,7) = VERIF_HRTD;
    
   
    %----------------------------------------------
    % Write Data to 'dataOut_' pns '.csv'
    %----------------------------------------------
    
    pns = num2str(pn(Np));
    File = ['R:\Algorithm_Verification\Verification_Test_Case_Data\AL010202\dataOut_' pns '_AL010202.csv'];
    
    % Open file 
    fid = fopen(File,'wt');
    fprintf(fid,['VERIF_NAP_END_CYCLE']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',VERIF_NAP_END_CYCLE);
    fprintf(fid,'\n');
    
    fprintf(fid,['VERIF_N_ALARM_CYCLE']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',VERIF_N_ALARM_CYCLE);
    fprintf(fid,'\n');
    
    fprintf(fid,['VERIF_CAL_STATUS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',VERIF_CAL_STATUS);
    fprintf(fid,'\n');
    
    fprintf(fid,['VERIF_RECAL_STATUS']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',VERIF_RECAL_STATUS);
    fprintf(fid,'\n');
    
    fprintf(fid,['VERIF_VAR_SCALE']);
    fprintf(fid,',');
    fprintf(fid,'%12.8f',VERIF_VAR_SCALE);
    fprintf(fid,'\n');
    
    clear k
    
    
    fprintf(fid,['VERIF_HRTF']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_IHRO']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_HRT']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_HRST']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_HRSD']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_AHRSD']);
    fprintf(fid,',');
    fprintf(fid,['VERIF_HRTD']);
    fprintf(fid,',');
    
    
    for k = 1:length(dataOutTS)
        fprintf(fid,'\n%12.11f, %d, %12.11f, %12.11f, %12.11f, %12.11f, %12.11f', dataOutTS(k,:));
        fprintf(fid,'\n%12.11f, %d, %12.11f, %12.11f, %12.11f, %12.11f, %12.11f', dataOutTS(k,:));        
    end
    
    status = fclose(fid);
    
    %----------------------------------------------

end
%------------------------------------------------------------------------------------------------------------------


clear kr tr tpr fpr apr
clear tss Gs cnv cnvd tssd tg G belt_adj
clear VERIF_HRTF VERIF_NAP_END_FRAME VERIF_N_ALARM_FRAME
clear dataInQTc dataInQTc dataInHR dataInHRA dataInHRO AllData AllDataSize
%*************************************************************************
%************************************************************************


end  % for p = 1:Np;  




% Average night duration 
ndurav = mean(andur); 

% Calclulate specificity 
spfc = 100*(Ntns+1e-20)./(Ntns+Nfps+1e-20); 

% Length of vector of correlation coefficients 
Nvcc = length(vcc); 

if Nvcc > 0 
% Average correlation coefficient 
avecc = mean(abs(vcc)); 
disp(' ')   
disp(['Average |cc| = ' num2str(avecc)])
end


% Calculate sensitivity 
if Nph == 0
Stvt = Ntps*0; 
else
Stvt = 100*(Ntps+1e-20)./(Ntps+Nfns+1e-20); 
end

% Calculate PPV 
% Positive predictive value 
 ppvs = 100*(Ntps+1e-20)./(Ntps+Nfps+1e-20); 
 % Negative predictive value 
 npvs = 100*Ntns./(Ntns+Nfns+1e-20); 



% Mean of true positive BGL 
mGtp = Gtps./(Ntps+1e-20);  
% Standard deviation of true positive BGL 
sGtp = (Gtp2s./(Ntps+1e-20)-mGtp.^2).^0.5; 


if Nths == 1
if first_response_time == 1
% Average time of hrv response 
atvar = atvar/npvar;     
disp(['Average first response delay = ' num2str(atvar) 'hr'])    
disp(' ')    
end
if Np>1
disp(' ')    
disp(['Sensitivity = ' num2str(Stvt) '%'])
disp(['Specificity = ' num2str(spfc) '%'])
disp(['Ntp = ' num2str(Ntps)])
disp(['Nfp = ' num2str(Nfps)])
disp(['Ntn = ' num2str(Ntns)])
disp(['Nfn = ' num2str(Nfns)])
end
end


if Nths > 1 & Npn > 0  
%***********************************************************************    
% Convert the number of false alarms of normal patients to the number of alarms per night
Nfpas = Nfpas/Npn; 

% Determine the maximum number of detected hypos 
Nhmax = max(Stvt); 

% Define the number of false alarms in normal patinets at optimum threshold 
Nfao = 10000; 
% Define the optimum threshold 
th1o = 0; 


% Determine the number of fale alarms corresponding to a specified sensitivity 
for k = 2:Nths-1
    % The number of false alarms 
    if Stvt(k)>=mfa & (Stvt(k-1)<mfa | Stvt(k+1)<mfa) & Nfpas(k)<Nfao 
    Nfao = Nfpas(k); 
    % The optimum threshold 
    th1o = ths(k); 
    % The specificity at specified sensitivity 
    spfcm = spfc(k); 
    end
end
   

% The acceptable rate of false alarms vs. threshold for this parameter  
%************************************************************
% Maximum acceptable number of false alarms calculated from Hdpm 
Nacm = Fac*log(1-Hdpm/100)/log(1-Hdp/100); 

% Define vector  
Nac = Stvt*0; 
for k = 1:Nths
Ntpk = Stvt(k);     
    if Ntpk <= Hdpm
Nac(k) = Fac*log(1-Ntpk/100)./log(1-Hdp/100); 
    else
    Nac(k) = Nacm; 
    end
end
%****************************************************




if run_optimization == 0
      
figure(54)
subplot(211)
hold on 
plot(ths,Stvt,'r')
plot(ths,spfc,'b')
%ylabel('Sensitivity, %')
legend('Sensitivity','Specificity',4)
grid on


figure(602)
subplot(211)
hold on 
grid on 
plot(ths,ppvs,'b')
plot(aoth*[1 1],[0 100],'r')
ylabel('PPV, %')
subplot(212)
hold on 
grid on 
plot(ths,npvs,'b')
plot(aoth*[1 1],[0 100],'r')
ylabel('NPV, %')


figure(600)
subplot(211)
hold on 
plot(ths,Stvt,'b')
if plot_Gtp==1
% Plot true positive BGL 
plot(ths,(mGtp-sGtp)*10,'m')
%plot(ths,mGtp*10,'m')
plot(ths,(mGtp+sGtp)*10,'m')
legend('Sensitivity','Gpt*10',3)
end
plot(aoth*[1 1],[0 100],'r')
ylabel('Sensitivity, %')
grid on
subplot(212)
hold on 
plot(ths,spfc,'b')
plot(aoth*[1 1],[0 100],'r')
if Nfao < 10000
plot(th1o,spfcm,'r.')
end
ylabel('Specificity, %')
xlabel('th1')
grid on

    
figure(58)
subplot(211)
hold on 
plot(ths,Stvt,'b')
ylabel('Sensitivity, %')
grid on
subplot(212)
hold on 
plot(ths,Nfpas,'b')
plot(ths,Nac,'c')
% Plot half of false alarm rate of random signal that produces the same sensitivity
if error_band==0 & ending_event == 1 & count_fp_in_hypos == 0
% True positive time interval 
tpti = dtae+dtbe; 
%plot(ths,0.5*Stvt/100*ndurav/tpti,'m')
%plot(ths,Stvt/100*6/tpti,'m')
end
if Nfao < 10000
plot(th1o,Nfao,'r.')
end
ylabel('False alarms per night')
xlabel('th1')
grid on


figure(54)
subplot(212)
hold on 
if training_gage == 1 
plot(ths,Stvt+spfc,'r')
ylabel('Sensitivity + Specificity')
disp(['Max(St+Sp)=' num2str(max(Stvt+spfc)) '%'])
end
if training_gage == 2 
% False alarm rate corresponding to the minimum acceptable sensitivity of a single parameter
Nacmin = Fac*log(1-Stvtsmin/100)./log(1-Hdp/100); 
plot(ths,Nac./max(Nfpas,Nacmin),'r')
ylabel('Advantage over noise')
end 
xlabel('th1')
grid on


figure(59)
grid on
xlabel('BGL at algorithm start, mmol/L')
ylabel('Time since algorithm start, hr')
axis([2 25 0 8])
end  % if run_optimization == 0

%****************************************************************************
end % of if Nths > 1 & Npn > 0  


% Save performance data to files 
%*****************************
if save_performance == 1 
File = ['algo_perf.txt'];   
% Open file 
fid = fopen(File,'wt');
fprintf(fid,'   Threshold,    Sensitivity, %%   Specificity, %%        PPV, %%           NPV, %%\n'); 
for k = 1:Nths
fprintf(fid,'%12.8e',ths(k));
fprintf(fid,'  %12.8e',Stvt(k));
fprintf(fid,'  %12.8e',spfc(k));
fprintf(fid,'  %12.8e',ppvs(k));
fprintf(fid,'  %12.8e',npvs(k));
fprintf(fid,'\n'); 
end
status = fclose(fid);


File = ['algo_perf_N.txt'];   
% Open file 
fid = fopen(File,'wt');
fprintf(fid,'   Threshold,           Ntp,          Nfp,          Ntn,          Nfn,      Rate of FA\n'); 
for k = 1:Nths
fprintf(fid,'%12.8e',ths(k));
fprintf(fid,'  %12.8f',Ntps(k));
fprintf(fid,'  %12.8f',Nfps(k));
fprintf(fid,'  %12.8f',Ntns(k));
fprintf(fid,'  %12.8f',Nfns(k));
fprintf(fid,'  %12.8f',Nfpas(k));
fprintf(fid,'\n'); 
end
status = fclose(fid);


if Nths > 1
    Athoa = []; 
end

save algo_perf.mat Athoa Atdhoa  

end % if save_performance == 1 
%*****************************

clear Ntps Nfns ppvs npvs
clear Ntns Nfps 






% Quantify the algorithm performance for the purpose of optimization 
if run_optimization == 1
%*******************************************************

% color number for optimization plots 
Ncop = 1 + ntsc - fix(ntsc/6)*6; 


figure(60+(nitop-1)*Nvft+nvft)
subplot(211)
title(['Iteration ' num2str(nitop) ',  Variable ' num2str(nvft)])
hold on 
plot(ths,Stvt,col(Ncop))
ylabel('Sensitivity, %')
grid on
subplot(212)
hold on 
plot(ths,spfc,col(Ncop))
ylabel('Specificity, %')
xlabel('th1')
grid on


% Determine the standard deviation of the width of sensitivity distribution 
%*************************************************************

% Sensitivity maximum 
Stvt_max = max(Stvt); 
% Sensitivity minimum 
Stvt_min = min(Stvt); 


if Stvt_max>Stvt_min 

% The number of width increments 
Nwds = 11; 

% Sensitivity increment 
dStvt = (Stvt_max-Stvt_min)/Nwds; 

% Array of sensitivity values for sampling of width 
Stvt_a = Stvt_min:dStvt:Stvt_max; 

for n=1:Nwds
for k=2:Nths
Stvt_an = Stvt_a(n); 
    
% Left boundary of the width measurement 
if (Stvt(k-1)<=Stvt_an & Stvt(k)>Stvt_an) | (Stvt(1)>Stvt_an & k==2)
Lbwm = ths(k-1);   
end    
    
% Right boundary of the width measurement 
if (Stvt(k-1)>Stvt_an & Stvt(k)<=Stvt_an) | (Stvt(Nths)>Stvt_an & k==Nths)
Rbwm = ths(k);   
end

end  % for k=2:Nths
% Width sample 
w_Stvt(n) = Rbwm-Lbwm; 
end % for n=1:Nwds

% Average width of the sensitivity distribution 
avw_Stvt = mean(w_Stvt); 
% Standard deviation of width of the sensitivity distribution 
std_Stvt = std(w_Stvt); 

end % if Stvt_max>Stvt_min 


if Stvt_max==Stvt_min 
% Average width of the sensitivity distribution 
avw_Stvt = ths(Nths)-ths(1); 
std_Stvt = 0; 
end

%***************************************************************


% Make the specificity preference coefficient dependent on the iteration number 
%cptsi = min(cpts,sqrt(cpts)^(nitop-1)); 
cptsi = cpts^(nitop/Nitop); 

% Define performance parameter 
% This performance parameter grows with specificity faster than with sensitiviy if specifity is below the targeted value 
% It does not depend on specificity at all if specifcity is above 80% 
ppr = Stvt-100 - cptsi*abs(spfc-spfct); 

% Find the ppr peak 
%*****************************************
% Define width of ppr peak that needs to be found 
%wppra = 1.0; 
if std_Stvt==0
wppra = thtoL*avw_Stvt; 
else 
wppra = thtoL*std_Stvt; 
end


% Threshold increment 
dths = ths(2)-ths(1); 

% The number of threshold increments corresponding to wppra 
Nwppra = 2*ceil(wppra/dths/2); 

% Update the width wppra 
wppra = Nwppra*dths; 

% The number of threshold increments at the lower level (b)
Nwpprb = brlow*Nwppra;

% Update the width wpprb 
wpprb = Nwpprb*dths; 


%*******************
% Define initial value of ppr maximum
pprmax = -10000; 

% Trigger setting for the cycle below  
update_Nppr2a = 0; 

for k = 1+Nwpprb/2:Nths-Nwpprb/2
% Minimum value of ppr over interval a
mina = min(ppr(k-Nwppra/2:k+Nwppra/2));     
% Minimum value of ppr over interval b
minb = min(ppr(k-Nwpprb/2:k+Nwpprb/2));     

% Find the beginning of ppr peak 
if mina>pprmax & minb>mina-stepab 
pprmax = mina;
% Beginning of a-level of ppr peak
Nppr1a = k-Nwppra/2; 
thsppr1a = ths(Nppr1a); 
% Trigger settings 
update_Nppr2a = 1; 
end

% Find the end of ppr peak 
if (mina<pprmax | minb<pprmax-stepab) & update_Nppr2a==1
  %End of a-level of ppr peak 
Nppr2a = k+Nwppra/2-1; 
thsppr2a = ths(Nppr2a);  
% Trigger settings 
update_Nppr2a = 0; 
end

end
%********************


% ppr peak width 
wppr = thsppr2a-thsppr1a; 

% Optimum threshodl 
thopt = (thsppr1a+thsppr2a)/2; 


figure(70+(nitop-1)*Nvft+nvft)
title(['Iteration ' num2str(nitop) ',  Variable ' num2str(nvft)])
hold on 
plot(ths,ppr,col(Ncop))
plot(thopt,pprmax,[col(Ncop) '*'])
plot([thopt-wppra/2 thopt+wppra/2],[pprmax pprmax],col(Ncop))
%plot([thopt-wppra/2 thopt-wppra/2],[pprmax pprmax-stepab],col(Ncop))
%plot([thopt+wppra/2 thopt+wppra/2],[pprmax pprmax-stepab],col(Ncop))
%plot([thopt-wpprb/2 thopt-wppra/2],[pprmax-stepab pprmax-stepab],col(Ncop))
%plot([thopt+wpprb/2 thopt+wppra/2],[pprmax-stepab pprmax-stepab],col(Ncop))
plot([thopt-wpprb/2 thopt-wppra/2],[pprmax-stepab pprmax],[col(Ncop) '-'])
plot([thopt+wppra/2 thopt+wpprb/2],[pprmax pprmax-stepab],[col(Ncop) '-'])
grid on 



% Update the key output parameters of the ppr for the current cycle
if (pprmaxo<pprmax) | (pprmaxo==pprmax & wppro<wppr)
pprmaxo = pprmax; 
thopto = thopt; 
wppro = wppr; 
% Element number of the optimum filtering time 
ntsco = ntsc; 
% Color for plotting the optimum threshold
Ncopo = Ncop; 
end

disp(['Variable ' num2str(nvft) ', Filtering time = ' num2str(Tf(nvft))]); 

end % of if run_optimization == 1
%*********************************************************


% Clear varables from the completed cycle 
clear cnv tss 

end % for ntsc = 1:Ntsc   Scan of filtering time of currently optimized variable 




% 
if run_optimization == 1 
%********************************************************
% The optimum value of filtering time 
Tsco = Tsc(ntsco); 

% update the optimum values of filtering times and threshold of current variable 
Tf(nvft) = Tsco; 
Tlag(nvft) = Tsco; 
th(nvft) = thopto;


disp(' ')
disp('Filtering time vector')
disp(Tf)
disp('Threshold vector')
disp(th)


% Plot the threshod optimum for the scanned range of filtering times 
figure(60+(nitop-1)*Nvft+nvft)
subplot(211)
plot(thopto*[1 1],[0 100],col(Ncopo))
subplot(212)
plot(thopto*[1 1],[0 100],col(Ncopo))

% Output updated optimum delays and thresholds into a file 
% Open file 
optf = fopen('opt.txt','at');    
    
fprintf(optf,'Delay =     ');   
% Print optimzed filtering time     
for k=1:Nv    
fprintf(optf,'  %12.8f',Tf(k));
end
fprintf(optf,'\n'); 

fprintf(optf,'Threshold = ');   
% Print optimzed filtering time     
for k=1:Nv    
fprintf(optf,'  %12.8f',th(k));
end
fprintf(optf,'\n'); 
fprintf(optf,'\n'); 

status = fclose(optf);
%******************************************************
end % if run_optimization == 1 


end  %  for nvft = 1:Nvft  % Scan variable number for optimization of filtering times

end  %for nitop = 1:Nitop
% loop of the number of iterations in optimizaiton of filtering times 


%num2clip(dataOut)

clear 










