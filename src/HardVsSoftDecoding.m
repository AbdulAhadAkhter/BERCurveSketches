clear all
%======================================================================================|
%Starting Parameters
%======================================================================================|
steps = 5000;       %Number Of Iterations
XAxis=40;           %XAxis points
Variance=0.0;       %0 variance assignment requirement
threshold=0.5;      %threshold because only 1 and 0 are possible in this case
MaxBit = 10^7;      %bits
repetition= 3;      %for this assignment, 3 repetition codes
%======================================================================================|
%sets to keep track of data
%======================================================================================|
VarArray =[];BERArray=[];
%======================================================================================|
%lookup table for repetition bits
%======================================================================================|
On= [1 1 1];Off= [0 0 0];
%======================================================================================|
%Main loop
%======================================================================================|
for i=1:XAxis
    Variance = Variance + 0.01;
    VarArray = [VarArray;1/Variance];
    StandardDeviation = Variance.^(1/2);
    %Reset Error state for each variance
    hardError = 0;
    softError = 0;
    for j=1:steps
        randbit = round(rand); %Generate random number with equal probability
        repetitionCode = repelem(randbit,repetition); %Repeat number 3 times
        total = repetitionCode + StandardDeviation.*randn([1,3]); %Add Gaussian noise to message
        %======================================================================================|
        %Hard Decision Decoding
        %======================================================================================|
        hdRound = round(total);     %Using .5 as threshold
        majbit = mode(hdRound);     %Determine Majority bit
        %Assign bit to a value 
         if total > threshold
                bitVal = [1 1 1];
         else
                bitVal = [0 0 0];
         end      
         if bitVal ~= repetitionCode
             hardError =hardError+1;
         end
        %======================================================================================|
        %Soft Decision using Euclidean comparison of norms
        %======================================================================================|
         if norm(total-Off)>norm(total-On)      %Professor Medra explained how a simple comparison is easier to do than
               softDecision = 1;                %what I was trying to do down below. I was adding everthing into an array then 
         else                                   %indexing whatever I would get and then grab the minimums. Couldn't figure it 
               softDecision = 0;                %out in time. Ended up using this instead. Cutting corners. haha
         end
         
         %TODO with comparisons
         %SDArray = [SDArray; x,y];
         %Minbit = min(SDArray,[],2);
         %Minimumbit = min(x,y);
         
         if repelem(softDecision,3) ~= repetitionCode
             softError = softError+1;
         end 
    end
    %======================================================================================|
    %BER Calculation for hard and soft decision decoding
    %======================================================================================|
    hardBER = hardError/steps;softBER = softError/steps;
    BERArray = [BERArray; hardBER, softBER];
end
%======================================================================================
%Graph
%======================================================================================
plot(VarArray,BERArray);legend('Hard Decision','Soft Decision');xlim([0 40]);ylim([0 0.35]);
xlabel('1/s^2');ylabel('BER');title('BER Curves - Decision Decoding');