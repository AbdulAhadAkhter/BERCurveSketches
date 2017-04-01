clear
Iterations = 10000; %Number Of Iterations
XAxis=100;          %XAxis points
Variance=0.0;
%sets to keep track of data
VarianceSet = [];
berSet=[];
%forloop to check for variances
for i=1:XAxis
    Variance = Variance + 0.01;
    VarianceSet = [VarianceSet;1/Variance];
    SD = Variance.^(1/2);
    error = 0;
    %forloop to check bits for current variance
    for j=1:Iterations
        bit = round(rand); %Generate random number
        noise = SD.*randn(Iterations,1); %Gaussian noise
        both = bit + noise; 
        %Assign bit to a value 
         if both > 0.5
                bitVal = 1;
         else
                bitVal = 0;
         end      
         if bitVal ~= bit
             error =error+1;
         end
    end
    %BER Calculation
    ber = error/Iterations;
    berSet = [berSet; ber];
end
%plotGraph
plot(VarianceSet,berSet)
xlabel('1/VAR');ylabel('BER');title('BER curve-Bilal Ishtiaque - 1320763');