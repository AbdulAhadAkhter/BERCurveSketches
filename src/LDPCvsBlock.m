%% CODE 
clear all; close all; clc
bits = 200;
Sig = round(rand(1,bits));
%Generator Array
genArray = [1 0 0 0 1 1 0;0 1 0 0 0 1 1;0 0 1 0 1 0 1;0 0 0 1 1 1 1];
%Parity check Array
parArray = gen2par(genArray);

%% Code Generation
%Found this algorithm online for code generation for a Linear Block Code
s = 0; 
t = 1;
u = 1; 
Array = []; 
SigArr = []; 
for s = 4:4:length(Sig)
    cw = mod(Sig(t:s)*genArray,2); 
    t = t+4;
    SigArr(u:u+6) = cw;
    u = u+7;
end
% Variances 
snr = [0:0.04:0.88];
snr1 = [0:1:22];
ber = zeros(length(snr1),1);
%E/N for ideal system
Eb_No=10.^(snr/10);

%% Loop for Linear Block Code 
%
for m = 1:length(snr1);                  
receivedSignal = awgn(5 * SigArr-1,snr1(m),'measured');
%Bit Decision
for k = 1:1:length(5 * SigArr-1)                
    if receivedSignal(k)>0
        b(k)=1;
    else
        b(k)=0;
    end 
end
msg = decode(b,7,4,'linear',genArray,syndtable(parArray));
[number1(m) BER1(m)]=biterr(Sig,msg);
end

%% Low Density Parity Check Code
%
ldpcEnc = comm.LDPCEncoder;
ldpcDec = comm.LDPCDecoder;
qpskMod = comm.QPSKModulator('BitInput',true);
qpskDemod = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio','VarianceSource','Input port');
errorCnt = comm.ErrorRate;

%% Loop for Low Density Parity Check
%
for k = 1:length(snr)
    noiseVar = 1/10^(snr(k)/10);
    errorStats = zeros(1,3);
    while errorStats(2) <= 200 && errorStats(3) < 5e6
        data = logical(randi([0 1],32400,1));   % Generate binary data
        encData = ldpcEnc(data);                % Apply LDPC encoding
        modSig = qpskMod(encData);              % Modulate
        rxSig = awgn(modSig,snr(k));            % Pass through AWGN channel
        demodSig = qpskDemod(rxSig,noiseVar);   % Demodulate
        rxData = ldpcDec(demodSig);             % Decode LDPC
        errorStats = errorCnt(data,rxData);     % Compute error stats
    end
    
    % Save the BER for the current Eb/No and reset the error rate counter
    ber(k) = errorStats(1);
    reset(errorCnt)
end

%% Plotting
%
plot(snr1,BER1,'-r*');
hold on
plot(snr,ber,'-o');
legend('Linear Block Code','Low Density Parity Check')
title('Comparison of LDPC vs linear block code')
xlabel('SNR')
ylabel('BER')