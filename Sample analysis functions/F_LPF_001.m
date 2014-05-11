%-- help for custom database LPF.m---
%
%Function filters data with a low pass filter
%
%The function will return a double array containing filtered values
%
%Column 1           Column 2    
%Time               Filtered Value
%
%Function arguments are:
%
%Column 1           Column 2
%Time               Value to be filtered
%
%
% Any dropout must be indicated by a zero value in column 2
% Added VAR_START_CYCLE in order to initialised system

function[dataOut] = F_LPF_001(dataIn, VAR_FILT_TIME, VAR_SAMPLING_INT, VAR_FILT_DROP_TIME, VAR_START_SAMPLE)


dataOut = dataIn;                                                                                       % Initialised output
dataOut(:,2) = 0;
Nahp = round(VAR_FILT_DROP_TIME/VAR_SAMPLING_INT);                                                      % Dropout Sample of Filter
len = length(dataIn);

b = VAR_FILT_TIME/3/VAR_SAMPLING_INT;


% low-pass filter  
%******************************************************************
for k = 1:len
    
    if k<VAR_START_SAMPLE
        dataOut(k,2) = dataIn(k,2);    
    elseif k<(VAR_START_SAMPLE+3)
        dataOut(k,2) = dataIn(VAR_START_SAMPLE,2);                                                       % Fills first 3 output values with inputs (non filtered)
    else
        % DropOut Filter
        if (dataIn(k-3,2)==0 | isnan(dataIn(k-3,2)) | (Nahp+(VAR_START_SAMPLE-1))<k-3)                       % This ensures the reference for Filter Drop Out is from VAR_START_SAMPLE, not 1. 
            dataOut(k,2) = (3-2/b)*dataOut(k-1,2) + 1/b^2*(1-b)*(3*b-1)*dataOut(k-2,2) + 1/b^2*(1-b)^2*dataOut(k-3,2);
        else
            % Normal Filter
            dataOut(k,2) = 1/b^3*dataIn(k-3,2) + 3*(b-1)/b*dataOut(k-1,2) - 3*(b-1)^2/b^2*dataOut(k-2,2) + (b-1)^3/b^3*dataOut(k-3,2);   
        end
    end
    
end
%*******************************************************************

