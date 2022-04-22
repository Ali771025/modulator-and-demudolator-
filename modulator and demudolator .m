
function y = DigitalSystem( p1 )
clear all;
clc
format long 
k=3; % bit/symbul
bit_number=10000;
A=2; % Amplitude for psk modulation
SNRIndB=[-4:1:14];
for i=1:length(SNRIndB)
    SNR(i)=(10^(SNRIndB(i)/10));
end
%SNR=[0];


%%%%%%%%%% Bit Generator %%%%%%%%%%
s=randn(1,bit_number);
for i=1:length(s) %% Equlizer
    if s(i)<0
      m(i)=0;
    else 
        m(i)=1;
    end
end 
if mod(bit_number,k)>0
    for i=1:k-mod(bit_number,k)
        m=[m,0];
    end
end

%%%%%%%%%% Modulator %%%%%%%%%%
i=1;
l=1;
while i<length(m)  %% create symbol
    r=1;
    for j=i:i+k-1
        input_symbol(l,r)=m(j);
        r=r+1;
    end;
    l=l+1;
    i=i+k;
end 


[Re_8PSK,Im_8PSK]=Modulator_8PSK(input_symbol,A);
Am_8ASK=Modulator_8ASK(input_symbol);
[I_8QAM,Q_8QAM]=Modulator_8QAM(input_symbol);

%%%%%%%%%% Transmit  %%%%%%%%%%
for i=1:length(SNR)
    y_Re_8PSK(i,:)=awgn(Re_8PSK,SNR(i),'measured','linear');
    y_Im_8PSK(i,:)=awgn(Im_8PSK,SNR(i),'measured','linear');
    
    y_Am_8ASK(i,:)=awgn(Am_8ASK,SNR(i),'measured','linear');
    
    y_I_8QAM(i,:)=awgn(I_8QAM,SNR(i),'measured','linear');
    y_Q_8QAM(i,:)=awgn(Q_8QAM,SNR(i),'measured','linear');
    %y_Re_8PSK(i,:)=Re_8PSK    % Ideal Channel 
    %y_Im_8PSK(i,:)=Im_8PSK;   % Ideal Channel  
    %y_Am_8ASK(i,:)=Am_8ASK;   % Ideal Channel 
    %y_I_8QAM(i,:)=I_8QAM;      % Ideal Channel 
    %y_Q_8QAM(i,:)=Q_8QAM;      % Ideal Channel 
end


%%%%%%%%%% Demodulator  %%%%%%%%%%
for i=1:length(SNR)
    mhat_8PSK(i,:,:)=Demodulator_8PSK(y_Re_8PSK(i,:),y_Im_8PSK(i,:));
    mhat_8ASK(i,:,:)=Demodulator_8ASK(y_Am_8ASK(i,:));
    mhat_8QAM(i,:,:)=Demodulator_8QAM(y_I_8QAM(i,:),y_Q_8QAM(i,:));
end

%%%%%%%%%% Probability of Error  %%%%%%%%%%
for i=1:length(SNR)
    [BER_8PSK(i),SER_8PSK(i)]=ErrorRateCalculate(input_symbol,mhat_8PSK(i,:,:));
    [BER_8ASK(i),SER_8ASK(i)]=ErrorRateCalculate(input_symbol,mhat_8ASK(i,:,:));
    [BER_8QAM(i),SER_8QAM(i)]=ErrorRateCalculate(input_symbol,mhat_8QAM(i,:,:));
end



%%%%%%%%%% Plot Diagrams  %%%%%%%%%%

subplot(1,2,1)
semilogy(SNRIndB,SER_8QAM,'b-*');
hold on
semilogy(SNRIndB,SER_8PSK,'r-*');
semilogy(SNRIndB,SER_8ASK,'g-*');

grid on
set(gca,'XTick',[-4:2:14]);
xlabel('SNR/bit(dB)');
ylabel('Symbol Error Probability');
legend('8QAM','8PSK','8ASK');
%%%%%%%
subplot(1,2,2)
semilogy(SNRIndB,BER_8QAM,'b-*');
hold on
semilogy(SNRIndB,BER_8PSK,'r-*');
semilogy(SNRIndB,BER_8ASK,'g-*');

set(gca,'XTick',[-4:2:14]);
%
%
grid on



end
