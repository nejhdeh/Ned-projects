% This program calculates probabilistic distribution of algorithm 
% performance for a limited number of patients 


clear 


% Sample size and true predictions number
Ns1 = 15;   Nt1 = 12;  
Ns2 = 17;   Nt2 = 14;  

hypothesis = 0;    % put 0 for H0 and 1 for H1 
% Probability within confidence intrevals
Pci = 0.95; 
%Pci = 0.9; 
% Significance level for one-tailed power calculation 
Apw1 = 0.05; 
% Enforce using of normal distribution 
% Calculate test parameters from splined data 
use_splines = 0; 
use_normal = 0; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
hold on 

grid on 
xlabel('%')
ylabel('Probability')
if hypothesis == 0
title('Hypothesis H0')
else
title('Hypothesis H1')
end

% Sensitivities
St1 = Nt1/Ns1;      
St2 = Nt2/Ns2;  

% Overall sensitivity 
Sto = (Nt1+Nt2)/(Ns1+Ns2);  


% Do calculation cycle for sample 1
%********************************************************************
% Define current number of patients and sensitivity 
Ns = Ns1; 

% DEfine sensitivity
if hypothesis == 0
St = Sto; 
else 
St = St1;    
end


% Define vector of the number of missed hypos
m = 0:1:Ns; 

% Define vector of probability distribution 
P1 = m*0; 


if (2*sqrt(St/Ns/(1-St+1e-5))<0.2 & 2*sqrt((1-St)/Ns/(St+1e-5))<0.2) | use_normal == 1
%************************************************************************
% Calculate probability distribution of missed hypos 
for k = 2:Ns
P1(k) = sqrt(Ns/(2*pi*m(k)*(Ns-m(k))))*exp(-Ns*(m(k)/Ns+St-1)^2/2/St/(1-St)); 
end
P1(1) = 0; 
P1(Ns+1) = 0; 
% Correct normalization 
P1 = P1/sum(P1); 

else
 
% Calculate factorial 
fNs = factorial(Ns); 
% Calculate probability distribution of missed hypos 
for k = 1:Ns+1
P1(k) = (1-St)^m(k)*St^(Ns-m(k))*fNs/factorial(m(k))/factorial(Ns-m(k)); 
end
%************************************************************************
end  % if 2*sqrt(St/Ns/(1-St+1e-5))<0.1 & 2*sqrt((1-St)/Ns/(St+1e-5))<0.1 


% Calculate vector of sensitivity 
Stv1 = (Ns-m)/Ns; 

% Fine grid of sensitivity 
Stv1s = 0:0.001:1; 

% Spline of distribution 
P1s = spline(Stv1,P1,Stv1s); 

% Find maximum of vector P1s
maxP1s = max(P1s); 


plot(Stv1*100,P1/maxP1s,'b.')
plot(Stv1s*100,P1s/maxP1s,'b:')


%***********************************************************


% Do calculation cycle for sample 2
%********************************************************************
% Define current number of patients and sensitivity 
Ns = Ns2; 

% DEfine sensitivity
if hypothesis == 0
St = Sto; 
else 
St = St2;    
end


% Define vector of the number of missed hypos
m = 0:1:Ns; 

% Define vector of probability distribution 
P2 = m*0; 


if (2*sqrt(St/Ns/(1-St+1e-5))<0.2 & 2*sqrt((1-St)/Ns/(St+1e-5))<0.2) | use_normal == 1
%************************************************************************
% Calculate probability distribution of missed hypos 
for k = 2:Ns
P2(k) = sqrt(Ns/(2*pi*m(k)*(Ns-m(k))))*exp(-Ns*(m(k)/Ns+St-1)^2/2/St/(1-St)); 
end
P2(1) = 0; 
P2(Ns+1) = 0; 
% Correct normalization 
P2 = P2/sum(P2); 

else
 
% Calculate factorial 
fNs = factorial(Ns); 
% Calculate probability distribution of missed hypos 
for k = 1:Ns+1
P2(k) = (1-St)^m(k)*St^(Ns-m(k))*fNs/factorial(m(k))/factorial(Ns-m(k)); 
end
%************************************************************************
end  % if 2*sqrt(St/Ns/(1-St+1e-5))<0.1 & 2*sqrt((1-St)/Ns/(St+1e-5))<0.1 


% Calculate vector of sensitivity 
Stv2 = (Ns-m)/Ns; 

% Fine grid of sensitivity 
Stv2s = 0:0.001:1; 

% Spline of distribution 
P2s = spline(Stv2,P2,Stv2s); 

% Find maximum of vector P2s
maxP2s = max(P2s); 

plot(Stv2*100,P2/maxP2s,'r.')
plot(Stv2s*100,P2s/maxP2s,'r:')


%***********************************************************


plot([St1 St1]*100,[0 1],'b')
plot([St2 St2]*100,[0 1],'r')



% Flip vectors to make sensitivity rise with the element number
P1 = fliplr(P1);
Stv1 = fliplr(Stv1);
P2 = fliplr(P2);
Stv2 = fliplr(Stv2);


% Calculate statistical tests from spline vectors
if use_splines == 1
P1 = P1s; 
P1 = P1/sum(P1); 
P2 = P2s; 
P2 = P2/sum(P2); 
Stv1 = Stv1s; 
Stv2 = Stv2s; 
end



% Vector lengths 
Np1 = length(P1);
Np2 = length(P2); 



if hypothesis == 0
% Calculate significance level 
%******************************************************************************

% Probability of sample 2 being greater than sample 1 by specified difference
%****************************
% (one-tail test)
Pone = 0; 

for n = 1:Np2
for k = 1:Np1
    
if (St2-St1)<=(Stv2(n)-Stv1(k)) 
Pone = Pone + P1(k)*P2(n); 
end    

end
end

% Two-tailed significance level 
disp(' ')
disp(['1T-significance level = ' num2str(Pone)])
disp(['1T-confidence level = ' num2str((1-Pone)*100) '%'])
%********************************


% Probability of two measurements being further or equal apart than a specified interval
%*******************************
% (two-tail test)
Ptwo = 0; 

for n = 1:Np2
for k = 1:Np1
    
if abs(St2-St1)<=abs(Stv2(n)-Stv1(k))      
Ptwo = Ptwo + P1(k)*P2(n); 
end    

end
end

% Two-tailed significance level 
disp(' ')
disp(['2T-significance level = ' num2str(Ptwo)])
disp(['2T-confidence level = ' num2str((1-Ptwo)*100) '%'])
%********************************
%**********************************************************************************
end % if hypothesis == 0




if hypothesis == 1
%*************************************************************


% Determine confidence interval of sample 1
%*********************************************
% Element number of the maximum probability of first sample 
[P1max NP1max] = max(P1); 

% Define probability within the confidence interval of first sample
Pci1 = P1max; 

% Define confidence interval element numbers of sample 1 
nci1 = [NP1max NP1max]; 

% DEfine cycle number for the following loop 
n = 0; 
while Pci1 < Pci
n = n+1; 
% Update the probability within confidence interval 
if 1<=NP1max-n
Pci1 = Pci1 + P1(NP1max-n); 
% Re-define the lower limit of confidnece interval 
nci1(1) = NP1max-n; 
end
if NP1max+n<=Np1
Pci1 = Pci1 + P1(NP1max+n); 
% Re-define the higher limit of confidnece interval 
nci1(2)= NP1max+n; 
end
end % while Pci1 < 0.95

% Confidence interval of sample 1
ci1 = [Stv1(nci1(1)) Stv1(nci1(2))]; 

if use_splines == 1
plot([ci1(1) ci1(1)]*100,[0 P1(nci1(1))/max(P1)],'b')
plot([ci1(2) ci1(2)]*100,[0 P1(nci1(2))/max(P1)],'b')
else
plot([ci1(1) ci1(1)]*100,[0 P1(nci1(1))/maxP1s],'b')
plot([ci1(2) ci1(2)]*100,[0 P1(nci1(2))/maxP1s],'b')  
end

disp(' ')
disp(['CI1 = ' num2str(ci1*100)])
% Significance level for power test purposes 
disp(['CI1 probability = ' num2str(Pci1)])


% Determine critical value for one-tailed power calculation 
%***************
% Define cycle number for the following loop 
n = Np1; 
% Define parameter corresponding to tail probability 
par = P1(n); 
while par < Apw1
n = n-1;       
par = par + P1(n);  
end % while par < 1-Pci 
% Define critical value 
Stv1c = Stv1(n);  
plot([1 1]*Stv1c*100,[0 P1(n)/max(P1)],'g')
%***************
 

% Determine confidence interval of sample 2
%*********************************************
% Element number of the maximum probability of first sample 
[P2max NP2max] = max(P2); 

% Define probability within the confidence interval of first sample
Pci2 = P2max; 

% Define confidence interval element numbers of sample 1 
nci2 = [NP2max NP2max]; 

% DEfine cycle number for the following loop 
n = 0; 
while Pci2 < Pci
n = n+1; 
% Update the probability within confidence interval 
if 1<=NP2max-n
Pci2 = Pci2 + P2(NP2max-n); 
% Re-define the lower limit of confidnece interval 
nci2(1) = NP2max-n; 
end
if NP2max+n<=Np2
Pci2 = Pci2 + P2(NP2max+n); 
% Re-define the higher limit of confidnece interval 
nci2(2)= NP2max+n; 
end
end % while Pci1 < 0.95


% Confidence interval of sample 1
ci2 = [Stv2(nci2(1)) Stv2(nci2(2))]; 

figure(1)
if use_splines == 1
plot([ci2(1) ci2(1)]*100,[0 P2(nci2(1))/max(P2)],'r')    
plot([ci2(2) ci2(2)]*100,[0 P2(nci2(2))/max(P2)],'r')
else
plot([ci2(1) ci2(1)]*100,[0 P2(nci2(1))/maxP2s],'r')    
plot([ci2(2) ci2(2)]*100,[0 P2(nci2(2))/maxP2s],'r')
end



disp(' ')
disp(['CI2 = ' num2str(ci2*100)])
% Significance level for power test purposes 
disp(['CI2 probability = ' num2str(Pci2)])
%****************************************************


% Define statistical power 
Pw = 0; 


if 1==0
for n = 1:Np2
for k = 1:Np1
    
% Probability that observation from one distribution 
% does not fall within the confidence interval of the other
if  (Stv1(k)<ci2(1) | ci2(2)<Stv1(k)) & (Stv2(n)<ci1(1) | ci1(2)<Stv2(n))
% Update power
Pw = Pw + P1(k)*P2(n); 
end    
    
end
end
end


if 1==1
% One-tailed power calculation 
for n = 1:Np2
    
if Stv1c<Stv2(n)
% Update power
Pw = Pw + P2(n); 
end    
    
end
end


disp(' ')
disp(['1T-Power = ' num2str(Pw*100) '%'])

%*************************************************************
end % if hypothesis == 1








clear 














































