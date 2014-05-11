%% F_ALG_HRTD Algorithm Shell based on Verified F_ALG_AL010300
%% Only Performs Heart Rate Trend Difference (HRTD) - NO SETTLING FILTER

%Inputs are as follows:
%    VAR_IN - Variable to be process, should be a array in the form [time value]
%    PARAM_IN - Structure of Parameter Settings
%Outputs are as follows:
%
%   VAR_OUT


function [VAR_OUT] =  F_ALG_HRTD(SSID,VAR_IN,PARAM_IN,CONST_IN,SET_IN)

    %------------------------------------------------------------------------------------------------------------------------------
    %% Generic Processing
    %------------------------------------------------------------------------------------------------------------------------------
    % Get HR Stream
    VAR_OUT.VAR_HR = F_DOWNSAMP(VAR_IN.HR,CONST_IN.C_DS_INT);
    VAR_OUT.VAR_HRO = F_DOWNSAMP(VAR_IN.HRO,CONST_IN.C_DS_INT);
    VAR_OUT.VAR_HRA = F_DOWNSAMP(VAR_IN.HRA,CONST_IN.C_DS_INT);
    % Determine Sampling Interval
    VAR_OUT.VAR_SAMPLING_INT = median(diff(VAR_OUT.VAR_HR(:,1)));
    % Initialise HR data
    [HRINIT_OUT] =  F_HR_INIT(VAR_OUT,SET_IN);
    % Write Initialised HR to VAR_HR Stream
    VAR_OUT.VAR_HR = HRINIT_OUT.VAR_HR;
    %------------------------------------------------------------------------------------------------------------------------------
    
    %------------------------------------------------------------------------------------------------------------------------------
    %% Standard Algorithm Processing
    %------------------------------------------------------------------------------------------------------------------------------
    % Invert Parameter
    VAR_OUT.VAR_IPARAM = F_PARAMSTAT_GAIN(VAR_OUT.VAR_HR,1);
    % Standard Low Pass Filter of IPARAM
    VAR_OUT.VAR_PARAMT = F_LPF_001(VAR_OUT.VAR_IPARAM, PARAM_IN.PARAM_FILT_TIME, VAR_OUT.VAR_SAMPLING_INT,100,HRINIT_OUT.VAR_STARTSAMPLE);
    % Trend Difference of VAR_OUT.VAR_PARAMT
    VAR_OUT.VAR_PARAMTD = F_TREND_DIFF_001(VAR_OUT.VAR_PARAMT,PARAM_IN.PARAM_DIFF_TIME, VAR_OUT.VAR_SAMPLING_INT, HRINIT_OUT.VAR_STARTSAMPLE);
    % Threshold of the Trend Difference (VAR_OUT.VAR_PARAMTD)
    VAR_OUT.VAR_PARAMTDT = F_THRESHOLD(VAR_OUT.VAR_PARAMTD,PARAM_IN.PARAM_THRESHOLD,SET_IN.SET_CROSSING_TYPE);
    %------------------------------------------------------------------------------------------------------------------------------
    
    %------------------------------------------------------------------------------------------------------------------------------
    %% Trigger
    %------------------------------------------------------------------------------------------------------------------------------
    VAR_OUT.VAR_TRIGGER = VAR_OUT.VAR_PARAMTDT;
    for j=1:length(VAR_OUT.VAR_PARAMTDT(:,2))
        % Logical Statement for Alarming
        if VAR_OUT.VAR_PARAMTDT(j,2)==1 
            VAR_OUT.VAR_TRIGGER(j,2) = 1;
        else
            VAR_OUT.VAR_TRIGGER(j,2) = 0;
        end
    end
    %------------------------------------------------------------------------------------------------------------------------------

return